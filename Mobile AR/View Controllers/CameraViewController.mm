//
//  CameraViewController.m
//  Mobile AR
//
//  Created by Justin Jean-Pierre on 2017-01-04.
//  Copyright © 2017 Jean-Pierre Digital. All rights reserved.
//

#import "CameraViewController.h"

using namespace std;
using namespace cv;

@interface CameraViewController ()

@property (nonatomic, strong) CvVideoCamera *videoCamera;
@property (nonatomic, strong) UIView *boundingBox;
@property (nonatomic) Ptr<Tracker> tracker;

@property (nonatomic, strong) NSTimer *boxTimer;

@property (nonatomic) BOOL shouldInvertColors;
@property (nonatomic) BOOL shouldDetectFeatures;
@property (nonatomic) BOOL shouldShowCube;
@property (nonatomic) BOOL isTracking;
@property (nonatomic) BOOL isTrackerInitialized;
@property (nonatomic) BOOL isRegionSpecified;

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
    self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    self.videoCamera.defaultFPS = 30;
    self.videoCamera.grayscaleMode = NO;

    _shouldInvertColors = _shouldDetectFeatures = _shouldShowCube = _isTracking = _isTrackerInitialized = _isRegionSpecified = NO;

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
    _shouldInvertColors = _shouldDetectFeatures = _shouldShowCube = _isTracking = _isTrackerInitialized = _isRegionSpecified = NO;

    // destroy tracker
    _tracker->~Tracker();
}

#pragma mark - Button actions - Image colour
- (IBAction)invertColors:(UIButton *)button {
    _shouldInvertColors = !_shouldInvertColors;

    NSLog(@"%s", __func__);
}

#pragma mark - Button actions - Corner detection
- (IBAction)detectFeatures:(UIButton *)button {
    _shouldDetectFeatures = !_shouldDetectFeatures;

    NSLog(@"%s", __func__);
}

#pragma mark - Button actions - Virtual overlay
-(IBAction)toggleCubeVisibility:(UIButton *)button {
    _shouldShowCube = !_shouldShowCube;

    _glView.alpha = (_shouldShowCube == YES);
}

-(IBAction)toggleCubePerpective:(UIButton *)button {
    NSLog(@"%s", __func__);

    [_glView changePerspective:button];
}

#pragma mark - Button actions - Tracker
-(IBAction)toggleTracking:(UIButton *)sender {
    _isTracking = !_isTracking;

    if (_isTracking == YES) {
        [_toggleTrackingButton setTitle:@"stop tracking" forState:UIControlStateNormal];
        
        if (_boundingBox == nil) {
            _boundingBox = [[UIView alloc] initWithFrame:CGRectZero];
        }

        [_boundingBox setFrame:CGRectZero];
        _boundingBox.layer.borderWidth = 2.0f;
        _boundingBox.layer.borderColor = [[UIColor redColor] CGColor];
        _boundingBox.layer.cornerRadius = 4.0f;

        [self.cameraView addSubview:_boundingBox];

        // create a tracker object
        if (_tracker == nil) {
            _tracker = Tracker::create("MIL");
            // some other trackers
//            _tracker = Tracker::create("KCF");
            //_tracker = Tracker::create("BOOSTING");
            // */
        }
    } else {
        [_toggleTrackingButton setTitle:@"start tracking" forState:UIControlStateNormal];
        [_boxTimer invalidate];
        [_boundingBox removeFromSuperview];
        _isTrackerInitialized = _isRegionSpecified = NO;
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

    if (_isTracking == YES && _tracker != nil) {
        // source: http://docs.opencv.org/3.1.0/d2/d0a/tutorial_introduction_to_tracker.html

        // create 3-channel copy of source image (to work with MIL tracker)
        Mat targetImage;
        cvtColor(image, targetImage, CV_BGRA2BGR);

        // check whether touchesEnded:withEvent was called and produced a non-zero ROI
        if (_isRegionSpecified == YES) {
            if (_isTrackerInitialized == NO) {
                _isTrackerInitialized = _tracker->init(targetImage, regionOfInterest);
            } else {
                // update ROI from tracker
                _tracker->update(targetImage, regionOfInterest);
            }
        }
    }
}

-(void)updateBoundingBox {
    _boundingBox.frame = CGRectMake(CGFloat(regionOfInterest.x),
                                    CGFloat(regionOfInterest.y),
                                    CGFloat(regionOfInterest.width),
                                    CGFloat(regionOfInterest.height));
}

#pragma mark - Touch handling
// the touches_____:withEvent: methods replace the selectROI()
// method and populate a Rect2d based on the user's input.
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (_isTrackerInitialized == NO) {
        if (_isTracking == YES) {
            _boundingBox.frame = CGRectMake([event.allTouches.anyObject locationInView:self.cameraView].x,
                                            [event.allTouches.anyObject locationInView:self.cameraView].y,
                                            0,
                                            0);
        }
    }
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (_isTrackerInitialized == NO) {
        if (_isTracking == YES) {
            _boundingBox.frame = CGRectMake(_boundingBox.frame.origin.x,
                                            _boundingBox.frame.origin.y,
                                            [event.allTouches.anyObject locationInView:self.cameraView].x - _boundingBox.frame.origin.x,
                                            [event.allTouches.anyObject locationInView:self.cameraView].y - _boundingBox.frame.origin.y);
        }
    }
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (_isTrackerInitialized == NO) {
        if (_isTracking == YES) {
            _boundingBox.frame = CGRectMake(_boundingBox.frame.origin.x,
                                            _boundingBox.frame.origin.y,
                                            [event.allTouches.anyObject locationInView:self.cameraView].x - _boundingBox.frame.origin.x,
                                            [event.allTouches.anyObject locationInView:self.cameraView].y - _boundingBox.frame.origin.y);

            // get coordinates from bounding box, set as ROI
            regionOfInterest.x = _boundingBox.frame.origin.x;
            regionOfInterest.y = _boundingBox.frame.origin.y;
            regionOfInterest.width = _boundingBox.frame.size.width;
            regionOfInterest.height = _boundingBox.frame.size.height;

            NSLog(@"selected image location: (%.0f, %.0f, %.0f, %.0f)",
                  regionOfInterest.x,
                  regionOfInterest.y,
                  regionOfInterest.width,
                  regionOfInterest.height);

            // let tracker start tracking
            _isRegionSpecified = YES;
            // update UI from time to time (every ~3ms)
            _boxTimer = [NSTimer scheduledTimerWithTimeInterval:0.003 target:self selector:@selector(updateBoundingBox) userInfo:nil repeats:YES];
        }
    }
}

@end
