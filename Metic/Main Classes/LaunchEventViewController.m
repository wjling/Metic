//
//  LaunchEventViewController.m
//  Metic
//
//  Created by ligang6 on 14-6-3.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "LaunchEventViewController.h"
#import "MTUser.h"
#import "CommonUtils.h"

@interface LaunchEventViewController ()
@property (nonatomic,strong) UIDatePicker *datePicker;
@property (nonatomic,strong) UIView *datePickerView;
@property (nonatomic,strong) UITextField *seletedText;
@property (nonatomic,strong) MTUser *user;
@end

@implementation LaunchEventViewController

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
    self.scrollView.delegate = self;
    self.begin_time_text.delegate = self;
    self.end_time_text.delegate = self;
    self.user = [MTUser sharedInstance];
    //self.event_text.delegate = self;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    
    if (self.scrollView.contentSize.height != 650) {
        NSLog(@"%f",self.scrollView.contentSize.height);
        [self.scrollView setContentSize:CGSizeMake(320, 650)];
        NSLog(@"%f",self.scrollView.contentSize.height);
    }
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    _datePicker = [[UIDatePicker alloc]initWithFrame:CGRectMake(0,0, 320, 216)];
    [_datePicker setBackgroundColor:[UIColor whiteColor]];
    
    
    UIButton *confirm = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    confirm.frame = CGRectMake(0, 216, 320, 30);
    [confirm setBackgroundColor:[UIColor grayColor]];
    [confirm setTitle:@"确定" forState:UIControlStateNormal];
    [confirm setTitle:@"确定" forState:UIControlStateHighlighted];
    [confirm addTarget:self action:@selector(closeDatePicker) forControlEvents:UIControlEventTouchUpInside];
    self.seletedText = textField;
    _datePickerView = [[UIView alloc]initWithFrame:CGRectMake(0, 150, 320, 246)];
    [self.datePickerView addSubview:_datePicker];
    [self.datePickerView addSubview:confirm];
    //[self.datePickerView setBackgroundColor:[UIColor blueColor]];
    [self.view addSubview:self.datePickerView];
    textField.enabled = NO;
    return NO;
}

- (void)closeDatePicker
{
    NSDate *curDate = [self.datePicker date];
    NSDateFormatter *formate = [[NSDateFormatter alloc]init];
    [formate setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    
    NSString *formateDateString = [formate stringFromDate:curDate];
    NSLog(@"%@",formateDateString);
    self.seletedText.enabled = YES;
    self.seletedText.text = formateDateString;
    
    [_datePickerView removeFromSuperview ];
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

- (IBAction)launch:(id)sender {
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    int duration = 0;
    int visibility = 0;
    int status = 0;
    double longitude = 999.999999;
    double latitude = 999.999999;
    NSString *friends = @"[]";
    
    [dictionary setValue:_user.userid forKey:@"id"];
    [dictionary setValue:self.subject_text.text forKey:@"subject"];
    [dictionary setValue:self.begin_time_text.text forKey:@"time"];
    [dictionary setValue:self.end_time_text.text forKey:@"endTime"];
    [dictionary setValue:self.detail_text.text forKey:@"remark"];
    [dictionary setValue:self.location_text.text forKey:@"location"];
    [dictionary setValue:[NSNumber numberWithInt:duration] forKey:@"duration"];
    [dictionary setValue:[NSNumber numberWithDouble:longitude] forKey:@"longitude"];
    [dictionary setValue:[NSNumber numberWithDouble:latitude] forKey:@"latitude"];
    [dictionary setValue:[NSNumber numberWithInt:visibility] forKey:@"visibility"];
    [dictionary setValue:[NSNumber numberWithInt:status] forKey:@"status"];
    [dictionary setValue:friends forKey:@"friends"];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    NSLog(@"%@",[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding]);
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:LAUNCH_EVENT];
    
}


-(void)finishWithReceivedData:(NSData *)rData
{
    NSString* temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
    NSLog(@"Received Data: %@",temp);
    NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
    NSNumber *cmd = [response1 valueForKey:@"cmd"];
    NSNumber *tmpid = [response1 valueForKey:@"event_id"];
    if ([cmd intValue] != SERVER_ERROR && [tmpid intValue] != -1) {
        [CommonUtils showSimpleAlertViewWithTitle:@"信息" WithMessage:@"活动发布成功" WithDelegate:self WithCancelTitle:@"确定"];
    }else{
        [CommonUtils showSimpleAlertViewWithTitle:@"信息" WithMessage:@"活动发布失败" WithDelegate:self WithCancelTitle:@"确定"];
    }
    
}



@end
