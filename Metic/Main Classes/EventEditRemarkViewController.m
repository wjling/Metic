//
//  EventEditRemarkViewController.m
//  WeShare
//
//  Created by 俊健 on 15/5/11.
//  Copyright (c) 2015年 WeShare. All rights reserved.
//

#import "EventEditRemarkViewController.h"
#import "CommonUtils.h"

@interface EventEditRemarkViewController ()

@end

@implementation EventEditRemarkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initUI
{
    [CommonUtils addLeftButton:self isFirstPage:NO];
    self.view.backgroundColor = [UIColor colorWithWhite:0.95f alpha:1.0f];
    self.title = @"修改活动描述";
    
}

@end
