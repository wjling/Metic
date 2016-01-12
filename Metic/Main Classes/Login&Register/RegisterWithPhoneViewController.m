//
//  RegisterWithPhoneViewController.m
//  WeShare
//
//  Created by 俊健 on 15/12/1.
//  Copyright (c) 2015年 WeShare. All rights reserved.
//

#import "RegisterWithPhoneViewController.h"
#import "CommonUtils.h"
#import "SVProgressHUD.h"
#import "MTAccountManager.h"
#import "AppDelegate.h"
#import "MenuViewController.h"
#import "FillinInfoViewController.h"
#import "RegisterViewController.h"
#import "MTPushMessageHandler.h"

#import <SMS_SDK/SMSSDK.h>

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
    self.passwdInputView.hidden = YES;
    [CommonUtils addLeftButton:self isFirstPage:NO];
    
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
    [self.verificationCodeTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
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
        }else {
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

- (IBAction)verificatePhoneNumber:(id)sender {
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
    
    [SVProgressHUD showWithStatus:@"正在验证手机号，请稍候" maskType:SVProgressHUDMaskTypeBlack];
    [SMSSDK commitVerificationCode:verificationCode phoneNumber:self.phoneTextField.text zone:@"+86" result:^(NSError *error) {
        if (!error) {
            NSLog(@"验证成功");
            [SVProgressHUD dismissWithSuccess:@"验证成功，请输入登录密码"];
            [self.passwdInputView setHidden:NO];
        } else {
            NSLog(@"验证失败");
            [SVProgressHUD dismissWithError:@"验证码错误"];
        }
    }];
}

- (IBAction)regist:(id)sender {
    [self resignKeyboard];
    NSString *phoneNumber = self.phoneTextField.text;
    NSString *password = self.passwordTextField.text;
    if (![CommonUtils isPhoneNumberVaild:phoneNumber]) {
        [SVProgressHUD showErrorWithStatus:@"手机号填写有误" duration:1.f];
        self.passwdInputView.hidden = YES;
        return;
    }else if ([password length] < 5) {
        [SVProgressHUD showErrorWithStatus:@"密码长度请不要小于5位" duration:1.f];
        return;
    }
    [SVProgressHUD showWithStatus:@"正在注册，请稍候" maskType:SVProgressHUDMaskTypeBlack];
    [self loginWithPhoneNumber:phoneNumber Password:password];
}

- (IBAction)registWithMail:(id)sender {
    UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    RegisterViewController* vc = [sb instantiateViewControllerWithIdentifier:@"RegisterViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)loginWithPhoneNumber:(NSString *)phoneNumber Password:(NSString *)password{
    
    [MTAccountManager registWithPhoneNumber:phoneNumber password:password success:^(MTLoginResponse *user) {
        MTLOG(@"login succeeded");
        AppDelegate *appDelegate =  (AppDelegate *)([UIApplication sharedApplication].delegate);
        appDelegate.isLogined = YES;
        
        //保存账户信息
        MTAccount *account = [MTAccount singleInstance];
        account.phoneNumber = phoneNumber;
        account.password = password;
        account.type = MTAccountTypePhoneNumber;
        account.hadCompleteInfo = NO;
        account.isActive = YES;
        [account saveAccount];
        [[NSUserDefaults standardUserDefaults] setObject:@"in" forKey:@"MeticStatus"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSNumber *userid = user.userId;
        [[MTUser sharedInstance] setUid:userid];
        
        [[MenuViewController sharedInstance] dianReset];
        [[MenuViewController sharedInstance] refresh];
        [[appDelegate leftMenu] clearVC];
        
        NSNumber* min_seq = user.minMegSeq;
        NSNumber* max_seq = user.maxMegSeq;
        [MTPushMessageHandler setupMaxNotificationSeq:min_seq];
        if (min_seq && max_seq && [min_seq integerValue] != 0 && [max_seq integerValue] != 0) {
            [MTPushMessageHandler pullAndHandlePushMessageWithMinSeq:min_seq andMaxSeq:max_seq andCallBackBlock:NULL];
        }
        [SVProgressHUD dismissWithSuccess:@"注册成功" afterDelay:1.f];
        [self jumpToFillinInfo];

    } failure:^(enum MTLoginResult result, NSString *message) {
        [SVProgressHUD dismissWithError:message afterDelay:1.f];
    }];
}

#pragma mark - push ViewController
- (void)jumpToFillinInfo
{
    UIStoryboard* mainStoryBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    FillinInfoViewController *vc = [mainStoryBoard instantiateViewControllerWithIdentifier:@"FillinInfoViewController"];
    vc.gender = @1;
    [self.navigationController pushViewController:vc animated:YES];
}
@end
