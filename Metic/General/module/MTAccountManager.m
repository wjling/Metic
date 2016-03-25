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
                if ([salt isEqual:[NSNull null]]) {
                    salt = @"";
                }
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
                        case USER_NOT_ACTIVE:
                        {
                            failure(MTLoginResultNotActive,@"此账户尚未激活");
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
                            break;
                        default:
                        {
                            MTLOG(@"server error");
                            failure(MTLoginResultUnknown,@"服务器异常");
                        }
                    }
                }];
                
            }
                break;
            case USER_NOT_ACTIVE:
            {
                failure(MTLoginResultNotActive,@"此账户尚未激活");
            }
                break;
            case USER_NOT_FOUND: {
                MTLOG(@"user not existed");
                failure(MTLoginResultFailure,@"用户不存在");
            }
                break;
            default:
            {
                failure(MTLoginResultFailure,@"网络异常，请重试");
            }
        }
    }];
}

+ (void)registWithEmail:(NSString *)email
               password:(NSString *)password
                success:(void (^)(MTLoginResponse *user))success
                failure:(void (^)(enum MTLoginResult result, NSString *message))failure;
{
    NSString* salt = [CommonUtils randomStringWithLength:6];
    NSMutableString* md5_str = [CommonUtils MD5EncryptionWithString:[[NSString alloc]initWithFormat:@"%@%@",password,salt]];

    NSMutableDictionary* mDic = [[NSMutableDictionary alloc] init];
    if (email) mDic[@"email"] = email;
    if (md5_str) mDic[@"passwd"] = md5_str;
    if (salt) mDic[@"salt"] = salt;

    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:mDic options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender* httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:REGISTER_DJANGO finshedBlock:^(NSData *rData) {
        if (!rData) {
            failure(MTLoginResultFailure,@"网络异常，请重试");
            return ;
        }
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
        NSNumber *cmd = [response valueForKey:@"cmd"];
        switch ([cmd intValue]) {
            case NORMAL_REPLY: {
                MTLOG(@"注册成功");
                success(nil);
            }
                break;
            case USER_EXIST: {
                MTLOG(@"user existed");
                failure(MTLoginResultFailure,@"用户已存在");
            }
                break;
            case USER_NOT_ACTIVE: {
                failure(MTLoginResultNotActive,@"此账户尚未激活");
            }
                break;
            case REQUEST_DATA_ERROR: {
                MTLOG(@"request data error");
                failure(MTLoginResultFailure,@"未知错误");
            }
                break;
            default:
                MTLOG(@"server error");
                failure(MTLoginResultUnknown,@"服务器异常");
        }
    }];
}

+ (void)resendActivateEmail:(NSString *)email
                    success:(void (^)())success
                    failure:(void (^)(NSString *message))failure
{
    NSMutableDictionary* mDic = [[NSMutableDictionary alloc] init];
    if (email) mDic[@"email"] = email;
    
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:mDic options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender* httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:REGISTER_RESEND finshedBlock:^(NSData *rData) {
        if (!rData) {
            failure(@"网络异常，请重试");
            return ;
        }
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
        NSNumber *cmd = [response valueForKey:@"cmd"];
        switch ([cmd intValue]) {
            case NORMAL_REPLY: {
                MTLOG(@"发送成功，请激活");
                success();
            }
                break;
            default:
                MTLOG(@"发送失败");
                failure(@"发送失败");
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
    NSMutableDictionary* mDic = [[NSMutableDictionary alloc] init];
    if (phone) mDic[@"phone"] = phone;
    if (md5_str) mDic[@"passwd"] = md5_str;
    if (salt) mDic[@"salt"] = salt;
    
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

#pragma mark - reset Password
+ (void)resetPwWithPhoneNumber:(NSString *)phone
                      password:(NSString *)password
                       success:(void (^)())success
                       failure:(void (^)(NSString *message))failure
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:phone forKey:@"email"];
    [dictionary setValue:@"" forKey:@"passwd"];
    [dictionary setValue:[NSNumber numberWithBool:NO] forKey:@"has_salt"];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:LOGIN_DJANGO finshedBlock:^(NSData *rData) {
        if (!rData) {
            failure(@"网络异常，请重试");
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
                if ([salt isEqual:[NSNull null]]) {
                    salt = @"";
                }
                NSString *str = [password stringByAppendingString:salt];
                
                //MD5 encrypt
                NSMutableString *md5_str = [NSMutableString string];
                md5_str = [CommonUtils MD5EncryptionWithString:str];

                NSMutableDictionary *mDic = [[NSMutableDictionary alloc] init];
                [mDic setValue:phone forKey:@"phone"];
                [mDic setValue:md5_str forKey:@"passwd"];

                
                NSData* jsonData = [NSJSONSerialization dataWithJSONObject:mDic options:NSJSONWritingPrettyPrinted error:nil];
                HttpSender* httpSender = [[HttpSender alloc]initWithDelegate:self];
                [httpSender sendMessage:jsonData withOperationCode:RESET_PASSWD_PHONE finshedBlock:^(NSData *rData) {
                    if (!rData) {
                        failure(@"网络异常，请重试");
                        return ;
                    }
                    NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
                    NSNumber *cmd = [response1 valueForKey:@"cmd"];
                    switch ([cmd intValue]) {
                        case NORMAL_REPLY: {
                            MTLOG(@"密码重置成功");
                            success();
                        }
                            break;
                        case USER_NOT_FOUND: {
                            MTLOG(@"user not existed");
                            failure(@"用户不存在");
                        }
                            break;
                        default:
                            MTLOG(@"server error");
                            failure(@"服务器异常");
                    }
                }];
            }
                break;
            case USER_NOT_ACTIVE:
            {
                failure(@"此账户尚未激活");
            }
                break;
            case USER_NOT_FOUND: {
                MTLOG(@"user not existed");
                failure(@"用户不存在");
            }
                break;
            default:
            {
                failure(@"服务器异常");
            }
        }
    }];
}

+ (void)modifyPwWithAccount:(NSString *)account
                oldPassword:(NSString *)oldPassword
                newPassword:(NSString *)newPassword
                    success:(void (^)())success
                    failure:(void (^)(NSString *message))failure
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:account forKey:@"email"];
    [dictionary setValue:@"" forKey:@"passwd"];
    [dictionary setValue:[NSNumber numberWithBool:NO] forKey:@"has_salt"];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:LOGIN_DJANGO finshedBlock:^(NSData *rData) {
        if (!rData) {
            failure(@"网络异常，请重试");
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
                NSString *currentPS_md5 = [CommonUtils MD5EncryptionWithString:[oldPassword stringByAppendingString:salt]];
                NSString *modifyPS_md5 = [CommonUtils MD5EncryptionWithString:[newPassword stringByAppendingString:salt]];
                
                NSMutableDictionary *json_dic = [[NSMutableDictionary alloc] init];
                [json_dic setValue:account forKey:@"email"];
                [json_dic setValue:currentPS_md5 forKey:@"passwd"];
                [json_dic setValue:modifyPS_md5 forKey:@"newpw"];
                [json_dic setValue:[NSNumber numberWithBool:NO] forKey:@"has_salt"];
                

                NSData* jsonData = [NSJSONSerialization dataWithJSONObject:json_dic options:NSJSONWritingPrettyPrinted error:nil];
                HttpSender* http = [[HttpSender alloc]initWithDelegate:self];
                [http sendMessage:jsonData withOperationCode:CHANGE_PW finshedBlock:^(NSData *rData) {
                    NSString* temp = @"";
                    if (rData) {
                        temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
                    } else {
                        MTLOG(@"修改密码，收到的rData为空");
                        failure(@"网络异常，请重试");
                        return;
                    }
                    MTLOG(@"Received Data: %@",temp);
                    NSMutableDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
                    NSNumber* cmd = [response1 objectForKey:@"cmd"];
                    MTLOG(@"cmd: %@",cmd);
                    if ([cmd integerValue] == NORMAL_REPLY) {
                        success();
                    } else {
                        failure(@"修改密码失败");
                    }
                }];
            }
                break;
            case USER_NOT_ACTIVE:
            {
                failure(@"此账户尚未激活");
            }
                break;
            case USER_NOT_FOUND: {
                MTLOG(@"user not existed");
                failure(@"用户不存在");
            }
                break;
            default:
            {
                failure(@"服务器异常");
            }
        }
    }];
}

+ (void)bindPhoneWithUserId:(NSNumber *)userId
                phoneNumber:(NSString *)phoneNumber
                   password:(NSString *)password
                       salt:(NSString *)salt
                     toBind:(enum MTPhoneBindSataus)toBind
                    success:(void (^)())success
                    failure:(void (^)(enum Return_Code errorCode, NSString *message, NSDictionary *info))failure
{
    NSMutableDictionary* json_dic = [[NSMutableDictionary alloc] init];
 
    if (toBind ==  MTPhoneBindSatausToBind && [password isKindOfClass:[NSString class]] && !salt) {
        salt = [CommonUtils randomStringWithLength:5];
    }
    if (toBind ==  MTPhoneBindSatausToBind && password && salt && salt.length == 5) {
        NSString *PS_md5 = [CommonUtils MD5EncryptionWithString:[password stringByAppendingString:salt]];
        json_dic[@"passwd"] = PS_md5;
        json_dic[@"salt"] = salt;
    }

    json_dic[@"id"] = userId;
    json_dic[@"my_phone"] = phoneNumber;
    json_dic[@"bind"] = @(toBind);
    
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:json_dic options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender* http = [[HttpSender alloc]initWithDelegate:self];
    [http sendMessage:jsonData withOperationCode:BIND_PHONE finshedBlock:^(NSData *rData) {
        NSString* temp = @"";
        if (rData) {
            temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
        } else {
            MTLOG(@"修改密码，收到的rData为空");
            failure(REQUEST_FAIL, @"网络异常，请重试", nil);
            return;
        }
        MTLOG(@"Received Data: %@",temp);
        NSMutableDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
        NSNumber* cmd = [response1 objectForKey:@"cmd"];
        MTLOG(@"cmd: %@",cmd);
        switch ([cmd intValue]) {
            case NORMAL_REPLY:
                success();
                break;
            case DATABASE_ERROR:
                MTLOG(@"database error");
                failure(DATABASE_ERROR, @"服务器发生错误", nil);
                break;
            case REQUEST_DATA_ERROR:
                MTLOG(@"request data error");
                failure(REQUEST_DATA_ERROR, @"请求错误", nil);
                break;
            case BIND_PHONE_ALREADY:
                MTLOG(@"bind phone already");
                if (toBind) {
                    failure(BIND_PHONE_ALREADY, @"绑定失败，此账号已经绑定另一手机号", nil);
                }else {
                    failure(BIND_PHONE_ALREADY, @"手机注册用户暂时不开通解绑功能", nil);
                }
                break;
            case BIND_PHONE_ERROR:
                MTLOG(@"request data error");
                if (toBind) {
                    failure(BIND_PHONE_ERROR, @"绑定失败，此手机号已被绑定", nil);
                }else {
                    failure(BIND_PHONE_ERROR, @"解绑失败", nil);
                }
                break;
            case PASSWD_NOT_SETTING: {
                NSString *salt = response1[@"salt"];
                failure(PASSWD_NOT_SETTING, @"请设置登录密码", salt? @{@"salt":salt}:nil);
            }
                break;
            default:
            {
                failure(REQUEST_FAIL, @"服务器异常", nil);
            }
        }
    }];
}

+ (void)checkPhoneInUse:(NSString *)phoneNumber
                    success:(void (^)(BOOL isInused))success
                    failure:(void (^)(NSString *message))failure
{
    if (!phoneNumber || ![phoneNumber isKindOfClass:[NSString class]] || [phoneNumber isEqualToString:@""]) {
        failure(@"输入错误");
        return;
    }
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:phoneNumber forKey:@"phone"];
    [dictionary setValue:@"" forKey:@"passwd"];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:CHECK_PHONE_AVAIL finshedBlock:^(NSData *rData) {
        if (!rData) {
            failure(@"网络异常，请重试");
            return;
        }
        NSString* temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
        MTLOG(@"Received Data: %@",temp);
        NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
        NSNumber *cmd = [response1 valueForKey:@"cmd"];
        switch ([cmd intValue]) {
            case PHONE_AVAIL:
                success(NO);
                break;
            case PHONE_INVALID:
                success(YES);
                break;
            default:
                failure(@"服务器异常");
        }
    }];
}
@end
