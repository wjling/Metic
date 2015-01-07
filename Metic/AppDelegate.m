//
//  AppDelegate.m
//  Metic
//
//  Created by ligang_mac4 on 14-5-26.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "AppDelegate.h"
#import "UMSocialWechatHandler.h"
#import "UMSocialSinaHandler.h"
#import "Source/security/SFHFKeychainUtils.h"
#import "Main Classes/MTMPMoviePlayerViewController.h"
#import "Main Classes/MTUser.h"
#import "MobClick.h"
#import "HttpSender.h"
#import "MenuViewController.h"
#import "NotificationsViewController.h"
#import "HomeViewController.h"
#import "XGPush.h"
#import "XGSetting.h"

#define _IPHONE80_ 80000

@implementation AppDelegate
{
    BOOL isConnected;
    int numOfSyncMessages;
    dispatch_queue_t sync_queue;
    BOOL isInBackground;
//    NSString* DB_path;
}
@synthesize mySocket;
@synthesize hostReach;
@synthesize heartBeatTimer;
@synthesize syncMessages;
@synthesize sql;
@synthesize notificationDelegate;
@synthesize networkStatusNotifier_view;
@synthesize isNetworkConnected;
@synthesize isLogined;
@synthesize leftMenu;
//@synthesize operationQueue;

//@synthesize user;
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSLog(@"app did finish launch===============");
    sync_queue = dispatch_queue_create("msg_syncueue", NULL);
    [self umengTrack];
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone"
															 bundle: nil];
	
//	MenuViewController *rightMenu = (MenuViewController*)[mainStoryboard
//                                                          instantiateViewControllerWithIdentifier: @"MenuViewController"];
//	//rightMenu.view.backgroundColor = [UIColor yellowColor];
//	rightMenu.cellIdentifier = @"rightMenuCell";
    
    NSUserDefaults* userDf = [NSUserDefaults standardUserDefaults];
    if (![userDf boolForKey:@"everLaunched"]) {
        [userDf setBool:YES forKey:@"everLaunched"];
        [userDf setBool:YES forKey:@"firstLaunched"];
        NSLog(@"The first launch");
        [userDf synchronize];
    }
    else
    {
        NSLog(@"Not the first launch");
        [userDf setBool:NO forKey:@"firstLaunched"];
        [userDf synchronize];
    }
	
	leftMenu = (MenuViewController*)[mainStoryboard
                                                         instantiateViewControllerWithIdentifier: @"MenuViewController"];
	leftMenu.cellIdentifier = @"leftMenuCell";

//	[SlideNavigationController sharedInstance].righMenu = rightMenu;
	[SlideNavigationController sharedInstance].leftMenu = leftMenu;
//    [leftMenu tableView:leftMenu.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:0]];
    [self initApp];
    self.sql = [[MySqlite alloc]init];
    self.syncMessages = [[NSMutableArray alloc]init];
    numOfSyncMessages = -1;
    isNetworkConnected = YES;
    isInBackground = NO;
    isLogined = NO;
    [self initViews];
//    [self initApp];
    
    _mapManager = [[BMKMapManager alloc]init];
    BOOL ret = [_mapManager start:@"oHzEkwMGSfXfqGcBF0B0vWK5" generalDelegate:nil];
	if (!ret) {
		NSLog(@"manager start failed!");
	}
    [UMSocialData setAppKey:@"53bb542e56240ba6e80a4bfb"];
    [UMSocialWechatHandler setWXAppId:@"wx4ec735a39c7a60f9" url:@"http://www.whatsact.com"];
    [UMSocialSinaHandler openSSOWithRedirectURL:@"http://www.whatsact.com"];
//    DB_path = [NSString stringWithFormat:@"%@/db",[MTUser sharedInstance].userid];
   
    //running in background
//    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
//    NSError *setCategoryErr = nil;
//    NSError *activationErr  = nil;
//    [[AVAudioSession sharedInstance]
//     setCategory: AVAudioSessionCategoryPlayback
//     error: &setCategoryErr];
//    [[AVAudioSession sharedInstance]
//     setActive: YES
//     error: &activationErr];
    
    // 监测网络情况
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name: kReachabilityChangedNotification
                                               object: nil];
    hostReach = [Reachability reachabilityWithHostName:@"www.baidu.com"];
    [hostReach startNotifier];
    
    //开启本地视频服务
    [self initLocalVideoServer];
    
//    application.applicationIconBadgeNumber = 0;
    
    //判断是否由远程消息通知触发应用程序启动
//    if ([launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey] != nil) {
//        //获取应用程序消息通知标记数
//        int badge = [UIApplication sharedApplication].applicationIconBadgeNumber;
//        if (badge > 0) {
//            badge--;
//            [UIApplication sharedApplication].applicationIconBadgeNumber = badge;
//        }
//        
//    }
//    
//    //消息推送注册
//    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
//     UIRemoteNotificationTypeSound |
//     UIRemoteNotificationTypeAlert |
//     UIRemoteNotificationTypeBadge];
    
    /* 信鸽推送 */
    
    [XGPush startApp:2200076416 appKey:@"ISVQ96G3S43K"];
    
    //推送反馈回调版本示例
    void (^successBlock)(void) = ^(void){
        //成功之后的处理
        NSLog(@"[XGPush]handleLaunching's successBlock");
    };
    
    void (^errorBlock)(void) = ^(void){
        //失败之后的处理
        NSLog(@"[XGPush]handleLaunching's errorBlock");
    };
    
    [XGPush handleLaunching:launchOptions successCallback:successBlock errorCallback:errorBlock];
    return YES;

}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
//     [[UIApplication sharedApplication] setKeepAliveTimeout:600 handler:^{
//         /*todo send keep live */
//         NSLog(@"alive in background");
//         [NSThread sleepForTimeInterval:10];
//     }];
     NSLog(@"app did enter Background====================");
    isInBackground = YES;
    application.applicationIconBadgeNumber = 0;
    
    UIApplication*   app = [UIApplication sharedApplication];
    __block    UIBackgroundTaskIdentifier bgTask;
    bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (bgTask != UIBackgroundTaskInvalid)
            {
                bgTask = UIBackgroundTaskInvalid;
            }
        });
    }];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (bgTask != UIBackgroundTaskInvalid)
            {
                bgTask = UIBackgroundTaskInvalid;
            }
        });
    });
    
    //预先保存mtuser内容
    NSString *userStatus = [[NSUserDefaults standardUserDefaults] objectForKey:@"MeticStatus"];
    if ([userStatus isEqualToString:@"in"]) {
        NSString* MtuserPath= [NSString stringWithFormat:@"%@/Documents/MTuser.txt", NSHomeDirectory()];
        if ([MTUser sharedInstance].name) {
            [self saveMarkers:[[NSMutableArray alloc] initWithObjects:[MTUser sharedInstance],nil] toFilePath:MtuserPath];
        }
    }
   
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [[UIApplication sharedApplication] clearKeepAliveTimeout];
    NSLog(@"app will enter foreground==================");
    application.applicationIconBadgeNumber = 0;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Playfrompause"
                                                        object:nil
                                                      userInfo:nil];
    isInBackground = NO;
    
    //同步推送消息
    NSLog(@"开始同步消息");
    void(^synchronizeDone)(NSNumber*, NSNumber*) = ^(NSNumber* min_seq, NSNumber* max_seq)
    {
        if (!min_seq || !max_seq) {
            return;
        }
        [self pullAndHandlePushMessageWithMinSeq:min_seq andMaxSeq:max_seq andCallBackBlock:nil];
    };
    [self synchronizePushSeqAndCallBack:synchronizeDone];

}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    application.applicationIconBadgeNumber = 0;
    NSLog(@"app did become active===================");
    isInBackground = NO;
    
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    //点击提示框的打开
    NSLog(@"点击通知");
    application.applicationIconBadgeNumber = 0;
    isInBackground = NO;
    
//    NSString* key = [NSString stringWithFormat:@"USER%@", [MTUser sharedInstance].userid];
//    NSUserDefaults* userDf = [NSUserDefaults standardUserDefaults];
//    NSMutableDictionary* userSettings = [NSMutableDictionary dictionaryWithDictionary:[userDf objectForKey:key]];
//    BOOL openNC = [[userSettings valueForKey:@"openWithNotificationCenter"]boolValue];
//    [userSettings setValue:[NSNumber numberWithBool:NO] forKey:@"openWithNotificationCenter"];
//    [userDf setObject:userSettings forKey:key];
//    [userDf synchronize];
//    if (openNC) {
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [self.leftMenu showNotificationCenter];
//        });
//        [self.leftMenu showNotificationCenter];
//        
//    }

}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    void (^successBlock)(void) = ^(void){
        //成功之后的处理
        NSLog(@"[XGPush]unRegisterDevice successBlock");
    };
    
    void (^errorBlock)(void) = ^(void){
        //失败之后的处理
        NSLog(@"[XGPush]unRegisterDevice errorBlock");
    };

    [XGPush unRegisterDevice:successBlock errorCallback:errorBlock];
    NSLog(@"Metic被残忍杀死了");
    NSString *userStatus = [[NSUserDefaults standardUserDefaults] objectForKey:@"MeticStatus"];
    if ([userStatus isEqualToString:@"in"]) {
        NSString* MtuserPath= [NSString stringWithFormat:@"%@/Documents/MTuser.txt", NSHomeDirectory()];
        if ([MTUser sharedInstance].name) {
            [self saveMarkers:[[NSMutableArray alloc] initWithObjects:[MTUser sharedInstance],nil] toFilePath:MtuserPath];
        }
    }
    
    
}

-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString * deviceTokenStr = [XGPush registerDevice: deviceToken];
    
    //打印获取的deviceToken的字符串
    NSLog(@"deviceTokenStr is %@",deviceTokenStr);
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSString *error_str = [NSString stringWithFormat:@"%@",error];
    NSLog(@"Failed to get token, error: %@",error_str);
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    //在此处理接受到的消息
    NSLog(@"APP receive remote userInfo: %@", userInfo);
    [XGPush handleReceiveNotification:userInfo];
//    NSString* message = [[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
//    NSMutableDictionary* message_dic = [CommonUtils NSDictionaryWithNSString:message];
    
    NSNumber* seq = [userInfo objectForKey:@"seq"];
    void(^getPushMessageDone)(NSDictionary*) = ^(NSDictionary* response)
    {
        
    };
    
    [self pullAndHandlePushMessageWithMinSeq:seq andMaxSeq:seq andCallBackBlock:getPushMessageDone];
}

-(void)initApp
{
    NSString *userStatus = [[NSUserDefaults standardUserDefaults] objectForKey:@"MeticStatus"];
    if ([userStatus isEqualToString:@"in"]) {
        NSString* MtuserPath= [NSString stringWithFormat:@"%@/Documents/MTuser.txt", NSHomeDirectory()];
        NSArray* users = [NSKeyedUnarchiver unarchiveObjectWithFile:MtuserPath];
        if (!users || users.count == 0) {
            [[NSUserDefaults standardUserDefaults] setObject:@"out" forKey:@"MeticStatus"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [[MTUser alloc]init];
        }
    }else{
        [[MTUser alloc]init];
    }

}

+(void)refreshMenu
{
    [(MenuViewController*)[SlideNavigationController sharedInstance].leftMenu refresh];
//    [(MenuViewController*)[SlideNavigationController sharedInstance].leftMenu clearVC];

}

#pragma mark - XinGe Push

- (void)registerPush{
    NSLog(@"XG register");
    
    void (^successCallback)(void) = ^(void){
        //如果变成需要注册状态
        if(![XGPush isUnRegisterStatus])
        {
            //iOS8注册push方法
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= _IPHONE80_
            
            float sysVer = [[[UIDevice currentDevice] systemVersion] floatValue];
            if(sysVer < 8){
                [self registerPushBelowiOS8];
            }
            else{
                [self registerPushForIOS8];
            }
#else
            //iOS8之前注册push方法
            //注册Push服务，注册后才能收到推送
            [self registerPushBelowiOS8];
#endif
            
        }
    };
    [XGPush initForReregister:successCallback];
    
}

-(void)registerPushBelowiOS8
{
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];

}

- (void)registerPushForIOS8{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= _IPHONE80_
    NSLog(@"register Push for iOS8 begin");
    //Types
    UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    
    //Actions
    UIMutableUserNotificationAction *acceptAction = [[UIMutableUserNotificationAction alloc] init];
    
    acceptAction.identifier = @"ACCEPT_IDENTIFIER";
    acceptAction.title = @"Accept";
    
    acceptAction.activationMode = UIUserNotificationActivationModeForeground;
    acceptAction.destructive = NO;
    acceptAction.authenticationRequired = NO;
    
    //Categories
    UIMutableUserNotificationCategory *inviteCategory = [[UIMutableUserNotificationCategory alloc] init];
    
    inviteCategory.identifier = @"INVITE_CATEGORY";
    
    [inviteCategory setActions:@[acceptAction] forContext:UIUserNotificationActionContextDefault];
    
    [inviteCategory setActions:@[acceptAction] forContext:UIUserNotificationActionContextMinimal];
    
    NSSet *categories = [NSSet setWithObjects:inviteCategory, nil];
    
    
    UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes:types categories:categories];
    
    [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
    
    
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    NSLog(@"register Push for iOS8 end");
#endif
}

-(void)handlePushMessage:(NSDictionary*)message andFeedBack:(BOOL)feedback
{
    NSNumber* seq = [message objectForKey:@"seq"];
    NSString* content_str = [message objectForKey:@"content"];
    NSDictionary* content_dic = [CommonUtils NSDictionaryWithNSString:content_str];
    NSMutableDictionary* msg_dic = [[NSMutableDictionary alloc]initWithDictionary:content_dic];
    [msg_dic setValue:[NSNumber numberWithInteger:-1] forKeyPath:@"ishandled"];
    [msg_dic setValue:seq forKey:@"seq"];
    NSInteger msg_cmd = [[msg_dic objectForKey:@"cmd"] integerValue];
    
    int type = -1;

    if (msg_cmd  == ADD_FRIEND_RESULT) //cmd 998
    {
        [[MTUser sharedInstance].friendRequestMsg insertObject:msg_dic atIndex:0];
        
        [[MTUser sharedInstance] synchronizeFriends];
        NSNumber* result = [msg_dic objectForKey:@"result"];
        NSLog(@"friend request result: %@",result);
        if ([result integerValue] == 1) {
            NSString* name = [msg_dic objectForKey:@"name"];
            NSString* email = [msg_dic objectForKey:@"email"];
            NSNumber* fid = [msg_dic objectForKey:@"id"];
            NSNumber* gender = [msg_dic objectForKey:@"gender"];
            NSString* path = [NSString stringWithFormat:@"%@/db",[MTUser sharedInstance].userid];
            [sql openMyDB:path];
            [sql insertToTable:@"friend"
                   withColumns:[[NSArray alloc]initWithObjects:@"id",@"name",@"email",@"gender", nil]
                     andValues:[[NSArray alloc] initWithObjects:
                                [NSString stringWithFormat:@"%@",fid],
                                [NSString stringWithFormat:@"'%@'",name],
                                [NSString stringWithFormat:@"'%@'",email],
                                [NSString stringWithFormat:@"%@",gender], nil]];
            [sql closeMyDB];
            //                [MTUser sharedInstance].friendList = [[MTUser sharedInstance] getFriendsFromDB];
            NSDictionary* newFriend = [CommonUtils packParamsInDictionary:fid,@"id",name,@"name",gender,@"gender",email,@"email",nil];
            [[MTUser sharedInstance].friendList addObject:newFriend];
            [[MTUser sharedInstance] friendListDidChanged];
        }
        else if ([result integerValue] == 0)
        {
            NSLog(@"friend request is refused");
        }
        
        type = 1;
        
    }
    else if (msg_cmd == 993 || msg_cmd == 992 || msg_cmd == 991) {
        if (![[MTUser sharedInstance].updateEventIds containsObject:[msg_dic valueForKey:@"event_id"]]) {
            [[MTUser sharedInstance].updateEventIds addObject:[msg_dic valueForKey:@"event_id"]];
            [[MTUser sharedInstance].updateEvents addObject:msg_dic];
            NSLog(@"新动态+1, updateEvents: %@",[MTUser sharedInstance].updateEvents);
        }
        type = -1;
        NSLog(@"新动态数量：%d",[MTUser sharedInstance].updateEventIds.count);
    }
    else if (msg_cmd == 988 || msg_cmd == 989) {
        [[MTUser sharedInstance].atMeEvents addObject:msg_dic];
        type = -1;
        NSLog(@"有人@你： %@",msg_dic);
    }
    else if (msg_cmd == 985) //活动被解散
    {
        [[MTUser sharedInstance].systemMsg insertObject:msg_dic atIndex:0];
//        NSString* subject = [msg_dic objectForKey:@"subject"];
        type = 2;
        
        NSString * path = [NSString stringWithFormat:@"%@/db",[MTUser sharedInstance].userid];
        [sql openMyDB:path];
        NSNumber* event_id1 = [msg_dic objectForKey:@"event_id"];
        NSDictionary *wheres = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%@",event_id1],@"event_id", nil];
        [sql deleteTurpleFromTable:@"event" withWhere:wheres];
        [sql closeMyDB];
        
        for (HomeViewController* vc in [SlideNavigationController sharedInstance].viewControllers) {
            if ([vc isKindOfClass:[HomeViewController class]]) {
                for (int i = 0; i < vc.events.count; i++) {
                    NSMutableDictionary* event = vc.events[i];
                    NSNumber* event_id2 = [event objectForKey:@"event_id"];
                    if ([event_id1 integerValue] == [event_id2 integerValue]) {
                        [vc.events removeObject:event];
                        [vc.tableView reloadData];
                        break;
                    }
                }
                [vc.eventIds_all removeObject:event_id1];
                break;
            }
        }
        
    }
    else if (msg_cmd == 984) //被踢出活动
    {
        [[MTUser sharedInstance].systemMsg insertObject:msg_dic atIndex:0];
//        NSString* subject = [msg_dic objectForKey:@"subject"];
        type = 2;
        
        NSString * path = [NSString stringWithFormat:@"%@/db",[MTUser sharedInstance].userid];
        [sql openMyDB:path];
        NSNumber* event_id1 = [msg_dic objectForKey:@"event_id"];
        NSDictionary *wheres = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%@",event_id1],@"event_id", nil];
        [sql deleteTurpleFromTable:@"event" withWhere:wheres];
        [sql closeMyDB];
        
        for (HomeViewController* vc in [SlideNavigationController sharedInstance].viewControllers) {
            if ([vc isKindOfClass:[HomeViewController class]]) {
                for (int i = 0; i < vc.events.count; i++) {
                    NSMutableDictionary* event = vc.events[i];
                    NSNumber* event_id2 = [event objectForKey:@"event_id"];
                    if ([event_id1 integerValue] == [event_id2 integerValue]) {
                        [vc.events removeObject:event];
                        [vc.tableView reloadData];
                        break;
                    }
                }
                [vc.eventIds_all removeObject:event_id1];
                break;
            }
        }
        
    }
    else if (msg_cmd == ADD_FRIEND_NOTIFICATION)
    {
        [[MTUser sharedInstance].friendRequestMsg insertObject:msg_dic atIndex:0];
        type = 1;

    }
    else if (msg_cmd == EVENT_INVITE_RESPONSE || msg_cmd == REQUEST_EVENT_RESPONSE)
    {
        [[MTUser sharedInstance].systemMsg insertObject:msg_dic atIndex:0];
        type = 2;
    }
    else if (msg_cmd == NEW_EVENT_NOTIFICATION || msg_cmd == REQUEST_EVENT)
    {
        [[MTUser sharedInstance].eventRequestMsg insertObject:msg_dic atIndex:0];
        type = 0;
    }
    
    NSString* path = [NSString stringWithFormat:@"%@/db",[MTUser sharedInstance].userid];
    [self.sql openMyDB:path];
    while (![self.sql isExistTable:@"notification"]) {
        [[NSRunLoop currentRunLoop]runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    NSArray* columns = [[NSArray alloc]initWithObjects:@"seq",@"msg",@"ishandled", nil];
//    NSString* timeStamp = [msg_dic objectForKey:@"timestamp"];
    NSArray* values = [[NSArray alloc]initWithObjects:
                       [NSString stringWithFormat:@"%@",seq],
                       [NSString stringWithFormat:@"'%@'",content_str],
                       [NSString stringWithFormat:@"%d",-1],
                       nil];
    [self.sql insertToTable:@"notification" withColumns:columns andValues:values];
    [self.sql closeMyDB];
    
    NSString* key = [NSString stringWithFormat:@"USER%@", [MTUser sharedInstance].userid];
    NSUserDefaults* userDf = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary* userSettings = [NSMutableDictionary dictionaryWithDictionary:[userDf objectForKey:key]];
    
    [userSettings setValue:[NSNumber numberWithBool:YES] forKey:@"openWithNotificationCenter"];
    int i = (type < 3 && type >= 0)? type : -1;
    NSLog(@"新消息来了，message type: %d", i);
    [userSettings setValue:[NSNumber numberWithInt:i] forKey:@"hasUnreadNotification"];
    
    [userDf setObject:userSettings forKey:key];
    [userDf synchronize];
    
    if ([(UIViewController*)self.notificationDelegate respondsToSelector:@selector(notificationDidReceive:)]) {
        [self.notificationDelegate notificationDidReceive:self.syncMessages];
    }
    
    int flag = [[userSettings objectForKey:@"hasUnreadNotification"]intValue];
    if (flag >= 0) {
        [self.leftMenu showUpdateInRow:4];
    }
    
    if (isInBackground) {
        [self.leftMenu showNotificationCenter];
    }
    
    NSDictionary* pack = [CommonUtils packParamsInDictionary:
                          [NSNumber numberWithInteger:type], @"type",
                          msg_dic, @"msg",
                          nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"pull_message" object:nil userInfo:pack];
    
    if (feedback) {
        //反馈给服务器
        [self feedBackPushMessagewithMinSeq:seq andMaxSeq:seq andCallBack:nil];
    }
    
}


-(void)synchronizePushSeqAndCallBack:(void(^)(NSNumber* min_seq, NSNumber* max_seq))block
{
    NSLog(@"开始同步消息");
    void(^returnResult)(NSData*) = ^(NSData* rData)
    {
        if (!rData) {
            NSLog(@"服务器返回的消息为空");
            return;
        }
        NSString* temp = [NSString string];
        if ([rData isKindOfClass:[NSString class]]) {
            temp = (NSString*)rData;
        }
        else if ([rData isKindOfClass:[NSData class]])
        {
            temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
        }
        NSDictionary* response = [CommonUtils NSDictionaryWithNSString:temp];
        int cmd = [[response objectForKey:@"cmd"]intValue];
        NSLog(@"同步消息seq，返回结果: %@", response);
        switch (cmd) {
            case NORMAL_REPLY:
            {
                NSNumber* min_seq = [response objectForKey:@"min_seq"];
                NSNumber* max_seq = [response objectForKey:@"max_seq"];
                if (block) {
                    block(min_seq,max_seq);
                }
                
            }
                break;
                
            default:
            {
                if (block) {
                    block(nil,nil);
                }
            }
                break;
        }
        
    };
    
    NSDictionary* json_dic = [CommonUtils packParamsInDictionary:
                              [NSNumber numberWithInteger:2], @"operation",
                              [MTUser sharedInstance].userid, @"id",
                              [NSNumber numberWithInt:0], @"min_seq",
                              [NSNumber numberWithInt:0], @"max_seq",
                              nil];
    NSData* json_data = [NSJSONSerialization dataWithJSONObject:json_dic options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender* http = [[HttpSender alloc]initWithDelegate:self];
    [http sendMessage:json_data withOperationCode:PUSH_MESSAGE HttpMethod:@"POST" finshedBlock:returnResult];
}

-(void)pullAndHandlePushMessageWithMinSeq:(NSNumber*)min_seq andMaxSeq:(NSNumber*)max_seq andCallBackBlock:(void(^)(NSDictionary* response))block
{
    void(^getPushMessageDone)(NSData*) = ^(NSData* rData)
    {
        if (!rData) {
            NSLog(@"服务器返回的消息为空");
            return;
        }
        NSString* temp = [NSString string];
        if ([rData isKindOfClass:[NSString class]]) {
            temp = (NSString*)rData;
        }
        else if ([rData isKindOfClass:[NSData class]])
        {
            temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
        }
        NSDictionary* response = [CommonUtils NSDictionaryWithNSString:temp];
        int cmd = [[response objectForKey:@"cmd"]intValue];
        NSLog(@"拉取的推送: %@", response);
        switch (cmd) {
            case NORMAL_REPLY:
            {
                NSArray* list = [response objectForKey:@"list"];
                for (int i = 0; i < list.count; i++) {
                    NSDictionary* message = [list objectAtIndex:i];
                    [self handlePushMessage:message andFeedBack:YES];
                }
                
            }
                break;
            default:
                break;
        }
        if (block) {
             block(response);
        }
    };
    NSDictionary* json_dic = [CommonUtils packParamsInDictionary:
                              [NSNumber numberWithInt:1], @"operation",
                              [MTUser sharedInstance].userid, @"id",
                              min_seq, @"min_seq",
                              max_seq, @"max_seq",
                              nil];
    NSData* json_data = [NSJSONSerialization dataWithJSONObject:json_dic options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender* http = [[HttpSender alloc]initWithDelegate:self];
    [http sendMessage:json_data withOperationCode:PUSH_MESSAGE HttpMethod:@"POST" finshedBlock:getPushMessageDone];
}

-(void)feedBackPushMessagewithMinSeq:(NSNumber*)min_seq andMaxSeq:(NSNumber*)max_seq andCallBack:(void(^)(NSDictionary* response))block
{
    void(^feedbackDone)(NSData*) = ^(NSData* rData)
    {
        if (!rData) {
            NSLog(@"服务器返回数据为空");
            return ;
        }
        NSString* temp = [NSString string];
        if ([rData isKindOfClass:[NSString class]]) {
            temp = (NSString*)rData;
        }
        else if ([rData isKindOfClass:[NSData class]])
        {
            temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
        }
        NSLog(@"反馈推送的结果：%@",temp);
        NSDictionary* response = [CommonUtils NSDictionaryWithNSString:temp];
        if (block) {
            block(response);
        }
    };
    NSDictionary* json_dic = [CommonUtils packParamsInDictionary:
                              [NSNumber numberWithInteger:0], @"operation",
                              [MTUser sharedInstance].userid, @"id",
                              min_seq, @"min_seq",
                              max_seq, @"max_seq",
                              nil];
    NSData* json_data = [NSJSONSerialization dataWithJSONObject:json_dic options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender *http = [[HttpSender alloc]initWithDelegate:self];
    [http sendMessage:json_data withOperationCode:PUSH_MESSAGE HttpMethod:@"POST" finshedBlock:feedbackDone];

}



#pragma mark - Network Status Checking
//================================Network Status Checking=====================================
-(void)initViews
{
//    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    CGRect frame = [UIScreen mainScreen].bounds;
    networkStatusNotifier_view = [[UIView alloc]initWithFrame:CGRectMake(0, frame.size.height + 1, frame.size.width, 20)];
//    [networkStatusNotifier_view setBackgroundColor:[UIColor yellowColor]];
    UILabel* label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, 20)];
    label.text = @"网络连接异常，请检查网络设置";
    [label setBackgroundColor:[UIColor redColor]];
    label.font = [UIFont systemFontOfSize:13];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
//    label.center = networkStatusNotifier_view.center;
    label.tag = 110;
    [networkStatusNotifier_view addSubview:label];
//    [self.window addSubview:networkStatusNotifier_view];
//    [self.window.rootViewController.view addSubview:networkStatusNotifier_view];
//    [self.window bringSubviewToFront:networkStatusNotifier_view];
//    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:networkStatusNotifier_view];
//    networkStatusNotifier_view.hidden = YES;
    CGRect f = networkStatusNotifier_view.frame;
    NSLog(@"network view: x: %f, y: %f, width: %f, height: %f",f.origin.x,f.origin.y,f.size.width,f.size.height);
}


- (void)reachabilityChanged:(NSNotification *)note {
    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
    NetworkStatus status = [curReach currentReachabilityStatus];
    NSString *userStatus =  [[NSUserDefaults standardUserDefaults] objectForKey:@"MeticStatus"];
    
    if (status == NotReachable) {
        if (isNetworkConnected) {
            [self showNetworkNotification:@"网络连接异常，请检查网络设置"];
        }
        isNetworkConnected = NO;
        
        if (isConnected) {
            [self disconnect];
        }
        
        NSLog(@"Network is not reachable");
    }
    else
    {
        if (!isNetworkConnected) {
            
            [UIView beginAnimations:@"showNetworkStatus" context:nil];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            [UIView setAnimationDidStopSelector:@selector(hideNetworkNotification)];
            [UIView setAnimationDuration:3];
            [UIView setAnimationDelegate:self];
            UILabel* label = (UILabel*)[networkStatusNotifier_view viewWithTag:110];
            label.text = @"网络连接恢复正常";
            [UIView commitAnimations];

        }
        isNetworkConnected = YES;
        while (![userStatus isEqualToString:@"in"]) {
//        while (!isLogined) {
            [[NSRunLoop currentRunLoop]runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }
        if (!isConnected) {
            [self connect];
        }

        
        
        NSLog(@"Network is reachable");
    }
}

+(BOOL)isEnableWIFI
{
    return ([[Reachability reachabilityForLocalWiFi] currentReachabilityStatus] != NotReachable);
}

+(BOOL)isEnableGPRS
{
    return ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] != NotReachable);
}

-(void)showNetworkNotification:(NSString*)message
{
    UILabel* label = (UILabel*)[networkStatusNotifier_view viewWithTag:110];
    label.text = message;
    CGRect frame = [UIApplication sharedApplication].keyWindow.frame;
    [[UIApplication sharedApplication].keyWindow addSubview:networkStatusNotifier_view];
    
    [UIView beginAnimations:@"showNetworkStatus" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
//    [UIView setAnimationDidStopSelector:@selector(hideNetworkNotification)];
    
    [UIView setAnimationDuration:1];
//    [UIView setAnimationRepeatCount:1];
    [UIView setAnimationDelegate:self];
    
    [networkStatusNotifier_view setFrame:CGRectMake(0, frame.size.height - networkStatusNotifier_view.frame.size.height, frame.size.width, networkStatusNotifier_view.frame.size.height)];
    [UIView commitAnimations];
    NSLog(@"show network notification");
    NSLog(@"notification bar, y: %f, height: %f",networkStatusNotifier_view.frame.origin.y, networkStatusNotifier_view.frame.size.height);
}

-(void)hideNetworkNotification
{
    CGRect frame = [UIScreen mainScreen].bounds;
    [UIView beginAnimations:@"hideNetworkStatus" context:nil];
    //    networkStatusNotifier_view.hidden = NO;
    [UIView setAnimationDelay:5];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    
    
    [UIView setAnimationDidStopSelector:@selector(NetworkNotificationDidHide)];
    [UIView setAnimationDuration:1];
//    [UIView setAnimationRepeatCount:1];
    [UIView setAnimationDelegate:self];
    
    [networkStatusNotifier_view setFrame:CGRectMake(0, frame.size.height + 1, frame.size.width, networkStatusNotifier_view.frame.size.height)];
    [UIView commitAnimations];
    
    NSLog(@"hide network notification");
    
}

-(void)NetworkNotificationDidHide
{
    [networkStatusNotifier_view removeFromSuperview];
}

//==========================================================================================

//===================================友盟统计 METHODS============================================

- (void)umengTrack {
    //    [MobClick setCrashReportEnabled:NO]; // 如果不需要捕捉异常，注释掉此行
    [MobClick setLogEnabled:NO];  // 打开友盟sdk调试，注意Release发布时需要注释掉此行,减少io消耗
    [MobClick setAppVersion:XcodeAppVersion]; //参数为NSString * 类型,自定义app版本信息，如果不设置，默认从CFBundleVersion里取
    //
    [MobClick startWithAppkey:UMENG_APPKEY reportPolicy:(ReportPolicy) REALTIME channelId:@""];
    //   reportPolicy为枚举类型,可以为 REALTIME, BATCH,SENDDAILY,SENDWIFIONLY几种
    //   channelId 为NSString * 类型，channelId 为nil或@""时,默认会被被当作@"App Store"渠道
    
    [MobClick checkUpdate];   //自动更新检查, 如果需要自定义更新请使用下面的方法,需要接收一个(NSDictionary *)appInfo的参数
    //    [MobClick checkUpdateWithDelegate:self selector:@selector(updateMethod:)];
    
    [MobClick updateOnlineConfig];  //在线参数配置
    
    //    1.6.8之前的初始化方法
    //    [MobClick setDelegate:self reportPolicy:REALTIME];  //建议使用新方法
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onlineConfigCallBack:) name:UMOnlineConfigDidFinishedNotification object:nil];
    
}

- (void)onlineConfigCallBack:(NSNotification *)note {
    
    NSLog(@"online config has fininshed and note = %@", note.userInfo);
}





//==========================================================================================

//===================================SOCKET METHODS============================================
-(void)handleReceivedMessage:(NSMutableDictionary*)response1
{
    NSString* cmd = [response1 objectForKey:@"cmd"];
    
    //处理推送消息
    if ([cmd isEqualToString:@"sync"]) {
        
        /*
         这种情况的推送的json格式：
         “timestamp": string
         "cmd": "sync"
         "num": int
         */
        
        if (numOfSyncMessages == -1) {
            numOfSyncMessages = [(NSNumber*)[response1 objectForKey:@"num"] intValue];
        };
    }
    else if([cmd isEqualToString:@"message"])
    {
        /*
         这种情况的推送的json格式：
         “timestamp": string
         "cmd": "message"
         "seq": int
         "msg": json(string)
         */
        
        [self.syncMessages addObject:response1];
        NSString* msg_str = [response1 objectForKey:@"msg"];
        NSMutableDictionary* msg_dic = [[NSMutableDictionary alloc]initWithDictionary:[CommonUtils NSDictionaryWithNSString:msg_str]];
        [msg_dic setValue:[NSNumber numberWithInteger:-1] forKeyPath:@"ishandled"];
        [msg_dic setValue:[response1 objectForKey:@"seq"] forKey:@"seq"];
        NSInteger msg_cmd = [[msg_dic objectForKey:@"cmd"] integerValue];
        
        
        if (msg_cmd  == ADD_FRIEND_RESULT) //cmd 998
        {
            [[MTUser sharedInstance].friendRequestMsg insertObject:msg_dic atIndex:0];
            [[MTUser sharedInstance] synchronizeFriends];
            NSNumber* result = [msg_dic objectForKey:@"result"];
            NSLog(@"friend request result: %@",result);
            if ([result integerValue] == 1) {
                NSString* name = [msg_dic objectForKey:@"name"];
                NSString* email = [msg_dic objectForKey:@"email"];
                NSNumber* fid = [msg_dic objectForKey:@"id"];
                NSNumber* gender = [msg_dic objectForKey:@"gender"];
                NSString* path = [NSString stringWithFormat:@"%@/db",[MTUser sharedInstance].userid];
                [sql openMyDB:path];
                [sql insertToTable:@"friend"
                       withColumns:[[NSArray alloc]initWithObjects:@"id",@"name",@"email",@"gender", nil]
                         andValues:[[NSArray alloc] initWithObjects:
                                    [NSString stringWithFormat:@"%@",fid],
                                    [NSString stringWithFormat:@"'%@'",name],
                                    [NSString stringWithFormat:@"'%@'",email],
                                    [NSString stringWithFormat:@"%@",gender], nil]];
                [sql closeMyDB];
                //                [MTUser sharedInstance].friendList = [[MTUser sharedInstance] getFriendsFromDB];
                NSDictionary* newFriend = [CommonUtils packParamsInDictionary:fid,@"id",name,@"name",gender,@"gender",email,@"email",nil];
                [[MTUser sharedInstance].friendList addObject:newFriend];
                [[MTUser sharedInstance] friendListDidChanged];
            }
            else if ([result integerValue] == 0)
            {
                NSLog(@"friend request is refused");
            }
            
            if (numOfSyncMessages <= 1) {
                [self sendMessageArrivedNotification:[NSString stringWithFormat:@"%@ 回复了你的好友请求", [msg_dic objectForKey:@"name"]] andNumber:numOfSyncMessages withType:1];
            }
            
        }
        else if (msg_cmd == 993 || msg_cmd == 992 || msg_cmd == 991) {
            if (![[MTUser sharedInstance].updateEventIds containsObject:[msg_dic valueForKey:@"event_id"]]) {
                [[MTUser sharedInstance].updateEventIds addObject:[msg_dic valueForKey:@"event_id"]];
                [[MTUser sharedInstance].updateEvents addObject:msg_dic];
                NSLog(@"新动态+1, updateEvents: %@",[MTUser sharedInstance].updateEvents);
            }
            NSLog(@"新动态数量：%d",[MTUser sharedInstance].updateEventIds.count);
            if (numOfSyncMessages <= 1) {
                NSString* subject = [msg_dic objectForKey:@"subject"];
                [self sendMessageArrivedNotification:[NSString stringWithFormat:@"\"%@\"活动更新啦",subject] andNumber:numOfSyncMessages withType:-1];
            }
            
        }
        else if (msg_cmd == 988 || msg_cmd == 989) {
            [[MTUser sharedInstance].atMeEvents addObject:msg_dic];
            if (numOfSyncMessages <= 1) {
                [self sendMessageArrivedNotification:@"有人@你啦" andNumber:numOfSyncMessages withType:-1];
            }
            NSLog(@"有人@你： %@",msg_dic);
        }
        else if (msg_cmd == 985) //活动被解散
        {
            [[MTUser sharedInstance].systemMsg insertObject:msg_dic atIndex:0];
            NSString* subject = [msg_dic objectForKey:@"subject"];
            if (numOfSyncMessages <= 1) {
                [self sendMessageArrivedNotification:[NSString stringWithFormat:@"%@ 活动已经被解散", subject] andNumber:numOfSyncMessages withType:2];
            }
            
            NSString * path = [NSString stringWithFormat:@"%@/db",[MTUser sharedInstance].userid];
            [sql openMyDB:path];
            NSNumber* event_id1 = [msg_dic objectForKey:@"event_id"];
            NSDictionary *wheres = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%@",event_id1],@"event_id", nil];
            [sql deleteTurpleFromTable:@"event" withWhere:wheres];
            [sql closeMyDB];
            
            for (HomeViewController* vc in [SlideNavigationController sharedInstance].viewControllers) {
                if ([vc isKindOfClass:[HomeViewController class]]) {
                    for (int i = 0; i < vc.events.count; i++) {
                        NSMutableDictionary* event = vc.events[i];
                        NSNumber* event_id2 = [event objectForKey:@"event_id"];
                        if ([event_id1 integerValue] == [event_id2 integerValue]) {
                            [vc.events removeObject:event];
                            [vc.tableView reloadData];
                            break;
                        }
                    }
                    [vc.eventIds_all removeObject:event_id1];
                    break;
                }
            }
            
        }
        else if (msg_cmd == 984) //被踢出活动
        {
            [[MTUser sharedInstance].systemMsg insertObject:msg_dic atIndex:0];
            NSString* subject = [msg_dic objectForKey:@"subject"];
            if (numOfSyncMessages <= 1) {
                [self sendMessageArrivedNotification:[NSString stringWithFormat:@"您已经被请出 %@ 活动", subject] andNumber:numOfSyncMessages withType:2];
            }
            
            NSString * path = [NSString stringWithFormat:@"%@/db",[MTUser sharedInstance].userid];
            [sql openMyDB:path];
            NSNumber* event_id1 = [msg_dic objectForKey:@"event_id"];
            NSDictionary *wheres = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%@",event_id1],@"event_id", nil];
            [sql deleteTurpleFromTable:@"event" withWhere:wheres];
            [sql closeMyDB];
            
            for (HomeViewController* vc in [SlideNavigationController sharedInstance].viewControllers) {
                if ([vc isKindOfClass:[HomeViewController class]]) {
                    for (int i = 0; i < vc.events.count; i++) {
                        NSMutableDictionary* event = vc.events[i];
                        NSNumber* event_id2 = [event objectForKey:@"event_id"];
                        if ([event_id1 integerValue] == [event_id2 integerValue]) {
                            [vc.events removeObject:event];
                            [vc.tableView reloadData];
                            break;
                        }
                    }
                    [vc.eventIds_all removeObject:event_id1];
                    break;
                }
            }
            
        }
        else if (msg_cmd == ADD_FRIEND_NOTIFICATION)
        {
            [[MTUser sharedInstance].friendRequestMsg insertObject:msg_dic atIndex:0];
            if (numOfSyncMessages <= 1) {
                NSString* name = [msg_dic objectForKey:@"name"];
                NSString* confirm_msg = [msg_dic objectForKey:@"confirm_msg"];
                [self sendMessageArrivedNotification:[NSString stringWithFormat:@"%@ 请求加你为好友\n验证信息:%@", name, confirm_msg] andNumber:numOfSyncMessages withType:1];
            }
        }
        else if (msg_cmd == EVENT_INVITE_RESPONSE || msg_cmd == REQUEST_EVENT_RESPONSE)
        {
            [[MTUser sharedInstance].systemMsg insertObject:msg_dic atIndex:0];
            if (numOfSyncMessages <= 1) {
                [self sendMessageArrivedNotification:@"有人回复了活动消息" andNumber:numOfSyncMessages withType:2];
            }
        }
        else if (msg_cmd == NEW_EVENT_NOTIFICATION || msg_cmd == REQUEST_EVENT)
        {
            [[MTUser sharedInstance].eventRequestMsg insertObject:msg_dic atIndex:0];
            if (numOfSyncMessages <= 1) {
                NSString* launcher = [msg_dic objectForKey:@"launcher"];
                NSString* subject = [msg_dic objectForKey:@"subject"];
                if (msg_cmd == NEW_EVENT_NOTIFICATION) {
                    [self sendMessageArrivedNotification:[NSString stringWithFormat:@"%@ 邀请你加入活动 \"%@\"",launcher,subject] andNumber:numOfSyncMessages withType:0];
                    
                }
                else
                {
                    [self sendMessageArrivedNotification:[NSString stringWithFormat:@"有人邀请你加入%@的活动 \"%@\"",launcher,subject] andNumber:numOfSyncMessages withType:0];
                }
            }
        }
        
        
        if (self.syncMessages.count == numOfSyncMessages) {
            NSNumber* seq = [response1 objectForKey:@"seq"];
            NSMutableDictionary* json = [CommonUtils packParamsInDictionary:
                                         @"feedback",@"cmd",[MTUser sharedInstance].userid, @"uid",
                                         seq,@"seq",
                                         nil];
            NSData* jsonData = [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:nil];
            [mySocket send:jsonData];
            NSLog(@"feedback send json: %@",json);
            //            NSThread* thread = [[NSThread alloc]initWithTarget:self selector:@selector(handleReceivedNotifications) object:nil];
            //
            //            [thread start];
            dispatch_sync(sync_queue, ^{
                [self handleReceivedNotifications:[NSMutableArray arrayWithArray:syncMessages] withCount:numOfSyncMessages];
            });
            
            numOfSyncMessages = -1;
            [self.syncMessages removeAllObjects];
            
            
            
        }
        
    }
    else if ([cmd isEqualToString:@"init"])
    {
        /*
         这种情况的推送的json格式：
         "cmd": "init"
         "seq": int
         */
        
        [self scheduleHeartBeat];
    }

}


- (void)handleReceivedNotifications:(NSMutableArray*)syn_messges withCount:(NSInteger)numOfMsg
{
    NSString* path = [NSString stringWithFormat:@"%@/db",[MTUser sharedInstance].userid];
    [self.sql openMyDB:path];
    while (![self.sql isExistTable:@"notification"]) {
        [[NSRunLoop currentRunLoop]runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    NSArray* columns = [[NSArray alloc]initWithObjects:@"seq",@"timestamp",@"msg",@"ishandled", nil];
    
    for (NSDictionary* message in syn_messges) {
        NSString* timeStamp = [message objectForKey:@"timestamp"];
        NSNumber* seq = [message objectForKey:@"seq"];
        NSString* msg = [message objectForKey:@"msg"];
        NSArray* values = [[NSArray alloc]initWithObjects:
                           [NSString stringWithFormat:@"%@",seq],
                           [NSString stringWithFormat:@"'%@'",timeStamp],
                           [NSString stringWithFormat:@"'%@'",msg],
                           [NSString stringWithFormat:@"%d",-1],
                           nil];
        [self.sql insertToTable:@"notification" withColumns:columns andValues:values];
    }
    [self.sql closeMyDB];
    
    NSString* key = [NSString stringWithFormat:@"USER%@", [MTUser sharedInstance].userid];
    NSUserDefaults* userDf = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary* userSettings = [NSMutableDictionary dictionaryWithDictionary:[userDf objectForKey:key]];
    [userSettings setValue:[NSNumber numberWithBool:YES] forKey:@"openWithNotificationCenter"];
    [userDf setObject:userSettings forKey:key];
    [userDf synchronize];
    
    //通知铃声
    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
    AudioServicesPlayAlertSound(1106);
    
    if (numOfSyncMessages > 1) {
        [self sendMessageArrivedNotification:@"收到一大堆消息" andNumber:numOfSyncMessages withType:-1];
    }

    
    if ([(UIViewController*)self.notificationDelegate respondsToSelector:@selector(notificationDidReceive:)]) {
        [self.notificationDelegate notificationDidReceive:self.syncMessages];
    }

//    [((MenuViewController*)[SlideNavigationController sharedInstance].leftMenu) showUpdateInRow:4];
    int flag = [[userSettings objectForKey:@"hasUnreadNotification"]intValue];
    if (flag >= 0) {
        [self.leftMenu showUpdateInRow:4];
    }
    
//    numOfSyncMessages = -1;
//    [self.syncMessages removeAllObjects];
    if (isInBackground) {
        [self.leftMenu showNotificationCenter];
    }
}

//参数：text：横幅显示的信息， num：消息数量， type：哪一类消息（与消息中心的tab编号相对应）
-(void)sendMessageArrivedNotification:(NSString*)text andNumber:(int)num withType:(int)type
{
    NSString* key = [NSString stringWithFormat:@"USER%@",[MTUser sharedInstance].userid];
    NSUserDefaults* userDf = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary* userSettings = [[NSMutableDictionary alloc]initWithDictionary:[userDf objectForKey:key]];
    BOOL flag = [[userSettings objectForKey:@"systemSetting1"] boolValue];
    NSLog(@"system setting1 flag: %d",flag);

    //发送通知
    UILocalNotification *notification=[[UILocalNotification alloc] init];
    if (notification!=nil) {
        NSDate *now=[NSDate new];
        notification.fireDate=[now dateByAddingTimeInterval:0];//0秒后通知
        notification.repeatInterval=0;//循环次数，kCFCalendarUnitWeekday一周一次
        notification.timeZone=[NSTimeZone defaultTimeZone];
        notification.applicationIconBadgeNumber = [UIApplication sharedApplication].applicationIconBadgeNumber + num; //应用的红色数字
        notification.soundName= UILocalNotificationDefaultSoundName;//声音，可以换成alarm.soundName = @"myMusic.caf"
        if (flag) {
            //去掉下面2行就不会弹出提示框
            notification.alertBody= text;//提示信息 弹出提示框
            notification.alertAction = @"打开";  //提示框按钮
            notification.hasAction = NO; //是否显示额外的按钮，为no时alertAction消失
        }
        
        // NSDictionary *infoDict = [NSDictionary dictionaryWithObject:@"someValue" forKey:@"someKey"];
        //notification.userInfo = infoDict; //添加额外的信息
        
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
//    [((MenuViewController*)[SlideNavigationController sharedInstance].leftMenu) showUpdateInRow:4];
    int i = (type < 3 && type >= 0)? type : -1;
    NSLog(@"新消息来了，message type: %d", i);
    [userSettings setValue:[NSNumber numberWithInt:i] forKey:@"hasUnreadNotification"];
    [userDf setObject:userSettings forKey:key];
    [userDf synchronize];
    
//    NSDictionary* setting = [[NSUserDefaults standardUserDefaults]objectForKey:key];
//    NSNumber* num_temp = [setting objectForKey:@"hasUnreadNotification"];
//    NSLog(@"存储的hasUnreadNotification: %@", num_temp);
    
}


#pragma mark - WebSocket
- (void)connect
{
    mySocket.delegate = nil;
    [mySocket close];
    
//    NSString* str = @"ws://203.195.174.128:10088/"; //腾讯
//    NSString* str = @"ws://115.29.103.9:10088/";
//    NSString* str = @"ws://localhost:9000/chat";
    
//    NSString* str = @"ws://42.96.203.86:10088/";//阿里 测试服
//    NSString* str = @"ws://whatsact.gz.1251096186.clb.myqcloud.com:10088/";//腾讯 正式服
    NSString* str = @[@"ws://42.96.203.86:10088/",@"ws://whatsact.gz.1251096186.clb.myqcloud.com:10088/"][Server];
    NSURL* url = [[NSURL alloc]initWithString:str];
    
    NSURLRequest* request = [[NSURLRequest alloc]initWithURL:url];
    mySocket = [[SRWebSocket alloc]initWithURLRequest:request];
    mySocket.delegate = self;
    NSLog(@"Connecting...");
    [mySocket open];
}

- (void)scheduleHeartBeat
{
    self.heartBeatTimer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(sendHeartBeatMessage) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop]addTimer:heartBeatTimer forMode:NSRunLoopCommonModes];
}

- (void)unscheduleHeartBeat
{
    [self.heartBeatTimer invalidate];
}

- (void)sendHeartBeatMessage
{
    if (isConnected) {
        
        [mySocket send:@""];
        NSLog(@"Heart beats_^_^_");
    }
    else
    {
        [self disconnect];
//        [self connect];
//        NSLog(@"Reconnecting...");
    }
    
}

- (void)disconnect
{
    [self.mySocket close];
    [self unscheduleHeartBeat];
    NSLog(@"Disconnected");
}

#pragma mark - SRWebSocketDelegate

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message
{
    NSData* temp = [[NSData alloc]init];
    if ([message isKindOfClass:[NSString class]]) {
        temp = [message dataUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"Get message(string): %@",message);
    }
    else if ([message isKindOfClass:[NSData class]])
    {
        temp = message;
        NSLog(@"Get message(data): %@",message);
    }
//    NSLog(@"Get message(data): %@",temp);
//    NSString* temp2 = [[NSString alloc]initWithData:temp encoding:NSUTF8StringEncoding];
//    NSLog(@"Transformed message(string): %@",temp2);

    NSMutableDictionary *response1 = [NSJSONSerialization JSONObjectWithData:temp options:NSJSONReadingMutableLeaves error:nil];
    
    [self handleReceivedMessage:response1];
   
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket;
{
    NSLog(@"Websocket Connected");
    isConnected = YES;
    NSDictionary* json = [CommonUtils packParamsInDictionary:[MTUser sharedInstance].userid,@"uid",nil];
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:nil];
    [mySocket send:jsonData];
    
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error;
{
    NSLog(@":( Websocket Failed With Error %@", error);
    isConnected = NO;
    [self disconnect];
    NSString *userStatus =  [[NSUserDefaults standardUserDefaults] objectForKey:@"MeticStatus"];
    NSLog(@"isNetworkConnected: %d, login status: %@",isNetworkConnected, userStatus);
    if (isNetworkConnected && [userStatus isEqualToString:@"in"]) {
        [self connect];
        NSLog(@"Reconnecting from fail...");
    }
    
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;
{
    NSLog(@"WebSocket closed, code: %d,reason: %@",code,reason);
    isConnected = NO;
    [self disconnect];
    NSString *userStatus =  [[NSUserDefaults standardUserDefaults] objectForKey:@"MeticStatus"];
    NSLog(@"isNetworkConnected: %d, login status: %@",isNetworkConnected, userStatus);
    if (isNetworkConnected && [userStatus isEqualToString:@"in"]) {
        [self connect];
        NSLog(@"Reconnecting from close...");
    }
}
//=============================================================================================


- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return  [UMSocialSnsService handleOpenURL:url];
}
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    return  [UMSocialSnsService handleOpenURL:url];
}

- (NSMutableArray *)loadMarkersFromFilePath:(NSString *)filePath {
    NSMutableArray *markers = nil;
    if (filePath == nil || [filePath length] == 0 ||
        [[NSFileManager defaultManager] fileExistsAtPath:filePath] == NO) {
        markers = [[NSMutableArray alloc] init];
    } else {
        markers = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    }
    return markers;
}




- (void)saveMarkers:(NSMutableArray *)markers toFilePath:(NSString *)filePath {
    [NSKeyedArchiver archiveRootObject:markers toFile:filePath];
}


//=============================================================================================
//视频缓存相关
- (void)startServer
{
    // Start the server (and check for problems)
	
	NSError *error;
	if([httpServer start:&error])
	{
		NSLog(@"Started HTTP Server on port %hu", [httpServer listeningPort]);
	}
	else
	{
		NSLog(@"Error starting HTTP Server: %@", error);
	}
}

- (void)initLocalVideoServer
{

	// Create server using our custom MyHTTPServer class
	httpServer = [[HTTPServer alloc] init];
	
	// Tell the server to broadcast its presence via Bonjour.
	// This allows browsers such as Safari to automatically discover our service.
	[httpServer setType:@"_http._tcp."];
	
	// Normally there's no need to run our server on any specific port.
	// Technologies like Bonjour allow clients to dynamically discover the server's port at runtime.
	// However, for easy testing you may want force a certain port so you can just hit the refresh button.
    [httpServer setPort:12345];
    
    // Serve files from our embedded Web folder
    
    NSString* webPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    webPath = [webPath stringByAppendingPathComponent:@"VideoTemp"];
    
    NSFileManager *fileManager=[NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:webPath])
    {
        [fileManager createDirectoryAtPath:webPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
	[httpServer setDocumentRoot:webPath];
    
    [self startServer];
}

- (NSUInteger)application:(UIApplication *)application
supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    
    if ([[self.window.rootViewController presentedViewController]
         isKindOfClass:[MTMPMoviePlayerViewController class]]) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskPortrait;
        if ([[self.window.rootViewController presentedViewController]
             isKindOfClass:[UINavigationController class]]) {
            return UIInterfaceOrientationMaskPortrait;
            // look for it inside UINavigationController
            UINavigationController *nc = (UINavigationController *)[self.window.rootViewController presentedViewController];
            
            // is at the top?
            if ([nc.topViewController isKindOfClass:[MPMoviePlayerViewController class]]) {
                return UIInterfaceOrientationMaskAllButUpsideDown;
                
                // or it's presented from the top?
            } else if ([[nc.topViewController presentedViewController]
                        isKindOfClass:[MPMoviePlayerViewController class]]) {
                return UIInterfaceOrientationMaskAllButUpsideDown;
            }
        }
    }
    
    return UIInterfaceOrientationMaskPortrait;
}
@end
