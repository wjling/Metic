//
//  ScanViewController.m
//  Metic
//
//  Created by ligang_mac4 on 14-7-23.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "ScanViewController.h"
#import "../Utils/CommonUtils.h"
#import "../Cell/CustomCellTableViewCell.h"

@interface ScanViewController ()
@property(nonatomic,strong)NSString* result;
@property(nonatomic,strong)NSString* type;
@property(nonatomic,strong)NSNumber* efid;
@property(nonatomic,strong)NSDictionary* events;
@property BOOL isScaning;
@end

@implementation ScanViewController
@synthesize readerView;

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
    readerView.readerDelegate = self;
    _isScaning = NO;
}

-(void) viewDidAppear:(BOOL)animated
{
    [readerView.scanner setSymbology:ZBAR_I25 config:ZBAR_CFG_ENABLE to:0];
    readerView.torchMode=0;
    if (!_isScaning) {
        _isScaning = YES;
        [readerView start];
    }
    
}

-(void) viewDidDisappear:(BOOL)animated
{
    if (_isScaning) {
        _isScaning = NO;
        [readerView stop];
    }
    [_resultView setHidden:YES];
    [_showView setHidden:YES];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)back:(id)sender {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle: nil];
    UIViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"HomeViewController"];
    [[SlideNavigationController sharedInstance] switchToViewController:vc withCompletion:nil];
}

- (IBAction)wantIn:(id)sender {
    UIAlertView* confirmAlert = [[UIAlertView alloc]initWithTitle:@"Confrim Message" message:@"Please input confirm message:" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    confirmAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [confirmAlert show];

}



- (void) searchEvent: (NSNumber *)eventid
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:eventid forKey:@"event_id"];
    [dictionary setValue:[MTUser sharedInstance].userid forKey:@"id"];
    NSLog(@"%@",dictionary);
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:SEARCH_EVENT];
}

-(void)showResult
{
    NSArray *nib = [[NSBundle mainBundle]loadNibNamed:@"CustomCellTableViewCell" owner:self options:nil];
    CustomCellTableViewCell *cell = [nib objectAtIndex:0];
    [cell setFrame:CGRectMake(0, 46, 300, 250)];
    NSDictionary *a = _events;
    if ([[a valueForKey:@"isIn"] intValue] == 1){
        [_inButton setHighlighted:YES];
        [_inButton setEnabled:NO];
    }
    cell.eventName.text = [a valueForKey:@"subject"];
    NSString* beginT = [a valueForKey:@"time"];
    NSString* endT = [a valueForKey:@"endTime"];
    cell.beginDate.text = [[[beginT substringWithRange:NSMakeRange(5, 5)] stringByAppendingString:@"日"] stringByReplacingOccurrencesOfString:@"-" withString:@"月"];
    cell.beginTime.text = [beginT substringWithRange:NSMakeRange(11, 5)];
    cell.endDate.text = [[[endT substringWithRange:NSMakeRange(5, 5)] stringByAppendingString:@"日"]  stringByReplacingOccurrencesOfString:@"-" withString:@"月"];
    cell.endTime.text = [endT substringWithRange:NSMakeRange(11, 5)];
    cell.timeInfo.text = [self calculateTimeInfo:beginT endTime:endT launchTime:[a valueForKey:@"launch_time"]];
    cell.location.text = [[NSString alloc]initWithFormat:@"活动地点: %@",[a valueForKey:@"location"] ];
    int participator_count = [[a valueForKey:@"member_count"] intValue];
    cell.member_count.text = [[NSString alloc] initWithFormat:@"已有 %d 人参加",participator_count];
    cell.launcherinfo.text = [[NSString alloc]initWithFormat:@"发起人: %@",[a valueForKey:@"launcher"] ];
    cell.eventId = [a valueForKey:@"event_id"];
    cell.avatar.layer.masksToBounds = YES;
    [cell.avatar.layer setCornerRadius:15];
    
    PhotoGetter* avatarGetter = [[PhotoGetter alloc]initWithData:cell.avatar authorId:[a valueForKey:@"launcher_id"]];
    [avatarGetter getPhoto];
    
    PhotoGetter* bannerGetter = [[PhotoGetter alloc]initWithData:cell.themePhoto authorId:[a valueForKey:@"event_id"]];
    [bannerGetter getBanner:[a valueForKey:@"code"]];
    
    //cell.homeController = self.homeController;
    
    NSArray *memberids = [a valueForKey:@"member"];
    
    for (int i =3; i>=0; i--) {
        UIImageView *tmp = ((UIImageView*)[((UIView*)[cell viewWithTag:103]) viewWithTag:i+1]);
        tmp.layer.masksToBounds = YES;
        [tmp.layer setCornerRadius:5];
        if (i < participator_count) {
            PhotoGetter* miniGetter = [[PhotoGetter alloc]initWithData:tmp authorId:memberids[i]];
            [miniGetter getPhoto];
        }else tmp.image = nil;
        
    }
    [_resultView addSubview:cell];
    [_resultView setHidden:NO];
    
}

-(void)resultAnalysis
{
    NSString* validInfo = [_result substringFromIndex:24];
    NSRange range = [validInfo rangeOfString:@"/"];
    NSString* type = [validInfo substringToIndex:range.location];
    _type = type;
    NSString* ID_STRING = [validInfo substringFromIndex:range.location+1];
    NSString* text = [CommonUtils stringByReversed:[ID_STRING substringToIndex:ID_STRING.length-3]];
    text = [text stringByAppendingString:[ID_STRING substringWithRange:NSMakeRange(ID_STRING.length-3, 3)]];
    text = [CommonUtils TextFrombase64String:text];
    text = [text substringFromIndex:5];
    _efid = [CommonUtils NSNumberWithNSString:text];
    if ([type isEqualToString:@"event"]) {
        [self searchEvent:_efid];
    }
}

-(NSString*)calculateTimeInfo:(NSString*)beginTime endTime:(NSString*)endTime launchTime:(NSString*)launchTime
{
    NSString* timeInfo = @"";
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    NSDate* begin = [dateFormatter dateFromString:beginTime];
    NSDate* end = [dateFormatter dateFromString:endTime];
    NSTimeInterval begins = [begin timeIntervalSince1970];
    NSTimeInterval ends = [end timeIntervalSince1970];
    NSString* launchInfo = [NSString stringWithFormat:@"创建于 %@日",[[launchTime substringWithRange:NSMakeRange(5, 5)] stringByReplacingOccurrencesOfString:@"-" withString:@"月"]];
    int dis = ends-begins;
    if (dis > 0) {
        NSString* duration = @"";
        if (dis >= 31536000) {
            duration = [NSString stringWithFormat:@"%d年",dis/31536000];
        }else if (dis >= 2592000) {
            duration = [NSString stringWithFormat:@"%d月",dis/2592000];
        }else if (dis >= 86400) {
            duration = [NSString stringWithFormat:@"%d日",dis/86400];
        }else if (dis >= 3600) {
            duration = [NSString stringWithFormat:@"%d小时",dis/3600];
        }else if (dis >= 60) {
            duration = [NSString stringWithFormat:@"%d分钟",dis/60];
        }else{
            duration = [NSString stringWithFormat:@"%d秒",dis];
        }
        
        timeInfo = [NSString stringWithFormat:@"活动持续时间：%@",duration];
        while (timeInfo.length < 15) {
            timeInfo = [timeInfo stringByAppendingString:@" "];
        }
        timeInfo = [timeInfo stringByAppendingString:launchInfo];
    }else timeInfo = launchInfo;
    return timeInfo;
}

-(void)dismissAlertView:(UIAlertView*) alertView
{
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
    
}
#pragma mark - HttpSender Delegate -
-(void)finishWithReceivedData:(NSData *)rData
{
    NSString* temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
    rData = [temp dataUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"received Data: %@",temp);
    NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
    NSNumber *cmd = [response1 valueForKey:@"cmd"];
    
    switch ([cmd intValue]) {
        case NORMAL_REPLY:
        {
            if ([response1 valueForKey:@"isIn"]) {
                self.events = response1;
                [self showResult];
            }else{
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"系统消息" message:@"请等待发起人验证" delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
                [alert show];
                [self performSelector:@selector(dismissAlertView:) withObject:alert afterDelay:1.5];
                [self performSelector:@selector(back:) withObject:alert afterDelay:2.0];
            }
            
        }
        break;
    }
}
#pragma mark - ZBarReaderView Delegate -
-(void)readerView:(ZBarReaderView *)readerView didReadSymbols:(ZBarSymbolSet *)symbols fromImage:(UIImage *)image
{
    for(ZBarSymbol *sym in symbols) {
        _result = sym.data;
        break;
    }
    if (_isScaning) {
        _isScaning = NO;
        [readerView stop];
    }
    [_showView setHidden:NO];
    [self resultAnalysis];
    
}


#pragma mark - SlideNavigationController Methods -

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
	return YES;
}

- (BOOL)slideNavigationControllerShouldDisplayRightMenu
{
	return NO;
}
-(void)sendDistance:(float)distance
{
//    if (distance>20) {
//        if (_isScaning) {
//            _isScaning = NO;
//            [readerView stop];
//        }
//    }else{
//        if (!_isScaning) {
//            _isScaning = YES;
//            [readerView start];
//        }
//    }

    if (distance > 0) {
        _shadowView.hidden = NO;
        [self.view bringSubviewToFront:self.shadowView];
        [self.shadowView setAlpha:distance/400.0];
    }else{
        //self.shadowView.hidden = YES;
        //[self.view sendSubviewToBack:self.shadowView];
    }
}


#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case 0:{
            NSInteger cancelBtnIndex = alertView.cancelButtonIndex;
            NSInteger okBtnIndex = alertView.firstOtherButtonIndex;
            if (buttonIndex == cancelBtnIndex) {
                ;
            }
            else if (buttonIndex == okBtnIndex)
            {
                NSString* cm = [alertView textFieldAtIndex:0].text;

                NSDictionary* dictionary = [CommonUtils packParamsInDictionary:[NSNumber numberWithInt:995],@"cmd",[MTUser sharedInstance].userid,@"id",cm,@"confirm_msg", _efid,@"event_id",nil];
                NSLog(@"%@",dictionary);
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
                HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
                [httpSender sendMessage:jsonData withOperationCode:PARTICIPATE_EVENT];

            }
        }
            break;
            
        default:
            break;
    }
}

@end
