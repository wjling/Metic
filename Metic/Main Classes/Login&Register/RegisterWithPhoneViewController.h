//
//  RegisterWithPhoneViewController.h
//  WeShare
//
//  Created by 俊健 on 15/12/1.
//  Copyright (c) 2015年 WeShare. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegisterWithPhoneViewController : UIViewController
@property (strong, nonatomic) IBOutlet UITextField *phoneTextField;
@property (strong, nonatomic) IBOutlet UITextField *verificationCodeTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) IBOutlet UIButton *getVerificationCodeBtn;
@property (strong, nonatomic) IBOutlet UIView *passwdInputView;
- (IBAction)getVerificationCode:(id)sender;
- (IBAction)verificatePhoneNumber:(id)sender;
- (IBAction)regist:(id)sender;
- (IBAction)registWithMail:(id)sender;

@end
