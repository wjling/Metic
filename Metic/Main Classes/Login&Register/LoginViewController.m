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
#import "FindPasswordViewController.h"
#import "CommonUtils.h"
#import "MobClick.h"
#import "MTPushMessageHandler.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "MTAccountManager.h"
#import "SVProgressHUD.h"
#import "SocialSnsApi.h"
#import "MTThridAccount.h"
#import "WeiboUser.h"

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

#pragma mark - Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [self setupUI];
    [self showBlackView];
    NSUserDefaults* userDf = [NSUserDefaults standardUserDefaults];
    if (![userDf boolForKey:@"hadShowWelcomePage"]) {
        MTLOG(@"login: it is the first launch");
        [userDf setBool:YES forKey:@"hadShowWelcomePage"];
        [self showWelcomePage];
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
    [self setupThirdLoginBtn];
    [self checkPreUP];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [MobClick beginLogPageView:@"登录"];
    [self.navigationController setNavigationBarHidden:NO];
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
- (void)showWelcomePage
{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone"
                                                         bundle: nil];
    WelcomePageViewController* vc = [storyboard instantiateViewControllerWithIdentifier:@"WelcomePageViewController"];
    [self presentViewController:vc animated:NO completion:^{
        [blackView removeFromSuperview];
        blackView = nil;
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

-(void)jumpToFillinInfo:(MTThridAccount *)thirdAccount
{
    if (![thirdAccount isKindOfClass:[MTThridAccount class]]) {
        thirdAccount = nil;
    }
    UIStoryboard* mainStoryBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    FillinInfoViewController *vc = [mainStoryBoard instantiateViewControllerWithIdentifier:@"FillinInfoViewController"];
    
    vc.gender = thirdAccount.gender;
    vc.name = thirdAccount.nickname;
    vc.thirdAccount = thirdAccount;
    [self.navigationController pushViewController:vc animated:YES];
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
    self.textField_userName.placeholder = @"请输入邮箱/手机号";
    self.textField_userName.keyboardType = UIKeyboardTypeEmailAddress;
    self.textField_userName.text = text_userName? text_userName:@"";
    self.textField_userName.leftView = userNameLeftView;
    self.textField_userName.leftViewMode = UITextFieldViewModeAlways;
    self.textField_userName.layer.cornerRadius = 5.f;
    self.textField_userName.layer.borderColor = [CommonUtils colorWithValue:0xEEEEEE].CGColor;
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
    self.textField_password.layer.borderColor = [CommonUtils colorWithValue:0xEEEEEE].CGColor;
    self.textField_password.layer.borderWidth = 2;
    self.textField_password.layer.masksToBounds = YES;
}

- (void)setupThirdLoginBtn {
    
    if ([WXApi isWXAppInstalled]) {
        
        [self.weixinLoginBtn setImage:[UIImage imageNamed:@"loading_wechat"] forState:UIControlStateNormal];
        self.weixinLoginBtn.hidden = NO;
        
        NSArray *constraints = self.view.constraints;
        for (NSLayoutConstraint *constraint in constraints) {
            if ([[constraint identifier] isEqualToString:@"qqBtnXAlign"]) {
                constraint.constant = 80;
            } else if ([[constraint identifier] isEqualToString:@"weiboBtnXAlign"]) {
                constraint.constant = -80;
            }
        }
    } else {
        
        [self.weixinLoginBtn setImage:[UIImage imageNamed:@"loading_wechat_gray"] forState:UIControlStateNormal];
        self.weixinLoginBtn.hidden = YES;

        NSArray *constraints = self.view.constraints;
        for (NSLayoutConstraint *constraint in constraints) {
            if ([[constraint identifier] isEqualToString:@"qqBtnXAlign"]) {
                constraint.constant = 50;
            } else if ([[constraint identifier] isEqualToString:@"weiboBtnXAlign"]) {
                constraint.constant = -50;
            }
        }
    }
    
    if ([WeiboSDK isWeiboAppInstalled]) {
        [self.weiboLoginBtn setImage:[UIImage imageNamed:@"loading_weibo"] forState:UIControlStateNormal];
    } else {
        [self.weiboLoginBtn setImage:[UIImage imageNamed:@"loading_weibo"] forState:UIControlStateNormal];
    }
    
    if ([QQApiInterface isQQInstalled]) {
        [self.qqLoginBtn setImage:[UIImage imageNamed:@"loading_qq"] forState:UIControlStateNormal];
    } else {
        [self.qqLoginBtn setImage:[UIImage imageNamed:@"loading_qq"] forState:UIControlStateNormal];
    }
}

-(void)forgetPSBtnClick:(id)sender
{
    FindPasswordViewController *vc = [[FindPasswordViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - ShowViews
-(void)showLaunchView
{
    CGRect bounds = [UIScreen mainScreen].bounds;
    CGFloat y;
    if (bounds.size.height <= 480) {
        y = 40;
    } else if (bounds.size.height <= 600){
        y = 70;
    } else {
        y = 90;
    }
    CGFloat view_width = bounds.size.width;
    CGFloat view_height = bounds.size.height;
    UIColor* bgColor = [CommonUtils colorWithValue:0x57caab];
    launchV = [[UIViewController alloc]init];
    UIView* page4 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, view_width, view_height)];
    UIImageView* imgV4_1 = [[UIImageView alloc]initWithFrame:CGRectMake(21, y, view_width - 42, 115)];
    UIImageView* imgV4_2 = [[UIImageView alloc]initWithFrame:CGRectMake(-60, view_height - 225 - 2 * y, view_width + 120, 385)];
    imgV4_1.contentMode = UIViewContentModeScaleAspectFill;
    imgV4_2.contentMode = UIViewContentModeScaleAspectFill;
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
         [blackView removeFromSuperview];
         blackView = nil;
         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
             [launchV dismissViewControllerAnimated:YES completion:nil];

         });
     }];
}

-(void)showBlackView
{
    if (!blackView) {
        CGRect screen = [UIScreen mainScreen].bounds;
        blackView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screen.size.width, screen.size.height)];
        [blackView setBackgroundColor:[UIColor blackColor]];
    }
    UIWindow *window = appDelegate.window;
    [window addSubview:blackView];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [blackView removeFromSuperview];
        blackView = nil;
    });
}

-(void)checkPreUP
{
    if (blackView) {
//        return;
    }
    NSString *userStatus =  [[NSUserDefaults standardUserDefaults] objectForKey:@"MeticStatus"];
    BOOL isIn = [userStatus isEqualToString:@"in"];
    if ([MTAccount isExist]) {
        MTAccount *account = [MTAccount singleInstance];
        BOOL hadCompleteInfo= account.hadCompleteInfo;
        BOOL isActive = account.isActive;
        enum MTAccountType type = account.type;
        if (type == MTAccountTypeEmail && account.email && account.password) {
            self.textField_userName.text = account.email;
            self.textField_password.text = account.password;
            if (!hadCompleteInfo || !isActive || !isIn)
                return;
            [self checkPassWordWithAccount:account.email Password:account.password];
        } else if (type == MTAccountTypePhoneNumber && account.phoneNumber && account.password) {
            self.textField_userName.text = account.phoneNumber;
            self.textField_password.text = account.password;
            if (!hadCompleteInfo || !isActive || !isIn)
                return;
            [self checkPassWordWithAccount:account.phoneNumber Password:account.password];
        } else if(type == MTAccountTypeQQ || type == MTAccountTypeWeChat || type == MTAccountTypeWeiBo) {
            if (!hadCompleteInfo || !isActive || !isIn)
                return;
            [self thirdPartyLoginWithOpenIdOnBackground:account.openId type:type];
        } else {
            [account deleteAccount];
            return;
        }
        appDelegate.isLogined = YES;
        [[MTUser sharedInstance] setUid:[MTUser sharedInstance].userid];

        [self performSelectorOnMainThread:@selector(jumpToMainView) withObject:nil waitUntilDone:YES];
        
    } else {
        [[NSUserDefaults standardUserDefaults] setValue:@"out" forKey:@"MeticStatus"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[MTAccount singleInstance] deleteAccount];
    }
}

#pragma mark - Button click
- (IBAction)loginButtonClicked:(id)sender {
    [self.textField_userName resignFirstResponder];
    [self.textField_password resignFirstResponder];

    if (![CommonUtils isEmailValid: textField_userName.text] && ![CommonUtils isPhoneNumberVaild:textField_userName.text]) {
        [SVProgressHUD showErrorWithStatus:@"账号格式不正确" duration:1.f];
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
    
    UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToQQ];
    
    snsPlatform.loginClickHandler(self,[UMSocialControllerService defaultControllerService],YES,^(UMSocialResponseEntity *response){
        
        if (response.responseCode == UMSResponseCodeSuccess) {
            
            NSDictionary *dict = [UMSocialAccountManager socialAccountDictionary];
            UMSocialAccountEntity *snsAccount = [dict valueForKey:UMShareToQQ];
            
            MTThridAccount *account = [[MTThridAccount alloc] init];
            account.openID = snsAccount.usid;
            account.gender = [response.thirdPlatformUserProfile[@"gender"] isEqualToString:@"男"]? @1:@0;
            account.iconUrl = snsAccount.iconURL;
            account.nickname = snsAccount.userName;
            
            [self thirdPartyLoginWithOpenId:account type:MTAccountTypeQQ];
            
        }
    });
}

- (IBAction)WeiXinLogin:(id)sender {
    
    if (![WXApi isWXAppInstalled]) {
        [SVProgressHUD showErrorWithStatus:@"请先安装微信客户端" duration:1.5f];
        return;
    }
    
    UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToWechatSession];
    
    snsPlatform.loginClickHandler(self,[UMSocialControllerService defaultControllerService],YES,^(UMSocialResponseEntity *response){
        
        if (response.responseCode == UMSResponseCodeSuccess) {
            
            NSDictionary *dict = [UMSocialAccountManager socialAccountDictionary];
            UMSocialAccountEntity *snsAccount = [dict valueForKey:UMShareToWechatSession];
            
            MTThridAccount *account = [[MTThridAccount alloc] init];
            account.openID = snsAccount.usid;
            account.gender = [response.thirdPlatformUserProfile[@"sex"] isEqual: @1]? @1:@0;
            account.iconUrl = snsAccount.iconURL;
            account.nickname = snsAccount.userName;
            
            [self thirdPartyLoginWithOpenId:account type:MTAccountTypeWeChat];
        }
    });
}

- (IBAction)WeiBoLogin:(id)sender {
    
    UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToSina];
    
    snsPlatform.loginClickHandler(self,[UMSocialControllerService defaultControllerService],YES,^(UMSocialResponseEntity *response){
        if (response.responseCode == UMSResponseCodeSuccess) {
            
            NSDictionary *dict = [UMSocialAccountManager socialAccountDictionary];
            UMSocialAccountEntity *snsAccount = [dict valueForKey:UMShareToSina];
            
            MTThridAccount *account = [[MTThridAccount alloc] init];
            account.openID = snsAccount.usid;
            account.iconUrl = snsAccount.iconURL;
            account.nickname = snsAccount.userName;
            WeiboUser *user = response.thirdPlatformUserProfile;
            account.gender = [user.gender isEqualToString:@"m"]? @1:@0;
            
            [self thirdPartyLoginWithOpenId:account type:MTAccountTypeWeiBo];
        }
    });
}

#pragma mark - Login
- (void)thirdPartyLoginWithOpenId:(MTThridAccount *)thirdAccount type:(enum MTAccountType)type {
    [SVProgressHUD showWithStatus:@"正在登录，请稍候" maskType:SVProgressHUDMaskTypeBlack];
    NSString *openId = thirdAccount.openID;
    [MTAccountManager thirdPartyLoginWithOpenId:openId type:type success:^(MTLoginResponse *user) {
        MTLOG(@"login succeeded");
        ((AppDelegate*)([UIApplication sharedApplication].delegate)).isLogined = YES;
        //保存账户信息
        BOOL hadCompleteInfo= [user.hadCompleteInfo boolValue];
        MTAccount *account = [MTAccount singleInstance];
        account.openId = openId;
        account.type = type;
        account.isActive = YES;
        account.hadCompleteInfo = hadCompleteInfo;
        [account saveAccount];
        
        [[NSUserDefaults standardUserDefaults] setObject:@"in" forKey:@"MeticStatus"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSNumber *userid = user.userId;
        [[MTUser sharedInstance] setUid:userid];
        
        [MenuViewController dianReset];
        [[MenuViewController sharedInstance] refresh];
        [[appDelegate leftMenu] clearVC];

        NSNumber* min_seq = user.minMegSeq;
        NSNumber* max_seq = user.maxMegSeq;
        [MTPushMessageHandler setupMaxNotificationSeq:min_seq];
        if (min_seq && max_seq && [min_seq integerValue] != 0 && [max_seq integerValue] != 0) {
            [MTPushMessageHandler pullAndHandlePushMessageWithMinSeq:min_seq andMaxSeq:max_seq andCallBackBlock:NULL];
        }
        [SVProgressHUD dismissWithSuccess:@"登录成功" afterDelay:1.f];
        
        if (!hadCompleteInfo) {
            [self jumpToFillinInfo:thirdAccount];
        } else {
            [self jumpToMainView];
        }
    } failure:^(enum MTLoginResult result, NSString *message) {
        [SVProgressHUD dismissWithError:message afterDelay:1.f];
    }];
}

- (void)login{
    [SVProgressHUD showWithStatus:@"正在登录，请稍候" maskType:SVProgressHUDMaskTypeBlack];
    [MTAccountManager loginWithAccount:self.logInEmail password:self.logInPassword success:^(MTLoginResponse *user) {
        MTLOG(@"login succeeded");
        ((AppDelegate*)([UIApplication sharedApplication].delegate)).isLogined = YES;
        
        //保存账户信息
        BOOL hadCompleteInfo= [user.hadCompleteInfo boolValue];
        BOOL isPhoneNumber = [CommonUtils isPhoneNumberVaild:self.logInEmail];
        MTAccount *account = [MTAccount singleInstance];
        if(isPhoneNumber) {
            account.phoneNumber = self.logInEmail;
            account.type = MTAccountTypePhoneNumber;
        } else {
            account.email = self.logInEmail;
            account.type = MTAccountTypeEmail;
        }
        account.email = self.logInEmail;
        account.password = self.logInPassword;
        account.hadCompleteInfo = hadCompleteInfo;
        account.isActive = YES;
        [account saveAccount];
        [[NSUserDefaults standardUserDefaults] setObject:@"in" forKey:@"MeticStatus"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSNumber *userid = user.userId;
        [[MTUser sharedInstance] setUid:userid];
        
        [MenuViewController dianReset];
        [[MenuViewController sharedInstance] refresh];
        [[appDelegate leftMenu] clearVC];
        
        NSNumber* min_seq = user.minMegSeq;
        NSNumber* max_seq = user.maxMegSeq;
        [MTPushMessageHandler setupMaxNotificationSeq:min_seq];
        if (min_seq && max_seq && [min_seq integerValue] != 0 && [max_seq integerValue] != 0) {
            [MTPushMessageHandler pullAndHandlePushMessageWithMinSeq:min_seq andMaxSeq:max_seq andCallBackBlock:NULL];
        }
        [SVProgressHUD dismissWithSuccess:@"登录成功" afterDelay:1.f];
        
        if (!hadCompleteInfo) {
            [self jumpToFillinInfo:nil];
        } else {
            [self jumpToMainView];
        }
    } failure:^(enum MTLoginResult result, NSString *message) {
        [SVProgressHUD dismissWithError:message afterDelay:1.f];
    }];
}

#pragma mark - Login in Background
-(void)checkPassWordWithAccount:(NSString *)account Password:(NSString *)password
{
    [MTAccountManager loginWithAccount:account password:password success:^(MTLoginResponse *user) {
    //同步推送消息
        MTLOG(@"开始同步消息");
        [MenuViewController dianReset];
        [[MenuViewController sharedInstance] refresh];
        [[appDelegate leftMenu] clearVC];
        void(^synchronizeDone)(NSNumber*, NSNumber*) = ^(NSNumber* min_seq, NSNumber* max_seq)
        {
            if (!min_seq || !max_seq) {
                return;
            }
            [MTPushMessageHandler pullAndHandlePushMessageWithMinSeq:min_seq andMaxSeq:max_seq andCallBackBlock:nil];
        };
        [MTPushMessageHandler synchronizePushSeqAndCallBack:synchronizeDone];
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
        [MenuViewController dianReset];
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

@end
