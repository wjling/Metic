//
//  SignSetttingViewController.m
//  Metic
//
//  Created by mac on 14-7-20.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "SignSetttingViewController.h"

@interface SignSetttingViewController ()
{
    NSString* newSign;
}

@end

@implementation SignSetttingViewController
@synthesize content_textView;
@synthesize rootView;

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
    UIColor *color = [UIColor colorWithRed:0.29 green:0.76 blue:0.61 alpha:1];
    self.content_textView.layer.borderColor = color.CGColor;
    self.content_textView.layer.borderWidth = 2;
    self.content_textView.delegate = rootView;
    [self.right_barButton addTarget:self action:@selector(rightBarBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    
}

//返回上一层
-(void)MTpopViewController{
    [self.navigationController popViewControllerAnimated:YES];
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

-(void)rightBarBtnClicked:(id)sender
{
    newSign = self.content_textView.text;
    NSDictionary* json = [CommonUtils packParamsInDictionary:
                          [MTUser sharedInstance].userid,@"id",
                          newSign,@"sign",nil  ];
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender* http = [[HttpSender alloc]initWithDelegate:self];
    [http sendMessage:jsonData withOperationCode:CHANGE_SETTINGS];
}

#pragma mark - HttpSenderDelegate
-(void)finishWithReceivedData:(NSData*) rData
{
    NSString* temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
    NSLog(@"Received Data: %@",temp);
    NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
    NSNumber* cmd = [response1 objectForKey:@"cmd"];
    NSLog(@"cmd: %@",cmd);
    switch ([cmd integerValue]) {
        case NORMAL_REPLY:
        {
            NSLog(@"个人描述修改成功");
            [MTUser sharedInstance].sign = newSign;
            [self.navigationController popViewControllerAnimated:YES];
        }
            break;
            
        default:
            NSLog(@"个人描述修改失败");
            [CommonUtils showSimpleAlertViewWithTitle:@"系统提示" WithMessage:@"由于网络原因个人描述修改失败" WithDelegate:self WithCancelTitle:@"O.O ||"];
            break;
    }
    
}


@end
