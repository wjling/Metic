//
//  LoginViewController.m
//  Metic
//
//  Created by ligang_mac4 on 14-5-27.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "LoginViewController.h"
#import "SFHFKeychainUtils.h"
#import "MobClick.h"

@interface LoginViewController ()
{
    enum TAG_LOGIN
    {
        Tag_userName = 50,
        Tag_password
    };
    UIViewController* launchV;
    UIView *blackView;
    CGRect originFrame;
    CGFloat viewOffet;
    UITapGestureRecognizer* tapRecognizer;
    
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
    NSLog(@"login did load, fromRegister: %d",fromRegister);
    NSUserDefaults* userDf = [NSUserDefaults standardUserDefaults];
    if (!fromRegister) {
        if ([userDf boolForKey:@"firstLaunched"]) {
            NSLog(@"login: it is the first launch");
            UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone"
                                                                 bundle: nil];
            WelcomePageViewController* vc = [storyboard instantiateViewControllerWithIdentifier:@"WelcomePageViewController"];
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
            {
                [self presentViewController:vc animated:NO completion:nil];
            }
        }
        else
        {
            NSLog(@"login: it is not the first launch");
//            [self showLaunchView];
//            [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(dismissLaunchView) userInfo:nil repeats:NO];
        }

    }
    
    //AppDelegate *myDelegate = [[UIApplication sharedApplication]delegate];
//    self.rootView.myDelegate = self;
    UIColor *backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"背景颜色方格.png"]];
    [self.view setBackgroundColor:backgroundColor];
    
//    self.Img_userName.layer.cornerRadius = 10;
//    self.Img_userName.layer.masksToBounds = YES;
//    self.Img_password.layer.cornerRadius = 3;
    self.Img_register.layer.cornerRadius = 3;
    self.textField_userName.tag = Tag_userName;
    self.textField_userName.returnKeyType = UIReturnKeyDone;
    self.textField_userName.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.textField_userName.delegate = self;
    self.textField_userName.placeholder = @"请输入您的邮箱";
    self.textField_userName.keyboardType = UIKeyboardTypeEmailAddress;
    self.textField_userName.text = text_userName? text_userName:@"";
    
    self.textField_password.tag = Tag_password;
    self.textField_password.returnKeyType = UIReturnKeyDone;
    self.textField_password.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.textField_password.delegate = self;
    self.textField_password.placeholder = @"请输入密码";
    self.textField_password.secureTextEntry = YES;
//    self.textField_password.text = @"";
    //[self checkPreUP];
    self.textField_password.text = text_password? text_password:@"";
   
    tapRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(backgroundBtn:)];
    [self.view addGestureRecognizer:tapRecognizer];
    
    

}

-(void)viewWillAppear:(BOOL)animated
{
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    NSLog(@"login will apear");
    if (fromRegister) {
//        [self.view setHidden:NO];
        [self dismissBlackView];
        fromRegister = NO;
//        text_password = nil;
//        text_userName = nil;
    }
    else{
//        [self.view setHidden:YES];
        [self showBlackView];
        [self checkPreUP];
    }
//    [(AppDelegate*)([UIApplication sharedApplication].delegate) initViews];
//    [super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSLog(@"login did appear, username: %@, user password: %@",text_userName, text_password);
    
//    textField_userName.text = text_userName;
//    textField_password.text = text_password;
    [MobClick beginLogPageView:@"登录"];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [MobClick endLogPageView:@"登录"];
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
    
    if ([segue.destinationViewController isKindOfClass:[FillinInfoViewController class]]) {
        FillinInfoViewController* vc = segue.destinationViewController;
        vc.gender = gender;
        vc.email = [textField_userName text];
        NSLog(@"register gender: %@",vc.gender);
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


-(void)showLaunchView
{
    CGRect bounds = [UIScreen mainScreen].bounds;
    CGFloat y;
    if (bounds.size.height <= 480) {
        y = 40;
    }
    else
    {
        y = 70;
    }
    CGFloat view_width = bounds.size.width;
    CGFloat view_height = bounds.size.height;
    UIColor* bgColor = [CommonUtils colorWithValue:0x57caab];
    launchV = [[UIViewController alloc]init];
//    [launchV.view setBackgroundColor:[UIColor greenColor]];
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
    [self.view.window.rootViewController.navigationController presentViewController:launchV animated:NO completion:nil];
}

-(void)dismissLaunchView
{
    
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
        //[((UIActivityIndicatorView*)[_waitingView viewWithTag:101]) stopAnimating];
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
        NSLog(@"用户 %@ 在线", userName);
        [self removeWaitingView];
        [(MenuViewController*)[SlideNavigationController sharedInstance].leftMenu clearVC];
        [[MTUser sharedInstance] setUid:[MTUser sharedInstance].userid];
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [self jumpToMainView];
//        });
        [button_login setEnabled:YES];
        [self performSelectorOnMainThread:@selector(jumpToMainView) withObject:nil waitUntilDone:YES];
//        [self jumpToMainView];
        return;
    }
    else if ([userStatus isEqualToString:@"change"])
    {
//        [self.view setHidden:NO];
        [self dismissBlackView];
        [[NSUserDefaults standardUserDefaults] setValue:@"out" forKey:@"MeticStatus"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else
    {
        [self dismissBlackView];
        [self showLaunchView];
        [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(dismissLaunchView) userInfo:nil repeats:NO];
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
    
//    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone"
//															 bundle: nil];
//    UIViewController* vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"HomeViewController"];
//    
//    [[SlideNavigationController sharedInstance] switchToViewController:vc withCompletion:nil];
    
}

- (void)jumpToRegisterView
{
    [self performSegueWithIdentifier:@"LoginToRegister" sender:self];
}

-(void)jumpToFillinInfo
{
//    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone"
//															 bundle: nil];
//    FillinInfoViewController* vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"FillinInfoViewController"];
//    vc.email = [textField_userName text];
//    [self.navigationController pushViewController:vc animated:YES];
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
    NSLog(@"%@",[self.textField_userName text]);
    self.logInEmail = [self.textField_userName text];
    self.logInPassword = [self.textField_password text];
    _timer = [NSTimer scheduledTimerWithTimeInterval:6.0f target:self selector:@selector(loginFail) userInfo:nil repeats:NO];
    [self.textField_password endEditing:YES];
    [self.textField_userName endEditing:YES];
    [self login];

}

-(void)login{
    [self backgroundBtn:self];
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
            [MTUser sharedInstance].saltValue = salt;
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
            
//            [(MenuViewController*)[SlideNavigationController sharedInstance].leftMenu clearVC];
            //[user getInfo:userid myid:userid delegateId:self];
            NSString* logintime = [response1 objectForKey:@"logintime"];
            if ([logintime isEqualToString:@"None"]) {
                [self jumpToFillinInfo];
            }
            else
            {
                [self jumpToMainView];
//                [self jumpToFillinInfo];
            }
            
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

#pragma mark - UITextFieldDelegate

//开始编辑输入框的时候，软键盘出现，执行此事件
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (viewOffet > 0) {
        return;
    }
    originFrame = self.view.frame;
    CGRect frame;
//    if ([textField superview] == self) {
//        frame = textField.frame;
//    }
//    else
//    {
//        frame = [textField convertRect:textField.frame toView:self];
//    }
//    frame = [button_login convertRect:button_login.frame toView:self.view];
    frame = button_login.frame;
    NSLog(@"login frame: x: %f, y: %f, width: %f, height: %f",frame.origin.x,frame.origin.y,frame.size.width,frame.size.height);
    viewOffet = frame.origin.y + button_login.frame.size.height - (self.view.frame.size.height - 216.0);//键盘高度216
    NSLog(@"textField offset: %f",viewOffet);
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
