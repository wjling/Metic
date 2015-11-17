//
//  MTAutoHideButton.h
//  WeShare
//
//  Created by 俊健 on 15/3/22.
//  Copyright (c) 2015年 WeShare. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    MTHideStateAppear = 1,
    MTHideStateDisappear = 2,
    MTHideStateAppearing = 3,
    MTHideStateDisappearing = 4
} MTHideState;

@interface MTAutoHideButton : UIButton{
    __weak UIScrollView *_scrollView;
}
@property (nonatomic, weak) UIScrollView *scrollView;
@property MTHideState hideState;
// 构造方法
- (instancetype)initWithScrollView:(UIScrollView *)scrollView;
// 结束使用、释放资源
- (void)appear;
- (void)disappear;
- (void)free;


@end
