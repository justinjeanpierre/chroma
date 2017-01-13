//
//  OverlayViewController.m
//  Mobile AR
//
//  Created by Justin Jean-Pierre on 2017-01-12.
//  Copyright © 2017 Jean-Pierre Digital. All rights reserved.
//

#import "OverlayViewController.h"

@interface OverlayViewController () {
    AVCaptureSession *session;
    AVCaptureMovieFileOutput *output;
}

@end

@implementation OverlayViewController

-(void)viewDidLoad {
    [super viewDidLoad];

    [self setTitle:@"cube view"];

    // configure capture devices
    session = [[AVCaptureSession alloc] init];
    [session setSessionPreset:AVCaptureSessionPreset640x480];

    NSArray *devices = [AVCaptureDevice devices];

    for (AVCaptureDevice *device in devices) {
        NSError *error;

        if ([device hasMediaType:AVMediaTypeVideo] &&
            [device position] == AVCaptureDevicePositionBack &&
            [device supportsAVCaptureSessionPreset:AVCaptureSessionPreset1920x1080]) {
            AVCaptureDeviceInput *videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:device error:&error];
            if ([session canAddInput:videoInput]) {
                [session addInput:videoInput];
            }

        }

        if ([device hasMediaType:AVMediaTypeAudio]) {
            AVCaptureDeviceInput *audioInput = [[AVCaptureDeviceInput alloc] initWithDevice:device error:&error];
            if ([session canAddInput:audioInput]) {
                [session addInput:audioInput];
            }
        }
    }

    [session startRunning];

    // add camera overlay to the view
    AVCaptureVideoPreviewLayer *videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    videoPreviewLayer.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [self.view.layer addSublayer:videoPreviewLayer];

    output = [[AVCaptureMovieFileOutput alloc] init];
    if ([session canAddOutput:output]) {
        [session addOutput:output];
    }


    // add OpenGL overlay to the view here
}

#pragma mark AVCaptureFileOutputRecordingDelegate methods

-(void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error {
    NSLog(@"%s", __func__);

}

-(void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections {
    NSLog(@"%s", __func__);
}

@end
