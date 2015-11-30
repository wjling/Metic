//
//  LoginViewController.m
//  Metic
//
//  Created by ligang_mac4 on 14-5-27.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "LoginViewController.h"
#import "MenuViewController.h"
#import "GetBackPasswordViewController.h"
#import "CommonUtils.h"
#import "MobClick.h"
#import "MTPushMessageHandler.h"
#import "TPKeyboardAvoidingScrollView.h"

@interface LoginViewController ()
{
    enum TAG_LOGIN
    {
        Tag_userName = 50,
        Tag_password
    };
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
@synthesize fromRegister;
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
    MTLOG(@"login did load, fromRegister: %d",fromRegister);
    [self setupUI];
    [self showBlackView];
    NSUserDefaults* userDf = [NSUserDefaults standardUserDefaults];
    appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    if (!fromRegister) {
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
}

//返回上一层
-(void)MTpopViewController{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    MTLOG(@"login will apear");
    if (fromRegister) {
        fromRegister = NO;
        textField_userName.text = text_userName;
        textField_password.text = text_password;
    }
    else{
        [self checkPreUP];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [MobClick beginLogPageView:@"登录"];
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
    [forgetPS_btn setTitle:@"忘记密码?" forState:UIControlStateNormal];
    [forgetPS_btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [forgetPS_btn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    forgetPS_btn.titleLabel.font = [UIFont systemFontOfSize:13];
    [forgetPS_btn setBackgroundColor:[UIColor clearColor]];
    [forgetPS_btn addTarget:self action:@selector(forgetPSBtnClick:) forControlEvents:UIControlEventTouchUpInside];

    UIColor *backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"背景颜色方格.png"]];
    [self.view setBackgroundColor:backgroundColor];
    
    self.Img_register.layer.cornerRadius = 3;
    
    UILabel *userNameLeftView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 44)];
    userNameLeftView.text = @"账号";
    userNameLeftView.font = [UIFont systemFontOfSize:15];
    userNameLeftView.textAlignment = NSTextAlignmentCenter;
    
    self.textField_userName.tag = Tag_userName;
//    self.textField_userName.returnKeyType = UIReturnKeyNext;
    self.textField_userName.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.textField_userName.placeholder = @"请输入您的邮箱";
    self.textField_userName.keyboardType = UIKeyboardTypeEmailAddress;
    self.textField_userName.text = text_userName? text_userName:@"";
    self.textField_userName.leftView = userNameLeftView;
    self.textField_userName.leftViewMode = UITextFieldViewModeAlways;
    
    UILabel *passwordLeftView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 44)];
    passwordLeftView.text = @"密码";
    passwordLeftView.font = [UIFont systemFontOfSize:15];
    passwordLeftView.textAlignment = NSTextAlignmentCenter;
    
    self.textField_password.tag = Tag_password;
//    self.textField_password.returnKeyType = UIReturnKeyDone;
    self.textField_password.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.textField_password.delegate = self;
    self.textField_password.placeholder = @"请输入密码";
    self.textField_password.secureTextEntry = YES;
    self.textField_password.text = text_password? text_password:@"";
    self.textField_password.leftView = passwordLeftView;
    self.textField_password.leftViewMode = UITextFieldViewModeAlways;
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


-(void)showWaitingView
{
    if (!_waitingView) {
        CGRect frame = self.view.bounds;
        _waitingView = [[UIView alloc]initWithFrame:frame];
        [_waitingView setUserInteractionEnabled:NO];
        [_waitingView setBackgroundColor:[UIColor blackColor]];
        [_waitingView setAlpha:0.5f];
        frame.origin.x = (frame.size.width - 100)/2.0;
        frame.origin.y = (frame.size.height - 100)/2.0;
        frame.size = CGSizeMake(100, 100);
        UIActivityIndicatorView* indicator = [[UIActivityIndicatorView alloc]initWithFrame:frame];
        [indicator setTag:101];
        [_waitingView addSubview:indicator];
    }
    
    [self.view addSubview:_waitingView];
    [((UIActivityIndicatorView*)[_waitingView viewWithTag:101]) startAnimating];
}

-(void)removeWaitingView
{
    if (_waitingView) {
        [_waitingView removeFromSuperview];
    }
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

-(void)loginFail
{
    [CommonUtils showSimpleAlertViewWithTitle:@"消息" WithMessage:@"网络异常，请重试" WithDelegate:self WithCancelTitle:@"确定"];
}

-(void)checkPreUP
{
    [self.button_login setEnabled:NO];
    [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(recoverloginbutton) userInfo:nil repeats:NO];
//    NSString *userName = [SFHFKeychainUtils getPasswordForUsername:@"MeticUserName"andServiceName:@"Metic0713" error:nil];
//    NSString *password = [SFHFKeychainUtils getPasswordForUsername:@"MeticPassword"andServiceName:@"Metic0713" error:nil];
//    NSString *userStatus = [SFHFKeychainUtils getPasswordForUsername:@"MeticStatus"andServiceName:@"Metic0713" error:nil];
    
    NSString* MtsecretPath= [NSString stringWithFormat:@"%@/Documents/Meticdata", NSHomeDirectory()];
    NSArray *arr = [NSKeyedUnarchiver unarchiveObjectWithFile: MtsecretPath];
    NSString *userName = [arr objectAtIndex:0];
    NSString *password =  [arr objectAtIndex:1];
    NSString *userStatus =  [[NSUserDefaults standardUserDefaults] objectForKey:@"MeticStatus"];
    if ([userStatus isEqualToString:@"in"]) {
        //处理登录状态下，直接跳转 需要读取默认信息。
        MTLOG(@"用户 %@ 在线", userName);
        appDelegate.isLogined = YES;
        appDelegate.hadCheckPassWord = NO;
        if (![[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == 0) {
            MTLOG(@"有网络，验证密码");
            [self checkPassWord];
        }
        [self removeWaitingView];
        [[MTUser sharedInstance] setUid:[MTUser sharedInstance].userid];
        [button_login setEnabled:YES];
        [self performSelectorOnMainThread:@selector(jumpToMainView) withObject:nil waitUntilDone:YES];
    
    }
    else if ([userStatus isEqualToString:@"change"])
    {
        [[NSUserDefaults standardUserDefaults] setValue:@"out" forKey:@"MeticStatus"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    if (userName && password) {
        self.textField_userName.text = userName;
        self.textField_password.text = password;
        self.logInEmail = userName;
        self.logInPassword = password;
        [self.button_login setEnabled:YES];
    }else [self.button_login setEnabled:YES];
}

-(void)checkPassWord
{
    if (appDelegate.hadCheckPassWord) {
        return;
    }
    NSString* MtsecretPath= [NSString stringWithFormat:@"%@/Documents/Meticdata", NSHomeDirectory()];
    NSArray *arr = [NSKeyedUnarchiver unarchiveObjectWithFile: MtsecretPath];
    NSString *userName = [arr objectAtIndex:0];
    NSString *password =  [arr objectAtIndex:1];
    self.logInEmail = userName;
    self.logInPassword = password;
    if (self.logInEmail && self.logInPassword) {
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
        [dictionary setValue:self.logInEmail forKey:@"email"];
        [dictionary setValue:@"" forKey:@"passwd"];
        [dictionary setValue:[NSNumber numberWithBool:NO] forKey:@"has_salt"];
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
        HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
        [httpSender sendMessage:jsonData withOperationCode:LOGIN finshedBlock:^(NSData *rData) {
            if (!rData) {
                MTLOG(@"服务器错误，返回的data为空");
                return;
            }
            NSString* temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
            MTLOG(@"Received Data: %@",temp);
            NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
            NSNumber *cmd = [response1 valueForKey:@"cmd"];
            switch ([cmd intValue]) {
                case GET_SALT:
                {
                    NSString *salt = [response1 valueForKey:@"salt"];
                    NSString *str = [self.logInPassword stringByAppendingString:salt];
                    [MTUser sharedInstance].saltValue = salt;
                    
                    //MD5 encrypt
                    NSMutableString *md5_str = [NSMutableString string];
                    md5_str = [CommonUtils MD5EncryptionWithString:str];
                    
                    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
                    [params setValue:self.logInEmail forKey:@"email"];
                    [params setValue:md5_str forKey:@"passwd"];
                    [params setValue:[NSNumber numberWithBool:YES] forKey:@"has_salt"];
                    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil];
                    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
                    [httpSender sendMessage:jsonData withOperationCode:LOGIN finshedBlock:^(NSData *rData) {
                        if (!rData) {
                            MTLOG(@"服务器错误，返回的data为空");
                            return;
                        }
                        NSString* temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
                        MTLOG(@"Received Data: %@",temp);
                        NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
                        NSNumber *cmd = [response1 valueForKey:@"cmd"];
                        switch ([cmd intValue]) {
                            case LOGIN_SUC:
                            {
                                appDelegate.hadCheckPassWord = YES;
                                MTLOG(@"验证密码成功");
                            }
                                break;
                            default:
                            {
                                //通知退出到登录页面
                                MTLOG(@"验证密码错误，强制退出到登录页面");
                                [[NSNotificationCenter defaultCenter]postNotificationName:@"forceQuitToLogin" object:nil];
                            }
                        }
                    }];
                    
                }
                    break;
                default:
                {
                    //通知退出到登录页面
                    MTLOG(@"获取盐值失败，强制退出到登录页面");
                    [[NSNotificationCenter defaultCenter]postNotificationName:@"forceQuitToLogin" object:nil];
                }
            }
        }];
    }
}

- (void) recoverloginbutton
{
    [button_login setEnabled:YES];
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
    if ([textField_userName text] != nil && [[textField_userName text] length]!= 0) {
        
        if (![CommonUtils isEmailValid: textField_userName.text]) {
            
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"邮箱格式不正确" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
            return;
        }
        
    }
    if ([textField_password text] != nil) {
        
        if ([[textField_password text] length] < 5) {
            
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"密码长度请不要小于5" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
            return;
        }
        
    }
    [sender setEnabled:NO];
    [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(recoverloginbutton) userInfo:nil repeats:NO];
    MTLOG(@"%@",[self.textField_userName text]);
    self.logInEmail = [self.textField_userName text];
    self.logInPassword = [self.textField_password text];
    _timer = [NSTimer scheduledTimerWithTimeInterval:6.0f target:self selector:@selector(loginFail) userInfo:nil repeats:NO];
    [self.textField_password endEditing:YES];
    [self.textField_userName endEditing:YES];
    [self login];

}

-(void)login{
//    [self backgroundBtn:self];
    [self showWaitingView];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:self.logInEmail forKey:@"email"];
    [dictionary setValue:@"" forKey:@"passwd"];
    [dictionary setValue:[NSNumber numberWithBool:NO] forKey:@"has_salt"];
    
    MTLOG(@"%@",dictionary);
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:LOGIN];
}

- (IBAction)registerBtnClicked:(id)sender
{
    [self jumpToRegisterView];
}


#pragma mark - HttpSenderDelegate

-(void)finishWithReceivedData:(NSData *)rData
{
    if (!rData) {
        MTLOG(@"服务器错误，返回的data为空");
        return;
    }
    NSString* temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
    MTLOG(@"Received Data: %@",temp);
    NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
    NSNumber *cmd = [response1 valueForKey:@"cmd"];
    switch ([cmd intValue]) {
        case GET_SALT:
        {
            NSString *salt = [response1 valueForKey:@"salt"];
            NSString *str = [self.logInPassword stringByAppendingString:salt];
            [MTUser sharedInstance].saltValue = salt;
            //MD5 encrypt
            NSMutableString *md5_str = [NSMutableString string];
            md5_str = [CommonUtils MD5EncryptionWithString:str];
            
            NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
            [params setValue:self.logInEmail forKey:@"email"];
            [params setValue:md5_str forKey:@"passwd"];
            [params setValue:[NSNumber numberWithBool:YES] forKey:@"has_salt"];
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil];
            MTLOG(@"%@",[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding]);
            
            HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
            [httpSender sendMessage:jsonData withOperationCode:LOGIN];
            
        }
            break;
        case LOGIN_SUC:
        {
            [_timer invalidate];
            appDelegate.hadCheckPassWord = YES;
//            BOOL name = [SFHFKeychainUtils storeUsername:@"MeticUserName" andPassword:self.logInEmail forServiceName:@"Metic0713" updateExisting:1 error:nil];
//            BOOL key = [SFHFKeychainUtils storeUsername:@"MeticPassword" andPassword:self.logInPassword forServiceName:@"Metic0713" updateExisting:1 error:nil];
//            BOOL status = [SFHFKeychainUtils storeUsername:@"MeticStatus" andPassword:@"in" forServiceName:@"Metic0713" updateExisting:1 error:nil];
            MTLOG(@"login succeeded");
            ((AppDelegate*)([UIApplication sharedApplication].delegate)).isLogined = YES;
            //保存信息
            NSString* MtsecretPath= [NSString stringWithFormat:@"%@/Documents/Meticdata", NSHomeDirectory()];
            NSArray *Array = [NSArray arrayWithObjects:self.logInEmail, self.logInPassword, nil];
            [[NSUserDefaults standardUserDefaults] setObject:@"in" forKey:@"MeticStatus"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [NSKeyedArchiver archiveRootObject:Array toFile:MtsecretPath];

            [self removeWaitingView];
            NSNumber *userid = [response1 valueForKey:@"id"];
            [[MTUser sharedInstance] setUid:userid];
            
            [[MenuViewController sharedInstance] dianReset];
            [[MenuViewController sharedInstance] refresh];
            [[appDelegate leftMenu] clearVC];
            NSString* logintime = [response1 objectForKey:@"logintime"];
            NSNumber* min_seq = [response1 objectForKey:@"min_seq"];
            NSNumber* max_seq = [response1 objectForKey:@"max_seq"];
            if (min_seq && max_seq && [min_seq integerValue] != 0 && [max_seq integerValue] != 0) {
                void(^getPushMessageDone)(NSDictionary*) = ^(NSDictionary* response)
                {
                    //反馈给服务器
                    [MTPushMessageHandler feedBackPushMessagewithMinSeq:min_seq andMaxSeq:max_seq andCallBack:nil];
                };
                [MTPushMessageHandler pullAndHandlePushMessageWithMinSeq:min_seq andMaxSeq:max_seq andCallBackBlock:getPushMessageDone];
            }
            if ([logintime isEqualToString:@"None"]) {
                [self jumpToFillinInfo];
            }
            else
            {
                [self jumpToMainView];
            }
            
            [button_login setEnabled:YES];
        }
            break;
        case PASSWD_NOT_CORRECT:
        {
            [_timer invalidate];
            [CommonUtils showSimpleAlertViewWithTitle:@"系统消息" WithMessage:@"密码错误，请重试" WithDelegate:self WithCancelTitle:@"确定"];
            [button_login setEnabled:YES];
            MTLOG(@"password not correct");
            
        }
            break;
        case USER_NOT_FOUND:
        {
            [_timer invalidate];
            [CommonUtils showSimpleAlertViewWithTitle:@"系统消息" WithMessage:@"此用户不存在，请先注册" WithDelegate:self WithCancelTitle:@"确定"];
            [button_login setEnabled:YES];
            MTLOG(@"user not found");
        }
            break;
        case NORMAL_REPLY:
        {
            [_timer invalidate];
//            [CommonUtils showSimpleAlertViewWithTitle:@"系统消息" WithMessage:@"网络异常1，请重试" WithDelegate:self WithCancelTitle:@"确定"];
            [button_login setEnabled:YES];
        }
            break;
            
        default:{
            [_timer invalidate];
            [CommonUtils showSimpleAlertViewWithTitle:@"系统消息" WithMessage:@"网络异常2，请重试" WithDelegate:self WithCancelTitle:@"确定"];
            [button_login setEnabled:YES];
        }
            break;
    }
    
    
}

#pragma mark - Alert Delegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex;{
    // the user clicked OK
    if (buttonIndex == 0)
    {
        [self removeWaitingView];
    }
}

@end
