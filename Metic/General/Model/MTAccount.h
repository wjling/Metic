//
//  MTAccount.h
//  WeShare
//
//  Created by 俊健 on 15/12/2.
//  Copyright (c) 2015年 WeShare. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ENUM(NSInteger, MTAccountType) {
    MTAccountTypeEmpty = -1,
    MTAccountTypeWeiBo,
    MTAccountTypeQQ,
    MTAccountTypeWeChat,
    MTAccountTypeEmail,
    MTAccountTypePhoneNumber,
};

@interface MTAccount : NSObject<NSCoding>

@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *phoneNumber;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *openId;
@property (nonatomic) enum MTAccountType type;
@property (nonatomic) BOOL hadCompleteInfo;

+ (BOOL)isExist;
+ (MTAccount *)singleInstance;
- (void)saveAccount;
- (void)deleteAccount;
@end
