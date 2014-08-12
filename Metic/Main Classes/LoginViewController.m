//
//  LoginViewController.m
//  Metic
//
//  Created by ligang_mac4 on 14-5-27.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "LoginViewController.h"
#import "../Source/security/SFHFKeychainUtils.h"

@interface LoginViewController ()
{
    enum TAG_LOGIN
    {
        Tag_userName = 50,
        Tag_password
    };
    
    
}
@property (strong, nonatomic) UIView* waitingView;
@property (strong, nonatomic) NSTimer* timer;
@end

@implementation LoginViewController

@synthesize textField_password;
@synthesize textField_userName;
@synthesize button_login;
@synthesize button_register;
@synthesize logInEmail;
@synthesize logInPassword;
@synthesize rootView;
@synthesize fromRegister;
@synthesize text_userName;
@synthesize text_password;

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
    
    //AppDelegate *myDelegate = [[UIApplication sharedApplication]delegate];
    self.rootView.myDelegate = self;
    UIColor *backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"背景颜色方格.png"]];
    [self.view setBackgroundColor:backgroundColor];
    
//    self.Img_userName.layer.cornerRadius = 10;
//    self.Img_userName.layer.masksToBounds = YES;
//    self.Img_password.layer.cornerRadius = 3;
    self.Img_register.layer.cornerRadius = 3;
    self.textField_userName.tag = Tag_userName;
    self.textField_userName.returnKeyType = UIReturnKeyDone;
    self.textField_userName.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.textField_userName.delegate = self.rootView;
    self.textField_userName.placeholder = @"请输入您的邮箱";
    self.textField_userName.keyboardType = UIKeyboardTypeEmailAddress;
    self.textField_userName.text = text_userName? text_userName:@"";
    
    self.textField_password.tag = Tag_password;
    self.textField_password.returnKeyType = UIReturnKeyDone;
    self.textField_password.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.textField_password.delegate = self.rootView;
    self.textField_password.placeholder = @"请输入密码";
    self.textField_password.secureTextEntry = YES;
    self.textField_password.text = @"";
    //[self checkPreUP];
    self.textField_password.text = text_password? text_password:@"";
    if (!fromRegister) {
        [self checkPreUP];
    }
    else
    {
        fromRegister = NO;
        text_password = nil;
        text_userName = nil;
    }
    


}

-(void)viewWillAppear:(BOOL)animated
{
    NSUserDefaults* userDf = [NSUserDefaults standardUserDefaults];
    if ([userDf boolForKey:@"firstLauch"]) {
        NSLog(@"login: it is first lauch");
//        WelcomePageViewController* vc = [[WelcomePageViewController alloc]init];
//        [self presentViewController:vc animated:YES completion:nil];
    }
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self checkPreUP];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        //[((UIActivityIndicatorView*)[_waitingView viewWithTag:101]) stopAnimating];
        [_waitingView removeFromSuperview];
    }
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
        [self removeWaitingView];
        [(MenuViewController*)[SlideNavigationController sharedInstance].leftMenu clearVC];
        [[MTUser sharedInstance] setUid:[MTUser sharedInstance].userid];
        [self jumpToMainView];
        [button_login setEnabled:YES];
        return;
    }
    if (userName && password) {
        self.textField_userName.text = userName;
        self.textField_password.text = password;
        self.logInEmail = userName;
        self.logInPassword = password;
        [self.button_login setEnabled:YES];
//        _timer = [NSTimer scheduledTimerWithTimeInterval:6.0f target:self selector:@selector(loginFail) userInfo:nil repeats:NO];
//        [self login];
    }else [self.button_login setEnabled:YES];
}



- (void) recoverloginbutton
{
    [button_login setEnabled:YES];
}

-(BOOL)isTextFieldEmpty
{
    if ([(UITextField *)[self.view viewWithTag:Tag_userName] text] == nil || [[(UITextField *)[self.view viewWithTag:Tag_userName] text] isEqualToString:@""]) {
        
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"User name can't be empty" delegate:self cancelButtonTitle:@"OK,I know" otherButtonTitles:nil, nil];
        [alert show];
        
        return NO;
    }
    if ([(UITextField *)[self.view viewWithTag:Tag_password] text] == nil || [[(UITextField *)[self.view viewWithTag:Tag_password] text] isEqualToString:@""]) {
        
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Password can't be empty" delegate:self cancelButtonTitle:@"OK,I know" otherButtonTitles:nil, nil];
        [alert show];
    }
    return YES;
    
}

- (void)jumpToMainView
{
    [self performSegueWithIdentifier:@"LoginToHome" sender:self];
}

- (void)jumpToRegisterView
{
    [self performSegueWithIdentifier:@"LoginToRegister" sender:self];
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
    NSLog(@"%@",[self.textField_userName text]);
    self.logInEmail = [self.textField_userName text];
    self.logInPassword = [self.textField_password text];
    _timer = [NSTimer scheduledTimerWithTimeInterval:6.0f target:self selector:@selector(loginFail) userInfo:nil repeats:NO];
    [self.textField_password endEditing:YES];
    [self.textField_userName endEditing:YES];
    [self login];

}

-(void)login{
    [self showWaitingView];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:self.logInEmail forKey:@"email"];
    [dictionary setValue:@"" forKey:@"passwd"];
    [dictionary setValue:[NSNumber numberWithBool:NO] forKey:@"has_salt"];
    
    NSLog(@"%@",dictionary);
    
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
    NSString* temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
    NSLog(@"Received Data: %@",temp);
    NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
    NSNumber *cmd = [response1 valueForKey:@"cmd"];
    switch ([cmd intValue]) {
        case GET_SALT:
        {
            NSString *salt = [response1 valueForKey:@"salt"];
            NSString *str = [self.logInPassword stringByAppendingString:salt];
            NSLog(@"password+salt: %@",str);
            
            //MD5 encrypt
            NSMutableString *md5_str = [NSMutableString string];
            md5_str = [CommonUtils MD5EncryptionWithString:str];
            
            NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
            [params setValue:self.logInEmail forKey:@"email"];
            [params setValue:md5_str forKey:@"passwd"];
            [params setValue:[NSNumber numberWithBool:YES] forKey:@"has_salt"];
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil];
            NSLog(@"%@",[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding]);
            
            HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
            [httpSender sendMessage:jsonData withOperationCode:LOGIN];
            
        }
            break;
        case LOGIN_SUC:
        {
            [_timer invalidate];
//            BOOL name = [SFHFKeychainUtils storeUsername:@"MeticUserName" andPassword:self.logInEmail forServiceName:@"Metic0713" updateExisting:1 error:nil];
//            BOOL key = [SFHFKeychainUtils storeUsername:@"MeticPassword" andPassword:self.logInPassword forServiceName:@"Metic0713" updateExisting:1 error:nil];
//            BOOL status = [SFHFKeychainUtils storeUsername:@"MeticStatus" andPassword:@"in" forServiceName:@"Metic0713" updateExisting:1 error:nil];
            NSLog(@"login succeeded");
            //保存信息
            NSString* MtsecretPath= [NSString stringWithFormat:@"%@/Documents/Meticdata", NSHomeDirectory()];
            NSArray *Array = [NSArray arrayWithObjects:self.logInEmail, self.logInPassword, nil];
            [[NSUserDefaults standardUserDefaults] setObject:@"in" forKey:@"MeticStatus"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [NSKeyedArchiver archiveRootObject:Array toFile:MtsecretPath];

            [self removeWaitingView];
            NSNumber *userid = [response1 valueForKey:@"id"];
            [[MTUser sharedInstance] setUid:userid];
            
//            [(MenuViewController*)[SlideNavigationController sharedInstance].leftMenu clearVC];
            //[user getInfo:userid myid:userid delegateId:self];
            
            [self jumpToMainView];
            [button_login setEnabled:YES];
        }
            break;
        case PASSWD_NOT_CORRECT:
        {
            [_timer invalidate];
            [CommonUtils showSimpleAlertViewWithTitle:@"系统消息" WithMessage:@"密码错误，请重试" WithDelegate:self WithCancelTitle:@"确定"];
            [button_login setEnabled:YES];
            NSLog(@"password not correct");
            
        }
            break;
        case USER_NOT_FOUND:
        {
            [_timer invalidate];
            [CommonUtils showSimpleAlertViewWithTitle:@"系统消息" WithMessage:@"用户名不存在" WithDelegate:self WithCancelTitle:@"确定"];
            [button_login setEnabled:YES];
            NSLog(@"user not found");
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

#pragma mark - InputHandleViewDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField;             // may be called if forced even if shouldEndEditing returns NO (e.g. view removed from window) or endEditing:YES called
{
//    switch (textField.tag) {
//            
//        case Tag_userName:
//        {
//            if ([textField text] != nil && [[textField text] length]!= 0) {
//                
//                if (![CommonUtils isEmailValid: textField.text]) {
//                    
//                    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"The format of email is invalid" delegate:self cancelButtonTitle:@"OK,I know" otherButtonTitles:nil, nil];
//                    [alert show];
//                }
//            }
//        }
//            break;
//        case Tag_password:
//        {
//            if ([textField text] != nil && [[textField text] length]!= 0) {
//                
//                if ([[textField text] length] < 5) {
//                    
//                    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"The length of the password should't less than 5" delegate:self cancelButtonTitle:@"OK,I know" otherButtonTitles:nil, nil];
//                    [alert show];
//                }
//            }
//        }
//            break;
//        default:
//            break;
//    }
    
    [textField resignFirstResponder];
    
}

@end
