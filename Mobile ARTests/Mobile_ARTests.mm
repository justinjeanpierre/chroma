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

- (void)testTrackingFramePerformance {
    UIImage *testImage = [UIImage imageNamed:@"Harris_Detector_Original_Image"];
    cv::Mat &img = *new cv::Mat();
    UIImageToMat(testImage, img);

    _tracker = KCFTracker(NO, YES, NO, NO);

    _isTracking = _isTrackerInitialized = _isRegionSpecified = YES;

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

- (void)testDetectingFramePerformance {
    UIImage *testImage = [UIImage imageNamed:@"Harris_Detector_Original_Image"];
    cv::Mat &img = *new cv::Mat();
    UIImageToMat(testImage, img);

    _shouldDetectFeatures = YES;

    roi.x = 10;
    roi.y = 10;
    roi.width = 100;
    roi.height = 100;

    [self measureBlock:^{
        [self processImage_detector:img];
    }];
}

-(void)processImage_detector:(cv::Mat &)srcImage { // see CameraDelegate.h

    CGRect contour = CGRectZero;

    if (_shouldDetectFeatures == YES) {
        cv::Mat gray_image;
        cv::Mat edges;
        cv::Rect2f bounding_rect;

        std::vector<std::vector<cv::Point>> contours;
        std::vector<cv::Vec4i> hierarchy;
        int largest_area = 0;

        // desaturate
        cvtColor(srcImage, gray_image, CV_BGR2GRAY);

        // edge detection code
        Canny(gray_image, edges, 5, 200, 3);

        // Find the contours in the image
        findContours( edges, contours, hierarchy, CV_RETR_CCOMP, CV_CHAIN_APPROX_SIMPLE );

        for( int i = 0; i < contours.size(); i++ ) { // iterate through each contour.
            double a = contourArea(contours[i], false);  //  Find the area of contour

            if(a > largest_area) {
                largest_area = a;
                // bounding rectangle for biggest contour
                bounding_rect = boundingRect(contours[i]);
            }

            //coordinates of all corners going clockwise:
            contour.origin.x = bounding_rect.x;
            contour.origin.y = bounding_rect.y;
            contour.size.width = contour.origin.x + bounding_rect.width;
            contour.size.height = contour.origin.y - bounding_rect.height;
        }
    }
}

- (void)testInvertingFramePerformance {
    UIImage *testImage = [UIImage imageNamed:@"Harris_Detector_Original_Image"];
    cv::Mat &img = *new cv::Mat();
    UIImageToMat(testImage, img);

    _tracker = KCFTracker(NO, YES, NO, NO);

    _shouldInvertColors = YES;

    roi.x = 10;
    roi.y = 10;
    roi.width = 100;
    roi.height = 100;

    [self measureBlock:^{
        [self processImage_invertor:img];
    }];
}

-(void)processImage_invertor:(cv::Mat &)srcImage { // see CameraDelegate.h
    if (_shouldInvertColors == YES) {
        // invert image
        cv::Mat image_copy;
        cvtColor(srcImage, image_copy, CV_BGRA2BGR);
        bitwise_not(image_copy, image_copy);
        cvtColor(image_copy, srcImage, CV_BGR2BGRA);
    }
}

@end
