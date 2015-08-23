//
//  MegUtils.m
//  WeShare
//
//  Created by 俊健 on 15/8/15.
//  Copyright (c) 2015年 WeShare. All rights reserved.
//

#import "MegUtils.h"
#import "AppConstants.h"

@implementation MegUtils

+(NSString *)avatarImagePathWithUserId:(NSNumber *)userId
{
    if (!userId)
        return @"";
    return [NSString stringWithFormat:@"/%@/avatar/%@.jpg",@[@"metis201415",@"whatsact"][Server],userId];
}

+(NSString *)avatarHDImagePathWithUserId:(NSNumber *)userId
{
    if (!userId)
        return @"";
    return [NSString stringWithFormat:@"/%@/avatar/%@_2.jpg",@[@"metis201415",@"whatsact"][Server],userId];
}

+(NSString *)bannerImagePathWithEventId:(NSNumber *)eventId
{
    if (!eventId)
        return @"";
    return [NSString stringWithFormat:@"/%@/banner/%@.jpg",@[@"metis201415",@"whatsact"][Server],eventId];
}

+(NSString *)photoImagePathWithImageName:(NSString *)imageName
{
    if (!imageName || [imageName isEqualToString:@""])
        return @"";
    return [NSString stringWithFormat:@"/%@/images/%@",@[@"metis201415",@"whatsact"][Server],imageName];
}

+(NSString *)videoThummbImagePathWithVideoName:(NSString *)videoName
{
    if (!videoName || [videoName isEqualToString:@""])
        return @"";
    return [NSString stringWithFormat:@"/%@/video/%@.thumb",@[@"metis201415",@"whatsact"][Server],videoName];
}

@end
