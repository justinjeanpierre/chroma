//
//  ViewController.m
//  Mobile AR
//
//  Created by Justin Jean-Pierre on 2017-02-19.
//  Copyright © 2017 Jean-Pierre Digital. All rights reserved.
//

#import "ViewController.h"
#import "FileBrowser-swift.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setTitle:@"Mobile AR"];
}

-(IBAction)didPressShowFilesButton:(UIButton *) sender {
    [self presentViewController:[[FileBrowser alloc] init] animated:NO completion:^{}];
}

@end
