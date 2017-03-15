//
//  CameraDelegate.m
//  Mobile AR
//
//  Created by Justin Jean-Pierre on 2017-03-15.
//  Copyright © 2017 Jean-Pierre Digital. All rights reserved.
//

#import "CameraDelegate.h"
#import "kcftracker.hpp"

using namespace std;
using namespace cv;

@interface CameraDelegate ()
@property (nonatomic) KCFTracker tracker;
@property (nonatomic) BOOL shouldInvertColors;
@property (nonatomic) BOOL shouldDetectFeatures;
@property (nonatomic) BOOL isTracking;
@property (nonatomic) BOOL isTrackerInitialized;
@property (nonatomic) BOOL isRegionSpecified;
@end

@implementation CameraDelegate

Rect2d regionOfInterest;

#pragma mark - CvVideoCameraDelegate methods

-(instancetype)init {
    self = [super init];

    // create a tracker object
    _tracker = KCFTracker(NO, YES, NO, NO);

    _shouldInvertColors = \
    _shouldDetectFeatures = \
    _isTracking = \
    _isTrackerInitialized = \
    _isRegionSpecified = NO;

    return self;
}

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

    Rect2f bounding_rect;
    CGRect contour;

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
            contour.origin.x = bounding_rect.x;
            contour.origin.y = bounding_rect.y;
            contour.size.width = contour.origin.x + bounding_rect.width;
            contour.size.height = contour.origin.y - bounding_rect.height;
        }

        [_displayTarget updateContourBoundingBoxWithRect:contour];
    }

    if (_isTracking == YES) {
        // source: http://docs.opencv.org/3.1.0/d2/d0a/tutorial_introduction_to_tracker.html

        // create 3-channel copy of source image
        Mat targetImage;
        cvtColor(image, targetImage, CV_BGRA2BGR);

        // check whether touchesEnded:withEvent was called and produced a non-zero ROI
        if (_isRegionSpecified == YES) {
            if (_isTrackerInitialized == NO) {
                _tracker.init(regionOfInterest, targetImage);
                _isTrackerInitialized = YES;
            } else {
                // update ROI from tracker
                regionOfInterest = _tracker.update(targetImage);

                // set overlay image to regionOfInterest contents
                if (0 <= regionOfInterest.x // asserted in modules/core/src/matrix.cpp, line 522
                    && 0 <= regionOfInterest.width
                    && regionOfInterest.x + regionOfInterest.width <= image.cols
                    && 0 <= regionOfInterest.y
                    && 0 <= regionOfInterest.height
                    && regionOfInterest.y + regionOfInterest.height <= image.rows) {

                    [_displayTarget updatePreviewWithImage:MatToUIImage(image)];
//                    [_displayTarget updatePreviewWithImage:MatToUIImage(image(regionOfInterest))]; // crop image to roi somehow
                    [_displayTarget updateTrackerBoundingBoxWithRect:CGRectMake(regionOfInterest.x,
                                                                                regionOfInterest.y,
                                                                                regionOfInterest.width,
                                                                                regionOfInterest.height)];
                }
            }
        }
    }
}

-(void)toggleTracking {
    _isTracking = !_isTracking;
}

-(void)toggleColorInversion {
    _shouldInvertColors = !_shouldInvertColors;
}

-(void)toggleFeatureDetection {
    _shouldDetectFeatures = !_shouldDetectFeatures;
}

-(void)updateRegionOfInterest:(cv::Rect)newROI {
    regionOfInterest = newROI;

    _isRegionSpecified = YES;
}

@end
