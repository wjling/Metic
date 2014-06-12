//
//  AppDelegate.h
//  Metic
//
//  Created by ligang_mac4 on 14-5-26.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlideNavigationController.h"
#import "CommonUtils.h"
#import "MenuViewController.h"
#import "MTUser.h"
#import "SRWebSocket.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate,SRWebSocketDelegate>
@property (strong, nonatomic) UIWindow *window;
@property (strong,nonatomic) SRWebSocket* mySocket;

- (void)connect;

@end
