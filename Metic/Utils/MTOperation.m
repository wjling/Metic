    //
//  MTOperation.m
//  WeShare
//
//  Created by 俊健 on 15/5/20.
//  Copyright (c) 2015年 WeShare. All rights reserved.
//

#import "MTOperation.h"
#import "MTUser.h"
#import "BOAlertController.h"
#import "SlideNavigationController.h"
#import "SVProgressHUD.h"
#import "MTDatabaseAffairs.h"
#import "SDImageCache.h"
#import <objc/runtime.h>
#import "MegUtils.h"

@interface MTOperation ()<UIAlertViewDelegate>

@end

@implementation MTOperation

+ (MTOperation *)sharedInstance {
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [self new];
    });
    return instance;
}

- (id)init {
    if ((self = [super init])) {
    }
    return self;
}

#pragma 添加那些把自己删掉的好友
-(void)inviteFriends:(NSArray*)notFriendsList
{
    if (notFriendsList.count == 0) {
        return;
    }
    NSString* names = @"";
    for (int i = 0; i < notFriendsList.count; i++) {
        NSNumber* fid = notFriendsList[i];
        NSString* fname = [[MTUser sharedInstance].alias_dic objectForKey:[NSString stringWithFormat:@"%@",fid]];
        if (fname == nil || [fname isEqual:[NSNull null]] || [fname isEqualToString:@""]) {
            fname = [[MTUser sharedInstance].nameFromID_dic objectForKey:[NSString stringWithFormat:@"%@",fid]];
        }
        
        if (i == 0) {
            names = [names stringByAppendingString:[NSString stringWithFormat:@"%@",fname]];
        }else{
            names = [names stringByAppendingString:[NSString stringWithFormat:@"、%@",fname]];
        }
        
    }
    
    NSString* message = [NSString stringWithFormat:@"%@ 不是你的好友，无法邀请，是否申请添加好友 ？",names];
    
    BOAlertController *alertView = [[BOAlertController alloc] initWithTitle:@"系统消息" message:message viewController:[SlideNavigationController sharedInstance]];
    RIButtonItem *cancelItem = [RIButtonItem itemWithLabel:@"取消" action:^{

    }];
    [alertView addButton:cancelItem type:RIButtonItemType_Cancel];
    
    RIButtonItem *okItem = [RIButtonItem itemWithLabel:@"确定" action:^{
        
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"添加好友" message:@"请填写好友申请信息：" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alert.tag = 120;
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        if ([MTUser sharedInstance].name && ![[MTUser sharedInstance].name isEqual:[NSNull null]]) {
            [alert textFieldAtIndex:0].text = [NSString stringWithFormat:@"我是%@",[MTUser sharedInstance].name];
        }
        
        
        void (^block)(NSInteger) = ^(NSInteger buttonIndex){
            if(buttonIndex == 0){
                
            }else if(buttonIndex == 1){
                [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
                NSString* cm = [alert textFieldAtIndex:0].text;
                NSNumber* userId = [MTUser sharedInstance].userid;
                
                NSString *friendlist = @"[";
                BOOL flag = YES;
                for (NSNumber* friendid in notFriendsList) {
                    friendlist = [friendlist stringByAppendingString: flag? @"%@":@",%@"];
                    if (flag) flag = NO;
                    friendlist = [NSString stringWithFormat:friendlist,friendid];
                }
                friendlist = [friendlist stringByAppendingString:@"]"];
                
                NSDictionary* json = [CommonUtils packParamsInDictionary:[NSNumber numberWithInt:ADD_FRIEND_NOTIFICATION],@"cmd",userId,@"id",cm,@"confirm_msg", friendlist,@"friend_list",[NSNumber numberWithInt:ADD_FRIEND],@"item_id",nil];
                NSData* jsonData = [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:nil];
                HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
                [httpSender sendMessage:jsonData withOperationCode:ADD_FRIEND_BATCH finshedBlock:^(NSData *rData) {
                    if (!rData) {
                        [SVProgressHUD dismissWithError:@"网络异常"];
                    }else{
                        NSString* temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
                        MTLOG(@"Received Data: %@",temp);
                        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
                        NSNumber *cmd = [response valueForKey:@"cmd"];
                        switch ([cmd intValue]) {
                            case NORMAL_REPLY:
                            {
                                [SVProgressHUD dismissWithSuccess:@"添加好友请求已发送"];
                            }
                                break;
                            default:
                            {
                                [SVProgressHUD dismissWithSuccess:@"添加好友请求已发送"];
                            }
                        }
                    }
                    
                    
                }];
            }
        };
        
        objc_setAssociatedObject(alert,@"MTinviteFriends",block,OBJC_ASSOCIATION_COPY);
        
        [alert show];
        
    }];
    [alertView addButton:okItem type:RIButtonItemType_Other];
    [alertView show];
}

#pragma 处理收藏活动id数据
-(NSArray*)processLikeEventID:(NSArray*)likeEventIdData
{
    MTLOG(@"%@",likeEventIdData);
    
    NSMutableArray* eventIds = [[NSMutableArray alloc]init];
    for (int i = 0; i < likeEventIdData.count; i++) {
        NSDictionary* item = likeEventIdData[i];
        NSNumber* eventId = [item valueForKey:@"event_id"];
        [eventIds addObject:eventId];
    }
    return eventIds;
}

#pragma 收藏／取消收藏活动操作
-(void)likeEventOperation:(NSArray*)eventIds like:(BOOL)islike finishBlock:(likeEventFinishBlock)finishBlock
{
    [SVProgressHUD showWithStatus:@"处理中.." maskType:SVProgressHUDMaskTypeGradient];
    
//    NSString *eventIdsStr = [CommonUtils arrayStyleStringfromNummerArray:[NSArray arrayWithArray:eventIds]];
    
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:[MTUser sharedInstance].userid forKey:@"id"];
    [dictionary setValue:eventIds forKey:@"event_list"];
    [dictionary setValue:islike? @1:@0 forKey:@"operation"];
//    MTLOG(@"%@",dictionary);
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:LIKE_EVENT finshedBlock:^(NSData *rData) {
        if (rData) {
            NSString* temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
            MTLOG(@"received Data: %@",temp);
            NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableContainers error:nil];
            NSNumber *cmd = [response1 valueForKey:@"cmd"];
            switch ([cmd intValue]) {
                case NORMAL_REPLY:{
                    [SVProgressHUD dismissWithSuccess:islike? @"收藏成功":@"取消收藏"];
                    NSArray* result = [response1 valueForKey:@"result"];
                    
                    BOOL normal = NO;
                    if (result && result.count) {
                        NSDictionary* item = result[0];
                        NSString* likeTime = [item valueForKey:@"likeTime"];
                        NSNumber* innerCmd = [item valueForKey:@"cmd"];
                        if ([likeTime isEqual: [NSNull null]]) {
                            likeTime = nil;
                        }
                        if (innerCmd) {
                            if ([innerCmd integerValue] == NORMAL_REPLY) {
                                normal = YES;
                                if (finishBlock) {
                                    finishBlock(YES,likeTime);
                                }
                                
                            }
                        }
                    }
                    if (!normal) {
                        if (finishBlock) {
                            finishBlock(NO,nil);
                        }
                    }
                    
                }
                    break;
                default:{
                    [SVProgressHUD dismissWithError:@"网络异常，请重试。"];
                    if (finishBlock) {
                        finishBlock(NO,nil);
                    }
                }
                    break;
            }
        }else{
            [SVProgressHUD dismissWithError:@"网络异常，请重试。"];
            if (finishBlock) {
                finishBlock(NO,nil);
            }
        }
        
    }];
}

-(void)getUrlFromServer:(NSString*) path
                 success:(void (^)(NSString* url))success
                 failure:(void (^)(NSString* message))failure
{
    if (!path) {
        if (failure) {
            failure(@"参数错误");
        }
        return;
    }
    if ([[SDImageCache sharedImageCache]diskImageExistsWithKey:path]) {
        if (success) {
            success(path);
        }
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
        [dictionary setValue:@"GET" forKey:@"method"];
        [dictionary setValue:path forKey:@"object"];
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
        HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
        [httpSender sendMessage:jsonData withOperationCode: GET_FILE_URL finshedBlock:^(NSData *rData) {
            if (!rData){
                if (failure) {
                    failure(@"网络异常");
                }
                return;
            }
            if (rData) {
                NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
                NSNumber *cmd = [response1 valueForKey:@"cmd"];
                switch ([cmd intValue]) {
                    case NORMAL_REPLY:
                    {
                        NSString* url = (NSString*)[response1 valueForKey:@"url"];
                        if (url) {
                            if (success) {
                                success(url);
                            }
                            return;
                        }
                    }
                        break;
                    default:
                        if (failure) {
                            failure(@"服务器异常");
                        }
                        return;
                        break;
                }
            }
        }];
    });
}

-(void)getVideoUrlFromServerWith:(NSString*) videoName
                success:(void (^)(NSString* url))success
                failure:(void (^)(NSString* message))failure
{
    if (!videoName) {
        if (failure) {
            failure(@"参数错误");
        }
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString *CacheDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        NSString *cachePath = [CacheDirectory stringByAppendingPathComponent:@"VideoCache"];
        
        //plan b 缓存视频
        NSFileManager *fileManager=[NSFileManager defaultManager];
        if(![fileManager fileExistsAtPath:cachePath])
        {
            [fileManager createDirectoryAtPath:cachePath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        if ([fileManager fileExistsAtPath:[cachePath stringByAppendingPathComponent:videoName]]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                success(@"existed");
            });
            return ;
        }
        
        NSString *path = [MegUtils videoPathWithVideoName:videoName];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
            [dictionary setValue:@"GET" forKey:@"method"];
            [dictionary setValue:path forKey:@"object"];
            
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
            HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
            [httpSender sendMessage:jsonData withOperationCode: GET_FILE_URL finshedBlock:^(NSData *rData) {
                if (!rData){
                    if (failure) {
                        failure(@"网络异常");
                    }
                    return;
                }
                if (rData) {
                    NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
                    NSNumber *cmd = [response1 valueForKey:@"cmd"];
                    switch ([cmd intValue]) {
                        case NORMAL_REPLY:
                        {
                            NSString* url = (NSString*)[response1 valueForKey:@"url"];
                            if (url) {
                                if (success) {
                                    success(url);
                                }
                                return;
                            }
                        }
                            break;
                        default:
                            if (failure) {
                                failure(@"服务器异常");
                            }
                            return;
                            break;
                            
                    }
                }
            }];
        });
    });
}

#pragma mark - Alert Delegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex;{
    // the user clicked OK
    if (alertView.tag == 120) {
        //添加那些把自己删掉的好友
        void (^block)(NSInteger) = objc_getAssociatedObject(alertView, @"MTinviteFriends");
        block(buttonIndex);
    }
}


@end
