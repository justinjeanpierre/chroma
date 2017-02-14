//
//  roi.cpp
//  Mobile AR
//
//  Created by Justin Jean-Pierre on 2017-02-10.
//  Copyright © 2017 Jean-Pierre Digital. All rights reserved.
//

#include "roi.hpp"
#include <iostream>

void cv::ROISelector::mouseHandler(int event, int x, int y, int flags, void *param) {

}

void cv::ROISelector::opencv_mouse_callback( int event, int x, int y, int , void *param) {

}

cv::Rect2d cv::ROISelector::select(Mat img, bool fromCenter) {
    return Rect2d();
}

cv::Rect2d cv::ROISelector::select(const cv::String& windowName, Mat img, bool showCrosshair, bool fromCenter) {
    return Rect2d();
}

cv::Rect2d selectROI(cv::Mat img, bool fromCenter) {
    return cv::Rect2d();
}

cv::Rect2d selectROI(const cv::String& windowName, cv::Mat img, bool showCrosshair, bool fromCenter) {
    return cv::Rect2d();
}


void selectROI(const cv::String& windowName, cv::Mat img, std::vector<cv::Rect2d> & boundingBox, bool fromCenter) {

}
