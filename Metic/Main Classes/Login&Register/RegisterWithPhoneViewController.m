//
//  RegisterWithPhoneViewController.m
//  WeShare
//
//  Created by 俊健 on 15/12/1.
//  Copyright (c) 2015年 WeShare. All rights reserved.
//

#import "RegisterWithPhoneViewController.h"
#import "CommonUtils.h"

@interface RegisterWithPhoneViewController ()

@end

@implementation RegisterWithPhoneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setupUI {
    self.title = @"手机注册";
    [CommonUtils addLeftButton:self isFirstPage:NO];
    
    UILabel *phoneLeftView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 38)];
    phoneLeftView.text = @"手机号";
    phoneLeftView.font = [UIFont systemFontOfSize:15];
    phoneLeftView.textAlignment = NSTextAlignmentCenter;
    
    self.phoneTextField.layer.borderWidth = 1.f;
    self.phoneTextField.layer.borderColor = [CommonUtils colorWithValue:0xEEEEEE].CGColor;
    self.phoneTextField.layer.cornerRadius = 5;
    self.phoneTextField.layer.masksToBounds = YES;
    self.phoneTextField.leftView = phoneLeftView;
    self.phoneTextField.leftViewMode = UITextFieldViewModeAlways;
    
    UIView *leftView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 10, 38)];
    
    self.verificationCodeTextField.layer.borderWidth = 1.f;
    self.verificationCodeTextField.layer.borderColor = [CommonUtils colorWithValue:0xEEEEEE].CGColor;
    self.verificationCodeTextField.layer.cornerRadius = 5;
    self.verificationCodeTextField.layer.masksToBounds = YES;
    self.verificationCodeTextField.leftView = leftView;
    self.verificationCodeTextField.leftViewMode = UITextFieldViewModeAlways;
    
    UILabel *passwordLeftView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 38)];
    passwordLeftView.text = @"密码";
    passwordLeftView.font = [UIFont systemFontOfSize:15];
    passwordLeftView.textAlignment = NSTextAlignmentCenter;
    
    self.passwordTextField.layer.borderWidth = 1.f;
    self.passwordTextField.layer.borderColor = [CommonUtils colorWithValue:0xEEEEEE].CGColor;
    self.passwordTextField.layer.cornerRadius = 5;
    self.passwordTextField.layer.masksToBounds = YES;
    self.passwordTextField.leftView = passwordLeftView;
    self.passwordTextField.leftViewMode = UITextFieldViewModeAlways;
}

- (IBAction)getVerificationCode:(id)sender {
    [sender setEnabled:NO];
    NSNumber *waitingTime = @60;
    NSMutableDictionary *dict = [@{@"waitingTime":waitingTime} mutableCopy];
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(refreshWaitingCount:) userInfo:dict repeats:YES];
    [timer fire];
}

- (void)refreshWaitingCount:(id)sender {
    NSTimer *timer = sender;
    NSMutableDictionary *dict = [timer userInfo];
    NSNumber *waitingTime = dict[@"waitingTime"];
    dict[@"waitingTime"] = @([waitingTime integerValue]-1);
    
    if (self == self.navigationController.viewControllers.lastObject && [waitingTime integerValue] > 0) {
        NSString *title = [NSString stringWithFormat:@"%@秒后重试",waitingTime];
        [self.getVerificationCodeBtn setTitle:title forState:UIControlStateNormal];
    }else {
        [self.getVerificationCodeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
        [self.getVerificationCodeBtn setEnabled:YES];
        [timer invalidate];
    }
}

- (IBAction)regist:(id)sender {
}

- (IBAction)registWithMail:(id)sender {
}
@end
