//
//  LoginViewController.h
//  Metic
//
//  Created by ligang_mac4 on 14-5-27.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MTUser.h"
#import "AppDelegate.h"
#import "HttpSender.h"
#import "CommonUtils.h"
#import "AppConstants.h"
#import "InputHandleView.h"
#import "WelcomePageViewController.h"
#import "FillinInfoViewController.h"

@interface LoginViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *textField_userName;
@property (weak, nonatomic) IBOutlet UITextField *textField_password;
@property (weak, nonatomic) IBOutlet UIButton* forgetPS_btn;
@property (weak, nonatomic) IBOutlet UIButton *button_login;
@property (weak, nonatomic) IBOutlet UIButton *button_register;
@property (nonatomic,retain) NSString* logInEmail;
@property (nonatomic, retain) NSString* logInPassword;
@property (strong, nonatomic) IBOutlet InputHandleView *rootView;
@property (strong,nonatomic) NSString* text_userName;
@property (strong,nonatomic) NSString* text_password;
@property (strong, nonatomic) NSNumber* gender; //用于注册后的信息
@property (strong, nonatomic) IBOutlet UIButton *qqLoginBtn;
@property (strong, nonatomic) IBOutlet UIButton *weixinLoginBtn;
@property (strong, nonatomic) IBOutlet UIButton *weiboLoginBtn;

-(void)login;
- (IBAction)loginButtonClicked:(id)sender;
- (IBAction)registerBtnClicked:(id)sender;
- (void)jumpToMainView;
- (void)jumpToRegisterView;
- (IBAction)QQLogin:(id)sender;
- (IBAction)WeiXinLogin:(id)sender;
- (IBAction)WeiBoLogin:(id)sender;

@end
