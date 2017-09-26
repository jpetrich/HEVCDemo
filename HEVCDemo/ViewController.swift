//
//  ViewController.swift
//  HEVCDemo
//
//  Created by Joseph Petrich on 9/26/17.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, FrameExtractorDelegate {
    var frameExtractor: FrameExtractor!
    var videoWriterH264: VideoWriter!
    var videoWriterH265: VideoWriter!
    var isRecording: Bool!

    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.notificationReceived), name: NSNotification.Name.AVCaptureSessionRuntimeError, object: nil)
        isRecording = false
        frameExtractor = FrameExtractor()
        frameExtractor.delegate = self
        videoWriterH264 = VideoWriter(withVideoType: AVVideoCodecType.h264)
        videoWriterH265 = VideoWriter(withVideoType: AVVideoCodecType.hevc)
    }
    
    @objc func notificationReceived(notification: NSNotification){
        print(notification)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func captured(frame: CMSampleBuffer) {
        if isRecording {
            videoWriterH264.write(sampleBuffer: frame)
            videoWriterH265.write(sampleBuffer: frame)
        }
    }
    @IBAction func recordPressed(_ sender: Any) {
        let button = sender as? UIButton
        if isRecording {
            isRecording = false
            videoWriterH264.stopWriting(completionHandler: { (status) in
                print("Done recording H264")
                do {
                    let attr = try FileManager.default.attributesOfItem(atPath: self.videoWriterH264.url.path)
                    let fileSize = attr[FileAttributeKey.size] as! UInt64
                    print("H264 file size = \(fileSize)")
                } catch {
                    
                }
            })
            videoWriterH265.stopWriting(completionHandler: { (status) in
                print("Done recording H265")
                do {
                    let attr = try FileManager.default.attributesOfItem(atPath: self.videoWriterH265.url.path)
                    let fileSize = attr[FileAttributeKey.size] as! UInt64
                    print("H265 file size = \(fileSize)")
                } catch {
                    
                }
            })
            button?.setTitle("Start Recording", for: .normal)
        }
        else {
            isRecording = true
            button?.setTitle("Stop Recording", for: .normal)
        }
    }
}
