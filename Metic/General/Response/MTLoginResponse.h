//
//  MTLoginResponse.h
//  WeShare
//
//  Created by 俊健 on 15/11/30.
//  Copyright (c) 2015年 WeShare. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Mantle.h"
#import "MTLJSONAdapter.h"

@interface MTLoginResponse : MTLModel <MTLJSONSerializing>

@property (nonatomic, strong) NSNumber *userId;
@property (nonatomic, strong) NSNumber *hadCompleteInfo;
@property (nonatomic, strong) NSString *lastLoginTime;
@property (nonatomic, strong) NSNumber *minMegSeq;
@property (nonatomic, strong) NSNumber *maxMegSeq;

@end
