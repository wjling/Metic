//
//  BindPhoneNumberViewController.h
//  WeShare
//
//  Created by 俊健 on 15/12/1.
//  Copyright (c) 2015年 WeShare. All rights reserved.
//

#import "BindPhoneNumberViewController.h"
#import "PasswordSettingViewController.h"
#import "CommonUtils.h"
#import "SVProgressHUD.h"
#import "MTAccountManager.h"
#import "MTUser.h"
#import "MTAccountManager.h"

#import <SMS_SDK/SMSSDK.h>

@interface BindPhoneNumberViewController ()

@property (nonatomic, strong) NSString *salt;

@end

@implementation BindPhoneNumberViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setupUI {
    self.title = @"绑定手机";
    [CommonUtils addLeftButton:self isFirstPage:NO];
    self.pwInputView.hidden = YES;
    
    UILabel *phoneLeftView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 38)];
    phoneLeftView.text = @"手机号";
    phoneLeftView.font = [UIFont systemFontOfSize:15];
    phoneLeftView.textAlignment = NSTextAlignmentCenter;
    
    self.phoneTextField.keyboardType = UIKeyboardTypeNumberPad;
    self.phoneTextField.layer.borderWidth = 1.f;
    self.phoneTextField.layer.borderColor = [CommonUtils colorWithValue:0xEEEEEE].CGColor;
    self.phoneTextField.layer.cornerRadius = 5;
    self.phoneTextField.layer.masksToBounds = YES;
    self.phoneTextField.leftView = phoneLeftView;
    self.phoneTextField.leftViewMode = UITextFieldViewModeAlways;
    
    UIView *leftView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 10, 38)];
    
    self.verificationCodeTextField.keyboardType = UIKeyboardTypeNumberPad;
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
    [self.passwordTextField resignFirstResponder];
    [self.verificationCodeTextField resignFirstResponder];
}

- (IBAction)getVerificationCode:(id)sender {
    [self resignKeyboard];
    NSString *phone = self.phoneTextField.text;
    if (![CommonUtils isPhoneNumberVaild:phone]) {
        [SVProgressHUD showErrorWithStatus:@"手机号填写有误" duration:1.f];
        return;
    }
    [sender setEnabled:NO];
    NSNumber *waitingTime = @60;
    NSMutableDictionary *dict = [@{@"waitingTime":waitingTime} mutableCopy];
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(refreshWaitingCount:) userInfo:dict repeats:YES];
    [timer fire];
    
    [MTAccountManager checkPhoneInUse:phone success:^(BOOL isInused) {
        if (!isInused) {
            [SMSSDK getVerificationCodeByMethod:SMSGetCodeMethodSMS phoneNumber:phone
                                           zone:@"86"
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
        } else {
            [timer invalidate];
            [self.getVerificationCodeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
            [self.getVerificationCodeBtn setEnabled:YES];
            [SVProgressHUD showErrorWithStatus:@"此手机号已被使用" duration:1.f];
        }
    } failure:^(NSString *message) {
        [timer invalidate];
        [self.getVerificationCodeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
        [self.getVerificationCodeBtn setEnabled:YES];
        [SVProgressHUD showErrorWithStatus:message duration:1.f];
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

- (IBAction)bindPhone:(id)sender {
    [self resignKeyboard];
    NSString *phoneNumber = self.phoneTextField.text;
    NSString *verificationCode = self.verificationCodeTextField.text;
    if (![CommonUtils isPhoneNumberVaild:phoneNumber]) {
        [SVProgressHUD showErrorWithStatus:@"手机号填写有误" duration:1.f];
        return;
    }else if ([verificationCode length] == 0) {
        [SVProgressHUD showErrorWithStatus:@"请输入验证码" duration:1.f];
        return;
    }
    
    [SVProgressHUD showWithStatus:@"正在验证手机，请稍候" maskType:SVProgressHUDMaskTypeBlack];
    [SMSSDK commitVerificationCode:verificationCode phoneNumber:self.phoneTextField.text zone:@"+86" result:^(NSError *error) {
        if (!error) {
            NSLog(@"验证成功");
            [SVProgressHUD showWithStatus:@"正在绑定手机，请稍候" maskType:SVProgressHUDMaskTypeBlack];
            [self bindPhoneNumber:phoneNumber password:nil salt:nil];
        } else {
            NSLog(@"验证失败");
            [SVProgressHUD dismissWithError:@"验证码错误"];
        }
    }];
}

- (IBAction)confirm:(id)sender {
    [self resignKeyboard];
    NSString *phoneNumber = self.phoneTextField.text;
    NSString *password = self.passwordTextField.text;
    if (![CommonUtils isPhoneNumberVaild:phoneNumber]) {
        [SVProgressHUD showErrorWithStatus:@"手机号填写有误" duration:1.f];
        self.pwInputView.hidden = YES;
        return;
    }else if ([password length] < 5) {
        [SVProgressHUD showErrorWithStatus:@"密码长度请不要小于5位" duration:1.f];
        return;
    }
    [SVProgressHUD showWithStatus:@"正在处理" maskType:SVProgressHUDMaskTypeBlack];
    [self bindPhoneNumber:phoneNumber password:password salt:self.salt];
}

- (void)bindPhoneNumber:(NSString *)phoneNumber password:(NSString *)password salt:(NSString *)salt{
    [MTAccountManager bindPhoneWithUserId:[MTUser sharedInstance].userid phoneNumber:phoneNumber password:password salt:(NSString *)salt toBind:MTPhoneBindSatausToBind success:^{
        [SVProgressHUD dismissWithSuccess:@"绑定成功" afterDelay:1.f];
        //保存账户信息
        MTAccount *account = [MTAccount singleInstance];
        account.phoneNumber = phoneNumber;
        [account saveAccount];
        MTUser *user = [MTUser sharedInstance];
        user.phone = phoneNumber;
        [self.navigationController popViewControllerAnimated:YES];
    } failure:^(enum Return_Code errorCode, NSString *message, NSDictionary *info) {
        [SVProgressHUD dismissWithSuccess:message afterDelay:1.f];
        if (errorCode == PASSWD_NOT_SETTING) {
            NSString *saltFromServer = info[@"salt"];
            if (saltFromServer) {
                self.salt = saltFromServer;
            }
            self.pwInputView.hidden = NO;
        }
    }];
}
@end
