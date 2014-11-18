//
//  WelcomePageViewController.h
//  Metic
//
//  Created by mac on 14-8-12.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonUtils.h"

@class AppDelegate;
@class LoginViewController;

@interface WelcomePageViewController : UIViewController<UIScrollViewDelegate>
@property (strong, nonatomic) IBOutlet UIScrollView *page_scrollview;
@property (strong, nonatomic) UIPageControl* pageControl;
@property (strong, nonatomic) UIView* page1;
@property (strong, nonatomic) UIView* page2;
@property (strong, nonatomic) UIView* page3;
@property (strong, nonatomic) UIView* page4;
@property (strong, nonatomic) UIView* scrollContentView;

@end
