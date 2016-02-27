//
//  MTOperation.h
//  WeShare
//
//  Created by 俊健 on 15/5/20.
//  Copyright (c) 2015年 WeShare. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ENUM(NSInteger, MTMediaType) {
    MTMediaTypeComment = -1,
    MTMediaTypePhoto,
    MTMediaTypeVideo,
};

@interface MTOperation : NSObject
+ (MTOperation *)sharedInstance;

typedef void(^likeEventFinishBlock)(BOOL isSuccess,NSString* likeTime);

typedef void(^likeMediaObjectFinishBlock)(BOOL isValid);

typedef void(^modifySpecificationFinishBlock)(BOOL isSuccess,NSString* likeTime);


//添加那些把自己删掉的好友
-(void)inviteFriends:(NSArray*)notFriendsList;

//处理收藏活动id数据
-(NSArray*)processLikeEventID:(NSArray*)likeEventIdData;

//收藏／取消收藏活动操作
-(void)likeEventOperation:(NSArray*)eventIds like:(BOOL)islike finishBlock:(likeEventFinishBlock)finishBlock;

//点赞/取消点赞操作
-(void)likeOperationWithType:(enum MTMediaType)type mediaId:(NSNumber *)mediaId eventId:(NSNumber *)eventId like:(BOOL)isLike finishBlock:(likeMediaObjectFinishBlock)finishBlock;

//修改图片描述操作
-(void)modifyPhotoSpecification:(NSString *)specification
                    withPhotoId:(NSNumber *)photoId
                        eventId:(NSNumber *)eventId
                        success:(void (^)())success
                        failure:(void (^)(NSString *message))failure;

//修改视频描述操作
-(void)modifyVideoSpecification:(NSString *)specification
                    withVideoId:(NSNumber *)videoId
                        eventId:(NSNumber *)eventId
                        success:(void (^)())success
                        failure:(void (^)(NSString *message))failure;

//获取视频分享链接
-(void)getVideoShareLinkEventId:(NSNumber *)eventId
                        videoId:(NSNumber *)videoId
                        success:(void (^)(NSString *shareLink))success
                        failure:(void (^)(NSString *message))failure;

-(void)checkPhotoFromServer:(NSString*) path
                       size:(CGSize)size
                    success:(void (^)(NSString* scalePath))success
                    failure:(void (^)(NSString* savePath, CGSize saveSize))failure;

-(void)getUrlFromServer:(NSString*) path
                 success:(void (^)(NSString* url))success
                 failure:(void (^)(NSString* message))failure;

-(void)getVideoUrlFromServerWith:(NSString*) videoName
                         success:(void (^)(NSString* url))success
                         failure:(void (^)(NSString* message))failure;

@end
