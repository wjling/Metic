//
//  AdViewController.m
//  WeShare
//
//  Created by ligang_mac4 on 14-8-19.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "AdViewController.h"
#import "CommonUtils.h"
#import "MobClick.h"
#import "MTUser.h"

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
    if (_URLtitle) [self.navigationItem setTitle:_URLtitle];
    _webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, 320, self.view.frame.size.height)];
    MTLOG(@"%f",self.view.frame.size.height);
    [self.view addSubview:_webView];
    NSURLRequest* request = [self MTUrlRequest];
    if (request) [_webView loadRequest:request];
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [MobClick beginEvent:@"外链"];
    [_webView setFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [MobClick beginEvent:@"外链"];
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

-(NSURLRequest*) MTUrlRequest
{
    if ([_method isEqualToString:@"GET"]) {
        for (int i = 0; i < _args.count; i++) {
            NSString* arg = _args[i];
            if (i == 0) _AdUrl = [_AdUrl stringByAppendingString:@"?"];
            if ([arg isEqualToString:@"account"]) {
                _AdUrl = [_AdUrl stringByAppendingString:[NSString stringWithFormat:@"%@=%@",arg,[MTUser sharedInstance].email]];
            }else if ([arg isEqualToString:@"id"]){
                _AdUrl = [_AdUrl stringByAppendingString:[NSString stringWithFormat:@"%@=%@",arg,[MTUser sharedInstance].userid]];
            }else continue;
            if (i != _args.count - 1) _AdUrl = [_AdUrl stringByAppendingString:@"&"];
        }
        NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:_AdUrl]];
        return request;


    }if ([_method isEqualToString:@"POST"]) {
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:[NSURL URLWithString:_AdUrl]];
        [request setHTTPMethod:@"POST"];

        
        NSString *body=@"";
        BOOL need = NO;
        for (int i = 0; i < _args.count; i++) {
            NSString* arg = _args[i];
            if ([arg isEqualToString:@"account"]) {
                if (need) {
                    body = [body stringByAppendingString:@"&"];
                }
                body = [body stringByAppendingString:[NSString stringWithFormat:@"%@=%@",@"account",[MTUser sharedInstance].email]];
                need = YES;
            }else if ([arg isEqualToString:@"id"]){
                if (need) {
                    body = [body stringByAppendingString:@"&"];
                }
                body = [body stringByAppendingString:[NSString stringWithFormat:@"%@=%@",@"id",[MTUser sharedInstance].userid]];
                need = YES;
            }
        }

        NSData* jsonData = [body dataUsingEncoding:NSUTF8StringEncoding];
        
        [request setHTTPMethod:@"POST"];
        [request setValue:@"text/xml" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:jsonData];
        NSString *postLength = [NSString stringWithFormat:@"%d",[jsonData length]];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        
        return request;
    }else{
        return nil;
    }
}
@end
