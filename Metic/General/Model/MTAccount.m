//
//  MTAccount.m
//  WeShare
//
//  Created by 俊健 on 15/11/30.
//  Copyright (c) 2015年 WeShare. All rights reserved.
//

#import "MTAccount.h"

@implementation MTAccount

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"userId": @"id",
             @"lastLoginTime": @"logintime",
             @"minMegSeq": @"min_seq",
             @"maxMegSeq": @"max_seq",
             };
}
@end
