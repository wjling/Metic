//
//  AboutPageViewController.m
//  WeShare
//
//  Created by mac on 14-8-31.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "AboutPageViewController.h"

@interface AboutPageViewController ()
{
    NSString* currentVersion;
}

@end

@implementation AboutPageViewController
@synthesize version_label;
@synthesize URL_button;

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
    currentVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    MTLOG(@"version: %@",currentVersion);
    version_label.text = [NSString stringWithFormat:@"活动宝 %@",currentVersion];
    
}

//返回上一层
-(void)MTpopViewController{
    [self.navigationController popViewControllerAnimated:YES];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)URLBtnClicked:(id)sender {
    MTLOG(@"open safari");
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.whatsact.com"]];
}
@end
