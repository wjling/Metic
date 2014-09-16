//
//  EventSquareViewController.h
//  WeShare
//
//  Created by ligang6 on 14-9-13.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonUtils.h"
#import "../Source/SlideNavigationController.h"

@interface EventSquareViewController : UIViewController<SlideNavigationControllerDelegate,UIScrollViewDelegate>
@property (strong, nonatomic) UIView *shadowView;
@end
