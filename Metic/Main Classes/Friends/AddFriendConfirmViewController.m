//
//  AddFriendComfirmViewController.m
//  Metic
//
//  Created by mac on 14-8-11.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "AddFriendConfirmViewController.h"
#import "SVProgressHUD.h"

@interface AddFriendConfirmViewController ()
{
    NSTimer* timer;
}

@end

@implementation AddFriendConfirmViewController
@synthesize fid;

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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dismissHUD
{
    [SVProgressHUD dismissWithError:@"网络异常" afterDelay:1.5];
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

- (IBAction)leftBarBtnClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)okBtnClicked:(id)sender {
    [SVProgressHUD showWithStatus:@"处理中" maskType:SVProgressHUDMaskTypeGradient];
    timer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(dismissHUD) userInfo:nil repeats:NO];
    [self.comfirm_textField resignFirstResponder];
    NSString* cm = self.comfirm_textField.text;
    NSNumber* userId = [MTUser sharedInstance].userid;
    NSNumber* friendId = self.fid;
    NSDictionary* json = [CommonUtils packParamsInDictionary:[NSNumber numberWithInt:999],@"cmd",userId,@"id",cm,@"confirm_msg", friendId,@"friend_id",[NSNumber numberWithInt:ADD_FRIEND],@"item_id",nil];
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:ADD_FRIEND];
    NSLog(@"add friend apply: %@",json);
    if ([self.fid isKindOfClass:[NSNumber class]]) {
        NSLog(@"fid is number");
    }
    else if ([self.fid isKindOfClass:[NSString class]])
    {
        NSLog(@"fid is string");
    }

}

#pragma mark - HttpSenderDelegate
- (void)finishWithReceivedData:(NSData *)rData
{
    NSString* temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
    NSLog(@"Received Data: %@",temp);
    NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
    NSNumber* cmd = [response1 objectForKey:@"cmd"];
    NSLog(@"cmd: %@",cmd);
    switch ([cmd integerValue]) {
        case NORMAL_REPLY:
            [SVProgressHUD dismissWithSuccess:@"验证信息发送成功" afterDelay:2];
            [timer invalidate];
            timer = nil;
            [self.navigationController popViewControllerAnimated:YES];
            break;
        case ALREADY_FRIENDS:
            [SVProgressHUD dismissWithError:@"已经是好友" afterDelay:2];
            [timer invalidate];
            timer = nil;
            break;
        case REQUEST_FAIL:
            break;
            
        default:
            break;
    }
}


@end
