# HEVCDemo
Small repo to show the file size issues with the new HEVC encoder on iOS 11. It writes simultaneously to an H264 and H265 encoded video.

1. Run the app on a hardware device running iOS 11.
2. Accept camera permissions
3. Tap "Start Recording"
4. Tap "Stop Recording"
5. Look in the console for the H264 and H265 video sizes or grab the container using Xcode's "Devices" window and look at the resulting files
