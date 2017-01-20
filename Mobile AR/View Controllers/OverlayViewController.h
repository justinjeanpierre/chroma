//
//  OverlayViewController.h
//  Mobile AR
//
//  Created by Justin Jean-Pierre on 2017-01-12.
//  Copyright © 2017 Jean-Pierre Digital. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "BoxView.h"

@interface OverlayViewController : UIViewController <AVCaptureFileOutputRecordingDelegate>

@property (nonatomic, retain) BoxView *glView;
@property (nonatomic, retain) IBOutlet UIButton *perspectiveButton;

@end
