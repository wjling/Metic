//
//  ReportViewController.m
//  WeShare
//
//  Created by ligang6 on 14-8-24.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "ReportViewController.h"
#import "MobClick.h"


@interface ReportViewController ()

@end

@implementation ReportViewController

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
    if (_event) {
        NSString* text = [NSString stringWithFormat:@"举报：%@ 活动\n",_event];
        [self.textView setText:text];
    }
    // Do any additional setup after loading the view from its nib.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [MobClick beginLogPageView:@"举报"];
    [self.titleTextField becomeFirstResponder];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [MobClick endLogPageView:@"举报"];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
