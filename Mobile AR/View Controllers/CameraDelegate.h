//
//  CameraDelegate.h
//  Mobile AR
//
//  Created by Justin Jean-Pierre on 2017-03-15.
//  Copyright © 2017 Jean-Pierre Digital. All rights reserved.
//

#import <opencv2/opencv.hpp>
#import <opencv2/videoio/cap_ios.h>
#import <opencv2/core/utility.hpp>
#import <opencv2/tracking.hpp>
#import <opencv2/videoio.hpp>
#import <opencv2/highgui.hpp>
#import <opencv2/imgcodecs/ios.h>
#import <iostream>
#import <cstring>
#import <Foundation/Foundation.h>

#import "Protocols.h"

@interface CameraDelegate : NSObject <CvVideoCameraDelegate>
@property (nonatomic, strong) NSObject <DisplayTargetProtocol>* displayTarget;
-(void)toggleTracking;
-(void)toggleColorInversion;
-(void)toggleFeatureDetection;
-(void)updateRegionOfInterest:(cv::Rect)newROI;

@end
