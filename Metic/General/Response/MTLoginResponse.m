//
//  MTLoginResponse.m
//  WeShare
//
//  Created by 俊健 on 15/11/30.
//  Copyright (c) 2015年 WeShare. All rights reserved.
//

#import "MTLoginResponse.h"

@implementation MTLoginResponse

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"userId": @"id",
             @"hadCompleteInfo": @"info_complete",
             @"lastLoginTime": @"logintime",
             @"minMegSeq": @"min_seq",
             @"maxMegSeq": @"max_seq",
             };
}
@end
