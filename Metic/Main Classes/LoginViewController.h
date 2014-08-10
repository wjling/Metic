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

@interface LoginViewController : UIViewController <InputHandleViewDelegate,HttpSenderDelegate>

@property (weak, nonatomic) IBOutlet UITextField *textField_userName;
@property (weak, nonatomic) IBOutlet UITextField *textField_password;
@property (weak, nonatomic) IBOutlet UIButton *button_login;
@property (weak, nonatomic) IBOutlet UIButton *button_register;
@property (strong, nonatomic) IBOutlet UIImageView *Img_userName;
@property (strong, nonatomic) IBOutlet UIImageView *Img_password;
@property (strong, nonatomic) IBOutlet UIButton *Img_register;
@property (nonatomic,retain) NSString* logInEmail;
@property (nonatomic, retain) NSString* logInPassword;
@property (strong, nonatomic) IBOutlet InputHandleView *rootView;
@property (nonatomic)BOOL fromRegister;
@property (strong,nonatomic) NSString* text_userName;
@property (strong,nonatomic) NSString* text_password;


-(void)login;
- (BOOL)isTextFieldEmpty;
- (IBAction)loginButtonClicked:(id)sender;
- (IBAction)registerBtnClicked:(id)sender;
//- (IBAction)backgroundBtn:(id)sender;
//- (IBAction)text_Clear:(id)sender;
- (void)jumpToMainView;
- (void)jumpToRegisterView;

@end
