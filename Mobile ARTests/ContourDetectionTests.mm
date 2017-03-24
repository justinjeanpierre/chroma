//
//  ContourDetectionTests.m
//  Mobile AR
//
//  Created by Justin Jean-Pierre on 2017-03-24.
//  Copyright © 2017 Jean-Pierre Digital. All rights reserved.
//


#import "kcftracker.hpp"

#import <XCTest/XCTest.h>
#import "CameraDelegate.h"

@interface ContourDetectionTests : XCTestCase

@property (nonatomic, strong) CameraDelegate *cameraDelegate;

@end

@implementation ContourDetectionTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testdetection {
    UIImage *testImage = [UIImage imageNamed:@"Harris_Detector_Original_Image"];
    cv::Mat &img = *new cv::Mat();
    UIImageToMat(testImage, img);

    _cameraDelegate = [[CameraDelegate alloc] init];
    _cameraDelegate.shouldDetectFeatures = YES;

    [_cameraDelegate detectContoursInImage:testImage];
}

@end
