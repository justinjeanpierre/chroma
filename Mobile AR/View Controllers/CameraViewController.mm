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

@property (nonatomic, retain) CvVideoCamera *videoCamera;
@property (nonatomic) BOOL shouldInvertColors;
@property (nonatomic) BOOL shouldDetectFeatures;
@property (nonatomic) BOOL shouldShowCube;
@property (nonatomic) BOOL isTracking;
@property (nonatomic) UIView *trackerView;

@property (nonatomic) Ptr<Tracker> tracker;
@property (nonatomic) Rect2d roi;

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

    if (_isTracking == YES) { // show default outline
        if (self.trackerView == nil) {
            self.trackerView = [[UIView alloc] initWithFrame:CGRectMake(self.cameraView.bounds.size.width/2 - 100,
                                                                        self.cameraView.bounds.size.height/2 - 100,
                                                                        200,
                                                                        200)];
        }

        self.trackerView.layer.borderWidth = 2.0f;
        self.trackerView.layer.borderColor = [[UIColor redColor] CGColor];
        self.trackerView.layer.cornerRadius = 4.0f;
        [self.cameraView addSubview:self.trackerView];

        // create a tracker object
        _tracker = Tracker::create("KCF");

        _roi = Rect2d();
        _roi.x = self.cameraView.bounds.origin.x;
        _roi.y = self.cameraView.bounds.origin.y;
        _roi.width = self.cameraView.bounds.size.width;
        _roi.height = self.cameraView.bounds.size.height;
    } else {
        [self.trackerView removeFromSuperview];

        // destroy tracker
        _tracker->~Tracker();
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
        Canny(image, image_copy, 100, 200);
    }

    if (_isTracking == YES) {
        // source: http://docs.opencv.org/3.1.0/d2/d0a/tutorial_introduction_to_tracker.html

        // create 3-channel copy of source image
        Mat targetImage;
        cvtColor(image, targetImage, CV_BGRA2BGR);

        // update tracker
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            // initialize tracker
            _tracker->init(targetImage, _roi);

            // update tracker
            if (_tracker->update(targetImage, _roi) == YES) {
                CGRect roiFrame = CGRectMake(CGFloat(_roi.x), CGFloat(_roi.y), CGFloat(_roi.width), CGFloat(_roi.height));
//                NSLog(@"(%f, %f, %f, %f)", roiFrame.origin.x, roiFrame.origin.y, roiFrame.size.width, roiFrame.size.width);

                // update bounds (on main thread)
                dispatch_async(dispatch_get_main_queue(), ^{
                    _trackerView.frame = roiFrame;
                });
            }
        });
    }
}

#pragma mark - BoxView
-(IBAction)toggleCubePerpective:(UIButton *)button {
    NSLog(@"%s", __func__);

    [_glView changePerspective:button];
}

@end
