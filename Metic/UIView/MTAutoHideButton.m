//
//  MTAutoHideButton.m
//  WeShare
//
//  Created by 俊健 on 15/3/22.
//  Copyright (c) 2015年 WeShare. All rights reserved.
//

#import "MTAutoHideButton.h"
#import "SlideNavigationController.h"
#import "CommonUtils.h"

NSString *const MTAutoHideButtonContentOffset = @"contentOffset";
@interface MTAutoHideButton ()
@property float contentOffsetY;

@end
@implementation MTAutoHideButton

#pragma mark - 初始化方法
- (instancetype)initWithScrollView:(UIScrollView *)scrollView
{
    if (self = [super init]) {
        self.scrollView = scrollView;
        [self initUI];
        [self initData];
    }
    return self;
}

-(void)initData
{
    _contentOffsetY = -10000;
    _hideState = MTHideStateAppear;
}

-(void)initUI
{
//    _add = [UIButton buttonWithType:UIButtonTypeCustom];
    [self setBackgroundImage:[CommonUtils createImageWithColor:[UIColor colorWithRed:85/255.0 green:203/255.0 blue:171/255.0 alpha:1.0]] forState:UIControlStateNormal];
    [self setBackgroundImage:[CommonUtils createImageWithColor:[UIColor colorWithRed:68/255.0 green:162/255.0 blue:137/255.0 alpha:1.0]] forState:UIControlStateHighlighted];
    
    UILabel* addLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    [addLabel setTag:12];
    [addLabel setBackgroundColor:[UIColor clearColor]];
    [addLabel setFont:[UIFont systemFontOfSize:50]];
    [addLabel setTextAlignment:NSTextAlignmentCenter];
    [addLabel setText:@"+"];
    [addLabel setTextColor:[UIColor whiteColor]];
    [self addSubview:addLabel];
    
    
    CGRect frame = [SlideNavigationController sharedInstance].view.window.frame;
    [self setFrame:CGRectMake(CGRectGetWidth(frame)*0.7, CGRectGetHeight(frame) - CGRectGetWidth(frame)*0.3 , CGRectGetWidth(frame)*0.2, CGRectGetWidth(frame)*0.2)];
    [[self viewWithTag:12] setFrame:CGRectMake(0, 0, CGRectGetWidth(frame)*0.2, CGRectGetWidth(frame)*0.17)];
    self.layer.cornerRadius = CGRectGetWidth(self.frame)/2;
    self.layer.masksToBounds = YES;
    
}

#pragma mark - UIScrollView相关
#pragma mark 设置UIScrollView
- (void)setScrollView:(UIScrollView *)scrollView
{
    // 移除之前的监听器
    [_scrollView removeObserver:self forKeyPath:MTAutoHideButtonContentOffset context:nil];
    // 监听contentOffset
    [scrollView addObserver:self forKeyPath:MTAutoHideButtonContentOffset options:NSKeyValueObservingOptionNew context:nil];
    
    // 设置scrollView
    _scrollView = scrollView;
}

- (void)appearBtn
{
    _hideState = MTHideStateAppearing;
    [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        CGRect frame = [SlideNavigationController sharedInstance].view.window.frame;
        [self setFrame:CGRectMake(CGRectGetWidth(frame)*0.7, CGRectGetHeight(frame) - CGRectGetWidth(frame)*0.3 , CGRectGetWidth(frame)*0.2, CGRectGetWidth(frame)*0.2)];
    } completion:^(BOOL finished) {
//        _hideState = MTHideStateAppear;
    }];
    
}

- (void)highBtn
{
    _hideState = MTHideStateDisappearing;
    [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        CGRect frame = [SlideNavigationController sharedInstance].view.window.frame;
        [self setFrame:CGRectMake(CGRectGetWidth(frame)*0.7, CGRectGetHeight(frame)*1.05 , CGRectGetWidth(frame)*0.2, CGRectGetWidth(frame)*0.2)];
    } completion:^(BOOL finished) {
//        _hideState = MTHideStateDisappear;
    }];
}

#pragma mark 监听UIScrollView的contentOffset属性
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    float new_contentOffsetY = _scrollView.contentOffset.y;
    if (new_contentOffsetY < 0 || new_contentOffsetY > _scrollView.contentSize.height - _scrollView.frame.size.height) {
        return;
    }
    
    if (_contentOffsetY == -10000) {
        _contentOffsetY = new_contentOffsetY;
        return;
    }

    
    if (new_contentOffsetY > _contentOffsetY) {
        [self highBtn];
    }else if(new_contentOffsetY < _contentOffsetY){
        [self appearBtn];
    }
    _contentOffsetY = new_contentOffsetY;
}

- (void)appear{
    [[SlideNavigationController sharedInstance].view.window addSubview:self];
}
- (void)disappear{
    [self removeFromSuperview];
}
- (void)free
{
    [self disappear];
    [_scrollView removeObserver:self forKeyPath:MTAutoHideButtonContentOffset];
}

@end
