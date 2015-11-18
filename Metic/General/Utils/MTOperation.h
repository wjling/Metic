//
//  MTOperation.h
//  WeShare
//
//  Created by 俊健 on 15/5/20.
//  Copyright (c) 2015年 WeShare. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MTOperation : NSObject
+ (MTOperation *)sharedInstance;

typedef void(^likeEventFinishBlock)(BOOL isSuccess,NSString* likeTime);

//添加那些把自己删掉的好友
-(void)inviteFriends:(NSArray*)notFriendsList;

//处理收藏活动id数据
-(NSArray*)processLikeEventID:(NSArray*)likeEventIdData;

//收藏／取消收藏活动操作
-(void)likeEventOperation:(NSArray*)eventIds like:(BOOL)islike finishBlock:(likeEventFinishBlock)finishBlock;

-(void)getUrlFromServer:(NSString*) path
                 success:(void (^)(NSString* url))success
                 failure:(void (^)(NSString* message))failure;

-(void)getVideoUrlFromServerWith:(NSString*) videoName
                         success:(void (^)(NSString* url))success
                         failure:(void (^)(NSString* message))failure;

@end
