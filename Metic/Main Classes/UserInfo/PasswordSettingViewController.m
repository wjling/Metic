//
//  PasswordSettingViewController.m
//  WeShare
//
//  Created by 俊健 on 15/12/23.
//  Copyright (c) 2015年 WeShare. All rights reserved.
//

#import "PasswordSettingViewController.h"
#import "CommonUtils.h"
#import "MTAccountManager.h"
#import "MTUser.h"
#import "SVProgressHUD.h"

@interface PasswordSettingViewController ()

@end

@implementation PasswordSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupUI {
    self.title = @"设置登录密码";
    [CommonUtils addLeftButton:self isFirstPage:NO];
    
    UILabel *passwordLeftView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 38)];
    passwordLeftView.text = @"密码";
    passwordLeftView.font = [UIFont systemFontOfSize:15];
    passwordLeftView.textAlignment = NSTextAlignmentCenter;
    
    self.passwordTextfield.keyboardType = UIKeyboardTypeASCIICapable;
    self.passwordTextfield.secureTextEntry = YES;
    self.passwordTextfield.layer.borderWidth = 1.f;
    self.passwordTextfield.layer.borderColor = [CommonUtils colorWithValue:0xEEEEEE].CGColor;
    self.passwordTextfield.layer.cornerRadius = 5;
    self.passwordTextfield.layer.masksToBounds = YES;
    self.passwordTextfield.leftView = passwordLeftView;
    self.passwordTextfield.leftViewMode = UITextFieldViewModeAlways;
}

- (IBAction)confirm:(id)sender {
    [self.passwordTextfield resignFirstResponder];
    NSString *password = self.passwordTextfield.text;
    
    if ([password length] < 5) {
        [SVProgressHUD showErrorWithStatus:@"密码长度请不要小于5位" duration:1.f];
        return;
    }
    
    [SVProgressHUD showWithStatus:@"正在绑定手机，请稍候" maskType:SVProgressHUDMaskTypeBlack];
    [MTAccountManager bindPhoneWithUserId:[MTUser sharedInstance].userid phoneNumber:self.verificatedPhone password:password salt:self.salt toBind:MTPhoneBindSatausToBind success:^{
        [SVProgressHUD dismissWithSuccess:@"绑定成功" afterDelay:1.f];
        //保存账户信息
        MTAccount *account = [MTAccount singleInstance];
        account.phoneNumber = self.verificatedPhone;
        account.password = password;
        [account saveAccount];
        MTUser *user = [MTUser sharedInstance];
        user.phone = self.verificatedPhone;
        [self.navigationController popViewControllerAnimated:YES];
        [self.navigationController popViewControllerAnimated:YES];
    } failure:^(enum Return_Code errorCode, NSString *message, NSDictionary *info) {
        [SVProgressHUD dismissWithSuccess:message afterDelay:1.f];
    }];
}
@end
