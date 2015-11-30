//
//  MTLoginManager.h
//  WeShare
//
//  Created by 俊健 on 15/11/30.
//  Copyright (c) 2015年 WeShare. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTAccount.h"

NS_ENUM(NSInteger, MTLoginResult) {
    MTLoginResultSuccess = 0,
    MTLoginResultFailure = 1,
    MTLoginResultUnknown = 2,
    MTLoginResultPasswordInvalid = 3,
    MTLoginResultCancel = 4,
};

@interface MTLoginManager : NSObject

@property (nonatomic) BOOL hadCheckPassWord;

/**
 *  Login weshare
 */
+ (void)loginWithAccount:(NSString *)account
                password:(NSString *)password
                 success:(void (^)(MTAccount *user))success
                 failure:(void (^)(enum MTLoginResult result, NSString *message))failure;


/**
 *
 *  Regist weshare
 *  @param success the success callback
 *  @param failure the failure callback
 */
+ (void)regist:(NSString *)username
      password:(NSString *)password
       success:(void (^)(MTAccount *user))success
       failure:(void (^)(enum MTLoginResult result, NSString *message))failure;

@end
