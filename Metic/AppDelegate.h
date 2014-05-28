//
//  AppDelegate.h
//  Metic
//
//  Created by ligang_mac4 on 14-5-26.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlideNavigationController.h"
#import "MenuViewController.h"
#import "MTUser.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    MTUser *user;
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) MTUser *user;


@end
