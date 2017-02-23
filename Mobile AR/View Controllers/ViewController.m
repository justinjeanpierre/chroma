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

    if (self.navigationItem.rightBarButtonItem != nil) {
        [self.navigationItem.rightBarButtonItem setTarget:self];
        [self.navigationItem.rightBarButtonItem setAction:@selector(didPressShowFilesButton:)];
    }
}

-(IBAction)didPressShowFilesButton:(UIButton *) sender {
    [self presentViewController:[[FileBrowser alloc] init] animated:NO completion:^{}];
}

@end
