//
//  ModifyPasswordViewController.m
//  WeShare
//
//  Created by mac on 14-9-2.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "ModifyPasswordViewController.h"
#import "SVProgressHUD.h"

@interface ModifyPasswordViewController ()
{
    NSTimer* timer;
}

@end

@implementation ModifyPasswordViewController
@synthesize currentPS_textfield;
@synthesize modifyPS_textfield;
@synthesize conformPS_textfield;
@synthesize currentPS_view;
@synthesize modifyPS_view;
@synthesize conformPS_view;

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
    NSLog(@"修改密码 view did load");
    [CommonUtils addLeftButton:self isFirstPage:NO];
    
}

//返回上一层
-(void)MTpopViewController{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"修改密码 view will appear");
    currentPS_view.layer.cornerRadius = 4;
    currentPS_view.layer.masksToBounds = YES;
    modifyPS_view.layer.cornerRadius = 4;
    modifyPS_view.layer.masksToBounds = YES;
    conformPS_view.layer.cornerRadius = 4;
    conformPS_view.layer.masksToBounds = YES;
    
    currentPS_textfield.secureTextEntry = YES;
    modifyPS_textfield.secureTextEntry = YES;
    conformPS_textfield.secureTextEntry = YES;
    [self registerForKeyboardNotifications];
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSLog(@"修改密码 view did appear");
}

-(void)viewDidDisappear:(BOOL)animated
{
    [self unRegisterForKeyboardNotifications];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    NSLog(@"keyBoard:%f", keyboardSize.height);  //216
    CGRect frame = _confirm_btn.frame;
    float offset = self.view.frame.size.height - keyboardSize.height - frame.size.height + 20 - frame.origin.y;
    if (offset > 0) {
        return;
    }
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
    NSDictionary *info = [notif userInfo];
    
    NSValue *value = [info objectForKey:UIKeyboardFrameBeginUserInfoKey];
    CGSize keyboardSize = [value CGRectValue].size;
    NSLog(@"keyboardWasHidden keyBoard:%f", keyboardSize.height);
    float offset = [UIScreen mainScreen].bounds.size.height - self.view.frame.origin.y - self.view.frame.size.height;
    [UIView beginAnimations:@"goDOWN" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.1f];
    
    [self.view setFrame:CGRectMake(0, self.view.frame.origin.y + offset, self.view.frame.size.width, self.view.frame.size.height)];
    [UIView commitAnimations];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)okBtnClicked:(id)sender {
    [SVProgressHUD showWithStatus:@"正在处理" maskType:SVProgressHUDMaskTypeNone];
    timer = [NSTimer scheduledTimerWithTimeInterval:6.0 target:self selector:@selector(dismissHUD:) userInfo:nil repeats:NO];
    NSString* currentPS = currentPS_textfield.text;
    NSString* modifyPS = modifyPS_textfield.text;
    NSString* conformPS = conformPS_textfield.text;
    NSLog(@"当前密码: %@, 修改密码: %@, 确认密码: %@",currentPS,modifyPS,conformPS);
    if (!currentPS || [currentPS isEqualToString:@""]) {
        [SVProgressHUD dismissWithError:@"请填写当前密码" afterDelay:1.5];
        return;
    }
    if (!modifyPS || [modifyPS isEqualToString:@""]) {
        [SVProgressHUD dismissWithError:@"请填写新密码" afterDelay:1.5];
        return;
    }
    if (!conformPS || [conformPS isEqualToString:@""]) {
        [SVProgressHUD dismissWithError:@"请确认新密码" afterDelay:1.5];
        return;
    }
    if (![modifyPS isEqualToString:conformPS]) {
//        [CommonUtils showSimpleAlertViewWithTitle:@"温馨提示" WithMessage:@"两次填写的新密码不一样" WithDelegate:self WithCancelTitle:@"确定"];
        [SVProgressHUD dismissWithError:@"填写的新密码不一致" afterDelay:1.5];
        return;
    }
    
    void (^modifyPasswordDone)(NSData*) = ^(NSData* rData)
    {
        [timer invalidate];
        NSString* temp = @"";
        if (rData) {
            temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
        }
        else
        {
            NSLog(@"修改密码，收到的rData为空");
            UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"系统提示" message:@"服务器未响应，有可能是网络未连接" delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
            [alertView show];
            [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(dismissAlert:) userInfo:alertView repeats:NO];
            return;
        }
        NSLog(@"Received Data: %@",temp);
        NSMutableDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
        NSNumber* cmd = [response1 objectForKey:@"cmd"];
        NSLog(@"cmd: %@",cmd);
        if ([cmd integerValue] == NORMAL_REPLY) {
            [SVProgressHUD dismissWithSuccess:@"密码修改成功" afterDelay:1.5];
            NSString* MtsecretPath= [NSString stringWithFormat:@"%@/Documents/Meticdata", NSHomeDirectory()];
            NSArray *Array = [NSArray arrayWithObjects:[MTUser sharedInstance].email, modifyPS, nil];
            [NSKeyedArchiver archiveRootObject:Array toFile:MtsecretPath];

            [self.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            [SVProgressHUD dismissWithError:@"出错啦~请重试" afterDelay:1.5];
        }
    };
    NSString* currentPS_md5;
    NSString* modifyPS_md5;
    NSLog(@"修改密码, salt: %@",[MTUser sharedInstance].saltValue);
    if ([MTUser sharedInstance].saltValue) {
        currentPS_md5 = [CommonUtils MD5EncryptionWithString:[currentPS stringByAppendingString:[MTUser sharedInstance].saltValue]];
        modifyPS_md5 = [CommonUtils MD5EncryptionWithString:[modifyPS stringByAppendingString:[MTUser sharedInstance].saltValue]];
    }
    
    NSMutableDictionary* json_dic = [CommonUtils packParamsInDictionary:
                                     [MTUser sharedInstance].email, @"email",
                                     currentPS_md5,@"passwd",
                                     modifyPS_md5,@"newpw",nil];
    NSLog(@"修改密码, json: %@",json_dic);
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:json_dic options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender* http = [[HttpSender alloc]initWithDelegate:self];
    [http sendMessage:jsonData withOperationCode:CHANGE_PW finshedBlock:modifyPasswordDone];
    
}

-(void)dismissHUD:(NSTimer*)timer
{
    [SVProgressHUD dismissWithError:@"服务器未响应"];
}

-(void)dismissAlert:(NSTimer*)t
{
    UIAlertView* alert = [t userInfo];
    [alert dismissWithClickedButtonIndex:0 animated:YES];
}
@end
