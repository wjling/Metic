//
//  AdViewController.m
//  WeShare
//
//  Created by ligang_mac4 on 14-8-19.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "AdViewController.h"
#import "../Utils/CommonUtils.h"
#import "MobClick.h"

@interface AdViewController ()
@property (nonatomic,strong) UIWebView* webView;
@end

@implementation AdViewController

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
    [CommonUtils addLeftButton:self isFirstPage:NO];
    _webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, 320, self.view.frame.size.height)];
    NSLog(@"%f",self.view.frame.size.height);
    [self.view addSubview:_webView];
    //_AdUrl = @"http://w.m.taobao.com/api/wap?app_key=53f2af05fd98c59abf001eb8&device_id=9aea6466f93a8ace1b0d6392402e1739950c720a&aid=B1C67A00-A23B-4EA6-9809-366989A7BC92&mac=02:00:00:00:00:00";
    NSURL *url =[NSURL URLWithString:_AdUrl];
    NSLog(@"打开广告页面  url：%@",_AdUrl);
    NSURLRequest *request =[NSURLRequest requestWithURL:url];
    [_webView loadRequest:request];
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [MobClick beginEvent:@"广告"];
    [_webView setFrame:CGRectMake(0, 0, 320, self.view.frame.size.height)];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [MobClick beginEvent:@"广告"];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)MTpopViewController
{
    [self.navigationController popViewControllerAnimated:YES];
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

@end
