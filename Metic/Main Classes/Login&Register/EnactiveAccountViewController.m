//
//  EnactiveAccountViewController.m
//  WeShare
//
//  Created by 俊健 on 15/12/5.
//  Copyright (c) 2015年 WeShare. All rights reserved.
//

#import "EnactiveAccountViewController.h"
#import "CommonUtils.h"

@interface EnactiveAccountViewController ()

@end

@implementation EnactiveAccountViewController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI
-(void)setupUI
{
    self.title = @"激活账号";
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [CommonUtils addLeftButton:self isFirstPage:NO];
}

@end
