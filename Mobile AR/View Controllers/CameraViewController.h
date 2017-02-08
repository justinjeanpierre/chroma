//
//  CameraViewController.h
//  Mobile AR
//
//  Created by Justin Jean-Pierre on 2017-01-04.
//  Copyright © 2017 Jean-Pierre Digital. All rights reserved.
//

#include <opencv2/opencv.hpp>
#include <opencv2/videoio/cap_ios.h>
#include <opencv2/core/utility.hpp>
#include <opencv2/tracking.hpp>
#include <opencv2/videoio.hpp>
#include <opencv2/highgui.hpp>
#include <iostream>
#include <cstring>
#import <UIKit/UIKit.h>
#import "BoxView.h"


@interface CameraViewController : UIViewController <CvVideoCameraDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *cameraView;
@property (nonatomic, retain) BoxView *glView;
@property (nonatomic, retain) IBOutlet UIButton *perspectiveButton;

-(IBAction)invertColors:(UIButton *)sender;
-(IBAction)detectFeatures:(UIButton *)sender;
-(IBAction)toggleCubeVisibility:(UIButton *)sender;
-(IBAction)toggleCubePerpective:(UIButton *)sender;

@end
