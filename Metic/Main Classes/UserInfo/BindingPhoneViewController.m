//
//  BindingPhoneViewController.m
//  WeShare
//
//  Created by mac on 14-9-3.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "BindingPhoneViewController.h"
#import "ContactsViewController.h"
#import "BindPhoneNumberViewController.h"
#import "DebindPhoneNumberViewController.h"

@interface BindingPhoneViewController ()

@end

@implementation BindingPhoneViewController
@synthesize gou_imageview;
@synthesize hint1_textfield;
@synthesize bindingNumber_label;
@synthesize hint2_label;
@synthesize checkContact_button;
@synthesize changeNumber_button;

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
    [CommonUtils addLeftButton:self isFirstPage:NO];
}

//返回上一层
-(void)MTpopViewController{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    MTUser *user = [MTUser sharedInstance];
    NSString* phone = user.phone;
    if (phone && ![phone isEqualToString:@""]) {
        hint1_textfield.hidden = NO;
        hint2_label.hidden = NO;
        gou_imageview.hidden = NO;
        bindingNumber_label.text = [NSString stringWithFormat:@"绑定的手机号：%@",phone];
        [changeNumber_button setTitle:@"更换绑定手机" forState:UIControlStateNormal];
    } else {
        hint1_textfield.hidden = YES;
        hint2_label.hidden = YES;
        gou_imageview.hidden = YES;
        bindingNumber_label.text = @"当前还未绑定手机号";
        [changeNumber_button setTitle:@"绑定手机号码" forState:UIControlStateNormal];
    }
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)checkContactClicked:(id)sender {
    UIStoryboard* mainStoryBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    ContactsViewController *vc = [mainStoryBoard instantiateViewControllerWithIdentifier:@"ContactsViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)changeNumberClicked:(id)sender {
    MTUser *user = [MTUser sharedInstance];
    NSString* phone = user.phone;
    if (phone && ![phone isEqualToString:@""]) {
        DebindPhoneNumberViewController *vc = [[DebindPhoneNumberViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        BindPhoneNumberViewController *vc = [[BindPhoneNumberViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
}
@end
