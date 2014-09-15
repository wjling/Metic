//
//  ModifyPasswordViewController.m
//  WeShare
//
//  Created by mac on 14-9-2.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "ModifyPasswordViewController.h"

@interface ModifyPasswordViewController ()
{
    UIView* waitingView;
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
    [self initWaitingView];
    
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
    
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSLog(@"修改密码 view did appear");
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

-(void)initWaitingView
{
    UIColor *color = [UIColor colorWithRed:0.29 green:0.76 blue:0.61 alpha:1];
    waitingView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    waitingView.alpha = 0.8;
    [waitingView setBackgroundColor:[UIColor blackColor]];
    UIActivityIndicatorView* activityIndicator = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 15, self.view.frame.size.height / 3 - 15, 30, 30)];
    [activityIndicator setColor:color];
    [waitingView addSubview:activityIndicator];
    [activityIndicator startAnimating];
    [self.view addSubview:waitingView];
    waitingView.hidden = YES;
}

-(void)showWaitingView
{
    waitingView.hidden = NO;
    [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(hideWaitingView) userInfo:nil repeats:NO];
}

-(void)hideWaitingView
{
    waitingView.hidden = YES;
}

- (IBAction)okBtnClicked:(id)sender {
    NSString* currentPS = currentPS_textfield.text;
    NSString* modifyPS = modifyPS_textfield.text;
    NSString* conformPS = conformPS_textfield.text;
    NSLog(@"当前密码: %@, 修改密码: %@, 确认密码: %@",currentPS,modifyPS,conformPS);
    if (!currentPS || [currentPS isEqualToString:@""]) {
        [CommonUtils showSimpleAlertViewWithTitle:@"温馨提示" WithMessage:@"请填写当前密码" WithDelegate:self WithCancelTitle:@"确定"];
        return;
    }
    if (!modifyPS || [modifyPS isEqualToString:@""]) {
        [CommonUtils showSimpleAlertViewWithTitle:@"温馨提示" WithMessage:@"请填写新密码" WithDelegate:self WithCancelTitle:@"确定"];
        return;
    }
    if (!conformPS || [conformPS isEqualToString:@""]) {
        [CommonUtils showSimpleAlertViewWithTitle:@"温馨提示" WithMessage:@"请确认新密码" WithDelegate:self WithCancelTitle:@"确定"];
        return;
    }
    
    if (![modifyPS isEqualToString:conformPS]) {
        [CommonUtils showSimpleAlertViewWithTitle:@"温馨提示" WithMessage:@"两次填写的新密码不一样" WithDelegate:self WithCancelTitle:@"确定"];
        return;
    }
    
    [self showWaitingView];
    void (^modifyPasswordDone)(NSData* rData) = ^(NSData* rData)
    {
        NSString* temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
        NSLog(@"Received Data: %@",temp);
        NSMutableDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
        NSNumber* cmd = [response1 objectForKey:@"cmd"];
        NSLog(@"cmd: %@",cmd);
        if ([cmd integerValue] == NORMAL_REPLY) {
            [self.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            [CommonUtils showSimpleAlertViewWithTitle:@"温馨提示" WithMessage:@"哎呀，出错啦～请重试。" WithDelegate:self WithCancelTitle:@"确定"];
        }
        [self hideWaitingView];

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
@end