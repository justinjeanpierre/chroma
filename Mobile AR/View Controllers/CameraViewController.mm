//
//  CameraViewController.m
//  Mobile AR
//
//  Created by Justin Jean-Pierre on 2017-01-04.
//  Copyright © 2017 Jean-Pierre Digital. All rights reserved.
//

#import "CameraViewController.h"
#import "FileBrowser-swift.h"
#import "kcftracker.hpp"

using namespace std;
using namespace cv;

@interface CameraViewController ()

@property (nonatomic, strong) CvVideoCamera *videoCamera;
@property (nonatomic, strong) UIView *trackerBoundingBox;
@property (nonatomic, strong) UIView *contourBoundingBox;
@property (nonatomic) KCFTracker kcfTracker;

@property (nonatomic, strong) NSTimer *trackerOutlineTimer;
@property (nonatomic, strong) NSTimer *contourOutlineTimer;

@property (nonatomic) BOOL shouldInvertColors;
@property (nonatomic) BOOL shouldDetectFeatures;
@property (nonatomic) BOOL shouldShowCube;
@property (nonatomic) BOOL shouldShowTexture;
@property (nonatomic) BOOL isTracking;
@property (nonatomic) BOOL isTrackerInitialized;
@property (nonatomic) BOOL isRegionSpecified;
@property (nonatomic) BOOL useKCFTracker;

@property (nonatomic, strong) UIImageView *trackedObjectImageView;

@end

@implementation CameraViewController

Rect2d regionOfInterest;
Rect2f bounding_rect;

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setTitle:@"Mobile AR"];

    if (self.navigationItem.rightBarButtonItem != nil) {
        [self.navigationItem.rightBarButtonItem setTarget:self];
        [self.navigationItem.rightBarButtonItem setAction:@selector(showFiles:)];
    }

    self.cameraView.clipsToBounds = YES;

    self.videoCamera = [[CvVideoCamera alloc] initWithParentView:self.cameraView];
    self.videoCamera.delegate = self;
    self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
    self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset1280x720; // switch to higher resolution
    self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    self.videoCamera.defaultFPS = 30;
    self.videoCamera.grayscaleMode = NO;

    // initialize all settings to NO
    _shouldInvertColors =   \
    _shouldDetectFeatures = \
    _shouldShowCube =       \
    _shouldShowTexture =    NO;

    // initial tracker state to NO
    _isTracking =           \
    _isTrackerInitialized = \
    _isRegionSpecified =    NO;

    // use KCF tracker by default?
    _useKCFTracker = YES;

    [self.videoCamera start];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Button actions - Switch trackers
-(IBAction)switchTrackers:(UIButton *)sender {
    _useKCFTracker = !_useKCFTracker;

    _useKCFTracker == YES?
        [sender setTitle:@"using KCF" forState:UIControlStateNormal]:
        [sender setTitle:@"using MIL" forState:UIControlStateNormal];
}

#pragma mark - Button actions - Switch cameras
-(IBAction)switchCameras:(id)sender {
    [self.videoCamera switchCameras];
}

#pragma mark - Button actions - Show files
-(IBAction)showFiles:(UIButton *) sender {
    [self presentViewController:[[FileBrowser alloc] init]
                       animated:NO
                     completion:^{}];
}

#pragma mark - Button actions - Image colour
- (IBAction)invertColors:(UIButton *)button {
    _shouldInvertColors = !_shouldInvertColors;

    NSLog(@"%s", __func__);
}

#pragma mark - Button actions - Corner detection
- (IBAction)detectFeatures:(UIButton *)button {
    _shouldDetectFeatures = !_shouldDetectFeatures;

    if (_shouldDetectFeatures == YES) {
        if (_contourBoundingBox == nil) {
            // we are trying to reuse the same box,
            // so only re-allocate it if it has
            // been released
            _contourBoundingBox = [[UIView alloc] initWithFrame:CGRectZero];
        }

        // make it really small...
        [_contourBoundingBox setFrame:CGRectZero];

        // set up the border width, colour, and radius
        _contourBoundingBox.layer.borderWidth = 2.0f;
        _contourBoundingBox.layer.borderColor = [[UIColor redColor] CGColor];
        _contourBoundingBox.layer.cornerRadius = 4.0f;

        // put the box on screen
        [self.cameraView addSubview:_contourBoundingBox];

        // UI update timer was triggered by the tracker.
        // we need to let the contour detector start the
        // timer as well
        _contourOutlineTimer = [NSTimer scheduledTimerWithTimeInterval:0.03
                                                                target:self
                                                              selector:@selector(updateContourBoundingBox)
                                                              userInfo:nil
                                                               repeats:YES];
    } else {
        // someone turned off the contour detection,
        // so we don't need the box on screen anymore.
        [_contourBoundingBox removeFromSuperview];
        [_contourOutlineTimer invalidate];
    }
}

#pragma mark - Button actions - Virtual overlay
-(IBAction)toggleCubeVisibility:(UIButton *)button {
    _shouldShowCube = !_shouldShowCube;

    // configure virtual cube
    if (_shouldShowCube == YES) {
        [button setTitle:@"hide cube" forState:UIControlStateNormal];
        if (!_glView) {
            _glView = [[BoxView alloc] initWithFrame:self.cameraView.bounds];
        } else {
            [_glView setFrame:self.cameraView.bounds];
        }

        [_glView enableOrientationUpdates];
        [self.cameraView insertSubview:_glView belowSubview:_trackedObjectImageView];
    } else {
        [button setTitle:@"show cube" forState:UIControlStateNormal];
        [_glView removeFromSuperview];
    }

    _glView.alpha = (_shouldShowCube == YES);
    _textureMenuButton.alpha = (_shouldShowCube == YES);
}

-(IBAction)toggleCubePerpective:(UIButton *)button {
    NSLog(@"%s", __func__);

    [_glView changePerspective:button];
}

-(IBAction)updateCube:(UIButton *)sender {
    NSLog(@"%s", __func__);

    // toggle one of the cube's points
//    [_glView updateBoxWithPoint:CGPoint3DMake(2, 2, 2)];
    [_glView scaleYBy:1.5];
}

-(IBAction)showTextureMenu:(UIButton *)sender {
    UIAlertController *textureMenuActions = [UIAlertController alertControllerWithTitle:@"Filter options"
                                                                                message:@"Select a filter to apply to the scene"
                                                                         preferredStyle:UIAlertControllerStyleActionSheet];

    UIAlertAction *texture1 = [UIAlertAction actionWithTitle:@"pebbles"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
        _shouldShowTexture = YES;

        [_glView updateTextureWithShaderIndex:1];
    }];

    UIAlertAction *texture2 = [UIAlertAction actionWithTitle:@"stones"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
        _shouldShowTexture = YES;

        [_glView updateTextureWithShaderIndex:2];
    }];

    UIAlertAction *texture3 = [UIAlertAction actionWithTitle:@"bricks"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
        _shouldShowTexture = YES;

        [_glView updateTextureWithShaderIndex:3];
    }];

    NSString *toggleMenuOptionString;
    _shouldShowTexture == YES ? toggleMenuOptionString = @"remove texture" : toggleMenuOptionString = @"show texture";


    UIAlertAction *texturetoggle = [UIAlertAction actionWithTitle:toggleMenuOptionString
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * _Nonnull action) {
        _shouldShowTexture = !_shouldShowTexture;
        [_glView updateTextureWithShaderIndex:(int)_shouldShowTexture];
    }];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * _Nonnull action) {
        _shouldShowTexture == YES ? [_glView updateTextureWithShaderIndex:(int)_shouldShowTexture] : [_glView updateTextureWithShaderIndex:0];
    }];

    [textureMenuActions addAction:texture1];
    [textureMenuActions addAction:texture2];
    [textureMenuActions addAction:texture3];
    [textureMenuActions addAction:texturetoggle];
    [textureMenuActions addAction:cancelAction];

    [self presentViewController:textureMenuActions animated:YES completion:^{}];
}

#pragma mark - Button actions - Tracker
-(IBAction)toggleTracking:(UIButton *)sender {
    _isTracking = !_isTracking;

    if (_isTracking == YES) {
        [_toggleTrackingButton setTitle:@"stop tracking" forState:UIControlStateNormal];
        
        if (_trackerBoundingBox == nil) {
            _trackerBoundingBox = [[UIView alloc] initWithFrame:CGRectZero];
        }

        [_trackerBoundingBox setFrame:CGRectZero];
        _trackerBoundingBox.layer.borderWidth = 2.0f;
        _trackerBoundingBox.layer.cornerRadius = 4.0f;

        _useKCFTracker == YES?
            _trackerBoundingBox.layer.borderColor = [[UIColor blackColor] CGColor]: // black for KCF
            _trackerBoundingBox.layer.borderColor = [[UIColor blueColor] CGColor];  // blue for MIL

        [self.cameraView addSubview:_trackerBoundingBox];

        // create a tracker object
        if (_useKCFTracker == YES) {
            _kcfTracker = KCFTracker(NO, YES, NO, NO);
        }

        // add "preview" box
        if (!_trackedObjectImageView) {
            _trackedObjectImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        }

        _trackedObjectImageView.layer.cornerRadius = _trackerBoundingBox.layer.cornerRadius;
        [self.cameraView addSubview:_trackedObjectImageView];

    } else {
        [_trackedObjectImageView removeFromSuperview];

        [_toggleTrackingButton setTitle:@"start tracking" forState:UIControlStateNormal];
        [_trackerOutlineTimer invalidate];
        [_trackerBoundingBox removeFromSuperview];
        _isTrackerInitialized = _isRegionSpecified = NO;

        _kcfTracker.~KCFTracker();
    }
}

#pragma mark - CvVideoCameraDelegate methods
-(void)processImage:(cv::Mat &)image {
    Mat image_copy;
    Mat gray_image;
    Mat edges;
    cvtColor(image, image_copy, CV_BGRA2BGR);
    cvtColor(image, gray_image, CV_BGR2GRAY);
    vector<vector<cv::Point>> contours;
    vector<Vec4i> hierarchy;
    int largest_area = 0;
    int largest_contour_index = 0;

    CGPoint corner1, corner2, corner3, corner4;

    if (_shouldInvertColors == YES) {
        // invert image
        bitwise_not(image_copy, image_copy);
        cvtColor(image_copy, image, CV_BGR2BGRA);
    }

    if (_shouldDetectFeatures == YES) {
        // edge detection code
        Canny(gray_image, edges, 5, 200, 3);
        
        // Find the contours in the image
        findContours( edges, contours, hierarchy, CV_RETR_CCOMP, CV_CHAIN_APPROX_SIMPLE );

        for( int i = 0; i < contours.size(); i++ ) { // iterate through each contour.
            double a = contourArea(contours[i], false);  //  Find the area of contour
            
            if(a > largest_area) {
                largest_area = a;
                largest_contour_index = i;  //index of largest contour
                // bounding rectangle for biggest contour
                bounding_rect = boundingRect(contours[i]);
            }
            
        //coordinates of all corners going clockwise:
            corner1.x = bounding_rect.x;
            corner1.y = bounding_rect.y;
            corner2.x = corner1.x + bounding_rect.width;
            corner2.y = corner1.y;
            corner3.x = corner2.x;
            corner3.y = corner2.y - bounding_rect.height;
            corner4.x = corner1.x;
            corner4.y = corner3.y;
        }
    }

    if (_isTracking == YES) {
        // source: http://docs.opencv.org/3.1.0/d2/d0a/tutorial_introduction_to_tracker.html

        // create 3-channel copy of source image
        Mat targetImage;
        cvtColor(image, targetImage, CV_BGRA2BGR);

        // check whether touchesEnded:withEvent was called and produced a non-zero ROI
        if (_isRegionSpecified == YES) {
            if (_isTrackerInitialized == NO) {
                _kcfTracker.init(regionOfInterest, targetImage);
                _isTrackerInitialized = YES;
            } else {
                // update ROI from tracker
                regionOfInterest = _kcfTracker.update(targetImage);

                // set overlay image to regionOfInterest contents
                if (0 <= regionOfInterest.x // asserted in modules/core/src/matrix.cpp, line 522
                    && 0 <= regionOfInterest.width
                    && regionOfInterest.x + regionOfInterest.width <= image.cols
                    && 0 <= regionOfInterest.y
                    && 0 <= regionOfInterest.height
                    && regionOfInterest.y + regionOfInterest.height <= image.rows) {
                        cv::Mat croppedImage = image(regionOfInterest);

//                        UIImage *tmp = MatToUIImage(croppedImage);
                        UIImage *tmp = MatToUIImage(image);
                        [_trackedObjectImageView performSelectorOnMainThread:@selector(setImage:) withObject:tmp waitUntilDone:NO];
                }
            }
        }
    }
}

-(void)updatePreviewWithImage:(UIImage *)img {
    [_trackedObjectImageView setImage:img];
}

-(void)updateTrackerBoundingBox {
    _trackerBoundingBox.frame = CGRectMake(CGFloat(regionOfInterest.x),
                                    CGFloat(regionOfInterest.y),
                                    CGFloat(regionOfInterest.width),
                                    CGFloat(regionOfInterest.height));

    _trackedObjectImageView.frame = CGRectMake(CGFloat(regionOfInterest.x + 2),
                                               CGFloat(regionOfInterest.y + 2),
                                               CGFloat(regionOfInterest.width - 4),
                                               CGFloat(regionOfInterest.height - 4));
}

-(void)updateContourBoundingBox {
    _contourBoundingBox.frame = CGRectMake(bounding_rect.x,
                                           bounding_rect.y,
                                           bounding_rect.width,
                                           bounding_rect.height);
}

#pragma mark - Touch handling
// the touches_____:withEvent: methods replace the selectROI()
// method and populate a Rect2d based on the user's input.
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (_isTrackerInitialized == NO) {
        if (_isTracking == YES) {
            _trackerBoundingBox.frame = CGRectMake([event.allTouches.anyObject locationInView:self.cameraView].x,
                                            [event.allTouches.anyObject locationInView:self.cameraView].y,
                                            0,
                                            0);
        }
    }
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (_isTrackerInitialized == NO) {
        if (_isTracking == YES) {
            _trackerBoundingBox.frame = CGRectMake(_trackerBoundingBox.frame.origin.x,
                                            _trackerBoundingBox.frame.origin.y,
                                            [event.allTouches.anyObject locationInView:self.cameraView].x - _trackerBoundingBox.frame.origin.x,
                                            [event.allTouches.anyObject locationInView:self.cameraView].y - _trackerBoundingBox.frame.origin.y);
        }
    }
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (_isTrackerInitialized == NO) {
        if (_isTracking == YES) {
            _trackerBoundingBox.frame = CGRectMake(_trackerBoundingBox.frame.origin.x,
                                            _trackerBoundingBox.frame.origin.y,
                                            [event.allTouches.anyObject locationInView:self.cameraView].x - _trackerBoundingBox.frame.origin.x,
                                            [event.allTouches.anyObject locationInView:self.cameraView].y - _trackerBoundingBox.frame.origin.y);

            // get coordinates from bounding box, set as ROI
            regionOfInterest.x = _trackerBoundingBox.frame.origin.x;
            regionOfInterest.y = _trackerBoundingBox.frame.origin.y;
            regionOfInterest.width = _trackerBoundingBox.frame.size.width;
            regionOfInterest.height = _trackerBoundingBox.frame.size.height;

            NSLog(@"selected image location: (%.0f, %.0f, %.0f, %.0f)",
                  regionOfInterest.x,
                  regionOfInterest.y,
                  regionOfInterest.width,
                  regionOfInterest.height);

            // let tracker start tracking
            _isRegionSpecified = YES;
            // update UI from time to time (every ~3ms)
            _trackerOutlineTimer = [NSTimer scheduledTimerWithTimeInterval:0.03
                                                         target:self
                                                       selector:@selector(updateTrackerBoundingBox)
                                                       userInfo:nil
                                                        repeats:YES];
        }
    }
}

@end
