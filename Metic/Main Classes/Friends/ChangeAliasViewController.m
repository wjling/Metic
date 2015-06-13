//
//  ChangeAliasViewController.m
//  WeShare
//
//  Created by ligang_mac4 on 14-10-20.
//  Copyright (c) 2014年 WeShare. All rights reserved.
//

#import "ChangeAliasViewController.h"
#import "SVProgressHUD.h"

@interface ChangeAliasViewController ()
{
    
    
}

@end

@implementation ChangeAliasViewController
@synthesize alias_view;
@synthesize ok_btn;
@synthesize fid;
@synthesize alias_new;
@synthesize rootView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initViews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)initViews
{
    rootView = [[InputHandleView alloc]initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height)];
    self.view = rootView;
    [self.view setBackgroundColor:[UIColor whiteColor]];  //不设背景会有一种视觉上的违和感
    self.navigationItem.title = @"修改好友备注";
    
    UIColor *color = [CommonUtils colorWithValue:0xbfbfbf];
    alias_view = [[UITextField alloc]init];
    [alias_view setFrame:CGRectMake(20, 60, 280, 40)];
    alias_view.layer.borderWidth = 1.5;
    alias_view.layer.borderColor = color.CGColor;
    alias_view.layer.cornerRadius = 3.5;
    alias_view.layer.masksToBounds = YES;
    alias_view.placeholder = @"输入好友备注";
    [alias_view setValue:[NSNumber numberWithInt:10] forKey:@"paddingLeft"];
//    alias_view.prefix_label.text = @"备注名";
//    alias_view.textField.delegate = rootView;
    
    ok_btn = [[UIBarButtonItem alloc]initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(okBtnClick)];
    
    self.navigationItem.rightBarButtonItem = ok_btn;
    [self.view addSubview:alias_view];
    
}

-(void)okBtnClick
{
    [SVProgressHUD showWithStatus:@"正在提交" maskType:SVProgressHUDMaskTypeClear];
    [alias_view resignFirstResponder];
    alias_new = alias_view.text? alias_view.text:@"";
    NSMutableDictionary* json_dic = [CommonUtils packParamsInDictionary:
                                     [MTUser sharedInstance].userid, @"id",
                                     fid, @"friend_id",
                                     [NSNumber numberWithInt:ALIAS_SET], @"operation",
                                     alias_new, @"alias", nil];
    NSLog(@"alias json: %@", json_dic);
    NSData* json_data = [NSJSONSerialization dataWithJSONObject:json_dic options:NSJSONWritingPrettyPrinted error:nil];
    
    void(^setAliasDone)(NSData *rData) = ^(NSData* rData)
    {
        NSString* temp;
        if (rData)
        {
            temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
        }
        else
        {
            NSLog(@"修改备注名，收到的rData为空");
            [SVProgressHUD dismissWithError:@"网络异常"];
            return;
        }
        NSLog(@"修改备注名,Received Data: %@",temp);
        NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
        NSInteger cmd = [[response1 objectForKey:@"cmd"]intValue];
        NSLog(@"cmd: %d",cmd);
        switch (cmd) {
            case NORMAL_REPLY:
            {
                dispatch_async(dispatch_get_global_queue(0, 0), ^
                               {
                                   [[MTUser sharedInstance].alias_dic setValue:alias_new forKey:[NSString stringWithFormat:@"%@",fid]];
                                   [[MTUser sharedInstance] aliasDicDidChanged];
                               });
    
                [SVProgressHUD dismissWithSuccess:@"备注名修改成功"];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self.navigationController popViewControllerAnimated:YES];
                });
            }
                break;
                
            default:
            {
                [SVProgressHUD dismissWithError:@"备注名修改失败"];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self.navigationController popViewControllerAnimated:YES];
                });
            }
                break;
        }
    };
    HttpSender *http = [[HttpSender alloc]initWithDelegate:self];
    [http sendMessage:json_data withOperationCode:ALIAS_OPERATION finshedBlock:setAliasDone];
}
@end
