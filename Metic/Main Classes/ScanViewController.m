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
#import "../Cell/UserTableViewCell.h"

@interface ScanViewController ()
@property(nonatomic,strong)NSString* result;
@property(nonatomic,strong)NSString* type;
@property(nonatomic,strong)NSNumber* efid;
@property(nonatomic,strong)NSDictionary* events;
@property(nonatomic,strong)NSDictionary* friend;
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
    readerView = [[ZBarReaderView alloc]init];
    readerView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [self.view addSubview:readerView];
    [self.view sendSubviewToBack:readerView];
    [CommonUtils addLeftButton:self isFirstPage:!_needPopBack];
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

-(void) viewWillDisappear:(BOOL)animated
{
    if (_isScaning) {
        _isScaning = NO;
        [readerView stop];
    }
    [_resultView setHidden:YES];
    [_controlView setHidden:YES];
    [_showView setHidden:YES];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//返回上一层
-(void)MTpopViewController{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)back:(id)sender {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle: nil];
    UIViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"HomeViewController"];
    [[SlideNavigationController sharedInstance] switchToViewController:vc withCompletion:nil];
}

- (IBAction)wantIn:(id)sender {
    if ([_type isEqualToString: @"event"]) {
        UIAlertView* confirmAlert = [[UIAlertView alloc]initWithTitle:@"系统消息" message:@"请输入验证信息：" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
        confirmAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
        [confirmAlert show];
    }else if ([_type isEqualToString: @"user"]){
        //添加好友
    }

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

- (void) searchUser: (NSNumber *)userid
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:userid forKey:@"friendId"];
    [dictionary setValue:[MTUser sharedInstance].userid forKey:@"myId"];
    NSLog(@"%@",dictionary);
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:SEARCH_FRIEND];
}

-(void)showResult
{
    
    if ([_type isEqualToString: @"event"]) {
        NSArray *nib = [[NSBundle mainBundle]loadNibNamed:@"CustomCellTableViewCell" owner:self options:nil];
        [[_resultView viewWithTag:151] removeFromSuperview];
        [[_resultView viewWithTag:152] removeFromSuperview];
        CustomCellTableViewCell *cell = [nib objectAtIndex:0];
        [cell setTag:151];
        [cell setFrame:CGRectMake(0, 46, 300, 250)];
        NSDictionary *a = _events;
        if ([[a valueForKey:@"isIn"] intValue] == 1){
            [_inButton setTitle:@"已加入" forState:UIControlStateNormal];
            [_inButton setHighlighted:YES];
            [_inButton setEnabled:NO];
        }else{
            [_inButton setTitle:@"加入活动" forState:UIControlStateNormal];
            [_inButton setHighlighted:NO];
            [_inButton setEnabled:YES];
        }
        cell.eventName.text = [a valueForKey:@"subject"];
        NSString* beginT = [a valueForKey:@"time"];
        NSString* endT = [a valueForKey:@"endTime"];
        cell.beginDate.text = [[[beginT substringWithRange:NSMakeRange(5, 5)] stringByAppendingString:@"日"] stringByReplacingOccurrencesOfString:@"-" withString:@"月"];
        cell.beginTime.text = [beginT substringWithRange:NSMakeRange(11, 5)];
        cell.endDate.text = [[[endT substringWithRange:NSMakeRange(5, 5)] stringByAppendingString:@"日"]  stringByReplacingOccurrencesOfString:@"-" withString:@"月"];
        cell.endTime.text = [endT substringWithRange:NSMakeRange(11, 5)];
        cell.timeInfo.text = [CommonUtils calculateTimeInfo:beginT endTime:endT launchTime:[a valueForKey:@"launch_time"]];
        cell.location.text = [[NSString alloc]initWithFormat:@"活动地点: %@",[a valueForKey:@"location"] ];
        int participator_count = [[a valueForKey:@"member_count"] intValue];
        cell.member_count.text = [[NSString alloc] initWithFormat:@"已有 %d 人参加",participator_count];
        //显示备注名
        NSString* alias = [[MTUser sharedInstance].alias_dic objectForKey:[NSString stringWithFormat:@"%@",[a valueForKey:@"launcher_id"]]];
        if (alias == nil || [alias isEqual:[NSNull null]]) {
            alias = [a valueForKey:@"launcher"];
        }
        cell.launcherinfo.text = [[NSString alloc]initWithFormat:@"发起人: %@",alias];
        cell.eventId = [a valueForKey:@"event_id"];
        cell.avatar.layer.masksToBounds = YES;
        [cell.avatar.layer setCornerRadius:15];
        
        PhotoGetter* avatarGetter = [[PhotoGetter alloc]initWithData:cell.avatar authorId:[a valueForKey:@"launcher_id"]];
        [avatarGetter getAvatar];
        
        PhotoGetter* bannerGetter = [[PhotoGetter alloc]initWithData:cell.themePhoto authorId:[a valueForKey:@"event_id"]];
        NSString* bannerURL = [a valueForKey:@"banner"];
        [bannerGetter getBanner:[a valueForKey:@"code"] url:bannerURL];
        
        //cell.homeController = self.homeController;
        
        NSArray *memberids = [a valueForKey:@"member"];
        
        for (int i =3; i>=0; i--) {
            UIImageView *tmp = ((UIImageView*)[((UIView*)[cell viewWithTag:103]) viewWithTag:i+1]);
            tmp.layer.masksToBounds = YES;
            [tmp.layer setCornerRadius:5];
            if (i < participator_count) {
                PhotoGetter* miniGetter = [[PhotoGetter alloc]initWithData:tmp authorId:memberids[i]];
                [miniGetter getAvatar];
            }else tmp.image = nil;
            
        }
        CGRect frame = _resultView.frame;
        frame.origin.y = 30;
        frame.size.height = 292;
        [_resultView setFrame:frame];
        [_resultView addSubview:cell];
        [_resultView setHidden:NO];
        [_controlView setHidden:NO];
    }else if([_type isEqualToString: @"user"])
    {
        NSArray *nib = [[NSBundle mainBundle]loadNibNamed:@"UserTableViewCell" owner:self options:nil];
        [[_resultView viewWithTag:151] removeFromSuperview];
        [[_resultView viewWithTag:152] removeFromSuperview];
        UserTableViewCell *cell = [nib objectAtIndex:0];
        [cell setTag:152];
        [cell setFrame:CGRectMake(0, 50, 300, 160)];
        NSDictionary *a = _friend;
        if ([[a valueForKey:@"isFriend"] boolValue] == YES){
            [_inButton setTitle:@"已是好友" forState:UIControlStateNormal];
            [_inButton setHighlighted:YES];
            [_inButton setEnabled:NO];
        }else{
            [_inButton setTitle:@"加为好友" forState:UIControlStateNormal];
            [_inButton setHighlighted:NO];
            [_inButton setEnabled:YES];
        }
        //显示备注名
        NSString* alias = [[MTUser sharedInstance].alias_dic objectForKey:[NSString stringWithFormat:@"%@",[a valueForKey:@"id"]]];
        if (alias == nil || [alias isEqual:[NSNull null]]) {
            alias = [a valueForKey:@"name"];
        }

        cell.name.text = alias;
        cell.signature.text = ([[a valueForKey:@"sign"] isEqual:[NSNull null]])?@"":[a valueForKey:@"sign"];
        cell.location.text = ([[a valueForKey:@"location"] isEqual:[NSNull null]])?@"":[a valueForKey:@"location"];
        cell.genderImg.image = ([[a valueForKey:@"gender"] intValue] == 1)? [UIImage imageNamed:@"男icon"]:[UIImage imageNamed:@"女icon"];
        PhotoGetter* avatarGetter = [[PhotoGetter alloc]initWithData:cell.avatar authorId:[a valueForKey:@"id"]];
        [avatarGetter getAvatar];
        [_resultView addSubview:cell];
        CGRect frame = _resultView.frame;
        frame.origin.y = 120;
        frame.size.height = 172;
        
        [_resultView setFrame:frame];
        [_resultView setHidden:NO];
        [_controlView setHidden:NO];
    }
    
    
}

-(void)resultAnalysis
{
    if (_result.length < 24 || ![[_result substringToIndex:24] isEqualToString:@"http://www.whatsact.com/"]) {
        UIAlertView* alertView = [CommonUtils showSimpleAlertViewWithTitle:@"系统消息" WithMessage:@"请扫描由活动宝网站或活动宝App提供的二维码" WithDelegate:self WithCancelTitle:@"确定"];
        [alertView setTag:10];
        return;
    }
    NSString* validInfo = [_result substringFromIndex:24];
    NSRange range = [validInfo rangeOfString:@"/"];
    if (range.location >= validInfo.length) {
        UIAlertView* alertView = [CommonUtils showSimpleAlertViewWithTitle:@"系统消息" WithMessage:@"请扫描由活动宝网站或活动宝App提供的二维码" WithDelegate:self WithCancelTitle:@"确定"];
        [alertView setTag:10];
        return;
    }
    NSString* type = [validInfo substringToIndex:range.location];
    _type = type;
    if (![type isEqualToString:@"event"] && ![type isEqualToString:@"user"]) {
        UIAlertView* alertView = [CommonUtils showSimpleAlertViewWithTitle:@"系统消息" WithMessage:@"请扫描由活动宝网站或活动宝App提供的二维码" WithDelegate:self WithCancelTitle:@"确定"];
        [alertView setTag:10];
    }
    NSString* ID_STRING = [validInfo substringFromIndex:range.location+1];
    if (ID_STRING.length <= 3) {
        UIAlertView* alertView = [CommonUtils showSimpleAlertViewWithTitle:@"系统消息" WithMessage:@"请扫描由活动宝网站或活动宝App提供的二维码" WithDelegate:self WithCancelTitle:@"确定"];
        [alertView setTag:10];
        return;
    }
    NSString* text = [CommonUtils stringByReversed:[ID_STRING substringToIndex:ID_STRING.length-3]];
    text = [text stringByAppendingString:[ID_STRING substringWithRange:NSMakeRange(ID_STRING.length-3, 3)]];
    text = [CommonUtils TextFrombase64String:text];
    text = [text substringFromIndex:5];
    _efid = [CommonUtils NSNumberWithNSString:text];
    if ([type isEqualToString:@"event"]) {
        [self searchEvent:_efid];
    }else if ([type isEqualToString:@"user"]){
        [self searchUser:_efid];
    }else {
        UIAlertView* alertView = [CommonUtils showSimpleAlertViewWithTitle:@"系统消息" WithMessage:@"请扫描由活动宝网站或活动宝App提供的二维码" WithDelegate:self WithCancelTitle:@"确定"];
        [alertView setTag:10];
    }
}

-(void)dismissAlertView:(UIAlertView*) alertView
{
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
    
}
#pragma mark - HttpSender Delegate -
-(void)finishWithReceivedData:(NSData *)rData
{
    NSString* temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
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
        case USER_EXIST:
        {
            NSArray *friends = [response1 valueForKey:@"friend_list"];
            if (friends.count > 0) {
                self.friend = friends[0];
                [self showResult];
            }else{
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"系统消息" message:@"用户不存在" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alert setTag:10];
                [alert show];
                
            }
            
            
        }
            break;
        case USER_NOT_FOUND:
        {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"系统消息" message:@"用户不存在" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert setTag:10];
            [alert show];
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
	return !_needPopBack;
}

- (BOOL)slideNavigationControllerShouldDisplayRightMenu
{
	return NO;
}
-(void)sendDistance:(float)distance
{

    if (distance > 0) {
        _shadowView.hidden = NO;
        [self.view bringSubviewToFront:self.shadowView];
        [self.shadowView setAlpha:distance/400.0];
        self.navigationController.navigationBar.alpha = 1 - distance/400.0;
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
        case 10:{
            [_showView setHidden:YES];
            [readerView start];
            _isScaning = YES;
        }
            break;
            
        default:
            break;
    }
}

@end
