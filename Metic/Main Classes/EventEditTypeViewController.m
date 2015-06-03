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

@interface EventEditTypeViewController ()
@property(nonatomic,strong) UIView* isAllowStrangerView;
@property(nonatomic,strong) UILabel* tips;
@property NSInteger visibility;

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
    
    [self initRightBtn];
    [self initEventType];
    
    UILabel* tips = [[UILabel alloc]initWithFrame:CGRectMake(40, CGRectGetMaxY(_isAllowStrangerView.frame) + 10, CGRectGetWidth(self.view.frame) - 20, 30)];
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
    _visibility = [[_eventInfo valueForKey:@"visibility"]integerValue];
    [self changeAllowStangerStage:nil];
}

-(void)initEventType
{
    _isAllowStrangerView = [[UIView alloc]initWithFrame:CGRectMake(20, 20, 280, 70)];
    [_isAllowStrangerView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:_isAllowStrangerView];

    UIButton* button1 = [[UIButton alloc]initWithFrame:CGRectMake(15, 0, 26, 26)];
    button1.tag = 1;
    [button1 setBackgroundImage:[UIImage imageNamed:@"允许陌生人"] forState:UIControlStateNormal];
    [button1 addTarget:self action:@selector(changeAllowStangerStage:) forControlEvents:UIControlEventTouchUpInside];
    [_isAllowStrangerView addSubview:button1];

    UILabel *label1 = [[UILabel alloc]initWithFrame:CGRectMake(45, 0, 80, 30)];
    label1.tag = 2;
    [label1 setBackgroundColor:[UIColor clearColor]];
    label1.text = @"公开活动";
    [label1 setFont:[UIFont systemFontOfSize:16]];
    [label1 setTextAlignment:NSTextAlignmentLeft];
    [_isAllowStrangerView addSubview:label1];

    UIButton* button2 = [[UIButton alloc]initWithFrame:CGRectMake(155, 0, 26, 26)];
    button2.tag = 3;
    [button2 setBackgroundImage:[UIImage imageNamed:@"允许陌生人"] forState:UIControlStateNormal];
    [button2 addTarget:self action:@selector(changeAllowStangerStage:) forControlEvents:UIControlEventTouchUpInside];
    [_isAllowStrangerView addSubview:button2];

    UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake(185, 0, 80, 30)];
    label2.tag = 4;
    [label2 setBackgroundColor:[UIColor clearColor]];
    label2.text = @"私密活动";
    [label2 setFont:[UIFont systemFontOfSize:16]];
    [label2 setTextAlignment:NSTextAlignmentLeft];
    [_isAllowStrangerView addSubview:label2];

    UIButton* button3 = [[UIButton alloc]initWithFrame:CGRectMake(15, 35, 26, 26)];
    button3.tag = 5;
    [button3 setBackgroundImage:[UIImage imageNamed:@"允许陌生人"] forState:UIControlStateNormal];
    [button3 addTarget:self action:@selector(changeAllowStangerStage:) forControlEvents:UIControlEventTouchUpInside];
    [_isAllowStrangerView addSubview:button3];

    UILabel *label3 = [[UILabel alloc]initWithFrame:CGRectMake(45, 35, 80, 30)];
    label3.tag = 6;
    [label3 setBackgroundColor:[UIColor clearColor]];
    label3.text = @"内容公开";
    [label3 setFont:[UIFont systemFontOfSize:16]];
    [label3 setTextAlignment:NSTextAlignmentLeft];
    [_isAllowStrangerView addSubview:label3];

    UIButton* button4 = [[UIButton alloc]initWithFrame:CGRectMake(155, 35, 26, 26)];
    button4.tag = 7;
    [button4 setBackgroundImage:[UIImage imageNamed:@"允许陌生人"] forState:UIControlStateNormal];
    [button4 addTarget:self action:@selector(changeAllowStangerStage:) forControlEvents:UIControlEventTouchUpInside];
    [_isAllowStrangerView addSubview:button4];

    UILabel *label4 = [[UILabel alloc]initWithFrame:CGRectMake(185, 35, 80, 30)];
    label4.tag = 8;
    [label4 setBackgroundColor:[UIColor clearColor]];
    label4.text = @"内容不公开";
    [label4 setFont:[UIFont systemFontOfSize:16]];
    [label4 setTextAlignment:NSTextAlignmentLeft];
    [_isAllowStrangerView addSubview:label4];

}

-(void)changeAllowStangerStage:(UIButton*)sender
{
    switch (sender.tag) {
        case 1:
            if (_visibility == 0) {
                _visibility = 2;
            }
            break;
        case 3:
            _visibility = 0;
            break;
        case 5:
            _visibility = 2;
            break;
        case 7:
            _visibility = 1;
            break;
        default:
            break;
    }
    if (_visibility == 0) {
        [(UIButton*)[_isAllowStrangerView viewWithTag:1] setBackgroundImage:[UIImage imageNamed:@"不允许陌生人"] forState:UIControlStateNormal];
        [(UIButton*)[_isAllowStrangerView viewWithTag:3] setBackgroundImage:[UIImage imageNamed:@"允许陌生人"] forState:UIControlStateNormal];
        [(UIButton*)[_isAllowStrangerView viewWithTag:5] setBackgroundImage:[UIImage imageNamed:@"不允许陌生人"] forState:UIControlStateNormal];
        ((UIButton*)[_isAllowStrangerView viewWithTag:5]).hidden = YES;
        ((UILabel*)[_isAllowStrangerView viewWithTag:6]).hidden = YES;
        [(UIButton*)[_isAllowStrangerView viewWithTag:7] setBackgroundImage:[UIImage imageNamed:@"不允许陌生人"] forState:UIControlStateNormal];
        ((UIButton*)[_isAllowStrangerView viewWithTag:7]).hidden = YES;
        ((UILabel*)[_isAllowStrangerView viewWithTag:8]).hidden = YES;
    }else if(_visibility == 1){
        [(UIButton*)[_isAllowStrangerView viewWithTag:1] setBackgroundImage:[UIImage imageNamed:@"允许陌生人"] forState:UIControlStateNormal];
        [(UIButton*)[_isAllowStrangerView viewWithTag:3] setBackgroundImage:[UIImage imageNamed:@"不允许陌生人"] forState:UIControlStateNormal];
        [(UIButton*)[_isAllowStrangerView viewWithTag:5] setBackgroundImage:[UIImage imageNamed:@"不允许陌生人"] forState:UIControlStateNormal];
        ((UIButton*)[_isAllowStrangerView viewWithTag:5]).hidden = NO;
        ((UILabel*)[_isAllowStrangerView viewWithTag:6]).hidden = NO;
        [(UIButton*)[_isAllowStrangerView viewWithTag:7] setBackgroundImage:[UIImage imageNamed:@"允许陌生人"] forState:UIControlStateNormal];
        ((UIButton*)[_isAllowStrangerView viewWithTag:7]).hidden = NO;
        ((UILabel*)[_isAllowStrangerView viewWithTag:8]).hidden = NO;
    }else if(_visibility == 2){
        [(UIButton*)[_isAllowStrangerView viewWithTag:1] setBackgroundImage:[UIImage imageNamed:@"允许陌生人"] forState:UIControlStateNormal];
        [(UIButton*)[_isAllowStrangerView viewWithTag:3] setBackgroundImage:[UIImage imageNamed:@"不允许陌生人"] forState:UIControlStateNormal];
        [(UIButton*)[_isAllowStrangerView viewWithTag:5] setBackgroundImage:[UIImage imageNamed:@"允许陌生人"] forState:UIControlStateNormal];
        ((UIButton*)[_isAllowStrangerView viewWithTag:5]).hidden = NO;
        ((UILabel*)[_isAllowStrangerView viewWithTag:6]).hidden = NO;
        [(UIButton*)[_isAllowStrangerView viewWithTag:7] setBackgroundImage:[UIImage imageNamed:@"不允许陌生人"] forState:UIControlStateNormal];
        ((UIButton*)[_isAllowStrangerView viewWithTag:7]).hidden = NO;
        ((UILabel*)[_isAllowStrangerView viewWithTag:8]).hidden = NO;
    }
}

- (void)initRightBtn
{
    UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightButton setFrame:CGRectMake(10, 2.5f, 51, 28)];
    [rightButton setBackgroundImage:[UIImage imageNamed:@"小按钮绿色"] forState:UIControlStateNormal];
    [rightButton setTitle:@"确定" forState:UIControlStateNormal];
    [rightButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [rightButton.titleLabel setLineBreakMode:NSLineBreakByClipping];
    [rightButton addTarget:self action:@selector(confirm) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightButtonItem=[[UIBarButtonItem alloc]initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
}

-(void)confirm
{
    [SVProgressHUD showWithStatus:@"处理中" maskType:SVProgressHUDMaskTypeClear];
    NSInteger lvisibility = _visibility;
    if (lvisibility == [[_eventInfo valueForKey:@"visibility"]integerValue]) {
        [self.navigationController popViewControllerAnimated:YES];
        [SVProgressHUD dismissWithSuccess:@"修改成功"];
        return;
    }
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:[_eventInfo valueForKey:@"event_id"] forKey:@"event_id"];
    [dictionary setValue:@(lvisibility) forKey:@"visibility"];
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
                    [_eventInfo setValue:@(lvisibility) forKey:@"visibility"];
                    [[MTDatabaseAffairs sharedInstance]saveEventToDB:_eventInfo];
                    [self.navigationController popViewControllerAnimated:YES];
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


@end
