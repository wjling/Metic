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
//#import "NSString+JSON.h"
#import "MenuViewController.h"
#import "MTUser.h"
#import "SRWebSocket.h"
#import "MySqlite.h"
#import "UMSocial.h"
#import <AVFoundation/AVFoundation.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate,SRWebSocketDelegate>
@property (strong, nonatomic) UIWindow *window;
@property (strong,nonatomic) SRWebSocket* mySocket;
@property (strong, nonatomic)NSTimer* heartBeatTimer;
@property (strong, nonatomic)MySqlite* sql;
@property (strong, nonatomic)NSMutableArray* syncMessages;
//@property (strong, nonatomic)NSOperationQueue* operationQueue;

- (void)connect;
- (void)scheduleHeartBeat;
- (void)unscheduleHeartBeat;
- (void)sendHeartBeatMessage;
- (void)disconnect;

- (void)insertNotificationsToDB;

@end
