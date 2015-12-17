//
//  ModifyPasswordViewController.m
//  WeShare
//
//  Created by mac on 14-9-2.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "ModifyPasswordViewController.h"
#import "SVProgressHUD.h"
#import "MTAccount.h"
#import "MTAccountManager.h"

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
    MTLOG(@"修改密码 view did load");
    [CommonUtils addLeftButton:self isFirstPage:NO];
    
}

//返回上一层
-(void)MTpopViewController{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    MTLOG(@"修改密码 view will appear");
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
    MTLOG(@"修改密码 view did appear");
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
    MTLOG(@"keyBoard:%f", keyboardSize.height);  //216
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
    MTLOG(@"keyboardWasHidden keyBoard:%f", keyboardSize.height);
    float offset = [UIScreen mainScreen].bounds.size.height - self.view.frame.origin.y - self.view.frame.size.height;
    [UIView beginAnimations:@"goDOWN" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.1f];
    
    [self.view setFrame:CGRectMake(0, self.view.frame.origin.y + offset, self.view.frame.size.width, self.view.frame.size.height)];
    [UIView commitAnimations];
}

- (IBAction)okBtnClicked:(id)sender {
    [SVProgressHUD showWithStatus:@"正在处理" maskType:SVProgressHUDMaskTypeNone];
    NSString* currentPS = currentPS_textfield.text;
    NSString* modifyPS = modifyPS_textfield.text;
    NSString* conformPS = conformPS_textfield.text;
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
        [SVProgressHUD dismissWithError:@"填写的新密码不一致" afterDelay:1.5];
        return;
    }
    MTUser *user = [MTUser sharedInstance];
    NSString *account = nil;
    if (user.email && user.email.length) {
        account = user.email;
    } else if (user.phone && user.phone.length) {
        account = user.phone;
    } else {
        [SVProgressHUD dismissWithError:@"操作失败" afterDelay:1.5];
        return;
    }
    
    [MTAccountManager modifyPwWithAccount:account oldPassword:currentPS newPassword:modifyPS success:^{
        [SVProgressHUD dismissWithSuccess:@"密码修改成功" afterDelay:1.5];
        MTAccount *account = [MTAccount singleInstance];
        account.password = modifyPS;
        [account saveAccount];
        [self.navigationController popViewControllerAnimated:YES];
    } failure:^(NSString *message) {
        [SVProgressHUD dismissWithError:message afterDelay:1.5];
    }];
}
@end
