//
//  CameraViewController.m
//  Mobile AR
//
//  Created by Justin Jean-Pierre on 2017-01-04.
//  Copyright © 2017 Jean-Pierre Digital. All rights reserved.
//

#import "CameraViewController.h"

using namespace cv;

@interface CameraViewController ()

@property (nonatomic, retain) CvVideoCamera *videoCamera;
@property (nonatomic) BOOL shouldInvertColors;
@property (nonatomic) BOOL shouldDetectFeatures;
@property (nonatomic) BOOL shouldShowCube;
@property (nonatomic) BOOL isTracking;

@end

@implementation CameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setTitle:@"OpenCV tool"];
    self.cameraView.clipsToBounds = YES;

    self.videoCamera = [[CvVideoCamera alloc] initWithParentView:self.cameraView];
    self.videoCamera.delegate = self;
    self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
    self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset640x480;
    self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationLandscapeLeft;
    self.videoCamera.defaultFPS = 60;
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
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

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

    NSLog(@"%s isTracking: %d", __func__, _isTracking);
}

#pragma mark - CvVideoCameraDelegate methods
-(void)processImage:(cv::Mat &)image {
//    NSLog(@"%s", __func__);

    Mat image_copy;
    cvtColor(image, image_copy, CV_BGRA2BGR);

    if (_shouldInvertColors == YES) {
        // invert image
        bitwise_not(image_copy, image_copy);
        cvtColor(image_copy, image, CV_BGR2BGRA);
    }

    if (_shouldDetectFeatures == YES) {
        // TODO: edge detection code goes here
        Canny(image, image_copy, 100, 200);
    }

    if (_isTracking == YES) {
        Rect2d roi;
    }
}

#pragma mark - BoxView
-(IBAction)toggleCubePerpective:(UIButton *)button {
    NSLog(@"%s", __func__);

    [_glView changePerspective:button];
}

@end
