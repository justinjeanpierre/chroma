//
//  Mobile_ARTests.m
//  Mobile ARTests
//
//  Created by Justin Jean-Pierre on 2017-02-19.
//  Copyright © 2017 Jean-Pierre Digital. All rights reserved.
//

#import "kcftracker.hpp"

#import <XCTest/XCTest.h>
#import "CameraDelegate.h"

@interface Mobile_ARTests : XCTestCase

@property (nonatomic, strong) CameraDelegate *cameraDelegate;
@property (nonatomic) KCFTracker tracker;

@property (nonatomic) BOOL shouldInvertColors;
@property (nonatomic) BOOL shouldDetectFeatures;
@property (nonatomic) BOOL isTracking;
@property (nonatomic) BOOL isTrackerInitialized;
@property (nonatomic) BOOL isRegionSpecified;

@end

@implementation Mobile_ARTests

cv::Rect2d roi;

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testTrackingFramePerformance {
    UIImage *testImage = [UIImage imageNamed:@"Harris_Detector_Original_Image"];
    cv::Mat &img = *new cv::Mat();
    UIImageToMat(testImage, img);

    _tracker = KCFTracker(NO, YES, NO, NO);

    _shouldInvertColors = _shouldDetectFeatures = _isTracking = _isTrackerInitialized = _isRegionSpecified = YES;

    roi.x = 10;
    roi.y = 10;
    roi.width = 100;
    roi.height = 100;

    [self measureBlock:^{
        [self processImage_tracker:img];
    }];
}

-(void)processImage_tracker:(cv::Mat &)srcImage { // see CameraDelegate.h
    // create 3-channel copy of source image
    cv::Mat targetImage;
    cv::Mat image = srcImage.clone();
    cvtColor(image, targetImage, CV_BGRA2BGR);

    _tracker.init(roi, targetImage);

    // check whether touchesEnded:withEvent was called and produced a non-zero ROI
    if (_isRegionSpecified == YES) {
        if (_isTrackerInitialized == NO) {
            _isTrackerInitialized = YES;
        } else {
            // update ROI from tracker
            roi = _tracker.update(targetImage);

            // set overlay image to regionOfInterest contents
            if (0 <= roi.x // asserted in modules/core/src/matrix.cpp, line 522
                && 0 <= roi.width
                && roi.x + roi.width <= image.cols
                && 0 <= roi.y
                && 0 <= roi.height
                && roi.y + roi.height <= image.rows) {

                cv::Mat croppedImage;
                image(roi).copyTo(croppedImage);
            }
        }
    }
}

@end
