//
//  MTMPMoviePlayerViewController.m
//  WeShare
//
//  Created by ligang6 on 14-9-30.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "MTMPMoviePlayerViewController.h"
#import "SlideNavigationController.h"

@interface MTMPMoviePlayerViewController ()

@end

@implementation MTMPMoviePlayerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[SlideNavigationController sharedInstance] setEffection:NO];

    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[SlideNavigationController sharedInstance] setEffection:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
