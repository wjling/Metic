//
//  MTDatabaseAffairs.h
//  WeShare
//
//  Created by 俊健 on 15/5/26.
//  Copyright (c) 2015年 WeShare. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTDatabaseHelper.h"

@interface MTDatabaseAffairs : NSObject

+ (MTDatabaseAffairs *)sharedInstance;
//保存活动信息至数据库
-(void)saveEventToDB:(NSDictionary*)event;

//保存图片信息至数据库
+ (void)updatePhotoInfoToDB:(NSArray*)photoInfos eventId:(NSNumber*)eventId;

//保存视频信息至数据库
+ (void)updateVideoInfoToDB:(NSArray*)videoInfos eventId:(NSNumber*)eventId;

@end
