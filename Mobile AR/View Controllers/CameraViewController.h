//
//  CameraViewController.h
//  Mobile AR
//
//  Created by Justin Jean-Pierre on 2017-01-04.
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
#import <UIKit/UIKit.h>
#import "BoxView.h"
#import "CameraDelegate.h"

@interface CameraViewController : UIViewController <DisplayTargetProtocol>

@property (weak, nonatomic) IBOutlet UIImageView *cameraView;
@property (nonatomic, retain) BoxView *boxView;
@property (nonatomic, retain) IBOutlet UIButton *perspectiveButton;
@property (nonatomic, retain) IBOutlet UIButton *toggleTrackingButton;
@property (nonatomic, weak) IBOutlet UIButton *textureMenuButton;

-(IBAction)invertColors:(UIButton *)sender;
-(IBAction)detectFeatures:(UIButton *)sender;
-(IBAction)toggleCubeVisibility:(UIButton *)sender;
-(IBAction)toggleCubePerpective:(UIButton *)sender;

// <DisplayTargetProtocol> methods
-(void)updatePreviewWithImage:(UIImage *)img;
-(void)updateTrackerBoundingBoxWithRect:(CGRect)newBoundingBox;
-(void)updateContourBoundingBoxWithRect:(CGRect)newBoundingBox;

@end
