//
//  MTLoginManager.m
//  WeShare
//
//  Created by 俊健 on 15/11/30.
//  Copyright (c) 2015年 WeShare. All rights reserved.
//

#import "MTLoginManager.h"
#import "MTAccount.h"
#import "HttpSender.h"
#import "CommonUtils.h"

typedef void(^MTLoginCompletedBlock)(BOOL isValid, NSString *errMeg);

@implementation MTLoginManager

+ (void)loginWithAccount:(NSString *)account
                password:(NSString *)password
                 success:(void (^)(MTAccount *user))success
                 failure:(void (^)(enum MTLoginResult result, NSString *message))failure
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:account forKey:@"email"];
    [dictionary setValue:@"" forKey:@"passwd"];
    [dictionary setValue:[NSNumber numberWithBool:NO] forKey:@"has_salt"];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:LOGIN finshedBlock:^(NSData *rData) {
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
                [httpSender sendMessage:jsonData withOperationCode:LOGIN finshedBlock:^(NSData *rData) {
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
                            MTAccount *user = [MTLJSONAdapter modelOfClass:[MTAccount class]
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

@end
