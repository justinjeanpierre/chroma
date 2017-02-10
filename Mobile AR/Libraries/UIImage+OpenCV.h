//
//  UIImage+OpenCV.h
//  Mobile AR
//
//  Created by Justin Jean-Pierre on 2017-02-09.
//  Copyright © 2017 Jean-Pierre Digital. All rights reserved.
//
//	based on http://stackoverflow.com/questions/8563356/nsimage-to-cvmat-and-vice-versa#20643074

#include <opencv2/opencv.hpp>
#import <UIKit/UIKit.h>

@interface UIImage (UIImage_OpenCV) {

}

+(UIImage *)imageWithCVMat:(const cv::Mat&)cvMat;
-(id)initWithCVMat:(const cv::Mat&)cvMat;

@property(nonatomic, readonly) cv::Mat CVMat;
@property(nonatomic, readonly) cv::Mat CVGrayscaleMat;

@end