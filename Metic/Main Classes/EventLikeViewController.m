//
//  EventLikeViewController.m
//  WeShare
//
//  Created by 俊健 on 15/5/22.
//  Copyright (c) 2015年 WeShare. All rights reserved.
//

#import "EventLikeViewController.h"
#import "SlideNavigationController.h"

@interface EventLikeViewController ()<SlideNavigationControllerDelegate>
@property (nonatomic,strong) UIView* shadowView;
@end

@implementation EventLikeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    [self initData];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initUI
{
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"收藏活动";
    
    //初始化阴影页
    _shadowView = [[UIView alloc]initWithFrame:self.view.bounds];
    _shadowView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    _shadowView.tag = 101;
    _shadowView.backgroundColor = [UIColor blackColor];
    _shadowView.alpha = 0;
    [self.view addSubview:_shadowView];
}

- (void)initData
{
    
}


#pragma mark - SlideNavigationController Methods -

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
    return YES;
}

- (BOOL)slideNavigationControllerShouldDisplayRightMenu
{
    return NO;
}
-(void)sendDistance:(float)distance
{
    if (distance > 0) {
        self.shadowView.hidden = NO;
        //[self.view bringSubviewToFront:self.shadowView];
        [self.shadowView setAlpha:distance/400.0];
        //[((SlideNavigationController*)self.navigationController) setBarAlpha:distance/400.0];
        self.navigationController.navigationBar.alpha = 1 - distance/400.0;
    }else{
        //self.shadowView.hidden = YES;
        //[self.view sendSubviewToBack:self.shadowView];
    }
}
@end
