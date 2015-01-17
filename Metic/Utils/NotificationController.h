//
//  NotificationController.h
//  WeShare
//
//  Created by ligang6 on 15-1-17.
//  Copyright (c) 2015年 WeShare. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NotificationController : NSObject

//访问活动详情
+(void)visitEvent:(NSNumber*)EventId;

//访问图片墙,返回是否需要刷新
+(BOOL)visitPhotoWall:(NSNumber*)EventId needClear:(BOOL)needClear;

//访问视频墙,返回是否需要刷新
+(BOOL)visitVideoWall:(NSNumber*)EventId needClear:(BOOL)needClear;

//清除无效提醒信息
+(void)clearInavalidInfo:(NSNumber*)EventId;
@end
