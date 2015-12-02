//
//  MTAccountManager.m
//  WeShare
//
//  Created by 俊健 on 15/11/30.
//  Copyright (c) 2015年 WeShare. All rights reserved.
//

#import "MTAccountManager.h"
#import "HttpSender.h"
#import "CommonUtils.h"

typedef void(^MTLoginCompletedBlock)(BOOL isValid, NSString *errMeg);

@implementation MTAccountManager

+ (void)loginWithAccount:(NSString *)account
                password:(NSString *)password
                 success:(void (^)(MTLoginResponse *user))success
                 failure:(void (^)(enum MTLoginResult result, NSString *message))failure
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:account forKey:@"email"];
    [dictionary setValue:@"" forKey:@"passwd"];
    [dictionary setValue:[NSNumber numberWithBool:NO] forKey:@"has_salt"];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:LOGIN_DJANGO finshedBlock:^(NSData *rData) {
        if (!rData) {
            failure(MTLoginResultFailure,@"网络异常，请重试");
            return;
        }
        NSString* temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
        MTLOG(@"Received Data: %@",temp);
        NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
        NSNumber *cmd = [response1 valueForKey:@"cmd"];
        switch ([cmd intValue]) {
            case GET_SALT:
            {
                NSString *salt = [response1 valueForKey:@"salt"];
                NSString *str = [password stringByAppendingString:salt];
                
                //MD5 encrypt
                NSMutableString *md5_str = [NSMutableString string];
                md5_str = [CommonUtils MD5EncryptionWithString:str];
                
                NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
                [params setValue:account forKey:@"email"];
                [params setValue:md5_str forKey:@"passwd"];
                [params setValue:[NSNumber numberWithBool:YES] forKey:@"has_salt"];
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil];
                HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
                [httpSender sendMessage:jsonData withOperationCode:LOGIN_DJANGO finshedBlock:^(NSData *rData) {
                    if (!rData) {
                        failure(MTLoginResultFailure,@"网络异常，请重试");
                        return;
                    }
                    NSString* temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
                    MTLOG(@"Received Data: %@",temp);
                    NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
                    NSNumber *cmd = [response1 valueForKey:@"cmd"];
                    switch ([cmd intValue]) {
                        case LOGIN_SUC:
                        {
                            MTLOG(@"验证密码成功");
                            MTLoginResponse *user = [MTLJSONAdapter modelOfClass:[MTLoginResponse class]
                                                        fromJSONDictionary:response1
                                                                     error:nil];
                            success(user);
                        }
                            break;
                        case PASSWD_NOT_CORRECT:
                        {
                            MTLOG(@"password not correct");
                            failure(MTLoginResultPasswordInvalid,@"密码错误，请重试");
                        }
                            break;
                        case USER_NOT_FOUND:
                        {
                            MTLOG(@"user not found");
                            failure(MTLoginResultFailure,@"此用户不存在，请先注册");
                        }
                        default:
                        {
                            MTLOG(@"server error");
                            failure(MTLoginResultUnknown,@"服务器异常");
                        }
                    }
                }];
                
            }
                break;
            default:
            {
                failure(MTLoginResultFailure,@"网络异常，请重试");
            }
        }
    }];
}

+ (void)registWithAccount:(NSString *)account
                 password:(NSString *)password
                  success:(void (^)(MTLoginResponse *user))success
                  failure:(void (^)(enum MTLoginResult result, NSString *message))failure
{
    NSString* salt = [CommonUtils randomStringWithLength:6];
    NSMutableString* md5_str = [CommonUtils MD5EncryptionWithString:[[NSString alloc]initWithFormat:@"%@%@",password,salt]];
    NSMutableDictionary* mDic = [CommonUtils packParamsInDictionary:account,@"email",md5_str,@"passwd",account,@"name",@1,@"gender",salt,@"salt",nil];

    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:mDic options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender* httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:REGISTER finshedBlock:^(NSData *rData) {
        if (!rData) {
            failure(MTLoginResultFailure,@"网络异常，请重试");
            return ;
        }
        NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
        NSNumber *cmd = [response1 valueForKey:@"cmd"];
        switch ([cmd intValue]) {
            case NORMAL_REPLY: {
                MTLOG(@"注册成功");
//                MTAccount *user = [MTLJSONAdapter modelOfClass:[MTAccount class]
//                                            fromJSONDictionary:response1
//                                                         error:nil];
                success(nil);
            }
                break;
            case USER_EXIST: {
                MTLOG(@"user existed");
                failure(MTLoginResultFailure,@"用户已存在");
            }
                break;
            default:
                MTLOG(@"server error");
                failure(MTLoginResultUnknown,@"服务器异常");
        }
    }];
}

+ (void)registWithPhoneNumber:(NSString *)phone
                     password:(NSString *)password
                      success:(void (^)(MTLoginResponse *user))success
                      failure:(void (^)(enum MTLoginResult result, NSString *message))failure
{
    NSString* salt = [CommonUtils randomStringWithLength:6];
    NSMutableString* md5_str = [CommonUtils MD5EncryptionWithString:[[NSString alloc]initWithFormat:@"%@%@",password,salt]];
    NSMutableDictionary* mDic = [CommonUtils packParamsInDictionary:phone,@"phone",md5_str,@"passwd",salt,@"salt",nil];
    
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:mDic options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender* httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:REGISTER_BY_PHONE finshedBlock:^(NSData *rData) {
        if (!rData) {
            failure(MTLoginResultFailure,@"网络异常，请重试");
            return ;
        }
        NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
        NSNumber *cmd = [response1 valueForKey:@"cmd"];
        switch ([cmd intValue]) {
            case NORMAL_REPLY: {
                MTLOG(@"注册成功");
                MTLoginResponse *user = [MTLJSONAdapter modelOfClass:[MTLoginResponse class]
                                            fromJSONDictionary:response1
                                                         error:nil];
                success(user);
            }
                break;
            case USER_EXIST: {
                MTLOG(@"user existed");
                failure(MTLoginResultFailure,@"用户已存在");
            }
                break;
            default:
                MTLOG(@"server error");
                failure(MTLoginResultUnknown,@"服务器异常");
        }
    }];
}

+ (void)thirdPartyLoginWithOpenId:(NSString *)openId
                             type:(enum MTAccountType)thirdPartyType
                          success:(void (^)(MTLoginResponse *user))success
                          failure:(void (^)(enum MTLoginResult result, NSString *message))failure
{
    NSDictionary *dict = @{@"openid":openId,
                           @"third_type":@(thirdPartyType)};
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender* httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:THIRD_PARTY_LOGIN finshedBlock:^(NSData *rData) {
        if (!rData) {
            failure(MTLoginResultFailure,@"网络异常，请重试");
            return ;
        }
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
        NSNumber *cmd = [response valueForKey:@"cmd"];
        switch ([cmd intValue]) {
            case LOGIN_SUC:
            {
                MTLOG(@"登录成功");
                MTLoginResponse *user = [MTLJSONAdapter modelOfClass:[MTLoginResponse class]
                                            fromJSONDictionary:response
                                                         error:nil];
                success(user);
            }
                break;
            case USER_NOT_FOUND:
            {
                MTLOG(@"用户不存在");
                failure(MTLoginResultPasswordInvalid,@"用户不存在");
            }
                break;
            case REQUEST_DATA_ERROR:
            {
                MTLOG(@"请求参数错误");
                failure(MTLoginResultPasswordInvalid,@"请求参数错误");
            }
                break;
            default:
            {
                MTLOG(@"其他错误");
                failure(MTLoginResultPasswordInvalid,@"未知错误");
            }
        }
    }];
}

@end
