//
//  CameraViewController.m
//  Mobile AR
//
//  Created by Justin Jean-Pierre on 2017-01-04.
//  Copyright © 2017 Jean-Pierre Digital. All rights reserved.
//

#import "CameraViewController.h"
#include "roi.hpp"

using namespace std;
using namespace cv;

@interface CameraViewController ()

@property (nonatomic, strong) CvVideoCamera *videoCamera;
@property (nonatomic) BOOL shouldInvertColors;
@property (nonatomic) BOOL shouldDetectFeatures;
@property (nonatomic) BOOL shouldShowCube;
@property (nonatomic) BOOL isTracking;
@property (nonatomic, strong) UIButton *boundingBox;
@property (nonatomic) Ptr<Tracker> tracker;
@property (nonatomic, strong) NSTimer *uiTimer;

@end

@implementation CameraViewController

Rect2d regionOfInterest;

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setTitle:@"OpenCV tool"];
    self.cameraView.clipsToBounds = YES;

    self.videoCamera = [[CvVideoCamera alloc] initWithParentView:self.cameraView];
    self.videoCamera.delegate = self;
    self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
    self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset640x480;
    self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationLandscapeLeft;
    self.videoCamera.defaultFPS = 30;
    self.videoCamera.grayscaleMode = NO;

    _shouldInvertColors = _shouldDetectFeatures = _shouldShowCube = _isTracking = NO;

    [self.videoCamera start];

    // configure virtual cube
    _glView = [[BoxView alloc] initWithFrame:self.view.frame];
    [self.cameraView addSubview:_glView];
    _glView.alpha = (_shouldShowCube == YES);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.

    // turn off image processing
    _shouldInvertColors = _shouldDetectFeatures = _shouldShowCube = _isTracking = NO;

    // destroy tracker
    _tracker->~Tracker();
}

#pragma mark - Button actions
- (IBAction)invertColors:(UIButton *)button {
    _shouldInvertColors = !_shouldInvertColors;

    NSLog(@"%s", __func__);
}

- (IBAction)detectFeatures:(UIButton *)button {
    _shouldDetectFeatures = !_shouldDetectFeatures;

    NSLog(@"%s", __func__);
}

-(IBAction)toggleCubeVisibility:(UIButton *)button {
    _shouldShowCube = !_shouldShowCube;

    _glView.alpha = (_shouldShowCube == YES);
}

-(IBAction)toggleTracking:(UIButton *)sender {
    _isTracking = !_isTracking;

    if (_isTracking == YES) { // show default outline
        if (self.boundingBox == nil) {
            self.boundingBox = [[UIButton alloc] init];
        }

        [self.boundingBox setFrame:CGRectMake(self.cameraView.bounds.size.width/2 - 100,
                                             self.cameraView.bounds.size.height/2 - 100,
                                             200,
                                             200)];
        self.boundingBox.layer.borderWidth = 2.0f;
        self.boundingBox.layer.borderColor = [[UIColor redColor] CGColor];
        self.boundingBox.layer.cornerRadius = 4.0f;
        [self.cameraView addSubview:self.boundingBox];

        // create a tracker object
        _tracker = Tracker::create("KCF");

        // create ROI
        regionOfInterest = Rect2d();
        regionOfInterest.x = 0;
        regionOfInterest.y = 0;
        regionOfInterest.width = 640;
        regionOfInterest.height = 480;

        self.uiTimer = [NSTimer scheduledTimerWithTimeInterval:(NSTimeInterval)0.1 target:self selector:@selector(updateUIElements) userInfo:NULL repeats:YES];

    } else {
        [self.uiTimer invalidate];
        [self.boundingBox removeFromSuperview];
    }
}

#pragma mark - CvVideoCameraDelegate methods
-(void)processImage:(cv::Mat &)image {
    Mat image_copy;
    cvtColor(image, image_copy, CV_BGRA2BGR);

    if (_shouldInvertColors == YES) {
        // invert image
        bitwise_not(image_copy, image_copy);
        cvtColor(image_copy, image, CV_BGR2BGRA);
    }

    if (_shouldDetectFeatures == YES) {
        // TODO: edge detection code goes here
    }

    if (_isTracking == YES) {
        // source: http://docs.opencv.org/3.1.0/d2/d0a/tutorial_introduction_to_tracker.html

        // create 3-channel copy of source image
        Mat targetImage;
        cvtColor(image, targetImage, CV_BGRA2BGR);

        // initialize tracker
        _tracker->init(targetImage, regionOfInterest);

        // update tracker
        if (_tracker->update(targetImage, regionOfInterest) == YES) {
            CGRect roiFrame = CGRectMake(CGFloat(regionOfInterest.x),
                                         CGFloat(regionOfInterest.y),
                                         CGFloat(regionOfInterest.width),
                                         CGFloat(regionOfInterest.height));
            NSLog(@"rFrame(%.0f, %.0f, %.0f, %.0f), tFrame(%.0f, %.0f, %.0f, %.0f)",
                  roiFrame.origin.x,
                  roiFrame.origin.y,
                  roiFrame.size.width,
                  roiFrame.size.width,
                  self.boundingBox.frame.origin.x,
                  self.boundingBox.frame.origin.y,
                  self.boundingBox.frame.size.width,
                  self.boundingBox.frame.size.width);
        }
    }
}

-(void)updateUIElements {
    [self.boundingBox setFrame:CGRectMake(CGFloat(regionOfInterest.x),
                                          CGFloat(regionOfInterest.y),
                                          CGFloat(regionOfInterest.width),
                                          CGFloat(regionOfInterest.height))];
    [self.boundingBox setNeedsDisplay];
}

#pragma mark - BoxView
-(IBAction)toggleCubePerpective:(UIButton *)button {
    NSLog(@"%s", __func__);

    [_glView changePerspective:button];
}

@end
