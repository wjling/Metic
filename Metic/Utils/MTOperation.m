//
//  MTOperation.m
//  WeShare
//
//  Created by 俊健 on 15/5/20.
//  Copyright (c) 2015年 WeShare. All rights reserved.
//

#import "MTOperation.h"
#import "MTUser.h"
#import "BOAlertController.h"
#import "SlideNavigationController.h"
#import "SVProgressHUD.h"

#import <objc/runtime.h>

@interface MTOperation ()<UIAlertViewDelegate>

@end

@implementation MTOperation

+ (MTOperation *)sharedInstance {
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [self new];
    });
    return instance;
}

- (id)init {
    if ((self = [super init])) {
    }
    return self;
}


-(void)inviteFriends:(NSArray*)notFriendsList
{
    if (notFriendsList.count == 0) {
        return;
    }
    NSString* names = @"";
    for (int i = 0; i < notFriendsList.count; i++) {
        NSNumber* fid = notFriendsList[i];
        NSString* fname = [[MTUser sharedInstance].alias_dic objectForKey:[NSString stringWithFormat:@"%@",fid]];
        if (fname == nil || [fname isEqual:[NSNull null]]) {
            fname = [[MTUser sharedInstance].nameFromID_dic objectForKey:[NSString stringWithFormat:@"%@",fid]];
        }
        
        if (i == 0) {
            names = [names stringByAppendingString:[NSString stringWithFormat:@"%@",fname]];
        }else{
            names = [names stringByAppendingString:[NSString stringWithFormat:@"、%@",fname]];
        }
        
    }
    
    NSString* message = [NSString stringWithFormat:@"%@ 不是你的好友，无法邀请，是否申请添加好友 ？",names];
    
    BOAlertController *alertView = [[BOAlertController alloc] initWithTitle:@"系统消息" message:message viewController:[SlideNavigationController sharedInstance]];
    RIButtonItem *cancelItem = [RIButtonItem itemWithLabel:@"取消" action:^{

    }];
    [alertView addButton:cancelItem type:RIButtonItemType_Cancel];
    
    RIButtonItem *okItem = [RIButtonItem itemWithLabel:@"确定" action:^{
        
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"添加好友" message:@"请填写好友申请信息：" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alert.tag = 120;
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        if ([MTUser sharedInstance].name && ![[MTUser sharedInstance].name isEqual:[NSNull null]]) {
            [alert textFieldAtIndex:0].text = [NSString stringWithFormat:@"我是%@",[MTUser sharedInstance].name];
        }
        
        
        void (^block)(NSInteger) = ^(NSInteger buttonIndex){
            if(buttonIndex == 0){
                
            }else if(buttonIndex == 1){
                [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
                NSString* cm = [alert textFieldAtIndex:0].text;
                NSNumber* userId = [MTUser sharedInstance].userid;
                
                NSString *friendlist = @"[";
                BOOL flag = YES;
                for (NSNumber* friendid in notFriendsList) {
                    friendlist = [friendlist stringByAppendingString: flag? @"%@":@",%@"];
                    if (flag) flag = NO;
                    friendlist = [NSString stringWithFormat:friendlist,friendid];
                }
                friendlist = [friendlist stringByAppendingString:@"]"];
                
                NSDictionary* json = [CommonUtils packParamsInDictionary:[NSNumber numberWithInt:999],@"cmd",userId,@"id",cm,@"confirm_msg", friendlist,@"friend_list",[NSNumber numberWithInt:ADD_FRIEND],@"item_id",nil];
                NSData* jsonData = [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:nil];
                HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
                [httpSender sendMessage:jsonData withOperationCode:ADD_FRIEND_BATCH finshedBlock:^(NSData *rData) {
                    if (!rData) {
                        [SVProgressHUD dismissWithError:@"网络异常"];
                    }else{
                        NSString* temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
                        NSLog(@"Received Data: %@",temp);
                        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
                        NSNumber *cmd = [response valueForKey:@"cmd"];
                        switch ([cmd intValue]) {
                            case NORMAL_REPLY:
                            {
                                [SVProgressHUD dismissWithSuccess:@"添加好友请求已发送"];
                            }
                                break;
                            default:
                            {
                                [SVProgressHUD dismissWithSuccess:@"添加好友请求已发送"];
                            }
                        }
                    }
                    
                    
                }];
            }
        };
        
        objc_setAssociatedObject(alert,@"MTinviteFriends",block,OBJC_ASSOCIATION_COPY);
        
        [alert show];
        
    }];
    [alertView addButton:okItem type:RIButtonItemType_Other];
    [alertView show];
}

#pragma mark - Alert Delegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex;{
    // the user clicked OK
    if (alertView.tag == 120) {
        //添加那些把自己删掉的好友
        void (^block)(NSInteger) = objc_getAssociatedObject(alertView, @"MTinviteFriends");
        block(buttonIndex);
    }
    
    
}

@end
