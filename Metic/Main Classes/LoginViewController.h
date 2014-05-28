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

@interface LoginViewController : UIViewController <UITextFieldDelegate,HttpSenderDelegate>

@property (weak, nonatomic) IBOutlet UITextField *textField_userName;
@property (weak, nonatomic) IBOutlet UITextField *textField_password;
@property (weak, nonatomic) IBOutlet UIButton *button_login;
@property (weak, nonatomic) IBOutlet UIButton *button_register;
@property (nonatomic,retain) NSString* logInEmail;
@property (nonatomic, retain) NSString* logInPassword;
@property(nonatomic,strong)MTUser *user;


- (BOOL)isTextFieldEmpty;
- (IBAction)loginButtonClicked:(id)sender;
- (IBAction)registerBtnClicked:(id)sender;
- (IBAction)backgroundBtn:(id)sender;
- (void)jumpToMainView;
- (void)jumpToRegisterView;

@end
