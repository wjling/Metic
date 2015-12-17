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
    MTLoginResultFailure,
    MTLoginResultUnknown,
    MTLoginResultNotActive,
    MTLoginResultPasswordInvalid,
    MTLoginResultCancel,
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
+ (void)registWithEmail:(NSString *)email
               password:(NSString *)password
                success:(void (^)(MTLoginResponse *user))success
                failure:(void (^)(enum MTLoginResult result, NSString *message))failure;

/**
 *
 *  Resend Activate Email
 *  @param success the success callback
 *  @param failure the failure callback
 */
+ (void)resendActivateEmail:(NSString *)email
                success:(void (^)())success
                failure:(void (^)(NSString *message))failure;
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

/**
 *  Reset Password With PhoneNumber
 */
+ (void)resetPwWithPhoneNumber:(NSString *)phone
                     password:(NSString *)password
                      success:(void (^)())success
                      failure:(void (^)(NSString *message))failure;

/**
 *  Modify Password With Account
 */
+ (void)modifyPwWithAccount:(NSString *)account
                oldPassword:(NSString *)oldPassword
                newPassword:(NSString *)newPassword
                    success:(void (^)())success
                    failure:(void (^)(NSString *message))failure;

/**
 *  Bind Phone With Account
 */
+ (void)bindPhoneWithUserId:(NSNumber *)userId
                phoneNumber:(NSString *)phoneNumber
                     toBind:(BOOL)toBind
                    success:(void (^)())success
                    failure:(void (^)(NSString *message))failure;

@end
