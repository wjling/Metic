//
//  EventEditTimeViewController.m
//  WeShare
//
//  Created by 俊健 on 15/5/11.
//  Copyright (c) 2015年 WeShare. All rights reserved.
//

#import "EventEditTimeViewController.h"
#import "SVProgressHUD.h"
#import "CommonUtils.h"
#import "FlatDatePicker.h"
#import "MTUser.h"
#import "MTDatabaseAffairs.h"

@interface EventEditTimeViewController ()<UITextFieldDelegate,FlatDatePickerDelegate>
@property (nonatomic,strong) UIButton* confirmBtn;
@property (nonatomic,strong) UITextField* beginTime;
@property (nonatomic,strong) UITextField* endTime;
@property (nonatomic,strong) UITextField *seletedText;
@property (nonatomic,strong) FlatDatePicker *flatDatePicker;
@end

@implementation EventEditTimeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    [self initData];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initUI
{
    [CommonUtils addLeftButton:self isFirstPage:NO];
    self.view.backgroundColor = [UIColor colorWithWhite:0.98f alpha:1.0f];
    self.title = @"修改活动时间";
    
    [self initRightBtn];
    
    UILabel* lab1 = [[UILabel alloc]initWithFrame:CGRectMake(10, 10 + 0, CGRectGetWidth(self.view.frame) - 20, 25)];
    
    lab1.text = @"活动开始时间";
    lab1.numberOfLines = 1;
    lab1.textAlignment = NSTextAlignmentLeft;
    lab1.font = [UIFont systemFontOfSize:16];
    lab1.textColor = [UIColor colorWithWhite:0.42f alpha:1.0f];
    [self.view addSubview:lab1];
    
    UILabel *paddingView1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 10, 25)];
    paddingView1.text = @" ";
    paddingView1.textColor = [UIColor darkGrayColor];
    paddingView1.backgroundColor = [UIColor clearColor];
    
    _beginTime = [[UITextField alloc]initWithFrame:CGRectMake(10, 40, CGRectGetWidth(self.view.frame) - 20, 40)];
    _beginTime.placeholder = @"请选择开始时间";
    _beginTime.font = [UIFont systemFontOfSize:16];
    _beginTime.textColor = [UIColor colorWithWhite:0.3 alpha:1.0f];
    _beginTime.textAlignment = NSTextAlignmentLeft;
    [_beginTime setBackgroundColor:[UIColor whiteColor]];
    _beginTime.layer.cornerRadius = 6;
    _beginTime.layer.masksToBounds = YES;
    _beginTime.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    _beginTime.delegate = self;
    _beginTime.leftView = paddingView1;
    _beginTime.leftViewMode = UITextFieldViewModeAlways;
    [self.view addSubview:_beginTime];
    
    UILabel* lab2 = [[UILabel alloc]initWithFrame:CGRectMake(10, 10 + 80, CGRectGetWidth(self.view.frame) - 20, 25)];
    
    lab2.text = @"活动结束时间";
    lab2.numberOfLines = 1;
    lab2.textAlignment = NSTextAlignmentLeft;
    lab2.font = [UIFont systemFontOfSize:16];
    lab2.textColor = [UIColor colorWithWhite:0.42f alpha:1.0f];
    [self.view addSubview:lab2];
    
    UILabel *paddingView2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 10, 25)];
    paddingView2.text = @" ";
    paddingView2.textColor = [UIColor darkGrayColor];
    paddingView2.backgroundColor = [UIColor clearColor];
    
    _endTime = [[UITextField alloc]initWithFrame:CGRectMake(10, 40 + 80, CGRectGetWidth(self.view.frame) - 20, 40)];
    _endTime.placeholder = @"请选择结束时间";
    _endTime.font = [UIFont systemFontOfSize:16];
    _endTime.textColor = [UIColor colorWithWhite:0.3 alpha:1.0f];
    _endTime.textAlignment = NSTextAlignmentLeft;
    [_endTime setBackgroundColor:[UIColor whiteColor]];
    _endTime.layer.cornerRadius = 6;
    _endTime.layer.masksToBounds = YES;
    _endTime.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    _endTime.delegate = self;
    _endTime.leftView = paddingView2;
    _endTime.leftViewMode = UITextFieldViewModeAlways;
    [self.view addSubview:_endTime];


    UILabel* tips = [[UILabel alloc]initWithFrame:CGRectMake(10, 170, CGRectGetWidth(self.view.frame) - 20, 30)];
    
    tips.text = @"修改活动时间后会通知所有活动参与者。";
    tips.numberOfLines = 2;
    tips.textAlignment = NSTextAlignmentLeft;
    tips.font = [UIFont systemFontOfSize:14];
    tips.textColor = [UIColor colorWithWhite:0.6f alpha:1.0f];
    [self.view addSubview:tips];
    
}

- (void)initData
{
    self.flatDatePicker = [[FlatDatePicker alloc] initWithParentView:self.view];
    self.flatDatePicker.delegate = self;
    
    
    NSString* beginT = [_eventInfo valueForKey:@"time"];
    NSString* endT = [_eventInfo valueForKey:@"endTime"];
    if (beginT && beginT.length > 16) {
        beginT = [beginT substringToIndex:16];
        _beginTime.text = beginT;
    }
    if (endT && endT.length > 16) {
        endT = [endT substringToIndex:16];
        _endTime.text = endT;
    }
}

- (void)initRightBtn
{
    UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _confirmBtn = rightButton;
    [rightButton setFrame:CGRectMake(10, 2.5f, 51, 28)];
    [rightButton setBackgroundImage:[UIImage imageNamed:@"小按钮绿色"] forState:UIControlStateNormal];
    [rightButton setTitle:@"确定" forState:UIControlStateNormal];
    [rightButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [rightButton.titleLabel setLineBreakMode:NSLineBreakByClipping];
    [rightButton addTarget:self action:@selector(confirm) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightButtonItem=[[UIBarButtonItem alloc]initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
}

- (void)checkTimeValid
{
    if ([self.beginTime.text isEqualToString:@""] || [self.endTime.text isEqualToString:@""]) {
        return;
    }
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm"];
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    NSDate* begin = [dateFormatter dateFromString:self.beginTime.text];
    NSDate* end = [dateFormatter dateFromString:self.endTime.text];
    NSTimeInterval begins = [begin timeIntervalSince1970];
    NSTimeInterval ends = [end timeIntervalSince1970];
    int dis = ends-begins;
    if (dis<0) {
        [CommonUtils showSimpleAlertViewWithTitle:@"提示" WithMessage:@"结束时间必须大于开始时间" WithDelegate:nil WithCancelTitle:@"确定"];
        self.endTime.text = @"";
    }
    
}


-(void)confirm
{
    [_beginTime resignFirstResponder];
    [_endTime resignFirstResponder];
    [SVProgressHUD showWithStatus:@"处理中" maskType:SVProgressHUDMaskTypeClear];
    
    NSString*beg_Time = ([self.beginTime.text isEqualToString:@""])? self.beginTime.text:[self.beginTime.text stringByAppendingString:@":00"];
    NSString*end_Time = ([self.endTime.text isEqualToString:@""])? self.endTime.text:[self.endTime.text stringByAppendingString:@":00"];
    
    if ([beg_Time isEqualToString:@""]) {
        if (![end_Time isEqualToString:@""]) {
            beg_Time = end_Time;
        }else{
//            NSDateFormatter *formate = [[NSDateFormatter alloc]init];
//            [formate setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
//            beg_Time = [formate stringFromDate:[NSDate date]];
//            end_Time = beg_Time;
        }
    } else if ([end_Time isEqualToString:@""]){
        end_Time = beg_Time;
    }else{
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
        [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
        [dateFormatter setLocale:[NSLocale currentLocale]];
        NSDate* begin = [dateFormatter dateFromString:beg_Time];
        NSDate* end = [dateFormatter dateFromString:end_Time];
        NSTimeInterval begins = [begin timeIntervalSince1970];
        NSTimeInterval ends = [end timeIntervalSince1970];
        int dis = ends-begins;
        if (dis<0) {
            [CommonUtils showSimpleAlertViewWithTitle:@"提示" WithMessage:@"结束时间必须大于开始时间" WithDelegate:nil WithCancelTitle:@"确定"];
            return;
        }
    }
    
    if ([beg_Time isEqualToString:@""] && [end_Time isEqualToString:@""]) {
        [SVProgressHUD dismissWithError:@"时间不能为空"];
        return;
    }
    if ([beg_Time isEqualToString:[_eventInfo valueForKey:@"time"]] && [end_Time isEqualToString:[_eventInfo valueForKey:@"endTime"]]) {
        [SVProgressHUD dismissWithSuccess:@"修改成功"];
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:[_eventInfo valueForKey:@"event_id"] forKey:@"event_id"];
    [dictionary setValue:beg_Time forKey:@"time"];
    [dictionary setValue:end_Time forKey:@"endTime"];
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
                    [_eventInfo setValue:beg_Time forKey:@"time"];
                    [_eventInfo setValue:end_Time forKey:@"endTime"];
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

#pragma mark - UITextField Delegate
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [_confirmBtn setEnabled:NO];
    _beginTime.userInteractionEnabled = NO;
    _endTime.userInteractionEnabled = NO;
    self.flatDatePicker.title = @"请选择活动日期";
    NSDate *date;
    if (![textField.text isEqualToString:@""]) {
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm"];
        [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
        [dateFormatter setLocale:[NSLocale currentLocale]];
        MTLOG(@"#%@#",textField.text);
        date= [dateFormatter dateFromString:textField.text];
    }else date = [NSDate date];
    self.seletedText = textField;
    [self.flatDatePicker setMaximumDate:[NSDate dateWithTimeIntervalSinceNow:15768000000]];
    self.flatDatePicker.datePickerMode = FlatDatePickerModeDate;
    [self.flatDatePicker setDate:date animated:NO];
    [self.flatDatePicker show];
    return NO;
}

#pragma mark - FlatDatePicker Delegate

- (void)flatDatePicker:(FlatDatePicker*)datePicker dateDidChange:(NSDate*)date {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    
    if (datePicker.datePickerMode == FlatDatePickerModeDate) {
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSString *value = [dateFormatter stringFromDate:date];
        self.seletedText.text = value;
    } else{
        if ([self.seletedText.text isEqualToString:@""]) {
            return;
        }
        [dateFormatter setDateFormat:@" HH:mm"];
        NSString *value = [dateFormatter stringFromDate:date];
        value = [[self.seletedText.text substringToIndex:10] stringByAppendingString:value];
        self.seletedText.text = value;
    }
}

- (void)flatDatePicker:(FlatDatePicker*)datePicker didCancel:(UIButton*)sender {
    self.seletedText.text = @"";
    [_confirmBtn setEnabled:YES];
    _beginTime.userInteractionEnabled = YES;
    _endTime.userInteractionEnabled = YES;
}

- (void)flatDatePicker:(FlatDatePicker*)datePicker didValid:(UIButton*)sender date:(NSDate*)date {
    if (datePicker.datePickerMode == FlatDatePickerModeDate) {
        [datePicker setDatePickerMode:FlatDatePickerModeTime];
        [datePicker dismiss];
        [datePicker setTitle:@"请输入活动时间"];
        [datePicker show];
        return;
    } else if (datePicker.datePickerMode == FlatDatePickerModeTime) {
        //[datePicker setDatePickerMode:FlatDatePickerModeDate];
        [_confirmBtn setEnabled:YES];
        _beginTime.userInteractionEnabled = YES;
        _endTime.userInteractionEnabled = YES;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self checkTimeValid];
        });
        return;
    }
    
}

@end
