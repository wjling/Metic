//
//  RegisterWithPhoneViewController.m
//  WeShare
//
//  Created by 俊健 on 15/12/1.
//  Copyright (c) 2015年 WeShare. All rights reserved.
//

#import "FindPwWithPhoneViewController.h"
#import "CommonUtils.h"
#import "SVProgressHUD.h"
#import "MTAccountManager.h"

#import <SMS_SDK/SMSSDK.h>

@interface FindPwWithPhoneViewController ()

@end

@implementation FindPwWithPhoneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setupUI {
    self.title = @"手机找回密码";
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
    
    self.passwordTextField.secureTextEntry = YES;
    self.passwordTextField.layer.borderWidth = 1.f;
    self.passwordTextField.layer.borderColor = [CommonUtils colorWithValue:0xEEEEEE].CGColor;
    self.passwordTextField.layer.cornerRadius = 5;
    self.passwordTextField.layer.masksToBounds = YES;
    self.passwordTextField.leftView = passwordLeftView;
    self.passwordTextField.leftViewMode = UITextFieldViewModeAlways;
}

- (void)resignKeyboard
{
    [self.phoneTextField resignFirstResponder];
    [self.verificationCodeTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
}

- (IBAction)getVerificationCode:(id)sender {
    [self resignKeyboard];
    if (![CommonUtils isPhoneNumberVaild:self.phoneTextField.text]) {
        [SVProgressHUD showErrorWithStatus:@"手机号填写有误" duration:1.f];
        return;
    }
    [sender setEnabled:NO];
    NSNumber *waitingTime = @60;
    NSMutableDictionary *dict = [@{@"waitingTime":waitingTime} mutableCopy];
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(refreshWaitingCount:) userInfo:dict repeats:YES];
    [timer fire];
    
    [SMSSDK getVerificationCodeByMethod:SMSGetCodeMethodSMS phoneNumber:self.phoneTextField.text
                                   zone:@"+86"
                       customIdentifier:nil
                                 result:^(NSError *error)
     {
         if (!error) {
             NSLog(@"验证码发送成功");
             [SVProgressHUD showSuccessWithStatus:@"验证码已发送" duration:1.f];
         } else {
             NSLog(@"验证码发送失败");
             [timer invalidate];
             [self.getVerificationCodeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
             [self.getVerificationCodeBtn setEnabled:YES];
             [SVProgressHUD showErrorWithStatus:@"获取失败，请重试" duration:1.f];
         }
     }];
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
        [timer invalidate];
        [self.getVerificationCodeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
        [self.getVerificationCodeBtn setEnabled:YES];
    }
}

- (IBAction)resetPassword:(id)sender {
    [self resignKeyboard];
    NSString *phoneNumber = self.phoneTextField.text;
    NSString *password = self.passwordTextField.text;
    NSString *verificationCode = self.verificationCodeTextField.text;
    if (![CommonUtils isPhoneNumberVaild:phoneNumber]) {
        [SVProgressHUD showErrorWithStatus:@"手机号填写有误" duration:1.f];
        return;
    }else if ([verificationCode length] == 0) {
        [SVProgressHUD showErrorWithStatus:@"请输入验证码" duration:1.f];
        return;
    }else if ([password length] < 5) {
        [SVProgressHUD showErrorWithStatus:@"密码长度请不要小于5位" duration:1.f];
        return;
    }
    
    [SVProgressHUD showWithStatus:@"正在重置密码，请稍候" maskType:SVProgressHUDMaskTypeBlack];
    [SMSSDK commitVerificationCode:verificationCode phoneNumber:self.phoneTextField.text zone:@"+86" result:^(NSError *error) {
        if (!error) {
            NSLog(@"验证成功");
            [self resetPwWithPhoneNumber:phoneNumber Password:password];
        } else {
            NSLog(@"验证失败");
            [SVProgressHUD dismissWithError:@"验证码错误"];
        }
    }];
}

- (void)resetPwWithPhoneNumber:(NSString *)phoneNumber Password:(NSString *)password{
    
    [MTAccountManager resetPwWithPhoneNumber:phoneNumber password:password success:^() {
        MTLOG(@"login succeeded");
        [SVProgressHUD dismissWithSuccess:@"密码重置成功，请重新登录" afterDelay:1.f];
        //保存账户信息
        MTAccount *account = [MTAccount singleInstance];
        account.phoneNumber = phoneNumber;
        account.password = password;
        account.type = MTAccountTypePhoneNumber;
        account.hadCompleteInfo = NO;
        account.isActive = NO;
        [account saveAccount];
        [self.navigationController popToRootViewControllerAnimated:YES];

    } failure:^(NSString *message) {
        [SVProgressHUD dismissWithError:message afterDelay:1.f];
    }];
}
@end
