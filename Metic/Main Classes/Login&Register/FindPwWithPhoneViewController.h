//
//  FindPwWithPhoneViewController.h
//  WeShare
//
//  Created by 俊健 on 15/12/1.
//  Copyright (c) 2015年 WeShare. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FindPwWithPhoneViewController : UIViewController
@property (strong, nonatomic) IBOutlet UITextField *phoneTextField;
@property (strong, nonatomic) IBOutlet UITextField *verificationCodeTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) IBOutlet UIButton *getVerificationCodeBtn;
@property (strong, nonatomic) IBOutlet UIView *passwdInputView;
- (IBAction)getVerificationCode:(id)sender;
- (IBAction)resetPassword:(id)sender;
- (IBAction)verificatePhoneNumber:(id)sender;

@end
