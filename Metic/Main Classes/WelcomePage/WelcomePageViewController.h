//
//  WelcomePageViewController.h
//  Metic
//
//  Created by mac on 14-8-12.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WelcomePageViewController : UIViewController<UIScrollViewDelegate>
@property (strong, nonatomic) IBOutlet UIView *rootView;
@property (strong, nonatomic) IBOutlet UIScrollView *page_scrollview;
@property (strong, nonatomic) UIPageControl* pageControl;

@end
