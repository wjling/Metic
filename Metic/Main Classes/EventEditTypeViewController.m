//
//  EventEditTypeViewController.m
//  WeShare
//
//  Created by 俊健 on 15/5/25.
//  Copyright (c) 2015年 WeShare. All rights reserved.
//

#import "EventEditTypeViewController.h"
#import "CommonUtils.h"
#import "SVProgressHUD.h"
#import "MTUser.h"
#import "MTDatabaseAffairs.h"
#import "SingleSelectionAlertView.h"


@interface EventEditTypeViewController () <SingleSelectionAlertViewDelegate>

@property (nonatomic, strong) UIButton *eventType;
@property (nonatomic, strong) UILabel* tips;
@property (nonatomic, strong) SingleSelectionAlertView *typeSelectView;

@property (nonatomic) NSInteger visibility;

@end

@implementation EventEditTypeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    [self initData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initUI
{
    [CommonUtils addLeftButton:self isFirstPage:NO];
    self.view.backgroundColor = [UIColor colorWithWhite:0.95f alpha:1.0f];
    self.title = @"修改活动类型";
    
    
    UILabel* lab1 = [[UILabel alloc]initWithFrame:CGRectMake(10, 10 + 0, CGRectGetWidth(self.view.frame) - 20, 25)];
    
    lab1.text = @"活动类型";
    lab1.numberOfLines = 1;
    lab1.textAlignment = NSTextAlignmentLeft;
    lab1.font = [UIFont systemFontOfSize:16];
    lab1.textColor = [UIColor colorWithWhite:0.42f alpha:1.0f];
    [self.view addSubview:lab1];
    
    UILabel *paddingView1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 10, 25)];
    paddingView1.text = @" ";
    paddingView1.textColor = [UIColor darkGrayColor];
    paddingView1.backgroundColor = [UIColor clearColor];
    
    self.eventType = [UIButton buttonWithType:UIButtonTypeSystem];
    self.eventType.frame = CGRectMake(10, 40, CGRectGetWidth(self.view.frame) - 20, 40);
    [self.eventType setTitleColor:[UIColor colorWithWhite:0.3 alpha:1.0f] forState:UIControlStateNormal];
    [self.eventType setBackgroundColor:[UIColor whiteColor]];
    self.eventType.layer.cornerRadius = 6;
    self.eventType.layer.masksToBounds = YES;
    [self.eventType addTarget:self action:@selector(changeEventType:) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:self.eventType];
    
    UILabel* tips = [[UILabel alloc]initWithFrame:CGRectMake(40, CGRectGetMaxY(self.eventType.frame) + 10, CGRectGetWidth(self.view.frame) - 20, 30)];
    tips = tips;
    tips.text = @"修改活动描述后会通知所有活动参与者。";
    tips.numberOfLines = 2;
    tips.textAlignment = NSTextAlignmentLeft;
    tips.font = [UIFont systemFontOfSize:13];
    tips.textColor = [UIColor colorWithWhite:0.6f alpha:1.0f];
    [self.view addSubview:tips];
}

-(void)initData
{
    self.visibility = [[_eventInfo valueForKey:@"visibility"]integerValue];

}

- (void)setVisibility:(NSInteger)visibility
{
    _visibility = visibility;
    NSArray *arr = @[@"公开（内容公开）", @"公开（内容不公开）",@"私人活动"];
    if (visibility >= 0 && visibility < arr.count) {
        NSString *title = arr[2-visibility];
        [self.eventType setTitle:title forState:UIControlStateNormal];
    }
}

- (void)changeEventType:(id)sender {
    NSArray *arr = @[@"公开活动（内容公开）", @"公开活动（内容不公开）",@"私人活动"];
    NSInteger index = 2 - _visibility;
    self.typeSelectView = [[SingleSelectionAlertView alloc]initWithContentSize:CGSizeMake(300, 400) withTitle:@"修改活动类型" withOptions:arr];
    self.typeSelectView.kDelegate = self;
    self.typeSelectView.tag = 0;
    [self.typeSelectView selectItemAtIndex:index];
    [self.typeSelectView show];
}

-(void)changeEventTypeWithVisibility:(NSInteger)visibility
{
    [SVProgressHUD showWithStatus:@"处理中" maskType:SVProgressHUDMaskTypeClear];
    if (visibility == [[_eventInfo valueForKey:@"visibility"]integerValue]) {
        [self.navigationController popViewControllerAnimated:YES];
        [SVProgressHUD dismissWithSuccess:@"修改成功"];
        return;
    }
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:[_eventInfo valueForKey:@"event_id"] forKey:@"event_id"];
    [dictionary setValue:@(visibility) forKey:@"visibility"];
    [dictionary setValue:[MTUser sharedInstance].userid forKey:@"id"];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:CHANGE_EVENT_INFO finshedBlock:^(NSData *rData) {
        if (rData) {
            NSDictionary *response = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableContainers error:nil];
            NSNumber *cmd = [response valueForKey:@"cmd"];
            switch ([cmd intValue]) {
                case NORMAL_REPLY:
                {
                    [SVProgressHUD dismissWithSuccess:@"修改成功"];
                    [_eventInfo setValue:@(visibility) forKey:@"visibility"];
                    self.visibility = visibility;
                    [[MTDatabaseAffairs sharedInstance]saveEventToDB:_eventInfo];
                }
                    break;
                case EVENT_NOT_EXIST:
                {
                    [SVProgressHUD dismissWithError:@"活动不存在"];
                    [self.navigationController popViewControllerAnimated:YES];
                }
                    break;
                case REQUEST_DATA_ERROR:
                {
                    [SVProgressHUD dismissWithError:@"没有修改权限"];
                    [self.navigationController popViewControllerAnimated:YES];
                }
                    break;
                default:
                {
                    [SVProgressHUD dismissWithError:@"服务器异常"];
                }
            }
        }else{
            [SVProgressHUD dismissWithError:@"网络异常"];
        }
    }];
    
}

#pragma mark - SingleSelectionAlertView Delegate
- (void)SingleSelectionAlertView:(id)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView isKindOfClass:[CustomIOS7AlertView class]]) {
        if (((CustomIOS7AlertView*)alertView).tag == 0) {
            if (buttonIndex == 1) {
                NSInteger type = [self.typeSelectView getSelectedIndex];
                NSInteger visibility = 2 - type;
                [self changeEventTypeWithVisibility:visibility];
            }
        }
    } else if ([alertView isKindOfClass:[UIButton class]]) {
        
    }
}
@end
