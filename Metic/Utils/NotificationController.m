//
//  NotificationController.m
//  WeShare
//
//  Created by ligang6 on 15-1-17.
//  Copyright (c) 2015年 WeShare. All rights reserved.
//

#import "NotificationController.h"
#import "MTUser.h"

@implementation NotificationController

//访问活动详情
+(void)visitEvent:(NSNumber*)EventId
{
    if (!EventId) return;
    NSArray *updatePVInfo = [[MTUser sharedInstance].updatePVStatus objectForKey:EventId];
    if (updatePVInfo) {
        NSMutableArray *status = [NSMutableArray arrayWithArray:updatePVInfo];
        status[3] = [NSNumber numberWithBool:NO];
        [[MTUser sharedInstance].updatePVStatus setObject:status forKey:EventId];
        [self clearInavalidPVInfo:EventId];
    }
    
    NSArray *updateInfo = [[MTUser sharedInstance].updateEventStatus objectForKey:EventId];
    if (updateInfo) {
        NSMutableArray *status = [NSMutableArray arrayWithArray:updateInfo];
        status[3] = [NSNumber numberWithBool:NO];
        [[MTUser sharedInstance].updateEventStatus setObject:status forKey:EventId];
        [self clearInavalidInfo:EventId];
    }

}

//访问图片墙,返回是否需要刷新
+(BOOL)visitPhotoWall:(NSNumber*)EventId needClear:(BOOL)needClear
{
    if (!EventId) return NO;
    BOOL ret = NO;
    NSArray *updatePVInfo = [[MTUser sharedInstance].updatePVStatus objectForKey:EventId];
    if (updatePVInfo) {
        NSMutableArray *status = [NSMutableArray arrayWithArray:updatePVInfo];
        if ([status[2]boolValue]) {
            ret = YES;
            if (needClear) {
                status[2] = [NSNumber numberWithBool:NO];
                [[MTUser sharedInstance].updatePVStatus setObject:status forKey:EventId];
            }
            
        }else ret = NO;
        if (needClear) [self clearInavalidPVInfo:EventId];
    }
    
    NSArray *updateInfo = [[MTUser sharedInstance].updateEventStatus objectForKey:EventId];
    if (updateInfo) {
        NSMutableArray *status = [NSMutableArray arrayWithArray:updateInfo];
        if ([status[2]boolValue]) {
            if (needClear) {
                status[2] = [NSNumber numberWithBool:NO];
                [[MTUser sharedInstance].updateEventStatus setObject:status forKey:EventId];
            }
            
        }
        if (needClear) [self clearInavalidInfo:EventId];
    }
    return ret;
}

//访问视频墙,返回是否需要刷新
+(BOOL)visitVideoWall:(NSNumber*)EventId needClear:(BOOL)needClear
{
    if (!EventId) return NO;
    BOOL ret = NO;
    NSArray *updatePVInfo = [[MTUser sharedInstance].updatePVStatus objectForKey:EventId];
    if (updatePVInfo) {
        NSMutableArray *status = [NSMutableArray arrayWithArray:updatePVInfo];
        if ([status[1]boolValue]) {
            ret = YES;
            if (needClear){
                status[1] = [NSNumber numberWithBool:NO];
                [[MTUser sharedInstance].updatePVStatus setObject:status forKey:EventId];
            }
        }else ret = NO;
        if (needClear) [self clearInavalidPVInfo:EventId];
    }
    
    NSArray *updateInfo = [[MTUser sharedInstance].updateEventStatus objectForKey:EventId];
    if (updateInfo) {
        NSMutableArray *status = [NSMutableArray arrayWithArray:updateInfo];
        if ([status[1]boolValue]) {
            if (needClear){
                status[1] = [NSNumber numberWithBool:NO];
                [[MTUser sharedInstance].updateEventStatus setObject:status forKey:EventId];
            }
        }
        if (needClear) [self clearInavalidInfo:EventId];
    }
    
    return ret;
}

//清除无效提醒信息
+(void)clearInavalidInfo:(NSNumber*)EventId{
    if (!EventId) return;
    NSArray *updateInfo = [[MTUser sharedInstance].updateEventStatus objectForKey:EventId];
    if (updateInfo) {
        if ([updateInfo[1]intValue]+[updateInfo[2]intValue]+[updateInfo[3]intValue] == 0) {
            [[MTUser sharedInstance].updateEventStatus removeObjectForKey:EventId];
        }
    }
}

//清除无效PV提醒信息
+(void)clearInavalidPVInfo:(NSNumber*)EventId{
    if (!EventId) return;
    NSArray *updatePVInfo = [[MTUser sharedInstance].updatePVStatus objectForKey:EventId];
    if (updatePVInfo) {
        if ([updatePVInfo[1]intValue]+[updatePVInfo[2]intValue] == 0) {
            [[MTUser sharedInstance].updatePVStatus removeObjectForKey:EventId];
        }
    }
}

//强制清除该活动所有提醒信息
+(void)clearEventInfo:(NSNumber*)EventId{
    if (!EventId) return;
    [[MTUser sharedInstance].updatePVStatus removeObjectForKey:EventId];
    [[MTUser sharedInstance].updateEventStatus removeObjectForKey:EventId];
}


@end
