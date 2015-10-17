//
//  MTPackageControl.m
//  WeShare
//
//  Created by 俊健 on 15/10/7.
//  Copyright (c) 2015年 WeShare. All rights reserved.
//

#import "MTPackageControl.h"
#import "HttpSender.h"
#import "AppConstants.h"
#import "CommonUtils.h"
#import "BOAlertController.h"
#import "SlideNavigationController.h"

@interface MTPackageControl ()

@end

@implementation MTPackageControl

//版本控制
+ (void)checkVersion {
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:@"ios" forKey:@"system"];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:GET_VERSION_INFO finshedBlock:^(NSData *rData) {
        if (!rData) {
            return;
        }
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
        NSNumber *cmd = [response valueForKey:@"cmd"];
        switch ([cmd intValue]) {
            case NORMAL_REPLY:
            {
                NSString *versionName = response[@"version_name"];
                NSString *minBuildBundle = response[@"minBuildBundle"];
                NSString *content = response[@"content"];
                NSString *url = response[@"url"];
                NSString *curVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
                
                if ([CommonUtils compareVersion1:curVersion andVersion2:minBuildBundle] < 0) {
                    
                    //触发强制升级
                    MTLOG(@"触发强制升级");
                    NSString *title = [NSString stringWithFormat:@"请升级到最新版本: %@",versionName];
                    BOAlertController *alertView = [[BOAlertController alloc] initWithTitle:title message:content viewController:[SlideNavigationController sharedInstance]];
                    RIButtonItem *okItem = [RIButtonItem itemWithLabel:@"确定" action:^{
                        [alertView show];
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
                    }];
                    [alertView addButton:okItem type:RIButtonItemType_Cancel];
                    [alertView show];
                }
                
            }
                break;
            default:{
                
            }
        }
    }];
}

@end
