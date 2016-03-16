//
//  EventPreviewViewController.h
//  WeShare
//
//  Created by 俊健 on 15/4/13.
//  Copyright (c) 2015年 WeShare. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventPreviewViewController : UIViewController
@property(nonatomic,strong) NSDictionary* eventInfo;
@property(nonatomic,strong) NSNumber *beingInvited;

//分享码 分享码不为nil时，无论什么类型活动都能申请加入
@property(nonatomic,strong) NSNumber *shareId;
@end
