//
//  MTShowTextViewController.m
//  WeShare
//
//  Created by 俊健 on 15/6/4.
//  Copyright (c) 2015年 WeShare. All rights reserved.
//

#import "MTShowTextViewController.h"
#import "CommonUtils.h"

static const NSUInteger fontSize = 22;

@interface MTShowTextViewController ()
@property(nonatomic,strong) UIScrollView* scrollView;
@property(nonatomic,strong) UILabel* label;
@end

@implementation MTShowTextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    [self initData];
    [self playAnimation];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)show
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self.view];
    [window.rootViewController addChildViewController:self];
}

- (void)initUI
{
    self.view.backgroundColor = [UIColor whiteColor];
    CGRect frame = self.view.frame;
    _scrollView = [[UIScrollView alloc]initWithFrame:frame];
    _scrollView.backgroundColor = [UIColor whiteColor];
    _scrollView.scrollEnabled = YES;
    _scrollView.showsVerticalScrollIndicator = YES;
    [self.view addSubview:_scrollView];
    
    float height = [CommonUtils calculateTextHeight:_content width:CGRectGetWidth(frame)-40 fontSize:fontSize isEmotion:NO];
    if (height < CGRectGetHeight(frame) - 20) {
        if (height < CGRectGetHeight(frame) - 150) {
            height = CGRectGetHeight(frame) - 150;
        }else height = CGRectGetHeight(frame) - 20;
    }
    
    _label = [[UILabel alloc]initWithFrame:CGRectMake(20, 40, CGRectGetWidth(frame)-40, height)];
    _label.userInteractionEnabled = YES;
    _label.font = [UIFont systemFontOfSize:fontSize];
    _label.textColor = [UIColor colorWithWhite:0.1 alpha:1.0f];
    _label.textAlignment = NSTextAlignmentCenter;
    _label.numberOfLines = 0;
    _label.text = _content;
    [_scrollView addSubview:_label];
    [_scrollView setContentSize:CGSizeMake(CGRectGetWidth(frame), height + 60)];
    
    UIView* shadow = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), 40)];
    CAGradientLayer* gradientLayer = [CAGradientLayer layer];  // 设置渐变效果
    gradientLayer.bounds = CGRectMake(0, 0, CGRectGetWidth(frame), 40);
    gradientLayer.frame = CGRectMake(0, 0, CGRectGetWidth(frame), 40);
    gradientLayer.colors = [NSArray arrayWithObjects:
                             (id)[[UIColor colorWithWhite:1.0f alpha:1.0f] CGColor],
                            (id)[[UIColor colorWithWhite:1.0f alpha:1.0f] CGColor],
                             (id)[[UIColor colorWithWhite:1.0f alpha:0.0f] CGColor], nil];
//    gradientLayer.startPoint = CGPointMake(0.5, 0.5);
//    gradientLayer.endPoint = CGPointMake(0.5, 1.0);
    [shadow.layer insertSublayer:gradientLayer atIndex:0];
    [self.view addSubview:shadow];
    
}

-(void)initData
{
    //点击退出MTShowTextViewController
    UITapGestureRecognizer * tapRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissDetail)];
    [_label addGestureRecognizer:tapRecognizer];
}

-(void)playAnimation
{
    self.view.alpha = 0.0f;
    [UIView animateWithDuration:0.4f animations:^{
        self.view.alpha = 1.0f;
    }];
}

-(void)dismissDetail
{
    [UIView animateWithDuration:0.5f animations:^{
        self.view.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
    }];
    
}
@end
