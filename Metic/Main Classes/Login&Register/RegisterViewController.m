//
//  RegisterViewController.m
//  Metic
//
//  Created by ligang_mac4 on 14-5-27.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "RegisterViewController.h"
#import "MobClick.h"
#import "SVProgressHUD.h"

@interface RegisterViewController ()
{
    BOOL registerSucceeded;
    NSNumber* gender;
    CGRect originFrame;
    CGFloat viewOffet;
}

@end

@implementation RegisterViewController
@synthesize textField_email;
@synthesize textField_confromPassword;
@synthesize textField_password;
@synthesize textField_userName;
@synthesize button_backToLogin;
@synthesize button_signUp;
@synthesize scrollView;
@synthesize rootView;
@synthesize male_button;
@synthesize female_button;

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
    self.navigationController.navigationBar.hidden = NO;
    // Do any additional setup after loading the view.
    
    UIColor *backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"背景颜色方格.png"]];
    [self.view setBackgroundColor:backgroundColor];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    self.scrollView.delegate  = self;
    
    male_button = [UIButton buttonWithType:UIButtonTypeCustom];
    male_button.frame = CGRectMake(0, 7, 55, 20);
    [male_button setImage:[UIImage imageNamed:@"注册性别按钮"] forState:UIControlStateNormal];
    [male_button setImage:[UIImage imageNamed:@"注册性别按钮按下效果"] forState:UIControlStateSelected];
    [male_button setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 35)];
    [male_button setTitle:@"男" forState:UIControlStateNormal];
    male_button.titleLabel.font = [UIFont systemFontOfSize:17];
    [male_button setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    
    female_button = [UIButton buttonWithType:UIButtonTypeCustom];
    female_button.frame = CGRectMake(80, 7, 55, 20);
    [female_button setImage:[UIImage imageNamed:@"注册性别按钮"] forState:UIControlStateNormal];
    [female_button setImage:[UIImage imageNamed:@"注册性别按钮按下效果"] forState:UIControlStateSelected];
    [female_button setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 35)];
    [female_button setTitle:@"女" forState:UIControlStateNormal];
    female_button.titleLabel.font = [UIFont systemFontOfSize:17];
    [female_button setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    
    male_button.selected = YES;
    female_button.selected = NO;
    [male_button addTarget:self action:@selector(genderBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [female_button addTarget:self action:@selector(genderBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.genderRoot_view addSubview:male_button];
    [self.genderRoot_view addSubview:female_button];
    
    male_button.hidden = YES;
    female_button.hidden = YES;
    
//    rootView.myDelegate = self;
//    textField_confromPassword.delegate = rootView;
    textField_email.delegate = self;
    textField_password.delegate = self;
//    textField_userName.delegate = rootView;
    
//    textField_confromPassword.placeholder = @"请再次输入密码";
    textField_email.placeholder = @"请输入您的邮箱";
    textField_password.placeholder = @"请输入您的密码，至少6位";
    textField_userName.placeholder = @"请输入您的昵称";
    
    textField_email.keyboardType = UIKeyboardTypeEmailAddress;
    textField_password.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
//    textField_confromPassword.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    
    textField_password.secureTextEntry = YES;
//    textField_confromPassword.secureTextEntry = YES;
    
    textField_userName.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField_password.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField_email.clearButtonMode = UITextFieldViewModeWhileEditing;
//    textField_confromPassword.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    UITapGestureRecognizer* tapRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(backgroundBtn:)];
    [self.view addGestureRecognizer:tapRecognizer];

}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    registerSucceeded = NO;
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
    
    if ([segue.destinationViewController isKindOfClass:[LoginViewController class]]) {
        LoginViewController* vc = segue.destinationViewController;
        if (registerSucceeded) {
            vc.text_userName = self.textField_email.text;
            vc.text_password = self.textField_password.text;
            vc.gender = gender;
        }
        vc.fromRegister = YES;
        MTLOG(@"register username: %@, password: %@, fromRegister: %d",self.textField_email.text,self.textField_password.text,vc.fromRegister);
    }
    
}


- (void)jumpToLogin
{
//    [self performSegueWithIdentifier:@"RegisterToLogin" sender:self];
//    [self.navigationController popViewControllerAnimated:YES];
    LoginViewController* login;
    NSArray *VCs = [self.navigationController viewControllers];
    for (int i = 0; i < VCs.count; i++) {
        UIViewController* vc = [VCs objectAtIndex:i];
        if ([vc isKindOfClass:[LoginViewController class]]) {
            login = (LoginViewController*)vc;
            break;
        }
    }
    if (login && registerSucceeded) {
        login.text_userName = self.textField_email.text;
        login.text_password = self.textField_password.text;
        login.gender = gender;
    }
    login.fromRegister = YES;
    MTLOG(@"register username: %@, password: %@, fromRegister: %d",self.textField_email.text,self.textField_password.text,login.fromRegister);
    [self.navigationController popToViewController:login animated:YES];
}

- (void)jumpToMain
{
    [self performSegueWithIdentifier:@"RegisterToMain" sender:self];
}




#pragma mark - button click
-(IBAction)signUpButtonClicked:(id)sender
{
    NSString* email = [textField_email text];
    NSString* password = [textField_password text];
//    NSString* conformPassword = [textField_confromPassword text];
//    NSString* userName = [textField_userName text];
    NSString* userName = email;
    
    NSString* salt = [CommonUtils randomStringWithLength:6];
    
    if (male_button.selected) {
        gender = [NSNumber numberWithInt:1];
    }
    else
    {
        gender = [NSNumber numberWithInt:0];
    }
    //    MTLOG(@"random String: %@",salt);
    if (![CommonUtils isEmailValid:email]) {
        [CommonUtils showSimpleAlertViewWithTitle:@"温馨提示" WithMessage:@"邮箱格式不正确" WithDelegate:self WithCancelTitle:@"确定"];
        return;
    }else if (password.length<6) {
        [CommonUtils showSimpleAlertViewWithTitle:@"温馨提示" WithMessage:@"密码长度至少6位" WithDelegate:self WithCancelTitle:@"确定"];
        return;
    }
    //    else if (![conformPassword isEqualToString:password])
//    {
//        [CommonUtils showSimpleAlertViewWithTitle:@"Warning" WithMessage:@"Password conformed error" WithDelegate:self WithCancelTitle:@"OK"];
//    }
//    else
    {
        NSMutableString* md5_str = [CommonUtils MD5EncryptionWithString:[[NSString alloc]initWithFormat:@"%@%@",password,salt]];
        NSMutableDictionary* mDic = [CommonUtils packParamsInDictionary:email,@"email",md5_str,@"passwd",userName,@"name",gender,@"gender",salt,@"salt",nil];
        
        MTLOG(@"test packDictionary: %@",mDic);
        
        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:mDic options:NSJSONWritingPrettyPrinted error:nil];
        HttpSender* httpSender = [[HttpSender alloc]initWithDelegate:self];
        [httpSender sendMessage:jsonData withOperationCode:REGISTER];
    }  
    
    [SVProgressHUD showWithStatus:@"请稍等.." maskType:SVProgressHUDMaskTypeGradient];
    [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(dismissHUD:) userInfo:nil repeats:NO];
}

-(void)dismissHUD:(id)sender
{
    [SVProgressHUD dismissWithError:@"服务器未响应" afterDelay:1];
}

- (IBAction)backToLoginButtonClicked:(id)sender
{
    
    [self jumpToLogin];
}

//- (IBAction)text_Clear:(id)sender {
//    if ([sender superview] == [self.textField_userName superview])
//    {
//        self.textField_userName.text =@"";
//    }
//    else if([sender superview] == [self.textField_email superview])
//    {
//        self.textField_email.text = @"";
//    }
//    else if([sender superview] == [self.textField_password superview])
//    {
//        self.textField_password.text = @"";
//    }
//    else if([sender superview] == [self.textField_confromPassword superview])
//    {
//        self.textField_confromPassword.text = @"";
//    }
//}

- (IBAction)step_back:(UIButton *)sender {
    CGPoint offset = CGPointMake(0, 0);
    [self.scrollView setContentOffset:offset animated:YES];
}

- (IBAction)step_next:(id)sender {
    if (![CommonUtils isEmailValid:textField_email.text]) {
        [CommonUtils showSimpleAlertViewWithTitle:@"温馨提示" WithMessage:@"账号请填写正确的邮箱格式" WithDelegate:self WithCancelTitle:@"确定"];
    }
    else if (textField_password.text.length<6) {
        [CommonUtils showSimpleAlertViewWithTitle:@"温馨提示" WithMessage:@"密码长度至少为6" WithDelegate:self WithCancelTitle:@"确定"];
    }
    else
    {
        CGPoint offset = CGPointMake(0, 201);
        [self.scrollView setContentOffset:offset animated:YES];
    }

}

- (IBAction)genderBtnClicked:(UIButton *)sender {
    if (sender == male_button) {
        male_button.selected = YES;
        female_button.selected = NO;
    }
    else
    {
        female_button.selected = YES;
        male_button.selected = NO;

    }
}

-(void)backgroundBtn:(id)sender
{
    if (viewOffet != 0) {
        viewOffet = 0;
        [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
        NSTimeInterval animationDuration = 0.30f;
        [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
        [UIView setAnimationDuration:animationDuration];
        self.view.frame = originFrame; //CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        [UIView commitAnimations];
    }
}



#pragma mark - HttpSenderDelegate

-(void)finishWithReceivedData:(NSData *)rData
{
    NSString* temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
    MTLOG(@"Register received Data: %@",temp);
    NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
    NSNumber *cmd = [response1 valueForKey:@"cmd"];
    switch ([cmd intValue]) {
        case NORMAL_REPLY:
            MTLOG(@"register succeeded");
            [SVProgressHUD dismissWithSuccess:@"注册成功" afterDelay:2];
            registerSucceeded = YES;
            [self jumpToLogin];
//            [self jumpToFillinInfo];
            break;
        case USER_EXIST:
        {
            MTLOG(@"user existed");
            [SVProgressHUD dismissWithError:@"用户已存在" afterDelay:1.5];
//            UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"用户已存在" delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
//            [alertView show];
//            [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(alertViewDismiss:) userInfo:alertView repeats:YES];
            break;
        }
        default:
            [SVProgressHUD dismissWithError:@"服务器返回异常" afterDelay:1];
            break;
    }
}

-(void)alertViewDismiss:(NSTimer*)timer
{
    [[timer userInfo] dismissWithClickedButtonIndex:0 animated:YES];
}


#pragma mark - UItextFieldDelegate

//开始编辑输入框的时候，软键盘出现，执行此事件
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (viewOffet > 0) {
        return;
    }
    originFrame = self.view.frame;
    CGRect frame;
    frame = [scrollView convertRect:button_signUp.frame toView:self.view];
    
    MTLOG(@"register frame: x: %f, y: %f, width: %f, height: %f",frame.origin.x,frame.origin.y,frame.size.width,frame.size.height);
    viewOffet = frame.origin.y + button_signUp.frame.size.height - (self.view.frame.size.height - 216.0 - 25);//键盘高度216
    MTLOG(@"textField offset: %f",viewOffet);
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    
    //将视图的Y坐标向上移动offset个单位，以使下面腾出地方用于软键盘的显示
    if(viewOffet > 0)
        self.view.frame = CGRectMake(0.0f, self.view.frame.origin.y - viewOffet, self.view.frame.size.width, self.view.frame.size.height);
    
    [UIView commitAnimations];
}

//当用户按下return键或者按回车键，keyboard消失
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    self.view.frame = originFrame; //CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    [UIView commitAnimations];
    
    return YES;
}

//输入框编辑完成以后，将视图恢复到原始状态
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    //    NSTimeInterval animationDuration = 0.30f;
    //    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    //    [UIView setAnimationDuration:animationDuration];
    //    self.view.frame = originFrame; //CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    //    [UIView commitAnimations];
    
}

@end
