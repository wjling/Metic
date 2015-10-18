//
//  MegUtils.h
//  WeShare
//
//  Created by 俊健 on 15/8/15.
//  Copyright (c) 2015年 WeShare. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MegUtils : NSObject

+(NSString *)avatarImagePathWithUserId:(NSNumber *)userId;

+(NSString *)avatarHDImagePathWithUserId:(NSNumber *)userId;

+(NSString *)bannerImagePathWithEventId:(NSNumber *)eventId;

+(NSString *)photoImagePathWithImageName:(NSString *)imageName;

+(NSString *)videoThummbImagePathWithVideoName:(NSString *)videoName;

+(NSString *)videoPathWithVideoName:(NSString *)videoName;

@end
