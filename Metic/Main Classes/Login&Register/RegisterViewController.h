//
//  RegisterViewController.h
//  Metic
//
//  Created by ligang_mac4 on 14-5-27.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HttpSender.h"
#import "CommonUtils.h"
#import "LoginViewController.h"
#import "FillinInfoViewController.h"

@interface RegisterViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *textField_email;
@property (weak, nonatomic) IBOutlet UITextField *textField_password;
@property (weak, nonatomic) IBOutlet UIButton *button_signUp;
@property (weak, nonatomic) IBOutlet UIButton *button_backToLogin;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

-(IBAction)signUpButtonClicked:(id)sender;
-(IBAction)backToLoginButtonClicked:(id)sender;

- (void)jumpToLogin;
- (void)jumpToMain;
@end
