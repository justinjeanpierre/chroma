//
//  CaptureViewController.swift
//  Mobile AR
//
//  Created by Justin Jean-Pierre on 2016-11-28.
//  Copyright © 2016 Jean-Pierre Digital. All rights reserved.
//

import UIKit
import AVFoundation

class CaptureViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {

    // outlets
    @IBOutlet weak var toggleRecordingButton: UIButton!

    // other vars
    lazy var captureSession = AVCaptureSession()
    var isRecording = false;
    var output: AVCaptureMovieFileOutput?

    @IBAction func toggleRecordStopState(sender: UIButton) {
        isRecording = !isRecording

        if isRecording {
            toggleRecordingButton.setTitle("stop", forState: .Normal)
            startRecording()
        } else {
            toggleRecordingButton.setTitle("record", forState: .Normal)
            stopRecording()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // configure view
        title = "Mobile AR"
        toggleRecordingButton.setTitle("record", forState: .Normal)

        // configure capture devices
        captureSession.sessionPreset = AVCaptureSessionPreset640x480

        for device in AVCaptureDevice.devices() {
            if device.hasMediaType(AVMediaTypeVideo)
                && device.position == AVCaptureDevicePosition.Back
                && device.supportsAVCaptureSessionPreset(AVCaptureSessionPreset1920x1080) {
                do {
                    let videoInput = try AVCaptureDeviceInput.init(device: device as! AVCaptureDevice)
                    if self.captureSession.canAddInput(videoInput) {
                        self.captureSession.addInput(videoInput)
                    }
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
            } else if device.hasMediaType(AVMediaTypeAudio) {
                do {
                    let audioInput = try AVCaptureDeviceInput.init(device: device as! AVCaptureDevice)
                    if self.captureSession.canAddInput(audioInput) {
                        self.captureSession.addInput(audioInput)
                    }
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
            }
        }

        captureSession.startRunning()

        // add the overlay to the view
        let viewFinder = AVCaptureVideoPreviewLayer(session: captureSession)
        let targetView = view
        let viewLayer  = targetView.layer

        viewFinder.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height)
        viewLayer.addSublayer(viewFinder)

        // configure AVCaptureMovieOutput object here
        output = AVCaptureMovieFileOutput()

        if captureSession.canAddOutput(output) {
            captureSession.addOutput(output)
        }
    }

    func startRecording() {
        captureSession.startRunning()

        // generate path to file
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        let documentsDirectory = paths[0]
        let fileURL = NSURL(fileURLWithPath: documentsDirectory.stringByAppendingString("/\(NSDate()).mov"), isDirectory: false)

        output?.startRecordingToOutputFileURL(fileURL, recordingDelegate: self)
    }

    func stopRecording() {
        captureSession.stopRunning()
        output?.stopRecording()
    }

    //  MARK: AVCaptureFileOutputRecordingDelegate methods

    func captureOutput(captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAtURL outputFileURL: NSURL!, fromConnections connections: [AnyObject]!, error: NSError!) {
        print(#function)
    }
}
