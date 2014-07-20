//
//  ScaningViewController.h
//  Metic
//
//  Created by ligang6 on 14-7-19.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlideNavigationController.h"

@interface ScaningViewController : UIViewController<SlideNavigationControllerDelegate>
@property (strong, nonatomic) IBOutlet UIView *shadowView;

@end
