//
//  EnactiveAccountViewController.m
//  WeShare
//
//  Created by 俊健 on 15/12/5.
//  Copyright (c) 2015年 WeShare. All rights reserved.
//

#import "EnactiveAccountViewController.h"
#import "MenuViewController.h"
#import "FillinInfoViewController.h"
#import "HomeViewController.h"
#import "CommonUtils.h"
#import "MTAccountManager.h"
#import "MTPushMessageHandler.h"
#import "SVProgressHUD.h"
#import "AppDelegate.h"

@interface EnactiveAccountViewController ()

@end

@implementation EnactiveAccountViewController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI
-(void)setupUI
{
    self.title = @"激活账号";
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [CommonUtils addLeftButton:self isFirstPage:NO];
}

#pragma mark - Navigation
- (void)jumpToMainView
{
    UIStoryboard* mainStoryBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    HomeViewController *vc = [mainStoryBoard instantiateViewControllerWithIdentifier:@"HomeViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)jumpToFillinInfo
{
    UIStoryboard* mainStoryBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    FillinInfoViewController *vc = [mainStoryBoard instantiateViewControllerWithIdentifier:@"FillinInfoViewController"];
    vc.gender = @1;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Private Method
- (IBAction)checkActivation:(id)sender {
    [SVProgressHUD showWithStatus:@"请稍候" maskType:SVProgressHUDMaskTypeBlack];
    [MTAccountManager loginWithAccount:self.email password:self.passwd success:^(MTLoginResponse *user) {
        MTLOG(@"login succeeded");
        AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        appDelegate.isLogined = YES;
        
        //保存账户信息
        BOOL hadCompleteInfo= [user.hadCompleteInfo boolValue];
        MTAccount *account = [MTAccount singleInstance];
        account.email = self.email;
        account.password = self.passwd;
        account.type = MTAccountTypeEmail;
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
        [SVProgressHUD dismissWithSuccess:@"激活成功，正在登录" afterDelay:1.f];
        
        if (!hadCompleteInfo) {
            [self jumpToFillinInfo];
        } else {
            [self jumpToMainView];
        }
    } failure:^(enum MTLoginResult result, NSString *message) {
        [SVProgressHUD dismissWithError:message afterDelay:1.f];
    }];
}

- (IBAction)resendEmail:(id)sender {
    [SVProgressHUD showWithStatus:@"正在发送，请稍候" maskType:SVProgressHUDMaskTypeBlack];
    [MTAccountManager resendActivateEmail:self.email success:^{
        [SVProgressHUD dismissWithSuccess:@"发送成功，请激活账号" afterDelay:0.5f];
    } failure:^(NSString *message) {
        [SVProgressHUD dismissWithError:message afterDelay:0.5f];
    }];
}

-(void)setEmail:(NSString *)email AndPasswd:(NSString *)passwd
{
    _email = email;
    _passwd = passwd;
}

@end
