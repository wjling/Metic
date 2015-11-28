//
//  MTPushMessageHandler.m
//  WeShare
//
//  Created by 俊健 on 15/11/18.
//  Copyright (c) 2015年 WeShare. All rights reserved.
//

#import "AppDelegate.h"
#import "MTPushMessageHandler.h"
#import "CommonUtils.h"
#import "MTUser.h"
#import "MTDatabaseHelper.h"
#import "XGPush.h"
#import "SlideNavigationController.h"
#import "MenuViewController.h"

@implementation MTPushMessageHandler

+ (MTPushMessageHandler *)sharedInstance {
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

+ (void)registerPush{
    MTLOG(@"XG register");
    
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

+ (void)registerPushBelowiOS8
{
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
    
}

+ (void)registerPushForIOS8{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= _IPHONE80_
    MTLOG(@"register Push for iOS8 begin");
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
    MTLOG(@"register Push for iOS8 end");
#endif
}

#pragma mark - Normal Push
+ (void)handlePushMessage:(NSDictionary*)message andFeedBack:(BOOL)feedback
{
    NSNumber* seq = [message objectForKey:@"seq"];
    static NSMutableSet *seqPool;
    @synchronized(self){
        if (!seqPool) {
            seqPool = [[NSMutableSet alloc] init];
        }
        if ([seqPool containsObject:seq]) {
            return;
        }else {
            [seqPool addObject:seq];
        }
    }
    
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
        
        NSNumber* result = [msg_dic objectForKey:@"result"];
        MTLOG(@"friend request result: %@",result);
        if ([result integerValue] == 1) {
            NSString* name = [msg_dic objectForKey:@"name"];
            NSString* email = [msg_dic objectForKey:@"email"];
            NSNumber* fid = [msg_dic objectForKey:@"id"];
            NSNumber* gender = [msg_dic objectForKey:@"gender"];
            [[MTDatabaseHelper sharedInstance]insertToTable:@"friend"
                                                withColumns:[[NSArray alloc]initWithObjects:@"id",@"name",@"email",@"gender", nil]
                                                  andValues:[[NSArray alloc] initWithObjects:
                                                             [NSString stringWithFormat:@"%@",fid],
                                                             [NSString stringWithFormat:@"'%@'",name],
                                                             [NSString stringWithFormat:@"'%@'",email],
                                                             [NSString stringWithFormat:@"%@",gender], nil]];
            
            NSDictionary* newFriend = [CommonUtils packParamsInDictionary:fid,@"id",name,@"name",gender,@"gender",email,@"email",nil];
            [[MTUser sharedInstance].friendList addObject:newFriend];
            [[MTUser sharedInstance] friendListDidChanged];
        }
        else if ([result integerValue] == 0)
        {
            MTLOG(@"friend request is refused");
        }
        
        type = 1;
        
        [[MTUser sharedInstance] synchronizeFriends];
        
    }
    else if (msg_cmd == NEW_COMMENT_NOTIFICATION || msg_cmd == NEW_PHOTO_NOTIFICATION || msg_cmd == NEW_VIDEO_NOTIFICATION) {
        if (![[MTUser sharedInstance].updateEventStatus objectForKey:[msg_dic valueForKey:@"event_id"]] ) {
            [[MTUser sharedInstance].updateEventStatus setObject:@[[msg_dic valueForKey:@"subject"],[NSNumber numberWithBool:NO],[NSNumber numberWithBool:NO],[NSNumber numberWithBool:NO]] forKey:[msg_dic valueForKey:@"event_id"]];
        }
        NSMutableArray *status = [[MTUser sharedInstance].updateEventStatus objectForKey:[msg_dic valueForKey:@"event_id"]];
        status = [NSMutableArray arrayWithArray:status];
        status[(msg_cmd - 990)] = [NSNumber numberWithBool:YES];
        [[MTUser sharedInstance].updateEventStatus setObject:status forKey:[msg_dic valueForKey:@"event_id"]];
        
        if (![[MTUser sharedInstance].updatePVStatus objectForKey:[msg_dic valueForKey:@"event_id"]] ) {
            [[MTUser sharedInstance].updatePVStatus setObject:@[[msg_dic valueForKey:@"subject"],[NSNumber numberWithBool:NO],[NSNumber numberWithBool:NO],[NSNumber numberWithBool:NO]] forKey:[msg_dic valueForKey:@"event_id"]];
        }
        NSMutableArray *pvStatus = [[MTUser sharedInstance].updatePVStatus objectForKey:[msg_dic valueForKey:@"event_id"]];
        pvStatus = [NSMutableArray arrayWithArray:pvStatus];
        pvStatus[(msg_cmd - 990)] = [NSNumber numberWithBool:YES];
        [[MTUser sharedInstance].updatePVStatus setObject:pvStatus forKey:[msg_dic valueForKey:@"event_id"]];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshPVRPStatus"
                                                            object:nil
                                                          userInfo:nil];
        type = -1;
        //        MTLOG(@"新动态数量：%lu",(unsigned long)[MTUser sharedInstance].updateEventStatus.count);
    }
    else if (msg_cmd == NEW_VIDEO_COMMENT_REPLY || msg_cmd == NEW_PHOTO_COMMENT_REPLY || msg_cmd == NEW_COMMENT_REPLY || msg_cmd == NEW_LIKE_NOTIFICATION) {
        if (msg_cmd == NEW_LIKE_NOTIFICATION) {
            //除重
            NSArray* atmeEvents = [NSArray arrayWithArray:[MTUser sharedInstance].atMeEvents];
            BOOL msgNeed = YES;
            for (int index = 0; index < atmeEvents.count; index ++) {
                NSDictionary* Oldmsg = atmeEvents[index];
                NSInteger Oldmsg_cmd = [[Oldmsg objectForKey:@"cmd"] integerValue];
                if (Oldmsg && Oldmsg_cmd == NEW_LIKE_NOTIFICATION) {
                    if ([[Oldmsg valueForKey:@"operation"] integerValue] == [[msg_dic valueForKey:@"operation"] integerValue]) {
                        NSInteger msg_operation = [[Oldmsg objectForKey:@"operation"] integerValue];
                        
                        if (msg_operation == 1) {
                            //活动评论点赞
                            if([[Oldmsg valueForKey:@"comment_id"] longValue] == [[msg_dic valueForKey:@"comment_id"] longValue] && [[Oldmsg valueForKey:@"author_id"] longValue] == [[msg_dic valueForKey:@"author_id"] longValue]){
                                [[MTUser sharedInstance].atMeEvents removeObject:Oldmsg];
                                [[MTUser sharedInstance].atMeEvents addObject:Oldmsg];
                                msgNeed = NO;
                                break;
                            }
                        }else if (msg_operation == 3){
                            //图片点赞
                            if([[Oldmsg valueForKey:@"photo_id"] longValue] == [[msg_dic valueForKey:@"photo_id"] longValue] && [[Oldmsg valueForKey:@"author_id"] longValue] == [[msg_dic valueForKey:@"author_id"] longValue]){
                                [[MTUser sharedInstance].atMeEvents removeObject:Oldmsg];
                                [[MTUser sharedInstance].atMeEvents addObject:Oldmsg];
                                msgNeed = NO;
                                break;
                            }
                        }else if (msg_operation == 5){
                            //视频点赞
                            if([[Oldmsg valueForKey:@"video_id"] longValue] == [[msg_dic valueForKey:@"video_id"] longValue] && [[Oldmsg valueForKey:@"author_id"] longValue] == [[msg_dic valueForKey:@"author_id"] longValue]){
                                [[MTUser sharedInstance].atMeEvents removeObject:Oldmsg];
                                [[MTUser sharedInstance].atMeEvents addObject:Oldmsg];
                                msgNeed = NO;
                                break;
                            }
                        }
                        
                    }
                }
            }
            if (msgNeed) [[MTUser sharedInstance].atMeEvents addObject:msg_dic];
            type = -1;
            MTLOG(@"有人@你： %@",msg_dic);
        }else{
            if ([[MTUser sharedInstance].atMeEvents containsObject:msg_dic]) {
                return;
            }
            [[MTUser sharedInstance].atMeEvents addObject:msg_dic];
            type = -1;
            MTLOG(@"有人@你： %@",msg_dic);
        }
    }
    else if (msg_cmd == QUIT_EVENT_NOTIFICATION) //活动被解散QUIT_EVENT_NOTIFICATION
    {
        [[MTUser sharedInstance].systemMsg insertObject:msg_dic atIndex:0];
        type = 2;
        
        NSNumber* event_id1 = [msg_dic objectForKey:@"event_id"];
        NSDictionary *wheres = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%@",event_id1],@"event_id", nil];
        [[MTDatabaseHelper sharedInstance]deleteTurpleFromTable:@"event" withWhere:wheres];
        
        
        NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:event_id1,@"eventId", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"deleteItem" object:nil userInfo:dict];
        
    }
    else if (msg_cmd == KICK_EVENT_NOTIFICATION) //被踢出活动984
    {
        [[MTUser sharedInstance].systemMsg insertObject:msg_dic atIndex:0];
        //        NSString* subject = [msg_dic objectForKey:@"subject"];
        type = 2;
        
        NSNumber* event_id1 = [msg_dic objectForKey:@"event_id"];
        NSDictionary *wheres = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%@",event_id1],@"event_id", nil];
        [[MTDatabaseHelper sharedInstance]deleteTurpleFromTable:@"event" withWhere:wheres];
        
        
        NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:event_id1,@"eventId", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"deleteItem" object:nil userInfo:dict];
        
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
        if([[msg_dic valueForKey:@"result"] boolValue]){
            [[NSNotificationCenter defaultCenter]postNotificationName:@"reloadEvent" object:nil userInfo:nil];
        }
    }
    else if (msg_cmd == NEW_EVENT_NOTIFICATION || msg_cmd == REQUEST_EVENT)
    {
        [[MTUser sharedInstance].eventRequestMsg insertObject:msg_dic atIndex:0];
        type = 0;
    }
    else if (msg_cmd == CHANGE_EVENT_INFO_NOTIFICATION)
    {
        [[MTUser sharedInstance].eventRequestMsg insertObject:msg_dic atIndex:0];
        type = 0;
    }
    
    
    NSArray* columns = [[NSArray alloc]initWithObjects:@"seq",@"msg",@"ishandled", nil];
    //    NSString* timeStamp = [msg_dic objectForKey:@"timestamp"];
    NSArray* values = [[NSArray alloc]initWithObjects:
                       [NSString stringWithFormat:@"%@",seq],
                       [NSString stringWithFormat:@"'%@'",content_str],
                       [NSString stringWithFormat:@"%d",-1],
                       nil];
    
    [[MTDatabaseHelper sharedInstance] insertToTable:@"notification" withColumns:columns andValues:values];
    
    NSString* key = [NSString stringWithFormat:@"USER%@", [MTUser sharedInstance].userid];
    NSUserDefaults* userDf = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary* userSettings = [NSMutableDictionary dictionaryWithDictionary:[userDf objectForKey:key]];
    
    [userSettings setValue:[NSNumber numberWithBool:YES] forKey:@"openWithNotificationCenter"];
    NSInteger i = (type < 3 && type >= 0)? type : -1;
    MTLOG(@"新消息来了，message type: %ld", (long)i);
    NSMutableDictionary* unRead_dic = [NSMutableDictionary dictionaryWithDictionary:[userSettings objectForKey:@"hasUnreadNotification1"]];
    
    if (!unRead_dic) {
        unRead_dic = [[NSMutableDictionary alloc]init];
    }
    if (i >= 0) {
        NSString* key_n = [NSString stringWithFormat:@"tab_%d", i];
        NSNumber* tabn_old = [unRead_dic objectForKey:key_n];
        NSNumber* tabn_new;
        if (tabn_old) {
            tabn_new = [NSNumber numberWithInteger:([tabn_old integerValue] + 1)];;
        }
        else
        {
            tabn_new = [NSNumber numberWithInteger:1];
        }
        [unRead_dic setValue:tabn_new forKey:key_n];
    }
    
    [unRead_dic setValue:[NSNumber numberWithInteger:i] forKey:@"tab_show"];
    [userSettings setValue:unRead_dic forKey:@"hasUnreadNotification1"];
    
    [userDf setObject:userSettings forKey:key];
    [userDf synchronize];
    MTLOG(@"appdelegate， unRead_dic: %@", unRead_dic);
    
    if ([(UIViewController*)[MTPushMessageHandler sharedInstance].notificationDelegate respondsToSelector:@selector(notificationDidReceive:)]) {
        [[MTPushMessageHandler sharedInstance].notificationDelegate notificationDidReceive:[NSArray arrayWithObject:message]];
    }
    
    int flag = type;
    if (flag >= 0) {
        //        MTLOG(@"收到新推送，显示消息中心红点");
        [(MenuViewController *)[SlideNavigationController sharedInstance].leftMenu showUpdateInRow:4];
        [[SlideNavigationController sharedInstance] showLeftBarButtonDian];
    }
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (delegate.isInBackground) {
        [(MenuViewController *)[SlideNavigationController sharedInstance].leftMenu showNotificationCenter];
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

+ (void)synchronizePushSeqAndCallBack:(void(^)(NSNumber* min_seq, NSNumber* max_seq))block
{
    MTLOG(@"开始同步消息");
    void(^returnResult)(NSData*) = ^(NSData* rData)
    {
        if (!rData) {
            MTLOG(@"服务器返回的消息为空");
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
        MTLOG(@"同步消息seq，返回结果: %@", response);
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
    MTLOG(@"发送同步序号请求：%@",json_dic);
    NSData* json_data = [NSJSONSerialization dataWithJSONObject:json_dic options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender* http = [[HttpSender alloc]initWithDelegate:self];
    [http sendMessage:json_data withOperationCode:PUSH_MESSAGE HttpMethod:HTTP_POST finshedBlock:returnResult];
}

+ (void)pullAndHandlePushMessageWithMinSeq:(NSNumber*)min_seq andMaxSeq:(NSNumber*)max_seq andCallBackBlock:(void(^)(NSDictionary* response))block
{
    void(^getPushMessageDone)(NSData*) = ^(NSData* rData)
    {
        if (!rData) {
            MTLOG(@"服务器返回的消息为空");
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
        MTLOG(@"拉取的推送: %@", response);
        switch (cmd) {
            case NORMAL_REPLY:
            {
                NSArray* list = [response objectForKey:@"list"];
                if (!list || list.count == 0) {
                    return;
                }
                
                for (int i = 0; i < list.count; i++) {
                    NSDictionary* message = [list objectAtIndex:i];
                    [self handlePushMessage:message andFeedBack:NO];
                }
                //反馈给服务器
                [self feedBackPushMessagewithMinSeq:min_seq andMaxSeq:max_seq andCallBack:^(NSDictionary *response) {
                    if ([response[@"cmd"] integerValue] == NORMAL_REPLY) {
                        if ([MTUser sharedInstance].userid) {
                            NSMutableDictionary* maxSeqDict = [[NSUserDefaults standardUserDefaults] objectForKey:@"maxNotificationSeq"];
                            NSNumber* remoteMaxSeq = @(MAX([min_seq integerValue], [max_seq integerValue]));
                            maxSeqDict = [[NSMutableDictionary alloc]initWithDictionary:maxSeqDict];
                            [maxSeqDict setObject:remoteMaxSeq forKey:[CommonUtils NSStringWithNSNumber:[MTUser sharedInstance].userid]];
                            
                            [[NSUserDefaults standardUserDefaults] setObject:maxSeqDict forKey:@"maxNotificationSeq"];
                            [[NSUserDefaults standardUserDefaults] synchronize];
                        }
                    }
                }];
            }
                break;
            default:
                break;
        }
        if (block) {
            block(response);
        }
    };
    NSNumber *localMinSeq = [min_seq copy];
    if ([MTUser sharedInstance].userid) {
        NSMutableDictionary* maxSeqDict = [[NSUserDefaults standardUserDefaults] objectForKey:@"maxNotificationSeq"];
        if (maxSeqDict) {
            NSNumber* localMaxSeq = [maxSeqDict objectForKey:[CommonUtils NSStringWithNSNumber:[MTUser sharedInstance].userid]];
            if(localMaxSeq){
                if ([localMaxSeq integerValue] > [max_seq integerValue] && [max_seq integerValue] != 0 && [min_seq integerValue]!= 0) {
                    //更新本地消息最大序号
                    maxSeqDict = [[NSMutableDictionary alloc]initWithDictionary:maxSeqDict];
                    [maxSeqDict setObject:min_seq forKey:[CommonUtils NSStringWithNSNumber:[MTUser sharedInstance].userid]];
                    [[NSUserDefaults standardUserDefaults] setObject:maxSeqDict forKey:@"maxNotificationSeq"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }else if([localMaxSeq integerValue] > [min_seq integerValue] && [max_seq integerValue] == 0 && [min_seq integerValue]!= 0){
                    //更新本地消息最大序号
                    maxSeqDict = [[NSMutableDictionary alloc]initWithDictionary:maxSeqDict];
                    [maxSeqDict setObject:min_seq forKey:[CommonUtils NSStringWithNSNumber:[MTUser sharedInstance].userid]];
                    [[NSUserDefaults standardUserDefaults] setObject:maxSeqDict forKey:@"maxNotificationSeq"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }else{
                    localMinSeq = [NSNumber numberWithInteger:[localMaxSeq integerValue]+1];
                }
            }
        }
    }
    
    NSDictionary* json_dic = [CommonUtils packParamsInDictionary:
                              [NSNumber numberWithInt:1], @"operation",
                              [MTUser sharedInstance].userid, @"id",
                              localMinSeq, @"min_seq",
                              max_seq, @"max_seq",
                              nil];
    MTLOG(@"拉取消息请求: %@", json_dic);
    NSData* json_data = [NSJSONSerialization dataWithJSONObject:json_dic options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender* http = [[HttpSender alloc]initWithDelegate:self];
    [http sendMessage:json_data withOperationCode:PUSH_MESSAGE HttpMethod:HTTP_POST finshedBlock:getPushMessageDone];
}

+ (void)feedBackPushMessagewithMinSeq:(NSNumber*)min_seq andMaxSeq:(NSNumber*)max_seq andCallBack:(void(^)(NSDictionary* response))block
{
    void(^feedbackDone)(NSData*) = ^(NSData* rData)
    {
        if (!rData) {
            MTLOG(@"服务器返回数据为空");
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
        MTLOG(@"反馈推送的结果：%@",temp);
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
    [http sendMessage:json_data withOperationCode:PUSH_MESSAGE HttpMethod:HTTP_POST finshedBlock:feedbackDone];
}

#pragma mark - System Push
+ (void)pullSystemNotificationWithSeq:(NSNumber*)seq
{
    if (!seq || [seq isEqual:[NSNull null]] || ![seq isKindOfClass:[NSNumber class]]) {
        return;
    }
    void (^pullsysDone)(NSData*) = ^(NSData* rData){
        if (!rData) {
            MTLOG(@"服务器返回数据为空");
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
        MTLOG(@"拉取系统推送的结果：%@",temp);
        NSDictionary* response = [CommonUtils NSDictionaryWithNSString:temp];
        NSArray* list = [response objectForKey:@"list"];
        if (list) {
            for (int i = 0; i < list.count; i++) {
                NSDictionary* list_item = [list objectAtIndex:i];
                if (!list_item || [list_item isEqual:[NSNull null]]) {
                    continue;
                }
                NSMutableDictionary* response_mul = [[NSMutableDictionary alloc]initWithDictionary:list_item];
                [response_mul setValue:seq forKey:@"seq"];
                [self handleSystemPushMessage:response_mul];
            }
            
        }
        
    };
    
    NSDictionary* json_dic = [CommonUtils packParamsInDictionary:
                              [NSNumber numberWithInt:3], @"operation",
                              seq, @"message_id",nil];
    MTLOG(@"拉取系统推送json: %@",json_dic);
    NSData* json_data = [NSJSONSerialization dataWithJSONObject:json_dic options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender* http = [[HttpSender alloc]initWithDelegate:self];
    [http sendMessage:json_data withOperationCode:PUSH_MESSAGE finshedBlock:pullsysDone];
}

+ (void)handleSystemPushMessage:(NSMutableDictionary*)md_message
{
    NSMutableDictionary* temp_message = [[NSMutableDictionary alloc]initWithDictionary:md_message];
    NSInteger cmd = [[temp_message objectForKey:@"cmd"]integerValue];
    NSNumber* seq = [temp_message objectForKey:@"seq"];
    int type = -1;
    if (cmd == SYSTEM_PUSH) {
        [[MTUser sharedInstance].systemMsg insertObject:temp_message atIndex:0];
        type = 2;
        if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"PopToFirstPageAndTurnToNotificationPage"
                                                                object:nil
                                                              userInfo:nil];
        }
    }
    else
    {
        return;
    }
    NSArray* columns = [[NSArray alloc]initWithObjects:@"seq",@"msg",@"ishandled", nil];
    NSArray* values = [[NSArray alloc]initWithObjects:
                       [NSString stringWithFormat:@"%@",seq],
                       [NSString stringWithFormat:@"'%@'",temp_message],
                       [NSString stringWithFormat:@"%d",-1],
                       nil];
    [[MTDatabaseHelper sharedInstance] insertToTable:@"notification" withColumns:columns andValues:values];
    
    NSString* key = [NSString stringWithFormat:@"USER%@", [MTUser sharedInstance].userid];
    NSUserDefaults* userDf = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary* userSettings = [NSMutableDictionary dictionaryWithDictionary:[userDf objectForKey:key]];
    
    [userSettings setValue:[NSNumber numberWithBool:YES] forKey:@"openWithNotificationCenter"];
    NSInteger i = (type < 3 && type >= 0)? type : -1;
    NSMutableDictionary* unRead_dic = [NSMutableDictionary dictionaryWithDictionary:[userSettings objectForKey:@"hasUnreadNotification1"]];
    
    if (!unRead_dic) {
        unRead_dic = [[NSMutableDictionary alloc]init];
    }
    if (i >= 0) {
        NSString* key_n = [NSString stringWithFormat:@"tab_%d", i];
        NSNumber* tabn_old = [unRead_dic objectForKey:key_n];
        NSNumber* tabn_new;
        if (tabn_old) {
            tabn_new = [NSNumber numberWithInteger:([tabn_old integerValue] + 1)];;
        }
        else
        {
            tabn_new = [NSNumber numberWithInteger:1];
        }
        [unRead_dic setValue:tabn_new forKey:key_n];
    }
    
    [unRead_dic setValue:[NSNumber numberWithInteger:i] forKey:@"tab_show"];
    [userSettings setValue:unRead_dic forKey:@"hasUnreadNotification1"];
    
    [userDf setObject:userSettings forKey:key];
    [userDf synchronize];
    MTLOG(@"appdelegate， unRead_dic: %@", unRead_dic);
    
    if ([(UIViewController*)[MTPushMessageHandler sharedInstance].notificationDelegate respondsToSelector:@selector(notificationDidReceive:)]) {
        [[MTPushMessageHandler sharedInstance].notificationDelegate notificationDidReceive:[NSArray arrayWithObject:temp_message]];
    }
    
    int flag = type;
    if (flag >= 0) {
        //        MTLOG(@"收到新推送，显示消息中心红点");
        [(MenuViewController *)[SlideNavigationController sharedInstance].leftMenu showUpdateInRow:4];
        [[SlideNavigationController sharedInstance] showLeftBarButtonDian];
    }
    
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (delegate.isInBackground) {
        [(MenuViewController *)[SlideNavigationController sharedInstance].leftMenu showNotificationCenter];
    }
    
    NSDictionary* pack = [CommonUtils packParamsInDictionary:
                          [NSNumber numberWithInteger:type], @"type",
                          temp_message, @"msg",
                          nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"pull_message" object:nil userInfo:pack];
    
    //反馈给服务器
    [self feedBackPushMessagewithMinSeq:seq andMaxSeq:seq andCallBack:nil];
}
@end
