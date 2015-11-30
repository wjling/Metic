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
//#import "MenuViewController.h"
#import "MTUser.h"
#import "SRWebSocket.h"

#import "UMSocial.h"
#import <AVFoundation/AVFoundation.h>
#import "BMapKit.h"
#import "Reachability.h"
#import "WelcomePageViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import "Source/HttpServer/HTTPServer.h"

@class MenuViewController;
@class NotificationsViewController;
//友盟统计 appkey
#define UMENG_APPKEY @"53f2af05fd98c59abf001eb8"

@interface AppDelegate : UIResponder <UIApplicationDelegate,SRWebSocketDelegate,BMKGeneralDelegate>
{
    HTTPServer *httpServer;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong,nonatomic) SRWebSocket* mySocket;
@property (strong, nonatomic) Reachability* hostReach;
@property (strong, nonatomic)NSTimer* heartBeatTimer;
@property (strong, atomic)NSMutableArray* syncMessages;
@property (strong, nonatomic) BMKMapManager* mapManager;
@property (strong, nonatomic) UIViewController* homeViewController;
@property (strong, nonatomic) UIView* networkStatusNotifier_view;
@property (strong, nonatomic) MenuViewController* leftMenu;
//@property (strong, nonatomic)NSOperationQueue* operationQueue;
@property (nonatomic) BOOL isNetworkConnected;
@property (nonatomic) BOOL isLogined;
@property (nonatomic) BOOL isInBackground;
-(void)initViews;
-(void)initApp;
+(void)refreshMenu;

+(BOOL)isEnableWIFI;
+(BOOL)isEnableGPRS;

- (void)connect;
- (void)scheduleHeartBeat;
- (void)unscheduleHeartBeat;
- (void)sendHeartBeatMessage;
- (void)disconnect;

- (void)saveMarkers:(NSMutableArray *)markers toFilePath:(NSString *)filePath;
- (void)sendMessageArrivedNotification:(NSString*)text andNumber:(int)num withType:(int)type;


@end
