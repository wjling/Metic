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
#import "MySqlite.h"
#import "UMSocial.h"
#import <AVFoundation/AVFoundation.h>
#import "BMapKit.h"
#import "Reachability.h"
#import "WelcomePageViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import "Source/HttpServer/HTTPServer.h"

@class MenuViewController;
@class NotificationsViewController;
//推送消息的通知协议，收到任何消息之后的逻辑可以通过实现notificationDidReceive方法
//说明：
//参数：messages 一个消息数组，里面的每个消息是一个字典NSDictionary
/*
 每个message的格式：
 “timestamp": string
 "cmd": "message"
 "seq": int
 "msg": json(string),形如{"cmd": int, "event_id":int,...}，其中cmd可参考Return_Code部分
 */
//友盟统计 appkey
#define UMENG_APPKEY @"53f2af05fd98c59abf001eb8"
@protocol NotificationDelegate

@optional
-(void) notificationDidReceive:(NSArray*) messages;

@end


@interface AppDelegate : UIResponder <UIApplicationDelegate,SRWebSocketDelegate,BMKGeneralDelegate>
{
    HTTPServer *httpServer;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong,nonatomic) SRWebSocket* mySocket;
@property (strong, nonatomic) Reachability* hostReach;
@property (strong, nonatomic)NSTimer* heartBeatTimer;
@property (strong, nonatomic)MySqlite* sql;
@property (strong, atomic)NSMutableArray* syncMessages;
@property (strong, nonatomic) id<NotificationDelegate> notificationDelegate;
@property (strong, nonatomic) BMKMapManager* mapManager;
@property (strong, nonatomic) UIViewController* homeViewController;
@property (strong, nonatomic) UIView* networkStatusNotifier_view;
@property (strong, nonatomic) MenuViewController* leftMenu;
//@property (strong, nonatomic)NSOperationQueue* operationQueue;
@property (nonatomic) BOOL isNetworkConnected;
@property (nonatomic) BOOL isLogined;

-(void)initViews;
-(void)initApp;
+(void)refreshMenu;

//信鸽推送相关
-(void)registerPush;
-(void)handlePushMessage:(NSDictionary*)message;

+(BOOL)isEnableWIFI;
+(BOOL)isEnableGPRS;

- (void)connect;
- (void)scheduleHeartBeat;
- (void)unscheduleHeartBeat;
- (void)sendHeartBeatMessage;
- (void)disconnect;

//- (void)handleReceivedNotifications;
- (void)saveMarkers:(NSMutableArray *)markers toFilePath:(NSString *)filePath;
- (void)sendMessageArrivedNotification:(NSString*)text andNumber:(int)num withType:(int)type;


@end
