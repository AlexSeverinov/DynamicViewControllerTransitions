//
//  CCRReplacebleViewController.m
//  DynamicViewControllerTransitions
//
//  Created by admin on 03/11/14.
//  Copyright (c) 2014 corsarus. All rights reserved.
//

#import "CCRReplaceableViewController.h"

@implementation CCRReplaceableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.userInteractionEnabled = NO;
    
    self.controllerPositionTitle = [[UILabel alloc] init];
    self.controllerPositionTitle.translatesAutoresizingMaskIntoConstraints= NO;
    [self.view addSubview:self.controllerPositionTitle];
    
    // Place the label at the bottom of the main view in a centered position 
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.controllerPositionTitle
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0
                                                           constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.controllerPositionTitle
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1.0
                                                           constant:CGRectGetMidY(self.view.bounds) - 64.0]];
}

@end
