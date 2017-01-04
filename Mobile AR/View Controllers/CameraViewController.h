//
//  CameraViewController.h
//  Mobile AR
//
//  Created by Justin Jean-Pierre on 2017-01-04.
//  Copyright © 2017 Jean-Pierre Digital. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <opencv2/opencv.hpp>
#import <opencv2/videoio/cap_ios.h>

@interface CameraViewController : UIViewController <CvVideoCameraDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *cameraView;

- (IBAction)invertColors:(UIButton *)button;
- (IBAction)detectFeatures:(UIButton *)button;

@end
