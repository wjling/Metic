 //
//  AppDelegate.m
//  Metic
//
//  Created by ligang_mac4 on 14-5-26.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "AppDelegate.h"
#import "UMSocialWechatHandler.h"
//#import "UMSocialSinaSSOHandler.h"
#import "UMSocialQQHandler.h"
#import "Main Classes/MTMPMoviePlayerViewController.h"
#import "Main Classes/BannerViewController.h"
#import "Main Classes/MTUser.h"
#import "MobClick.h"
#import "HttpSender.h"
#import "MenuViewController.h"
#import "NotificationsViewController.h"
#import "HomeViewController.h"
#import "XGPush.h"
#import "XGSetting.h"
#import "MTDatabaseHelper.h"
#import "SDWebImageManager.h"
#import "MTPushMessageHandler.h"

#import <ShareSDK/ShareSDK.h>
#import <ShareSDKConnector/ShareSDKConnector.h>

//腾讯开放平台（对应QQ和QQ空间）SDK头文件
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>

//微信SDK头文件
#import "WXApi.h"

//新浪微博SDK头文件
#import "WeiboSDK.h"

#define _IPHONE80_ 80000

@implementation AppDelegate
{
    BOOL isConnected;
    int numOfSyncMessages;
    dispatch_queue_t sync_queue;
    NSTimer* netWorkViewTimer;
//    NSString* DB_path;
}
@synthesize mySocket;
@synthesize hostReach;
@synthesize heartBeatTimer;
@synthesize syncMessages;
@synthesize networkStatusNotifier_view;
@synthesize isNetworkConnected;
@synthesize isLogined;
@synthesize leftMenu;
@synthesize isInBackground;
//@synthesize operationQueue;

//@synthesize user;
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    MTLOG(@"app did finish launch===============");
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(forceQuitToLogin) name:@"forceQuitToLogin" object:nil];
    [self NetworkStatusInitViews];
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
        MTLOG(@"The first launch");
        [userDf synchronize];
    }
    else
    {
        MTLOG(@"Not the first launch");
        [userDf setBool:NO forKey:@"firstLaunched"];
        [userDf synchronize];
    }
	
	leftMenu = (MenuViewController*)[mainStoryboard instantiateViewControllerWithIdentifier: @"MenuViewController"];
	leftMenu.cellIdentifier = @"leftMenuCell";

	[SlideNavigationController sharedInstance].leftMenu = leftMenu;
    
    [self initApp];
    self.syncMessages = [[NSMutableArray alloc]init];
    numOfSyncMessages = -1;
    isNetworkConnected = YES;
    isInBackground = NO;
    isLogined = NO;
    
    _mapManager = [[BMKMapManager alloc]init];
    BOOL ret;
    if (isEnterprise == 0) {
        ret = [_mapManager start:@"mk9WfL1PxXjguCdYsdW7xQYc" generalDelegate:nil];//上架版本
    }else if(isEnterprise == 1){
        ret = [_mapManager start:@"oHzEkwMGSfXfqGcBF0B0vWK5" generalDelegate:nil];//企业版本
    }else if (isEnterprise == 2)
    {
        ret = [_mapManager start:@"qF8lbnGm6cIaAVe0tUTTBnyg" generalDelegate:nil];//企业版本测试服
    }
	if (!ret) {
		MTLOG(@"manager start failed!");
	}
    
    //初始化Umeng
    [self initUmeng];
    
    // 初始化ShareSDK
    [self initShareSDK];
    
    // 监测网络情况
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name: kReachabilityChangedNotification
                                               object: nil];
    hostReach = [Reachability reachabilityWithHostName:@"www.baidu.com"];
    [hostReach startNotifier];
    
    //开启本地视频服务
    [self initLocalVideoServer];
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"shouldIgnoreTurnToNotifiPage"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    //初始化信鸽推送
    [self initXGPush:launchOptions];
    
    NSDictionary*userInfo = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
    if (userInfo) {
        NSInteger cmd = [[userInfo valueForKey:@"cmd"] integerValue];
        if (cmd == ADD_FRIEND_NOTIFICATION || cmd == ADD_FRIEND_RESULT || cmd == NEW_EVENT_NOTIFICATION || cmd == REQUEST_EVENT || cmd == QUIT_EVENT_NOTIFICATION || cmd == KICK_EVENT_NOTIFICATION) {
            //新消息来了 type：1跳转到消息中心 type：0表示忽略
            [[NSUserDefaults standardUserDefaults]setInteger:1 forKey:@"newNotificationCome"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }else{
            [[NSUserDefaults standardUserDefaults]setInteger:0 forKey:@"newNotificationCome"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }

    }else {
        [[NSUserDefaults standardUserDefaults]setInteger:0 forKey:@"newNotificationCome"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 1];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
    
    [[SDImageCache sharedImageCache] setShouldDecompressImages:NO];
    [[SDWebImageDownloader sharedDownloader] setShouldDecompressImages:NO];
    [[SDImageCache sharedImageCache] setMaxCacheAge:60 * 60 * 24 * 30 * 50]; // 50 years
//    [[SDImageCache sharedImageCache] setMaxMemoryCost:10000];
    
    SDWebImageManager.sharedManager.cacheKeyFilter = ^(NSURL *url) {
        NSString *path = url.path;
        if ([path hasPrefix:@"/whatsact"]) {
            path = [path stringByReplacingOccurrencesOfString:@"/whatsact" withString:@""];
        }else if ([path hasPrefix:@"/metis201415"]) {
            path = [path stringByReplacingOccurrencesOfString:@"/metis201415" withString:@""];
        }
        return path;
    };
    
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
//         MTLOG(@"alive in background");
//         [NSThread sleepForTimeInterval:10];
//     }];
     MTLOG(@"app did enter Background====================");
    isInBackground = YES;
    application.applicationIconBadgeNumber = 0;
    
    UIApplication*   app = [UIApplication sharedApplication];
    __block    UIBackgroundTaskIdentifier bgTask;
    bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [application endBackgroundTask:bgTask];
            bgTask = UIBackgroundTaskInvalid;
        });
    }];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        //预先保存mtuser内容
        NSString *userStatus = [[NSUserDefaults standardUserDefaults] objectForKey:@"MeticStatus"];
        if ([userStatus isEqualToString:@"in"]) {
            NSString* MtuserPath= [NSString stringWithFormat:@"%@/Documents/MTuser.txt", NSHomeDirectory()];
            if ([MTUser sharedInstance].name) {
                [self saveMarkers:[[NSMutableArray alloc] initWithObjects:[MTUser sharedInstance],nil] toFilePath:MtuserPath];
            }
        }
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    });

}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
//    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 1];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
    
    [[UIApplication sharedApplication] clearKeepAliveTimeout];
    MTLOG(@"app will enter foreground==================");
    application.applicationIconBadgeNumber = 0;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Playfrompause"
                                                        object:nil
                                                      userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"playTheMPMoviePlayer"
                                                        object:nil
                                                      userInfo:nil];
    isInBackground = NO;
    
    //同步推送消息
    MTLOG(@"开始同步消息");
    void(^synchronizeDone)(NSNumber*, NSNumber*) = ^(NSNumber* min_seq, NSNumber* max_seq)
    {
        if (!min_seq || !max_seq) {
            return;
        }
        [MTPushMessageHandler pullAndHandlePushMessageWithMinSeq:min_seq andMaxSeq:max_seq andCallBackBlock:nil];
    };
    [MTPushMessageHandler synchronizePushSeqAndCallBack:synchronizeDone];

}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    application.applicationIconBadgeNumber = 0;
    MTLOG(@"app did become active===================");
    isInBackground = NO;
    
    //通知活动中心刷新新动态
    [[NSNotificationCenter defaultCenter] postNotificationName:@"adjustInfoView" object:nil userInfo:nil];
    
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    //点击本地通知提示框的打开
    MTLOG(@"点击本地通知");
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
    
//    void (^successBlock)(void) = ^(void){
//        //成功之后的处理
//        MTLOG(@"[XGPush]unRegisterDevice successBlock");
//    };
//    
//    void (^errorBlock)(void) = ^(void){
//        //失败之后的处理
//        MTLOG(@"[XGPush]unRegisterDevice errorBlock");
//    };
//
//    [XGPush unRegisterDevice:successBlock errorCallback:errorBlock];
    MTLOG(@"Metic被残忍杀死了");
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
    MTLOG(@"deviceTokenStr is %@",deviceTokenStr);
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSString *error_str = [NSString stringWithFormat:@"%@",error];
    MTLOG(@"Failed to get token, error: %@",error_str);
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    //判断位于前台还是后台
    NSInteger cmd = [[userInfo valueForKey:@"cmd"] integerValue];
    if (cmd == ADD_FRIEND_NOTIFICATION || cmd == ADD_FRIEND_RESULT || cmd == NEW_EVENT_NOTIFICATION || cmd == REQUEST_EVENT || cmd == QUIT_EVENT_NOTIFICATION || cmd == KICK_EVENT_NOTIFICATION) {
        switch ([application applicationState]) {
            case UIApplicationStateActive:
                MTLOG(@"UIApplicationStateActive");
                break;
            case UIApplicationStateInactive:
                MTLOG(@"UIApplicationStateInactive");
                [[NSNotificationCenter defaultCenter] postNotificationName:@"PopToFirstPageAndTurnToNotificationPage"
                                                                    object:nil
                                                                  userInfo:nil];
                break;
            case UIApplicationStateBackground:
                MTLOG(@"UIApplicationStateBackground");
                [[NSNotificationCenter defaultCenter] postNotificationName:@"PopToFirstPageAndTurnToNotificationPage"
                                                                    object:nil
                                                                  userInfo:nil];
                break;
                
            default:
                break;
        }
    }
    
    
    //在此处理接受到的消息
    
    MTLOG(@"APP receive remote userInfo: %@", userInfo);
    [XGPush handleReceiveNotification:userInfo];
    
    //当位于前台 而且该消息序号大于本地消息最大序号才拉取该推送消息
    NSNumber* seq = [userInfo objectForKey:@"seq"];
    if ([application applicationState] == UIApplicationStateActive) {
        
        if (cmd != SYSTEM_PUSH) {
            if ([MTUser sharedInstance].userid) {
                NSMutableDictionary* maxSeqDict = [[NSUserDefaults standardUserDefaults] objectForKey:@"maxNotificationSeq"];
                if (maxSeqDict) {
                    NSNumber* localMaxSeq = [maxSeqDict objectForKey:[CommonUtils NSStringWithNSNumber:[MTUser sharedInstance].userid]];
                    if([localMaxSeq integerValue] >= [seq integerValue]){
                        return;
                    }
                }
            }
            void(^getPushMessageDone)(NSDictionary*) = ^(NSDictionary* response){};
            [MTPushMessageHandler pullAndHandlePushMessageWithMinSeq:seq andMaxSeq:seq andCallBackBlock:getPushMessageDone];
        }
        
    }
    //拉系统推送
    if (cmd == SYSTEM_PUSH) {
        [MTPushMessageHandler pullSystemNotificationWithSeq:seq];
    }
}

-(void)initApp
{
    NSString *userStatus = [[NSUserDefaults standardUserDefaults] objectForKey:@"MeticStatus"];
    if ([userStatus isEqualToString:@"in"]) {
        NSString* MtuserPath= [NSString stringWithFormat:@"%@/Documents/MTuser.txt", NSHomeDirectory()];
        NSFileManager *fileManager=[NSFileManager defaultManager];
        if([fileManager fileExistsAtPath:MtuserPath])
        {
            NSArray* users;
            @try {
                users = [NSKeyedUnarchiver unarchiveObjectWithFile:MtuserPath];
            }
            @catch (NSException *exception) {
            }
            @finally {
                if (!users || users.count == 0) {
                    [[NSUserDefaults standardUserDefaults] setObject:@"out" forKey:@"MeticStatus"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    [[MTUser alloc]init];
                }
            }
        }else{
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


#pragma mark - Network Status Checking
//================================Network Status Checking=====================================
-(void)NetworkStatusInitViews
{
//    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    CGRect frame = [UIScreen mainScreen].bounds;
    networkStatusNotifier_view = [[UIView alloc]initWithFrame:CGRectMake(0, frame.size.height, frame.size.width, 20)];
//    [networkStatusNotifier_view setBackgroundColor:[UIColor yellowColor]];
    UILabel* label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, 20)];
    label.text = @"网络连接异常，请检查网络设置";
    [label setBackgroundColor:[UIColor redColor]];
    label.font = [UIFont systemFontOfSize:13];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.tag = 110;
    [networkStatusNotifier_view addSubview:label];
    networkStatusNotifier_view.tag = 0;
    
//    netWorkViewTimer = [NSTimer timerWithTimeInterval:5.0 target:self selector:@selector(netWorkTimerSelector:) userInfo:nil repeats:NO];
}

- (void)netWorkTimerSelector:(NSTimer*)t
{
    MTLOG(@"network timer selector fire");
    if ([hostReach currentReachabilityStatus] != NotReachable) {
        [self hideNetworkNotification];
        isNetworkConnected = YES;
    }
}


- (void)reachabilityChanged:(NSNotification *)note {
    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
    NetworkStatus status = [curReach currentReachabilityStatus];
//    NSString *userStatus =  [[NSUserDefaults standardUserDefaults] objectForKey:@"MeticStatus"];
    dispatch_time_t delaytime = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 1.5);
    dispatch_after(delaytime, dispatch_get_main_queue(), ^{
        if ([hostReach currentReachabilityStatus] == NotReachable) {
            
            [self showNetworkNotification:@"网络连接异常，请检查网络设置"];
            
            isNetworkConnected = NO;
            MTLOG(@"Network is not reachable");
        }
        else
        {
            [self hideNetworkNotification];
            
            isNetworkConnected = YES;
            MTLOG(@"Network is reachable");
        }

    });
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
    MTLOG(@"显示 network notification");
    CGRect frame = [UIApplication sharedApplication].keyWindow.frame;
//    MTLOG(@"screen bounds.height: %f",[UIScreen mainScreen].bounds.size.height);
//    MTLOG(@"window.size.height: %f",[UIApplication sharedApplication].keyWindow.frame.size.height);
//    MTLOG(@"notification bar, y: %f, height: %f",networkStatusNotifier_view.frame.origin.y, networkStatusNotifier_view.frame.size.height);
//    MTLOG(@"show-----superview: %@, tag: %ld", [networkStatusNotifier_view superview], [networkStatusNotifier_view tag]);
    if ((networkStatusNotifier_view.frame.origin.y  != frame.size.height &&(networkStatusNotifier_view.frame.origin.y + networkStatusNotifier_view.frame.size.height) > frame.size.height) || [networkStatusNotifier_view superview] != nil || [networkStatusNotifier_view tag] == 1 ) {
        MTLOG(@"显示_没有执行");
        return;
    }
    UILabel* label = (UILabel*)[networkStatusNotifier_view viewWithTag:110];
    label.text = message;
    
    [[UIApplication sharedApplication].keyWindow addSubview:networkStatusNotifier_view];
    
    [UIView beginAnimations:@"showNetworkStatus" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDidStopSelector:@selector(NetworkNotificationDidShow)];
    
    [UIView setAnimationDuration:0.8];
//    [UIView setAnimationRepeatCount:1];
    [UIView setAnimationDelegate:self];
    
    [networkStatusNotifier_view setFrame:CGRectMake(0, frame.size.height - networkStatusNotifier_view.frame.size.height, frame.size.width, networkStatusNotifier_view.frame.size.height)];
    [UIView commitAnimations];
//    networkStatusNotifier_view.tag = 1;
}

-(void)hideNetworkNotification
{
    CGRect frame = [UIApplication sharedApplication].keyWindow.frame;
    MTLOG(@"隐藏 network notification");
//    MTLOG(@"hide-----superview: %@, tag: %ld", [networkStatusNotifier_view superview], [networkStatusNotifier_view tag]);

//    MTLOG(@"notification bar, y: %f, height: %f",networkStatusNotifier_view.frame.origin.y, networkStatusNotifier_view.frame.size.height);
    if ((networkStatusNotifier_view.frame.origin.y + networkStatusNotifier_view.frame.size.height) > frame.size.height || [networkStatusNotifier_view superview] == nil || [networkStatusNotifier_view tag] == 0) {
        MTLOG(@"隐藏_没有执行");
        return;
    }
    
    [UIView beginAnimations:@"hideNetworkStatus" context:nil];
    //    networkStatusNotifier_view.hidden = NO;
//    [UIView setAnimationDelay:5];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    
    
    [UIView setAnimationDidStopSelector:@selector(NetworkNotificationDidHide)];
    [UIView setAnimationDuration:0.8];
//    [UIView setAnimationRepeatCount:1];
    [UIView setAnimationDelegate:self];
    
    [networkStatusNotifier_view setFrame:CGRectMake(0, frame.size.height, frame.size.width, networkStatusNotifier_view.frame.size.height)];
    [UIView commitAnimations];
}

-(void)NetworkNotificationDidShow
{
    MTLOG(@"network notification did show");
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 0.0), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        networkStatusNotifier_view.tag = 1;
    });
    [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(netWorkTimerSelector:) userInfo:nil repeats:NO];
}

-(void)NetworkNotificationDidHide
{
    MTLOG(@"network notification did hide");
    [networkStatusNotifier_view removeFromSuperview];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 0.0), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        networkStatusNotifier_view.tag = 0;
    });
//    [netWorkViewTimer invalidate];
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
    
//    [MobClick checkUpdate];   //自动更新检查, 如果需要自定义更新请使用下面的方法,需要接收一个(NSDictionary *)appInfo的参数
    //    [MobClick checkUpdateWithDelegate:self selector:@selector(updateMethod:)];
    
    [MobClick updateOnlineConfig];  //在线参数配置
    
    //    1.6.8之前的初始化方法
    //    [MobClick setDelegate:self reportPolicy:REALTIME];  //建议使用新方法
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onlineConfigCallBack:) name:UMOnlineConfigDidFinishedNotification object:nil];
    
}

- (void)onlineConfigCallBack:(NSNotification *)note {
    
    MTLOG(@"online config has fininshed and note = %@", note.userInfo);
}

#pragma 密码验证失败 返回到登录页面
- (void)forceQuitToLogin
{
    MTLOG(@"切换账号");
    [XGPush unRegisterDevice];
    ((AppDelegate*)[[UIApplication sharedApplication] delegate]).isLogined = NO;
//    [((AppDelegate*)[[UIApplication sharedApplication] delegate]) disconnect];
    [[MTUser alloc] init];
    [[NSUserDefaults standardUserDefaults] setValue:@"change" forKey:@"MeticStatus"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[SlideNavigationController sharedInstance] popToRootViewControllerAnimated:YES];
    });
    
}


////==========================================================================================
//
////===================================SOCKET METHODS============================================
//-(void)handleReceivedMessage:(NSMutableDictionary*)response1
//{
//    NSString* cmd = [response1 objectForKey:@"cmd"];
//    
//    //处理推送消息
//    if ([cmd isEqualToString:@"sync"]) {
//        
//        /*
//         这种情况的推送的json格式：
//         “timestamp": string
//         "cmd": "sync"
//         "num": int
//         */
//        
//        if (numOfSyncMessages == -1) {
//            numOfSyncMessages = [(NSNumber*)[response1 objectForKey:@"num"] intValue];
//        };
//    }
//    else if([cmd isEqualToString:@"message"])
//    {
//        /*
//         这种情况的推送的json格式：
//         “timestamp": string
//         "cmd": "message"
//         "seq": int
//         "msg": json(string)
//         */
//        
//        [self.syncMessages addObject:response1];
//        NSString* msg_str = [response1 objectForKey:@"msg"];
//        NSMutableDictionary* msg_dic = [[NSMutableDictionary alloc]initWithDictionary:[CommonUtils NSDictionaryWithNSString:msg_str]];
//        [msg_dic setValue:[NSNumber numberWithInteger:-1] forKeyPath:@"ishandled"];
//        [msg_dic setValue:[response1 objectForKey:@"seq"] forKey:@"seq"];
//        NSInteger msg_cmd = [[msg_dic objectForKey:@"cmd"] integerValue];
//        
//        
//        if (msg_cmd  == ADD_FRIEND_RESULT) //cmd 998
//        {
//            [[MTUser sharedInstance].friendRequestMsg insertObject:msg_dic atIndex:0];
//            [[MTUser sharedInstance] synchronizeFriends];
//            NSNumber* result = [msg_dic objectForKey:@"result"];
//            MTLOG(@"friend request result: %@",result);
//            if ([result integerValue] == 1) {
//                NSString* name = [msg_dic objectForKey:@"name"];
//                NSString* email = [msg_dic objectForKey:@"email"];
//                NSNumber* fid = [msg_dic objectForKey:@"id"];
//                NSNumber* gender = [msg_dic objectForKey:@"gender"];
//                [[MTDatabaseHelper sharedInstance]insertToTable:@"friend"
//                                                    withColumns:[[NSArray alloc]initWithObjects:@"id",@"name",@"email",@"gender", nil]
//                                                      andValues:[[NSArray alloc] initWithObjects:
//                                                                 [NSString stringWithFormat:@"%@",fid],
//                                                                 [NSString stringWithFormat:@"'%@'",name],
//                                                                 [NSString stringWithFormat:@"'%@'",email],
//                                                                 [NSString stringWithFormat:@"%@",gender], nil]];
//                                //                [MTUser sharedInstance].friendList = [[MTUser sharedInstance] getFriendsFromDB];
//                NSDictionary* newFriend = [CommonUtils packParamsInDictionary:fid,@"id",name,@"name",gender,@"gender",email,@"email",nil];
//                [[MTUser sharedInstance].friendList addObject:newFriend];
//                [[MTUser sharedInstance] friendListDidChanged];
//            }
//            else if ([result integerValue] == 0)
//            {
//                MTLOG(@"friend request is refused");
//            }
//            
//            if (numOfSyncMessages <= 1) {
//                [self sendMessageArrivedNotification:[NSString stringWithFormat:@"%@ 回复了你的好友请求", [msg_dic objectForKey:@"name"]] andNumber:numOfSyncMessages withType:1];
//            }
//            
//        }
//        else if (msg_cmd == NEW_COMMENT_NOTIFICATION || msg_cmd == NEW_PHOTO_NOTIFICATION || msg_cmd == NEW_VIDEO_NOTIFICATION) {
//            if (![[MTUser sharedInstance].updateEventStatus objectForKey:[msg_dic valueForKey:@"event_id"]] ) {
//                [[MTUser sharedInstance].updateEventStatus setObject:@[[msg_dic valueForKey:@"subject"],[NSNumber numberWithBool:NO],[NSNumber numberWithBool:NO],[NSNumber numberWithBool:NO]] forKey:[msg_dic valueForKey:@"event_id"]];
//            }
//            NSMutableArray *status = [[MTUser sharedInstance].updateEventStatus valueForKey:[msg_dic valueForKey:@"event_id"]];
//            status = [NSMutableArray arrayWithArray:status];
//            status[(msg_cmd - 990)] = [NSNumber numberWithBool:YES];
//            [[MTUser sharedInstance].updateEventStatus setObject:status forKey:[msg_dic valueForKey:@"event_id"]];
//            
//            if (![[MTUser sharedInstance].updatePVStatus objectForKey:[msg_dic valueForKey:@"event_id"]] ) {
//                [[MTUser sharedInstance].updatePVStatus setObject:@[[msg_dic valueForKey:@"subject"],[NSNumber numberWithBool:NO],[NSNumber numberWithBool:NO],[NSNumber numberWithBool:NO]] forKey:[msg_dic valueForKey:@"event_id"]];
//            }
//            NSMutableArray *pvStatus = [[MTUser sharedInstance].updatePVStatus objectForKey:[msg_dic valueForKey:@"event_id"]];
//            pvStatus = [NSMutableArray arrayWithArray:pvStatus];
//            pvStatus[(msg_cmd - 990)] = [NSNumber numberWithBool:YES];
//            [[MTUser sharedInstance].updatePVStatus setObject:pvStatus forKey:[msg_dic valueForKey:@"event_id"]];
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshPVRPStatus"
//                                                                object:nil
//                                                              userInfo:nil];
//            
//            
////            MTLOG(@"新动态数量：%d",[MTUser sharedInstance].updateEventStatus.count);
//            if (numOfSyncMessages <= 1) {
//                NSString* subject = [msg_dic objectForKey:@"subject"];
//                [self sendMessageArrivedNotification:[NSString stringWithFormat:@"\"%@\"活动更新啦",subject] andNumber:numOfSyncMessages withType:-1];
//            }
//            
//        }
//        else if (msg_cmd == NEW_VIDEO_COMMENT_REPLY || msg_cmd == NEW_PHOTO_COMMENT_REPLY || msg_cmd == NEW_COMMENT_REPLY || msg_cmd == NEW_LIKE_NOTIFICATION) {
//            [[MTUser sharedInstance].atMeEvents addObject:msg_dic];
//            if (numOfSyncMessages <= 1) {
//                [self sendMessageArrivedNotification:@"有人@你啦" andNumber:numOfSyncMessages withType:-1];
//            }
////            MTLOG(@"有人@你： %@",msg_dic);
//        }
//        else if (msg_cmd == QUIT_EVENT_NOTIFICATION) //活动被解散
//        {
//            [[MTUser sharedInstance].systemMsg insertObject:msg_dic atIndex:0];
//            NSString* subject = [msg_dic objectForKey:@"subject"];
//            if (numOfSyncMessages <= 1) {
//                [self sendMessageArrivedNotification:[NSString stringWithFormat:@"%@ 活动已经被解散", subject] andNumber:numOfSyncMessages withType:2];
//            }
//            
//            NSNumber* event_id1 = [msg_dic objectForKey:@"event_id"];
//            NSDictionary *wheres = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%@",event_id1],@"event_id", nil];
//            [[MTDatabaseHelper sharedInstance]deleteTurpleFromTable:@"event" withWhere:wheres];
//            
//            NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:event_id1,@"eventId", nil];
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"deleteItem" object:nil userInfo:dict];
//            
//        }
//        else if (msg_cmd == KICK_EVENT_NOTIFICATION) //被踢出活动
//        {
//            [[MTUser sharedInstance].systemMsg insertObject:msg_dic atIndex:0];
//            NSString* subject = [msg_dic objectForKey:@"subject"];
//            if (numOfSyncMessages <= 1) {
//                [self sendMessageArrivedNotification:[NSString stringWithFormat:@"您已经被请出 %@ 活动", subject] andNumber:numOfSyncMessages withType:2];
//            }
//            
//            NSNumber* event_id1 = [msg_dic objectForKey:@"event_id"];
//            NSDictionary *wheres = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%@",event_id1],@"event_id", nil];
//            [[MTDatabaseHelper sharedInstance]deleteTurpleFromTable:@"event" withWhere:wheres];
//            NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:event_id1,@"eventId", nil];
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"deleteItem" object:nil userInfo:dict];
//            
//        }
//        else if (msg_cmd == ADD_FRIEND_NOTIFICATION)
//        {
//            [[MTUser sharedInstance].friendRequestMsg insertObject:msg_dic atIndex:0];
//            if (numOfSyncMessages <= 1) {
//                NSString* name = [msg_dic objectForKey:@"name"];
//                NSString* confirm_msg = [msg_dic objectForKey:@"confirm_msg"];
//                [self sendMessageArrivedNotification:[NSString stringWithFormat:@"%@ 请求加你为好友\n验证信息:%@", name, confirm_msg] andNumber:numOfSyncMessages withType:1];
//            }
//        }
//        else if (msg_cmd == EVENT_INVITE_RESPONSE || msg_cmd == REQUEST_EVENT_RESPONSE)
//        {
//            [[MTUser sharedInstance].systemMsg insertObject:msg_dic atIndex:0];
//            if (numOfSyncMessages <= 1) {
//                [self sendMessageArrivedNotification:@"有人回复了活动消息" andNumber:numOfSyncMessages withType:2];
//            }
//            if([[msg_dic valueForKey:@"result"] boolValue]){
//                [[NSNotificationCenter defaultCenter]postNotificationName:@"reloadEvent" object:nil userInfo:nil];
//            }
//        }
//        else if (msg_cmd == NEW_EVENT_NOTIFICATION || msg_cmd == REQUEST_EVENT)
//        {
//            [[MTUser sharedInstance].eventRequestMsg insertObject:msg_dic atIndex:0];
//            if (numOfSyncMessages <= 1) {
//                NSString* launcher = [msg_dic objectForKey:@"launcher"];
//                NSString* subject = [msg_dic objectForKey:@"subject"];
//                if (msg_cmd == NEW_EVENT_NOTIFICATION) {
//                    [self sendMessageArrivedNotification:[NSString stringWithFormat:@"%@ 邀请你加入活动 \"%@\"",launcher,subject] andNumber:numOfSyncMessages withType:0];
//                    
//                }
//                else
//                {
//                    [self sendMessageArrivedNotification:[NSString stringWithFormat:@"有人邀请你加入%@的活动 \"%@\"",launcher,subject] andNumber:numOfSyncMessages withType:0];
//                }
//            }
//        }
//        
//        
//        if (self.syncMessages.count == numOfSyncMessages) {
//            NSNumber* seq = [response1 objectForKey:@"seq"];
//            NSMutableDictionary* json = [CommonUtils packParamsInDictionary:
//                                         @"feedback",@"cmd",[MTUser sharedInstance].userid, @"uid",
//                                         seq,@"seq",
//                                         nil];
//            NSData* jsonData = [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:nil];
//            [mySocket send:jsonData];
////            MTLOG(@"feedback send json: %@",json);
//            //            NSThread* thread = [[NSThread alloc]initWithTarget:self selector:@selector(handleReceivedNotifications) object:nil];
//            //
//            //            [thread start];
//            dispatch_sync(sync_queue, ^{
//                [self handleReceivedNotifications:[NSMutableArray arrayWithArray:syncMessages] withCount:numOfSyncMessages];
//            });
//            
//            numOfSyncMessages = -1;
//            [self.syncMessages removeAllObjects];
//            
//            
//            
//        }
//        
//    }
//    else if ([cmd isEqualToString:@"init"])
//    {
//        /*
//         这种情况的推送的json格式：
//         "cmd": "init"
//         "seq": int
//         */
//        
//        [self scheduleHeartBeat];
//    }
//
//}
//
//
//- (void)handleReceivedNotifications:(NSMutableArray*)syn_messges withCount:(NSInteger)numOfMsg
//{
//
//
//    NSArray* columns = [[NSArray alloc]initWithObjects:@"seq",@"timestamp",@"msg",@"ishandled", nil];
//    
//    for (NSInteger i = 0; i < syn_messges.count; i++) {
//        NSDictionary* message = [syn_messges objectAtIndex:i];
//        NSString* timeStamp = [message objectForKey:@"timestamp"];
//        NSNumber* seq = [message objectForKey:@"seq"];
//        NSString* msg = [message objectForKey:@"msg"];
//        NSArray* values = [[NSArray alloc]initWithObjects:
//                           [NSString stringWithFormat:@"%@",seq],
//                           [NSString stringWithFormat:@"'%@'",timeStamp],
//                           [NSString stringWithFormat:@"'%@'",msg],
//                           [NSString stringWithFormat:@"%d",-1],
//                           nil];
//        [[MTDatabaseHelper sharedInstance]insertToTable:@"notification" withColumns:columns andValues:values];
//    }
//    
//    NSString* key = [NSString stringWithFormat:@"USER%@", [MTUser sharedInstance].userid];
//    NSUserDefaults* userDf = [NSUserDefaults standardUserDefaults];
//    NSMutableDictionary* userSettings = [NSMutableDictionary dictionaryWithDictionary:[userDf objectForKey:key]];
//    [userSettings setValue:[NSNumber numberWithBool:YES] forKey:@"openWithNotificationCenter"];
//    [userDf setObject:userSettings forKey:key];
//    [userDf synchronize];
//    
//    //通知铃声
//    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
//    AudioServicesPlayAlertSound(1106);
//    
//    if (numOfSyncMessages > 1) {
//        [self sendMessageArrivedNotification:@"收到一大堆消息" andNumber:numOfSyncMessages withType:-1];
//    }
//
//    
//    if ([(UIViewController*)self.notificationDelegate respondsToSelector:@selector(notificationDidReceive:)]) {
//        [self.notificationDelegate notificationDidReceive:self.syncMessages];
//    }
//
////    [((MenuViewController*)[SlideNavigationController sharedInstance].leftMenu) showUpdateInRow:4];
//    int flag = [[[userSettings objectForKey:@"hasUnreadNotification1"] objectForKey:@"tab_show"] integerValue];
//    if (flag >= 0) {
//        [self.leftMenu showUpdateInRow:4];
//        [[SlideNavigationController sharedInstance]showLeftBarButtonDian];
//    }
//    
////    numOfSyncMessages = -1;
////    [self.syncMessages removeAllObjects];
//    if (isInBackground) {
//        [self.leftMenu showNotificationCenter];
//    }
//}

////参数：text：横幅显示的信息， num：消息数量， type：哪一类消息（与消息中心的tab编号相对应）
//-(void)sendMessageArrivedNotification:(NSString*)text andNumber:(int)num withType:(int)type
//{
//    NSString* key = [NSString stringWithFormat:@"USER%@",[MTUser sharedInstance].userid];
//    NSUserDefaults* userDf = [NSUserDefaults standardUserDefaults];
//    NSMutableDictionary* userSettings = [[NSMutableDictionary alloc]initWithDictionary:[userDf objectForKey:key]];
//    BOOL flag = [[userSettings objectForKey:@"systemSetting1"] boolValue];
//    MTLOG(@"system setting1 flag: %d",flag);
//
//    //发送通知
//    UILocalNotification *notification=[[UILocalNotification alloc] init];
//    if (notification!=nil) {
//        NSDate *now=[NSDate new];
//        notification.fireDate=[now dateByAddingTimeInterval:0];//0秒后通知
//        notification.repeatInterval=0;//循环次数，kCFCalendarUnitWeekday一周一次
//        notification.timeZone=[NSTimeZone defaultTimeZone];
//        notification.applicationIconBadgeNumber = [UIApplication sharedApplication].applicationIconBadgeNumber + num; //应用的红色数字
//        notification.soundName= UILocalNotificationDefaultSoundName;//声音，可以换成alarm.soundName = @"myMusic.caf"
//        if (flag) {
//            //去掉下面2行就不会弹出提示框
//            notification.alertBody= text;//提示信息 弹出提示框
//            notification.alertAction = @"打开";  //提示框按钮
//            notification.hasAction = NO; //是否显示额外的按钮，为no时alertAction消失
//        }
//        
//        // NSDictionary *infoDict = [NSDictionary dictionaryWithObject:@"someValue" forKey:@"someKey"];
//        //notification.userInfo = infoDict; //添加额外的信息
//        
//        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
//    }
////    [((MenuViewController*)[SlideNavigationController sharedInstance].leftMenu) showUpdateInRow:4];
//    int i = (type < 3 && type >= 0)? type : -1;
//    MTLOG(@"新消息来了，message type: %d", i);
//    NSMutableDictionary* unRead_dic = [NSMutableDictionary dictionaryWithDictionary:[userSettings objectForKey:@"hasUnreadNotification1"]];
//    
//    if (!unRead_dic) {
//        unRead_dic = [[NSMutableDictionary alloc]init];
//    }
//    if (i >= 0) {
//        NSString* key_n = [NSString stringWithFormat:@"tab_%d", i];
//        NSNumber* tabn_old = [unRead_dic objectForKey:key_n];
//        NSNumber* tabn_new;
//        if (tabn_old) {
//            tabn_new = [NSNumber numberWithInteger:([tabn_old integerValue] + 1)];;
//        }
//        else
//        {
//            tabn_new = [NSNumber numberWithInteger:1];
//        }
//        [unRead_dic setValue:tabn_new forKey:key_n];
//    }
//    
//    [unRead_dic setValue:[NSNumber numberWithInteger:i] forKey:@"tab_show"];
//    [userSettings setValue:unRead_dic forKey:@"hasUnreadNotification1"];
//    [userDf setObject:userSettings forKey:key];
//    [userDf synchronize];
//        
//}


//#pragma mark - WebSocket
//- (void)connect
//{
//    mySocket.delegate = nil;
//    [mySocket close];
//    
////    NSString* str = @"ws://203.195.174.128:10088/"; //腾讯
////    NSString* str = @"ws://115.29.103.9:10088/";
////    NSString* str = @"ws://localhost:9000/chat";
//    
////    NSString* str = @"ws://182.254.176.64:10088/";//阿里 测试服
////    NSString* str = @"ws://whatsact.gz.1251096186.clb.myqcloud.com:10088/";//腾讯 正式服
//    NSString* str = @[@"ws://182.254.176.64:10088/",@"ws://whatsact.gz.1251096186.clb.myqcloud.com:10088/"][Server];
//    NSURL* url = [[NSURL alloc]initWithString:str];
//    
//    NSURLRequest* request = [[NSURLRequest alloc]initWithURL:url];
//    mySocket = [[SRWebSocket alloc]initWithURLRequest:request];
//    mySocket.delegate = self;
//    MTLOG(@"Connecting...");
//    [mySocket open];
//}
//
//- (void)scheduleHeartBeat
//{
//    self.heartBeatTimer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(sendHeartBeatMessage) userInfo:nil repeats:YES];
//    [[NSRunLoop currentRunLoop]addTimer:heartBeatTimer forMode:NSRunLoopCommonModes];
//}
//
//- (void)unscheduleHeartBeat
//{
//    [self.heartBeatTimer invalidate];
//}
//
//- (void)sendHeartBeatMessage
//{
//    if (isConnected) {
//        
//        [mySocket send:@""];
//        MTLOG(@"Heart beats_^_^_");
//    }
//    else
//    {
//        [self disconnect];
////        [self connect];
////        MTLOG(@"Reconnecting...");
//    }
//    
//}
//
//- (void)disconnect
//{
//    [self.mySocket close];
//    [self unscheduleHeartBeat];
//    MTLOG(@"Disconnected");
//}

#pragma mark - SRWebSocketDelegate

//- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message
//{
//    NSData* temp = [[NSData alloc]init];
//    if ([message isKindOfClass:[NSString class]]) {
//        temp = [message dataUsingEncoding:NSUTF8StringEncoding];
//        MTLOG(@"Get message(string): %@",message);
//    }
//    else if ([message isKindOfClass:[NSData class]])
//    {
//        temp = message;
//        MTLOG(@"Get message(data): %@",message);
//    }
////    MTLOG(@"Get message(data): %@",temp);
////    NSString* temp2 = [[NSString alloc]initWithData:temp encoding:NSUTF8StringEncoding];
////    MTLOG(@"Transformed message(string): %@",temp2);
//
//    NSMutableDictionary *response1 = [NSJSONSerialization JSONObjectWithData:temp options:NSJSONReadingMutableLeaves error:nil];
//    
//    [self handleReceivedMessage:response1];
//   
//}
//
//- (void)webSocketDidOpen:(SRWebSocket *)webSocket;
//{
//    MTLOG(@"Websocket Connected");
//    isConnected = YES;
//    NSDictionary* json = [CommonUtils packParamsInDictionary:[MTUser sharedInstance].userid,@"uid",nil];
//    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:nil];
//    [mySocket send:jsonData];
//    
//}
//
//- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error;
//{
//    MTLOG(@":( Websocket Failed With Error %@", error);
//    isConnected = NO;
//    [self disconnect];
//    NSString *userStatus =  [[NSUserDefaults standardUserDefaults] objectForKey:@"MeticStatus"];
//    MTLOG(@"isNetworkConnected: %d, login status: %@",isNetworkConnected, userStatus);
////    if (isNetworkConnected && [userStatus isEqualToString:@"in"]) {
////        [self connect];
////        MTLOG(@"Reconnecting from fail...");
////    }
//    
//}
//
//- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;
//{
////    MTLOG(@"WebSocket closed, code: %d,reason: %@",code,reason);
//    isConnected = NO;
//    [self disconnect];
//    NSString *userStatus =  [[NSUserDefaults standardUserDefaults] objectForKey:@"MeticStatus"];
//    MTLOG(@"isNetworkConnected: %d, login status: %@",isNetworkConnected, userStatus);
////    if (isNetworkConnected && [userStatus isEqualToString:@"in"]) {
////        [self connect];
////        MTLOG(@"Reconnecting from close...");
////    }
//}
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
		MTLOG(@"Started HTTP Server on port %hu", [httpServer listeningPort]);
	}
	else
	{
		MTLOG(@"Error starting HTTP Server: %@", error);
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
    if ([[self.window.rootViewController presentedViewController] isKindOfClass:[MTMPMoviePlayerViewController class]]||[[self.window.rootViewController presentedViewController] isKindOfClass:[BannerViewController class]])
    {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskPortrait;
    }
}

- (void)initXGPush:(NSDictionary *)launchOptions
{
    /* 信鸽推送 */
    if (isEnterprise == 0) {
        [XGPush startApp:2200086281 appKey:@"IHI87C3K71YC"];//上架版本
    }else if (isEnterprise == 1){
        [XGPush startApp:2200076416 appKey:@"ISVQ96G3S43K"];//企业版本
    }else if (isEnterprise == 2){
        [XGPush startApp:2200107997 appKey:@"I2MC33N3Z6UZ"];//企业版本测试服
    }
    
    //推送反馈回调版本示例
    void (^successBlock)(void) = ^(void){
        //成功之后的处理
        MTLOG(@"[XGPush]handleLaunching's successBlock");
    };
    
    void (^errorBlock)(void) = ^(void){
        //失败之后的处理
        MTLOG(@"[XGPush]handleLaunching's errorBlock");
    };
    
    [XGPush handleLaunching:launchOptions successCallback:successBlock errorCallback:errorBlock];
}

#pragma mark - umeng Init
- (void)initUmeng
{
    [UMSocialData setAppKey:@"53bb542e56240ba6e80a4bfb"];
    [UMSocialWechatHandler setWXAppId:@"wx6f7ea17b99ab01e7" appSecret:@"975f26374a1ade1290b1d4dfa767ed1f" url:@"http://www.whatsact.com"];
    //    [UMSocialSinaSSOHandler openNewSinaSSOWithRedirectURL:@"http://www.sina.com"];
    [UMSocialQQHandler setQQWithAppId:@"1102021463" appKey:@"9KXHG6HqBWrjonAd" url:@"http://www.whatsact.com"];
    [UMSocialConfig hiddenNotInstallPlatforms:@[UMShareToQQ,UMShareToSina,UMShareToWechatSession,UMShareToWechatFavorite,UMShareToWechatTimeline]];
}

#pragma mark - shareSDK Init
- (void)initShareSDK
{
    [ShareSDK registerApp:@"ce2c74fa5630"
     
          activePlatforms:@[
                            @(SSDKPlatformTypeSinaWeibo),
                            @(SSDKPlatformTypeWechat),
                            @(SSDKPlatformTypeQQ),]
                 onImport:^(SSDKPlatformType platformType)
     {
         switch (platformType)
         {
             case SSDKPlatformTypeWechat:
                 [ShareSDKConnector connectWeChat:[WXApi class]];
                 break;
             case SSDKPlatformTypeQQ:
                 [ShareSDKConnector connectQQ:[QQApiInterface class] tencentOAuthClass:[TencentOAuth class]];
                 break;
             case SSDKPlatformTypeSinaWeibo:
                 [ShareSDKConnector connectWeibo:[WeiboSDK class]];
                 break;
             default:
                 break;
         }
     }
          onConfiguration:^(SSDKPlatformType platformType, NSMutableDictionary *appInfo)
     {
         
         switch (platformType)
         {
             case SSDKPlatformTypeSinaWeibo:
                 //设置新浪微博应用信息,其中authType设置为使用SSO＋Web形式授权
                 [appInfo SSDKSetupSinaWeiboByAppKey:@"1312051023"
                                           appSecret:@"6f39d1c54b182992680b4949a0c00c87"
                                         redirectUri:@"http://www.sina.com"
                                            authType:SSDKAuthTypeBoth];
                 break;
             case SSDKPlatformTypeWechat:
                 [appInfo SSDKSetupWeChatByAppId:@"wx6f7ea17b99ab01e7"
                                       appSecret:@"975f26374a1ade1290b1d4dfa767ed1f"];
                 break;
             case SSDKPlatformTypeQQ:
                 [appInfo SSDKSetupQQByAppId:@"1102021463"
                                      appKey:@"9KXHG6HqBWrjonAd"
                                    authType:SSDKAuthTypeBoth];
                 break;
             default:
                 break;
         }
     }];
}



@end
