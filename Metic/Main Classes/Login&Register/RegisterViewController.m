//
//  RegisterViewController.m
//  Metic
//
//  Created by ligang_mac4 on 14-5-27.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "RegisterViewController.h"
#import "MenuViewController.h"
#import "AppDelegate.h"
#import "MobClick.h"
#import "SVProgressHUD.h"
#import "MTAccountManager.h"
#import "MTPushMessageHandler.h"

@interface RegisterViewController ()

@end

@implementation RegisterViewController
@synthesize textField_email;
@synthesize textField_password;
@synthesize button_backToLogin;
@synthesize button_signUp;
@synthesize scrollView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"邮箱注册";
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    textField_email.placeholder = @"请输入您的邮箱";
    textField_password.placeholder = @"请输入您的密码，至少5位";
    
    textField_email.keyboardType = UIKeyboardTypeEmailAddress;
    textField_password.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    textField_password.secureTextEntry = YES;
    
    textField_password.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField_email.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    UILabel *userNameLeftView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 44)];
    userNameLeftView.text = @"账号";
    userNameLeftView.font = [UIFont systemFontOfSize:15];
    userNameLeftView.textAlignment = NSTextAlignmentCenter;
    textField_email.leftView = userNameLeftView;
    textField_email.leftViewMode = UITextFieldViewModeAlways;
    
    UILabel *passwordLeftView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 44)];
    passwordLeftView.text = @"密码";
    passwordLeftView.font = [UIFont systemFontOfSize:15];
    passwordLeftView.textAlignment = NSTextAlignmentCenter;
    textField_password.leftView = passwordLeftView;
    textField_password.leftViewMode = UITextFieldViewModeAlways;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [MobClick beginLogPageView:@"注册首页"];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [MobClick endLogPageView:@"注册首页"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


- (void)jumpToLogin
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)jumpToMain
{
    [self performSegueWithIdentifier:@"RegisterToMain" sender:self];
}

-(void)jumpToFillinInfo
{
    [self performSegueWithIdentifier:@"regist_fillinInfo" sender:self];
}

#pragma mark - button click
-(IBAction)signUpButtonClicked:(id)sender
{
    [self.textField_email resignFirstResponder];
    [self.textField_password resignFirstResponder];
    
    NSString* email = [textField_email text];
    NSString* password = [textField_password text];
    
    if (![CommonUtils isEmailValid: textField_email.text]) {
        [SVProgressHUD showErrorWithStatus:@"邮箱格式不正确" duration:1.f];
        return;
    } else if ([[textField_password text] length] < 5) {
        [SVProgressHUD showErrorWithStatus:@"密码长度请不要小于5位" duration:1.f];
        return;
    }
    
    [MTAccountManager registWithAccount:email password:password success:^(MTAccount *user) {
        AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        appDelegate.isLogined = YES;
        //保存信息
        [SVProgressHUD dismissWithSuccess:@"注册成功" afterDelay:1.f];
//        [self jumpToFillinInfo];
        
    } failure:^(enum MTLoginResult result, NSString *message) {
        [SVProgressHUD dismissWithError:message afterDelay:1.f];
    }];
    
    [SVProgressHUD showWithStatus:@"正在注册，请稍后" maskType:SVProgressHUDMaskTypeGradient];
}

- (IBAction)backToLoginButtonClicked:(id)sender
{
    [self jumpToLogin];
}

@end
