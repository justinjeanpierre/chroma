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
@property (nonatomic, strong) UIView *trackerBoundingBox;
@property (nonatomic, strong) UIView *contourBoundingBox;
@property (nonatomic) Ptr<Tracker> tracker;

@property (nonatomic, strong) NSTimer *trackerOutlineTimer;
@property (nonatomic, strong) NSTimer *contourOutlineTimer;

@property (nonatomic) BOOL shouldInvertColors;
@property (nonatomic) BOOL shouldDetectFeatures;
@property (nonatomic) BOOL shouldShowCube;
@property (nonatomic) BOOL isTracking;
@property (nonatomic) BOOL isTrackerInitialized;
@property (nonatomic) BOOL isRegionSpecified;

@end

@implementation CameraViewController

Rect2d regionOfInterest;
cv::Rect bounding_rect;

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setTitle:@"Mobile AR"];

    if (self.navigationItem.rightBarButtonItem != nil) {
        [self.navigationItem.rightBarButtonItem setTarget:self];
        [self.navigationItem.rightBarButtonItem setAction:@selector(didPressShowFilesButton:)];
    }

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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

    // turn off image processing
    _shouldInvertColors = _shouldDetectFeatures = NO;

    // turn off cube
    _shouldShowCube = NO;

    // turn off tracker
    _isTracking = _isTrackerInitialized = _isRegionSpecified = NO;

    // destroy tracker
    if (_tracker) {
        _tracker->~Tracker();
    }
}

#pragma mark - Button actions - Show files
-(IBAction)didPressShowFilesButton:(UIButton *) sender {
    [self presentViewController:[[FileBrowser alloc] init] animated:NO completion:^{}];
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
        _contourBoundingBox.layer.borderColor = [[UIColor greenColor] CGColor];
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

    _glView.alpha = (_shouldShowCube == YES);

    // configure virtual cube
    if (_shouldShowCube == YES) {
        [button setTitle:@"hide cube" forState:UIControlStateNormal];
        if (!_glView) {
            _glView = [[BoxView alloc] initWithFrame:self.cameraView.frame];
        } else {
            [_glView setFrame:self.cameraView.frame];
        }

        [self.cameraView addSubview:_glView];
    } else {
        [button setTitle:@"show cube" forState:UIControlStateNormal];
        [_glView removeFromSuperview];
    }
}

-(IBAction)toggleCubePerpective:(UIButton *)button {
    NSLog(@"%s", __func__);

    [_glView changePerspective:button];
}

-(IBAction)updateCube:(UIButton *)sender {
    NSLog(@"%s", __func__);

    [_glView updateBoxWithPoint:CGPoint3DMake(2, 2, 2)];
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
        _trackerBoundingBox.layer.borderColor = [[UIColor redColor] CGColor];
        _trackerBoundingBox.layer.cornerRadius = 4.0f;

        [self.cameraView addSubview:_trackerBoundingBox];

        // create a tracker object
        if (_tracker == nil) {
            _tracker = Tracker::create("MIL");
//            _tracker = Tracker::create("KCF");
//            _tracker = Tracker::create("BOOSTING");
        }
    } else {
        [_toggleTrackingButton setTitle:@"start tracking" forState:UIControlStateNormal];
        [_trackerOutlineTimer invalidate];
        [_trackerBoundingBox removeFromSuperview];
        _isTrackerInitialized = _isRegionSpecified = NO;
    }
}

#pragma mark - CvVideoCameraDelegate methods
-(void)processImage:(cv::Mat &)image {
    Mat image_copy;
    Mat gray_image;
    Mat edges;
    cvtColor(image, image_copy, CV_BGRA2BGR);
    cvtColor(image, gray_image, CV_BGR2GRAY);
    vector<vector<cv::Point> > contours;
    vector<Vec4i> hierarchy;
    int largest_area=0;
    int largest_contour_index=0;

    int corner1_x, corner1_y, corner2_x, corner2_y, corner3_x, corner3_y, corner4_x, corner4_y;

    if (_shouldInvertColors == YES) {
        // invert image
        bitwise_not(image_copy, image_copy);
        cvtColor(image_copy, image, CV_BGR2BGRA);
    }

    if (_shouldDetectFeatures == YES) {
        // edge detection code
        Canny(gray_image, edges, 5, 200, 3);
        
        // Find the contours in the image
        findContours( edges, contours, hierarchy,CV_RETR_CCOMP, CV_CHAIN_APPROX_SIMPLE );
        
        
        for( int i = 0; i< contours.size(); i++ ) // iterate through each contour.
        {
            double a=contourArea( contours[i],false);  //  Find the area of contour
            
            if(a>largest_area){
                largest_area=a;
                largest_contour_index=i;  //index of largest contour
                // bounding rectangle for biggest contour
                bounding_rect=boundingRect(contours[i]);
            }
            
        //coordinates of all corners going clockwise:
            corner1_x = bounding_rect.x;
            corner1_y = bounding_rect.y;
            corner2_x = corner1_x + bounding_rect.width;
            corner2_y = corner1_y;
            corner3_x = corner2_x;
            corner3_y = corner2_y - bounding_rect.height;
            corner4_x = corner1_x;
            corner4_y = corner3_y;
        }
        
        //for testing purposes
        cout << "index"<< largest_contour_index<< endl;
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

-(void)updateTrackerBoundingBox {
    _trackerBoundingBox.frame = CGRectMake(CGFloat(regionOfInterest.x),
                                    CGFloat(regionOfInterest.y),
                                    CGFloat(regionOfInterest.width),
                                    CGFloat(regionOfInterest.height));
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
