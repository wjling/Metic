//
//  LoginViewController.m
//  Metic
//
//  Created by ligang_mac4 on 14-5-27.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "LoginViewController.h"
#import "RegisterWithPhoneViewController.h"
#import "MenuViewController.h"
#import "GetBackPasswordViewController.h"
#import "CommonUtils.h"
#import "MobClick.h"
#import "MTPushMessageHandler.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "MTAccountManager.h"
#import "SVProgressHUD.h"
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKConnector/ShareSDKConnector.h>

@interface LoginViewController ()
{
    UIViewController* launchV;
    UIView *blackView;
    AppDelegate* appDelegate;
}
@property (strong, nonatomic) UIView* waitingView;
@property (strong, nonatomic) NSTimer* timer;
@end

@implementation LoginViewController

@synthesize textField_password;
@synthesize textField_userName;
@synthesize forgetPS_btn;
@synthesize button_login;
@synthesize button_register;
@synthesize logInEmail;
@synthesize logInPassword;
@synthesize rootView;
@synthesize text_userName;
@synthesize text_password;
@synthesize gender; 

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
    [self setupUI];
    [self showBlackView];
    NSUserDefaults* userDf = [NSUserDefaults standardUserDefaults];
    appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    if (![userDf boolForKey:@"hadShowWelcomePage"]) {
        MTLOG(@"login: it is the first launch");
        [userDf setBool:YES forKey:@"hadShowWelcomePage"];
        UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone"
                                                             bundle: nil];
        WelcomePageViewController* vc = [storyboard instantiateViewControllerWithIdentifier:@"WelcomePageViewController"];
        [self presentViewController:vc animated:NO completion:nil];
    } else {
        MTLOG(@"login: it is not the first launch");
        [self showLaunchView];
    }
}

//返回上一层
-(void)MTpopViewController{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [MobClick beginLogPageView:@"登录"];
    [self.navigationController setNavigationBarHidden:NO];
    [self checkPreUP];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [MobClick endLogPageView:@"登录"];
    MTLOG(@"login view did disappear");
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[FillinInfoViewController class]]) {
        FillinInfoViewController* vc = segue.destinationViewController;
        vc.gender = gender;
        vc.email = [textField_userName text];
        MTLOG(@"register gender: %@",vc.gender);
    }
}

#pragma mark - Private Methods
- (void)setupUI
{
    self.title = @"登陆";
    [self.navigationController setNavigationBarHidden:YES];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [CommonUtils addLeftButton:self isFirstPage:NO];
    
    [forgetPS_btn setTitle:@"忘记密码?" forState:UIControlStateNormal];
    forgetPS_btn.titleLabel.font = [UIFont systemFontOfSize:13];
    [forgetPS_btn setBackgroundColor:[UIColor clearColor]];
    [forgetPS_btn addTarget:self action:@selector(forgetPSBtnClick:) forControlEvents:UIControlEventTouchUpInside];

    UILabel *userNameLeftView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 44)];
    userNameLeftView.text = @"账号";
    userNameLeftView.font = [UIFont systemFontOfSize:15];
    userNameLeftView.textAlignment = NSTextAlignmentCenter;
    
    self.textField_userName.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.textField_userName.placeholder = @"请输入邮箱／手机号";
    self.textField_userName.keyboardType = UIKeyboardTypeEmailAddress;
    self.textField_userName.text = text_userName? text_userName:@"";
    self.textField_userName.leftView = userNameLeftView;
    self.textField_userName.leftViewMode = UITextFieldViewModeAlways;
    self.textField_userName.layer.cornerRadius = 5.f;
    self.textField_userName.layer.borderColor = [CommonUtils colorWithValue:0xDDDDDD].CGColor;
    self.textField_userName.layer.borderWidth = 2;
    self.textField_userName.layer.masksToBounds = YES;
    
    UILabel *passwordLeftView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 44)];
    passwordLeftView.text = @"密码";
    passwordLeftView.font = [UIFont systemFontOfSize:15];
    passwordLeftView.textAlignment = NSTextAlignmentCenter;
    
    self.textField_password.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.textField_password.placeholder = @"请输入密码";
    self.textField_password.secureTextEntry = YES;
    self.textField_password.text = text_password? text_password:@"";
    self.textField_password.leftView = passwordLeftView;
    self.textField_password.leftViewMode = UITextFieldViewModeAlways;
    self.textField_password.layer.cornerRadius = 5.f;
    self.textField_password.layer.borderColor = [CommonUtils colorWithValue:0xDDDDDD].CGColor;
    self.textField_password.layer.borderWidth = 2;
    self.textField_password.layer.masksToBounds = YES;
}

-(void)forgetPSBtnClick:(id)sender
{
    UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    GetBackPasswordViewController* vc = [sb instantiateViewControllerWithIdentifier:@"GetBackPasswordViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - ShowViews
-(void)showLaunchView
{
    CGRect bounds = [UIScreen mainScreen].bounds;
    CGFloat y;
    if (bounds.size.height <= 480) {
        y = 40;
    } else {
        y = 70;
    }
    CGFloat view_width = bounds.size.width;
    CGFloat view_height = bounds.size.height;
    UIColor* bgColor = [CommonUtils colorWithValue:0x57caab];
    launchV = [[UIViewController alloc]init];
    UIView* page4 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, view_width, view_height)];
    UIImageView* imgV4_1 = [[UIImageView alloc]initWithFrame:CGRectMake(21, y, view_width - 42, 115)];
    UIImageView* imgV4_2 = [[UIImageView alloc]initWithFrame:CGRectMake(-60, view_height - 245 - 2 * y, view_width + 120, 385)];
    [page4 setBackgroundColor:bgColor];
    imgV4_1.image = [UIImage imageNamed:@"splash_text4"];
    imgV4_2.image = [UIImage imageNamed:@"splash_img4"];
    page4.clipsToBounds = YES;
    [page4 addSubview:imgV4_1];
    [page4 addSubview:imgV4_2];
    [launchV.view addSubview:page4];
    launchV.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self.navigationController presentViewController:launchV animated:NO completion:
     ^{
         [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(dismissLaunchView) userInfo:nil repeats:NO];
     }];
}

-(void)dismissLaunchView
{
    [self dismissBlackView];
    [launchV dismissViewControllerAnimated:YES completion:nil];
}

-(void)showBlackView
{
    if (!blackView) {
        CGRect screen = [UIScreen mainScreen].bounds;
        blackView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screen.size.width, screen.size.height)];
        [blackView setBackgroundColor:[UIColor blackColor]];
    }
    [self.view addSubview:blackView];
    [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(dismissBlackView) userInfo:nil repeats:NO];
}

-(void)dismissBlackView
{
    [blackView removeFromSuperview];
}

-(void)checkPreUP
{
    NSString *userStatus =  [[NSUserDefaults standardUserDefaults] objectForKey:@"MeticStatus"];
    if ([userStatus isEqualToString:@"in"] && [MTAccount isExist]) {
        MTAccount *account = [MTAccount singleInstance];
        enum MTAccountType type = account.type;
        if (type == MTAccountTypeEmail) {
            [self checkPassWordWithAccount:account.email Password:account.password];
        }else if (type == MTAccountTypePhoneNumber) {
            [self checkPassWordWithAccount:account.phoneNumber Password:account.password];
        }else if(type == MTAccountTypeQQ || type == MTAccountTypeWeChat || type == MTAccountTypeWeiBo) {
            [self thirdPartyLoginWithOpenIdOnBackground:account.openId type:type];
        }
        appDelegate.isLogined = YES;
        [[MTUser sharedInstance] setUid:[MTUser sharedInstance].userid];

        BOOL hadCompleteInfo= account.hadCompleteInfo;
        if (!hadCompleteInfo) {
            [self performSelectorOnMainThread:@selector(jumpToFillinInfo) withObject:nil waitUntilDone:YES];
        } else {
            [self performSelectorOnMainThread:@selector(jumpToMainView) withObject:nil waitUntilDone:YES];
        }
        
    } else {
        [[NSUserDefaults standardUserDefaults] setValue:@"out" forKey:@"MeticStatus"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[MTAccount singleInstance] deleteAccount];
    }
}

-(void)checkPassWordWithAccount:(NSString *)account Password:(NSString *)password
{
    [MTAccountManager loginWithAccount:account password:password success:^(MTLoginResponse *user) {
    } failure:^(enum MTLoginResult result, NSString *message) {
        if (result == MTLoginResultPasswordInvalid) {
            MTLOG(@"验证密码失败，强制退出到登录页面");
            [[NSNotificationCenter defaultCenter]postNotificationName:@"forceQuitToLogin" object:nil];
        }
    }];
}

- (void)thirdPartyLoginWithOpenIdOnBackground:(NSString *)openId type:(enum MTAccountType)type {
    [MTAccountManager thirdPartyLoginWithOpenId:openId type:type success:^(MTLoginResponse *user) {
        MTLOG(@"login succeeded");
        ((AppDelegate*)([UIApplication sharedApplication].delegate)).isLogined = YES;
        //保存账户信息
        [[MenuViewController sharedInstance] dianReset];
        [[MenuViewController sharedInstance] refresh];
        [[appDelegate leftMenu] clearVC];
        
        NSNumber* min_seq = user.minMegSeq;
        NSNumber* max_seq = user.maxMegSeq;
        if (min_seq && max_seq && [min_seq integerValue] != 0 && [max_seq integerValue] != 0) {
            [MTPushMessageHandler pullAndHandlePushMessageWithMinSeq:min_seq andMaxSeq:max_seq andCallBackBlock:NULL];
        }
    } failure:^(enum MTLoginResult result, NSString *message) {
    }];
}

- (void)jumpToMainView
{
    [self performSegueWithIdentifier:@"loginTohome" sender:self];
}

- (void)jumpToRegisterView
{
    [self performSegueWithIdentifier:@"LoginToRegister" sender:self];
}

-(void)jumpToFillinInfo
{
    [self performSegueWithIdentifier:@"login_fillinInfo" sender:self];
}

#pragma mark - Button click
- (IBAction)loginButtonClicked:(id)sender {
    [self.textField_userName resignFirstResponder];
    [self.textField_password resignFirstResponder];
    
    if (![CommonUtils isEmailValid: textField_userName.text]) {
        [SVProgressHUD showErrorWithStatus:@"邮箱格式不正确" duration:1.f];
        return;
    } else if ([[textField_password text] length] < 5) {
        [SVProgressHUD showErrorWithStatus:@"密码长度请不要小于5位" duration:1.f];
        return;
    }
   
    MTLOG(@"%@",[self.textField_userName text]);
    self.logInEmail = [self.textField_userName text];
    self.logInPassword = [self.textField_password text];

    [self login];
}

- (IBAction)registerBtnClicked:(id)sender
{
    RegisterWithPhoneViewController *vc = [[RegisterWithPhoneViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)QQLogin:(id)sender {
    [ShareSDK getUserInfo:SSDKPlatformTypeQQ
           onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error)
     {
         if (state == SSDKResponseStateSuccess) {
             NSString *openId = user.uid;
             [self thirdPartyLoginWithOpenId:openId type:MTAccountTypeQQ];
         } else {
             NSLog(@"%@",error);
         }
     }];
}

- (IBAction)WeiXinLogin:(id)sender {
    [ShareSDK getUserInfo:SSDKPlatformTypeWechat
           onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error)
     {
         if (state == SSDKResponseStateSuccess) {
             NSString *openId = user.uid;
             [self thirdPartyLoginWithOpenId:openId type:MTAccountTypeWeChat];
         } else {
             NSLog(@"%@",error);
         }
     }];
}

- (IBAction)WeiBoLogin:(id)sender {
    [ShareSDK getUserInfo:SSDKPlatformTypeSinaWeibo
           onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error)
     {
         if (state == SSDKResponseStateSuccess) {
             NSString *openId = user.uid;
             [self thirdPartyLoginWithOpenId:openId type:MTAccountTypeWeiBo];
         } else {
             NSLog(@"%@",error);
         }
     }];
}

- (void)thirdPartyLoginWithOpenId:(NSString *)openId type:(enum MTAccountType)type {
    [SVProgressHUD showWithStatus:@"正在登录，请稍后" maskType:SVProgressHUDMaskTypeBlack];
    [MTAccountManager thirdPartyLoginWithOpenId:openId type:type success:^(MTLoginResponse *user) {
        MTLOG(@"login succeeded");
        ((AppDelegate*)([UIApplication sharedApplication].delegate)).isLogined = YES;
        //保存账户信息
        BOOL hadCompleteInfo= [user.hadCompleteInfo boolValue];
        MTAccount *account = [MTAccount singleInstance];
        account.openId = openId;
        account.type = type;
        account.hadCompleteInfo = hadCompleteInfo;
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
        if (min_seq && max_seq && [min_seq integerValue] != 0 && [max_seq integerValue] != 0) {
            [MTPushMessageHandler pullAndHandlePushMessageWithMinSeq:min_seq andMaxSeq:max_seq andCallBackBlock:NULL];
        }
        [SVProgressHUD dismissWithSuccess:@"登录成功" afterDelay:1.f];
        
        if (!hadCompleteInfo) {
            [self jumpToFillinInfo];
        } else {
            [self jumpToMainView];
        }
    } failure:^(enum MTLoginResult result, NSString *message) {
        [SVProgressHUD dismissWithError:message afterDelay:1.f];
    }];
}

- (void)login{
    [SVProgressHUD showWithStatus:@"正在登录，请稍后" maskType:SVProgressHUDMaskTypeBlack];
    [MTAccountManager loginWithAccount:self.logInEmail password:self.logInPassword success:^(MTLoginResponse *user) {
        MTLOG(@"login succeeded");
        ((AppDelegate*)([UIApplication sharedApplication].delegate)).isLogined = YES;
        
        //保存账户信息
        BOOL hadCompleteInfo= [user.hadCompleteInfo boolValue];
        MTAccount *account = [MTAccount singleInstance];
        account.email = self.logInEmail;
        account.password = self.logInPassword;
        account.type = MTAccountTypeEmail;
        account.hadCompleteInfo = hadCompleteInfo;
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
        if (min_seq && max_seq && [min_seq integerValue] != 0 && [max_seq integerValue] != 0) {
            [MTPushMessageHandler pullAndHandlePushMessageWithMinSeq:min_seq andMaxSeq:max_seq andCallBackBlock:NULL];
        }
        [SVProgressHUD dismissWithSuccess:@"登录成功" afterDelay:1.f];
        
        if (!hadCompleteInfo) {
            [self jumpToFillinInfo];
        } else {
            [self jumpToMainView];
        }
    } failure:^(enum MTLoginResult result, NSString *message) {
        [SVProgressHUD dismissWithError:message afterDelay:1.f];
    }];
}

@end
