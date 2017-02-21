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

    @IBAction func toggleRecordStopState(_ sender: UIButton) {
        isRecording = !isRecording

        if isRecording {
            toggleRecordingButton.setTitle("stop", for: UIControlState())
            startRecording()
        } else {
            toggleRecordingButton.setTitle("record", for: UIControlState())
            stopRecording()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // configure view
        title = "record video"
        toggleRecordingButton.setTitle("record", for: UIControlState())

        // configure capture devices
        captureSession.sessionPreset = AVCaptureSessionPreset640x480

        for device in AVCaptureDevice.devices() {
            if (device as AnyObject).hasMediaType(AVMediaTypeVideo)
                && (device as AnyObject).position == AVCaptureDevicePosition.back
                && (device as AnyObject).supportsAVCaptureSessionPreset(AVCaptureSessionPreset1920x1080) {
                do {
                    let videoInput = try AVCaptureDeviceInput.init(device: device as! AVCaptureDevice)
                    if self.captureSession.canAddInput(videoInput) {
                        self.captureSession.addInput(videoInput)
                    }
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
            } else if (device as AnyObject).hasMediaType(AVMediaTypeAudio) {
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
        let viewLayer  = targetView?.layer

        viewFinder?.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height)
        viewLayer?.addSublayer(viewFinder!)

        // configure AVCaptureMovieOutput object here
        output = AVCaptureMovieFileOutput()

        if captureSession.canAddOutput(output) {
            captureSession.addOutput(output)
        }
    }

    func startRecording() {
        captureSession.startRunning()

        // generate path to file
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let documentsDirectory = paths[0]
        let fileURL = URL(fileURLWithPath: documentsDirectory + "/\(Date()).mov", isDirectory: false)

        output?.startRecording(toOutputFileURL: fileURL, recordingDelegate: self)
    }

    func stopRecording() {
        captureSession.stopRunning()
        output?.stopRecording()
    }

    //  MARK: AVCaptureFileOutputRecordingDelegate methods

    func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
        print(#function)
    }
}
