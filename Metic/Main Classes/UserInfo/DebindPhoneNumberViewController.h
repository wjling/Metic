//
//  DebindPhoneNumberViewController.h
//  WeShare
//
//  Created by 俊健 on 15/12/1.
//  Copyright (c) 2015年 WeShare. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DebindPhoneNumberViewController : UIViewController
@property (strong, nonatomic) IBOutlet UITextField *phoneTextField;
@property (strong, nonatomic) IBOutlet UITextField *verificationCodeTextField;
@property (strong, nonatomic) IBOutlet UIButton *getVerificationCodeBtn;
- (IBAction)getVerificationCode:(id)sender;
- (IBAction)debindPhone:(id)sender;

@end
