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

    if (_shouldInvertColors == YES) {
        // invert image
        Mat image_copy;
        cvtColor(image, image_copy, CV_BGRA2BGR);
        bitwise_not(image_copy, image_copy);
        cvtColor(image_copy, image, CV_BGR2BGRA);
    }

    CGRect contour = CGRectZero;
    if (_shouldDetectFeatures == YES) {
        Mat gray_image;
        Mat edges, dst, dest_frame;
        Rect2f bounding_rect;
        
        vector<vector<cv::Point>> contours;
        vector<Vec4i> hierarchy;
        vector<Point2f> corners;
        int largest_area = 0;
        int ratio;

        //desaturate
        cvtColor(image, gray_image, CV_BGR2GRAY);
        
        //bilateral filter
        cv::bilateralFilter(gray_image, dest_frame, 3 ,6, 1.5);

        // edge detection code
        Canny(dest_frame, edges, 100, 220 , 3);

        // Find the contours in the image
        findContours( edges, contours, hierarchy, CV_RETR_CCOMP, CV_CHAIN_APPROX_SIMPLE );
        
        //Find corners in the image
        goodFeaturesToTrack( gray_image,corners, 50, 0.01, 10, Mat(), 3, true, 0.04 );
        
        // corner detection largest contour
        
        //contour comparison
        for ( int i = 0; i < contours.size(); i++ ) { // iterate through each contour.
            double a = contourArea(contours[i], false);  //  Find the area of contour

            if (a > largest_area) {
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
        
        // integer ratio (height/width) variable to be passed for virtual mapping
        ratio = contour.size.height/contour.size.width;
        [_displayTarget scaleModelByXAxisRatio:0 yAxisRatio:ratio zAxisRatio:0];

        if (ratio > 0) {
            [_displayTarget updateContourBoundingBoxWithRect:contour];
            _shouldDetectFeatures = NO;// process on single frame
        }
    }

    if (_isTracking == YES) {
        // source: http://docs.opencv.org/3.1.0/d2/d0a/tutorial_introduction_to_tracker.html

        // create 3-channel copy of source image
        Mat targetImage;
        cvtColor(image, targetImage, CV_BGRA2BGR);

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
                    && regionOfInterest.y + regionOfInterest.height <= image.rows)
                {
                    // select region to display in tracker ROI from input image
                    cv::Rect2f cropBounds = regionOfInterest;
                    cropBounds.x += regionOfInterest.tl().x;
                    cropBounds.y += regionOfInterest.tl().y;
                    cropBounds.width = 2 * regionOfInterest.size().width;
                    cropBounds.height = 2 * regionOfInterest.size().height;

                    // quick fix to keep app from crashing when
                    // tracker overlay moves to edge of view
                    if (0 <= cropBounds.x
                        && 0 <= cropBounds.width
                        && cropBounds.x + cropBounds.width <= image.cols
                        && 0 <= cropBounds.y
                        && 0 <= cropBounds.height
                        && cropBounds.y + cropBounds.height <= image.rows)
                    {
                        // copy ROI from source image to tracker overlay image
                        Mat croppedImage;
                        image(cropBounds).copyTo(croppedImage);

                        // convert image back to original colours
                        cvtColor(croppedImage, croppedImage, CV_BGR2BGRA);

                        // ask delegate to update tracker overlay image and bounds
                        [_displayTarget updatePreviewWithImage:MatToUIImage(croppedImage)];
                    }

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
