//
//  MTPushMessageHandler.h
//  WeShare
//
//  Created by 俊健 on 15/11/18.
//  Copyright (c) 2015年 WeShare. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NotificationDelegate

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

@optional
-(void) notificationDidReceive:(NSArray*) messages;
@end

@interface MTPushMessageHandler : NSObject

@property (strong, nonatomic) id<NotificationDelegate> notificationDelegate;

+ (MTPushMessageHandler *)sharedInstance;

//信鸽推送相关
+ (void)registerPush;

#pragma mark - Normal Push
+ (void)handlePushMessage:(NSDictionary*)message andFeedBack:(BOOL)feedback;
+ (void)synchronizePushSeqAndCallBack:(void(^)(NSNumber* min_seq, NSNumber* max_seq))block;
+ (void)pullAndHandlePushMessageWithMinSeq:(NSNumber*)min_seq andMaxSeq:(NSNumber*)max_seq andCallBackBlock:(void(^)(NSDictionary* response))block;
+ (void)feedBackPushMessagewithMinSeq:(NSNumber*)min_seq andMaxSeq:(NSNumber*)max_seq andCallBack:(void(^)(NSDictionary* response))block;

#pragma mark - System Push
+ (void)pullSystemNotificationWithSeq:(NSNumber*)seq;
+ (void)handleSystemPushMessage:(NSMutableDictionary*)md_message;

@end
