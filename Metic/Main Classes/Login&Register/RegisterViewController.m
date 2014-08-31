//
//  RegisterViewController.m
//  Metic
//
//  Created by ligang_mac4 on 14-5-27.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "RegisterViewController.h"
#import "MobClick.h"

@interface RegisterViewController ()
{
    BOOL registerSucceeded;
    NSNumber* gender;
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
    
    rootView.myDelegate = self;
//    textField_confromPassword.delegate = rootView;
    textField_email.delegate = rootView;
    textField_password.delegate = rootView;
    textField_userName.delegate = rootView;
    
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

}

-(void)viewDidAppear:(BOOL)animated
{
    registerSucceeded = NO;
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
    
    if ([segue.destinationViewController isKindOfClass:[LoginViewController class]]) {
        LoginViewController* vc = segue.destinationViewController;
        if (registerSucceeded) {
            vc.text_userName = self.textField_email.text;
            vc.text_password = self.textField_password.text;
            vc.gender = gender;
        }
        vc.fromRegister = YES;
        NSLog(@"register username: %@, password: %@, fromRegister: %d",self.textField_email.text,self.textField_password.text,vc.fromRegister);
    }
    
}


- (void)jumpToLogin
{
    [self performSegueWithIdentifier:@"RegisterToLogin" sender:self];
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
    //    NSLog(@"random String: %@",salt);
//    if (password.length<6) {
//        [CommonUtils showSimpleAlertViewWithTitle:@"Warning" WithMessage:@"Wrong password length" WithDelegate:self WithCancelTitle:@"OK"];
//    }
//    else if (![CommonUtils isEmailValid:email]) {
//        [CommonUtils showSimpleAlertViewWithTitle:@"Warning" WithMessage:@"Wrong email format" WithDelegate:self WithCancelTitle:@"OK"];
//    }
//    else if (![conformPassword isEqualToString:password])
//    {
//        [CommonUtils showSimpleAlertViewWithTitle:@"Warning" WithMessage:@"Password conformed error" WithDelegate:self WithCancelTitle:@"OK"];
//    }
//    else
    {
        NSMutableString* md5_str = [CommonUtils MD5EncryptionWithString:[[NSString alloc]initWithFormat:@"%@%@",password,salt]];
        NSMutableDictionary* mDic = [CommonUtils packParamsInDictionary:email,@"email",md5_str,@"passwd",userName,@"name",gender,@"gender",salt,@"salt",nil];
        
        NSLog(@"test packDictionary: %@",mDic);
        
        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:mDic options:NSJSONWritingPrettyPrinted error:nil];
        HttpSender* httpSender = [[HttpSender alloc]initWithDelegate:self];
        [httpSender sendMessage:jsonData withOperationCode:REGISTER];
//        [self jumpToFillinInfo];
//        registerSucceeded = YES;
//        [self jumpToLogin];
    }
    
    
    //    NSMutableDictionary* mDic = [CommonUtils packParamsInDictionary:[NSNumber numberWithInt:4],email,@"email",md5_str,@"passwd",userName,@"name",gender,@"gender",salt,@"salt",nil];
    
    
    
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
    if (textField_password.text.length<6) {
        [CommonUtils showSimpleAlertViewWithTitle:@"温馨提示" WithMessage:@"密码长度至少为5" WithDelegate:self WithCancelTitle:@"确定"];
    }
    else if (![CommonUtils isEmailValid:textField_email.text]) {
        [CommonUtils showSimpleAlertViewWithTitle:@"温馨提示" WithMessage:@"账号请填写正确的邮箱格式" WithDelegate:self WithCancelTitle:@"确定"];
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



#pragma mark - HttpSenderDelegate

-(void)finishWithReceivedData:(NSData *)rData
{
    NSString* temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
    NSLog(@"Register received Data: %@",temp);
    NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
    NSNumber *cmd = [response1 valueForKey:@"cmd"];
    switch ([cmd intValue]) {
        case NORMAL_REPLY:
            NSLog(@"register succeeded");
            registerSucceeded = YES;
            [self jumpToLogin];
//            [self jumpToFillinInfo];
            break;
        case USER_EXIST:
        {
            NSLog(@"user existed");
            UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"用户已存在" delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
            [alertView show];
            [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(alertViewDismiss:) userInfo:alertView repeats:YES];
            break;
        }
        default:
            break;
    }
}

-(void)alertViewDismiss:(NSTimer*)timer
{
    [[timer userInfo] dismissWithClickedButtonIndex:0 animated:YES];
}


//#pragma mark - UItextFieldDelegate
//
//- (void)textFieldDidBeginEditing:(UITextField *)textField;           // became first responder
//{
//    
//}
//
//
//- (void)textFieldDidEndEditing:(UITextField *)textField;             // may be called if forced even if shouldEndEditing returns NO (e.g. view removed from window) or endEditing:YES called
//{
//    [textField resignFirstResponder];
//    
//}

@end
