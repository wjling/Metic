//
//  MTAccountManager.h
//  WeShare
//
//  Created by 俊健 on 15/11/30.
//  Copyright (c) 2015年 WeShare. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTLoginResponse.h"
#import "MTAccount.h"

NS_ENUM(NSInteger, MTLoginResult) {
    MTLoginResultSuccess = 0,
    MTLoginResultFailure = 1,
    MTLoginResultUnknown = 2,
    MTLoginResultPasswordInvalid = 3,
    MTLoginResultCancel = 4,
};

@interface MTAccountManager : NSObject

@property (nonatomic) BOOL hadCheckPassWord;

/**
 *  Login weshare
 */
+ (void)loginWithAccount:(NSString *)account
                password:(NSString *)password
                 success:(void (^)(MTLoginResponse *user))success
                 failure:(void (^)(enum MTLoginResult result, NSString *message))failure;

/**
 *
 *  Regist weshare With Email
 *  @param success the success callback
 *  @param failure the failure callback
 */
+ (void)registWithAccount:(NSString *)account
      password:(NSString *)password
       success:(void (^)(MTLoginResponse *user))success
       failure:(void (^)(enum MTLoginResult result, NSString *message))failure;

/**
 *
 *  Regist weshare With PhoneNumber
 *  @param success the success callback
 *  @param failure the failure callback
 */
+ (void)registWithPhoneNumber:(NSString *)phone
                     password:(NSString *)password
                      success:(void (^)(MTLoginResponse *user))success
                      failure:(void (^)(enum MTLoginResult result, NSString *message))failure;

/**
 *  Third Party Login weshare
 */
+ (void)thirdPartyLoginWithOpenId:(NSString *)openId
                             type:(enum MTAccountType)thirdPartyType
                          success:(void (^)(MTLoginResponse *user))success
                          failure:(void (^)(enum MTLoginResult result, NSString *message))failure;


@end
