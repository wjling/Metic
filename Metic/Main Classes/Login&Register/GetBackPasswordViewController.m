//
//  GetBackPasswordViewController.m
//  WeShare
//
//  Created by mac on 15-2-28.
//  Copyright (c) 2015年 WeShare. All rights reserved.
//

#import "GetBackPasswordViewController.h"
#import "SVProgressHUD.h"
#import "CommonUtils.h"
#import "AppConstants.h"
#import "HttpSender.h"

@interface GetBackPasswordViewController ()
{
    UITextField* email_textfield;
    UIButton* ok_btn;
    NSTimer* timer;
}

@end

@implementation GetBackPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initViews];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];

    [self registerForKeyboardNotifications];
    [super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [self unRegisterForKeyboardNotifications];
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

-(void)initViews
{
    float leftInset = 10;
    UILabel* tip1 = [[UILabel alloc]initWithFrame:CGRectMake(leftInset, 30, 200, 30)];
    tip1.text = @"您正在找回密码，请按提示操作";
    tip1.font = [UIFont systemFontOfSize:13];
    tip1.textColor = [UIColor grayColor];
    [self.view addSubview:tip1];
    
    email_textfield = [[UITextField alloc]initWithFrame:CGRectMake(leftInset, 80, self.view.frame.size.width - leftInset * 2, 40)];
    email_textfield.placeholder = @"请输入作为账号的邮箱";
    [email_textfield setBackgroundColor:[UIColor whiteColor]];
    email_textfield.layer.cornerRadius = 4;
    email_textfield.clearButtonMode = UITextFieldViewModeWhileEditing;
    UIView* view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, 8)];
    email_textfield.leftView = view;
    email_textfield.leftViewMode = UITextFieldViewModeAlways;
    [self.view addSubview:email_textfield];
    
    UITextView* tip2 = [[UITextView alloc]initWithFrame:CGRectMake(leftInset, 140, self.view.frame.size.width - leftInset * 2, 40)];
    tip2.text = @"系统将会自动生成一个新密码发送到此邮箱，请收到后及时进入安全中心进行修改";
    tip2.userInteractionEnabled = NO;
    tip2.font = [UIFont systemFontOfSize:13];
    tip2.textColor = [UIColor grayColor];
    [tip2 setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:tip2];
    
    ok_btn = [[UIButton alloc]initWithFrame:CGRectMake(leftInset, 200, self.view.frame.size.width - leftInset * 2, 40)];
    [ok_btn setBackgroundImage:[UIImage imageNamed:@"登录按钮"] forState:UIControlStateNormal];
    [ok_btn setTitle:@"确定" forState:UIControlStateNormal];
    [ok_btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [ok_btn addTarget:self action:@selector(okBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:ok_btn];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)dismissHUD:(NSTimer*)timer
{
    [SVProgressHUD dismissWithError:@"服务器未响应"];
}

-(void)okBtnClick:(id)sender
{
    [SVProgressHUD showWithStatus:@"正在处理.." maskType:SVProgressHUDMaskTypeNone];
    timer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(dismissHUD:) userInfo:nil repeats:NO];
    if ([email_textfield.text isEqual:[NSNull null]] || [email_textfield.text isEqualToString:@""]) {
        [SVProgressHUD showErrorWithStatus:@"邮箱不能为空" duration:1.5];
        return;
    }
    if (![CommonUtils isEmailValid:email_textfield.text]) {
        [SVProgressHUD showErrorWithStatus:@"邮箱格式不正确" duration:1.5];
        return;
    }
    
    void (^getbackPsDone)(NSData*) = ^(NSData* rData)
    {
        [timer invalidate];
        NSString* temp = @"";
        if (rData) {
            temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
        }
        else
        {
            NSLog(@"修改密码，收到的rData为空");
            return;
        }
        NSLog(@"Received Data: %@",temp);
        NSMutableDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
        NSNumber* cmd = [response1 objectForKey:@"cmd"];
        NSLog(@"cmd: %@",cmd);
        switch ([cmd integerValue]) {
            case NORMAL_REPLY:
            {
                [SVProgressHUD  dismissWithSuccess:@"操作成功，请查收邮件" afterDelay:1.5];
            }
                break;
            default:
                break;
        }
    };
    
    NSDictionary* json_dic = [CommonUtils packParamsInDictionary:
                              email_textfield.text, @"email",
                              nil];
    NSData* json_data = [NSJSONSerialization dataWithJSONObject:json_dic options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender* http = [[HttpSender alloc]initWithDelegate:self];
    [http sendMessage:json_data withOperationCode:FIND_BACK_PASSWORD finshedBlock:getbackPsDone];
    
}

- (void) registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter]  addObserver:self selector:@selector(keyboardWasHidden:) name:UIKeyboardDidHideNotification object:nil];
}

- (void) unRegisterForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) keyboardWasShown:(NSNotification *) notif
{
    NSDictionary *info = [notif userInfo];
    NSValue *value = [info objectForKey:UIKeyboardFrameBeginUserInfoKey];
    CGSize keyboardSize = [value CGRectValue].size;
    float keyboard_height;
    NSLog(@"keyBoard:%f", keyboardSize.height);  //216
    if (keyboardSize.height == 0 || keyboardSize.height > 202) {
        keyboard_height = 202;
    }
    else
    {
        keyboard_height = keyboardSize.height;
    }
    CGRect frame = ok_btn.frame;
    float offset = self.view.frame.size.height - keyboard_height - frame.size.height - frame.origin.y;
    CGRect newFrame = self.view.frame;
    newFrame.origin.y += offset;
    [UIView beginAnimations:@"goUP" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.1f];
    [self.view setFrame:newFrame];
    [UIView commitAnimations];
}
- (void) keyboardWasHidden:(NSNotification *) notif
{
//    NSDictionary *info = [notif userInfo];
//    
//    NSValue *value = [info objectForKey:UIKeyboardFrameBeginUserInfoKey];
//    CGSize keyboardSize = [value CGRectValue].size;
//    NSLog(@"keyboardWasHidden keyBoard:%f", keyboardSize.height);
    float offset = [UIScreen mainScreen].bounds.size.height - self.view.frame.origin.y - self.view.frame.size.height;
    [UIView beginAnimations:@"goDOWN" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.1f];
    
    [self.view setFrame:CGRectMake(0, self.view.frame.origin.y + offset, self.view.frame.size.width, self.view.frame.size.height)];
    [UIView commitAnimations];
}


@end
