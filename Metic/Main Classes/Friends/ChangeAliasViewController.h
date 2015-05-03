//
//  ChangeAliasViewController.h
//  WeShare
//
//  Created by ligang_mac4 on 14-10-20.
//  Copyright (c) 2014年 WeShare. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HttpSender.h"
#import "CommonUtils.h"
#import "MTUser.h"
#import "AppConstants.h"
#import "InputHandleView.h"
#import "myInputView.h"

@interface ChangeAliasViewController : UIViewController
@property (strong, nonatomic) UITextField *alias_view;
@property (strong, nonatomic) UIBarButtonItem *ok_btn;
@property (strong, nonatomic) InputHandleView *rootView;

@property (strong, nonatomic) NSNumber *fid;   //需要传入数据
@property (strong, nonatomic) NSString* alias_new;

@end
