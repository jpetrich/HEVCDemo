//   Copyright 2018 Joseph Petrich
//
//   Licensed under the Apache License, Version 2.0 (the "License");
//   you may not use this file except in compliance with the License.
//   You may obtain a copy of the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in writing, software
//   distributed under the License is distributed on an "AS IS" BASIS,
//   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//   See the License for the specific language governing permissions and
//   limitations under the License.
//
//
//  VideoWriter.swift
//  HEVCDemo
//
//  Created by Joseph Petrich on 9/26/17.
//

import Foundation
import AVFoundation

class VideoWriter {
    var avAssetWriter: AVAssetWriter
    var avAssetWriterInput: AVAssetWriterInput
    var url:URL
    
    init(withVideoType type:AVVideoCodecType){
        if #available(iOS 11.0, *) {
            avAssetWriterInput = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: [AVVideoCodecKey:type, AVVideoHeightKey:720, AVVideoWidthKey:1280])
        } else {
            avAssetWriterInput = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: [AVVideoCodecKey:AVVideoCodecH264, AVVideoHeightKey:720, AVVideoWidthKey:1280])
        }
        avAssetWriterInput.expectsMediaDataInRealTime = true
        do {
            let directory = try VideoWriter.directoryForNewVideo()
            if (type == AVVideoCodecType.hevc){
                url = directory.appendingPathComponent(UUID.init().uuidString.appending(".hevc"))
            }
            else {
                url = directory.appendingPathComponent(UUID.init().uuidString.appending(".mp4"))
            }
            avAssetWriter = try AVAssetWriter(url: url, fileType: AVFileType.mp4)
            avAssetWriter.add(avAssetWriterInput)
            avAssetWriter.movieFragmentInterval = kCMTimeInvalid
        } catch {
            fatalError("Could not initialize avAssetWriter \(error)")
        }
    }
    
    func write(sampleBuffer buffer: CMSampleBuffer) {
        if avAssetWriter.status == AVAssetWriterStatus.unknown {
            avAssetWriter.startWriting()
            avAssetWriter.startSession(atSourceTime: CMSampleBufferGetPresentationTimeStamp(buffer))
        }
        if avAssetWriterInput.isReadyForMoreMediaData {
            avAssetWriterInput.append(buffer)
        }
    }
    
    func stopWriting(completionHandler handler: @escaping (AVAssetWriterStatus) -> Void) {
        avAssetWriter.finishWriting {
            handler(self.avAssetWriter.status)
        }
    }
    
    static func directoryForNewVideo() throws -> URL {
        let videoDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("videos")
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        let dateDir = videoDir?.appendingPathComponent(formatter.string(from:Date()))
        try FileManager.default.createDirectory(atPath: (dateDir?.path)!, withIntermediateDirectories: true, attributes: nil)
        return dateDir!
    }
}
