//
//  NameSettingViewController.m
//  Metic
//
//  Created by mac on 14-7-17.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "NameSettingViewController.h"

@interface NameSettingViewController ()
{
    NSString* newName;
    NSString* DB_path;
}

@end

@implementation NameSettingViewController


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
    DB_path = [NSString stringWithFormat:@"%@/db",[MTUser sharedInstance].userid];
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

- (IBAction)confirmClicked:(id)sender {
    newName = self.name_textField.text;
    if ([newName isEqualToString:@""]) {
        [CommonUtils showSimpleAlertViewWithTitle:@"提示" WithMessage:@"新的昵称不能为空" WithDelegate:self WithCancelTitle:@"OK"];
    }
    else
    {
        NSDictionary* json = [CommonUtils packParamsInDictionary:[MTUser sharedInstance].userid,@"id",newName,@"name",nil  ];
        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:nil];
        HttpSender* http = [[HttpSender alloc]initWithDelegate:self];
        [http sendMessage:jsonData withOperationCode:CHANGE_SETTINGS];
    }
    
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
            [MTUser sharedInstance].name = newName;
            NSLog(@"昵称修改成功");
        }
            break;
            
        default:
            NSLog(@"昵称修改失败");
            break;
    }
    [self.navigationController popViewControllerAnimated:YES];
    
}
@end
