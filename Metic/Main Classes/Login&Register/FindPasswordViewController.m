//
//  FindPasswordViewController.m
//  WeShare
//
//  Created by 俊健 on 15/12/15.
//  Copyright (c) 2015年 WeShare. All rights reserved.
//

#import "FindPasswordViewController.h"
#import "GetBackPasswordViewController.h"
#import "FindPwWithPhoneViewController.h"
#import "CommonUtils.h"

@interface FindPasswordViewController ()

@end

@implementation FindPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma UI Settings
- (void)setupUI {
    self.title = @"找回密码";
    [CommonUtils addLeftButton:self isFirstPage:NO];
    self.verificateWithTelButton.layer.cornerRadius = 5;
    self.verificateWithTelButton.layer.masksToBounds = YES;
    [self.verificateWithTelButton setBackgroundImage:[CommonUtils createImageWithColor:[CommonUtils colorWithValue:0x59C19A]] forState:UIControlStateNormal];
    [self.verificateWithTelButton setBackgroundImage:[CommonUtils createImageWithColor:[CommonUtils colorWithValue:0x4AA383]] forState:UIControlStateHighlighted];
    
    self.verificateWithEmailButton.layer.cornerRadius = 5;
    self.verificateWithEmailButton.layer.masksToBounds = YES;
    [self.verificateWithEmailButton setBackgroundImage:[CommonUtils createImageWithColor:[CommonUtils colorWithValue:0xE4713C]] forState:UIControlStateNormal];
    [self.verificateWithEmailButton setBackgroundImage:[CommonUtils createImageWithColor:[CommonUtils colorWithValue:0xC56233]] forState:UIControlStateHighlighted];
}

- (IBAction)verificateWithTel:(id)sender {
    FindPwWithPhoneViewController *vc = [[FindPwWithPhoneViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)verificateWithEmailButton:(id)sender {
    UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    GetBackPasswordViewController* vc = [sb instantiateViewControllerWithIdentifier:@"GetBackPasswordViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}
@end
