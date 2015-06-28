//
//  AvatarViewController.h
//  WeShare
//
//  Created by 俊健 on 15/6/24.
//  Copyright (c) 2015年 WeShare. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserInfoViewController.h"

@interface AvatarViewController : UIViewController
@property (nonatomic,weak) UserInfoViewController* controller;

-(void)refresh;
@end
