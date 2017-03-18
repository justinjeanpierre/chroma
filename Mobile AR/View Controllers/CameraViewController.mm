//
//  CameraViewController.m
//  Mobile AR
//
//  Created by Justin Jean-Pierre on 2017-01-04.
//  Copyright © 2017 Jean-Pierre Digital. All rights reserved.
//

#import "CameraViewController.h"
#import "FileBrowser-swift.h"

using namespace std;
using namespace cv;

@interface CameraViewController ()

@property (nonatomic, strong) CvVideoCamera *videoCamera;
@property (nonatomic, strong) CameraDelegate *captureDelegate;
@property (nonatomic, strong) UIView *trackerBoundingBox;
@property (nonatomic, strong) UIView *contourBoundingBox;

@property (nonatomic, strong) NSTimer *trackerOutlineTimer;
@property (nonatomic, strong) NSTimer *contourOutlineTimer;

@property (nonatomic) BOOL shouldInvertColors;
@property (nonatomic) BOOL shouldDetectFeatures;
@property (nonatomic) BOOL shouldShowCube;
@property (nonatomic) BOOL shouldShowTexture;
@property (nonatomic) BOOL isTracking;
@property (nonatomic) BOOL isTrackerInitialized;
@property (nonatomic) BOOL isRegionSpecified;

@property (nonatomic, strong) UIImageView *trackedObjectImageView;

@end

@implementation CameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setTitle:@"Mobile AR"];

    if (self.navigationItem.rightBarButtonItem != nil) {
        [self.navigationItem.rightBarButtonItem setTarget:self];
        [self.navigationItem.rightBarButtonItem setAction:@selector(showFiles:)];
    }

    self.cameraView.clipsToBounds = YES;

    // TODO: why is camera preview not covering full 6+/7+ screen?
    self.videoCamera = [[CvVideoCamera alloc] initWithParentView:self.cameraView];
    self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
    self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset1280x720;
    self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    self.videoCamera.defaultFPS = 30;
    self.videoCamera.grayscaleMode = NO;

    self.captureDelegate = [[CameraDelegate alloc] init];
    self.captureDelegate.displayTarget = self;
    self.videoCamera.delegate = self.captureDelegate;

    // initialize all settings to NO
    _shouldInvertColors =   \
    _shouldDetectFeatures = \
    _shouldShowCube =       \
    _shouldShowTexture =    NO;

    // initial tracker state to NO
    _isTracking =           \
    _isTrackerInitialized = \
    _isRegionSpecified =    NO;

    [self.videoCamera start];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
    [self.captureDelegate toggleColorInversion];
}

#pragma mark - Button actions - Corner detection
- (IBAction)detectFeatures:(UIButton *)button {
    _shouldDetectFeatures = !_shouldDetectFeatures;
    [self.captureDelegate toggleFeatureDetection];

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
    [_glView changePerspective:button];
}

-(IBAction)updateCube:(UIButton *)sender {
    // toggle one of the cube's points
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
    [self.captureDelegate toggleTracking];

    if (_isTracking == YES) {
        [_toggleTrackingButton setTitle:@"stop tracking" forState:UIControlStateNormal];
        
        if (_trackerBoundingBox == nil) {
            _trackerBoundingBox = [[UIView alloc] initWithFrame:CGRectZero];
        }

        [_trackerBoundingBox setFrame:CGRectZero];
        _trackerBoundingBox.layer.borderWidth = 2.0f;
        _trackerBoundingBox.layer.cornerRadius = 4.0f;

        [self.cameraView addSubview:_trackerBoundingBox];

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
    }
}

-(void)updatePreviewWithImage:(UIImage *)newImage {
    dispatch_async(dispatch_get_main_queue(), ^{
        [_trackedObjectImageView performSelectorOnMainThread:@selector(setImage:)
                                                  withObject:newImage
                                               waitUntilDone:NO];
    });
}

-(void)updateTrackerBoundingBoxWithRect:(CGRect)newBoundingBox {
    dispatch_async(dispatch_get_main_queue(), ^{
        _trackerBoundingBox.frame = newBoundingBox;

        _trackedObjectImageView.frame = CGRectMake(newBoundingBox.origin.x + 2,
                                                   newBoundingBox.origin.y + 2,
                                                   newBoundingBox.size.width - 4,
                                                   newBoundingBox.size.height - 4);
    });
}

-(void)updateContourBoundingBoxWithRect:(CGRect)newBoundingBox {
    dispatch_async(dispatch_get_main_queue(), ^{
        _contourBoundingBox.frame = newBoundingBox;
    });
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
            Rect2d roi;

            roi.x = _trackerBoundingBox.frame.origin.x;
            roi.y = _trackerBoundingBox.frame.origin.y;
            roi.width = _trackerBoundingBox.frame.size.width;
            roi.height = _trackerBoundingBox.frame.size.height;

            NSLog(@"selected image location: (%.0f, %.0f, %.0f, %.0f)",
                  roi.x,
                  roi.y,
                  roi.width,
                  roi.height);

            // let tracker start tracking
            _isRegionSpecified = YES;
            [self.captureDelegate updateRegionOfInterest:roi];
        }
    }
}

@end
