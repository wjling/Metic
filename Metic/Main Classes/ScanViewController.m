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
#import "SVProgressHUD.h"
#import "EventDetailViewController.h"
#import "MegUtils.h"

@interface ScanViewController ()
@property(nonatomic,strong)NSString* result;
@property(nonatomic,strong)NSString* type;
@property(nonatomic,strong)NSNumber* efid;
@property(nonatomic,strong)NSDictionary* events;
@property(nonatomic,strong)NSDictionary* friend;
@property (nonatomic, strong) UIImageView * line;
@property (nonatomic, strong) NSTimer * timer;
@property NSInteger operationNum;
@property BOOL upOrdown;
@property BOOL isScaning;
@property BOOL need_auth;
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
    [self initUI];
    _need_auth = YES;
    _operationNum = 0;
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
    [super viewDidAppear:animated];
    [readerView.scanner setSymbology:ZBAR_I25 config:ZBAR_CFG_ENABLE to:0];
    readerView.torchMode=0;
    
    if (!_isScaning) {
        _isScaning = YES;
        [readerView start];
    }
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:.02 target:self selector:@selector(animation) userInfo:nil repeats:YES];
    }
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (_isScaning) {
        _isScaning = NO;
        [readerView stop];
    }
    [_resultView setHidden:YES];
    [_controlView setHidden:YES];
    [_showView setHidden:YES];
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}

//返回上一层
-(void)MTpopViewController{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)back:(id)sender {
    
    [_resultView setHidden:YES];
    [_controlView setHidden:YES];
    [_showView setHidden:YES];
    [readerView start];
    _isScaning = YES;
    
    
    
    return;
    UIViewController *vc = _menu.homeViewController;
    if (vc) {
        [[SlideNavigationController sharedInstance] switchToViewController:vc withCompletion:nil];
    }else{
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle: nil];
        UIViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"HomeViewController"];
        _menu.homeViewController = vc;
        [[SlideNavigationController sharedInstance] switchToViewController:vc withCompletion:nil];
    }
    
}

- (void) initUI
{
    float stdH = (self.view.bounds.size.height - 64)/2 - 108;
    float wid = self.view.bounds.size.width;
    NSLog(@"作图起始高度：%f",stdH);
    
    UIView* up = [[UIView alloc]initWithFrame:CGRectMake(0, 0, wid, stdH)];
    up.backgroundColor =[UIColor blackColor];
    up.alpha = 0.7;
    [_GUI addSubview:up];
    
    UIView* left = [[UIView alloc]initWithFrame:CGRectMake(0, stdH, 47, 216)];
    left.backgroundColor =[UIColor blackColor];
    left.alpha = 0.7;
    [_GUI addSubview:left];
    
    UIView* right = [[UIView alloc]initWithFrame:CGRectMake(wid -47, stdH, 47, 216)];
    right.backgroundColor =[UIColor blackColor];
    right.alpha = 0.7;
    [_GUI addSubview:right];
    
    UIView* down = [[UIView alloc]initWithFrame:CGRectMake(0, stdH + 216, wid, stdH)];
    down.backgroundColor =[UIColor blackColor];
    down.alpha = 0.7;
    [_GUI addSubview:down];
    
    UILabel *label1 = [[UILabel alloc]initWithFrame:CGRectMake(60, 10, 200, 21)];
    label1.text = @"请将取景器对准";
    label1.textAlignment = NSTextAlignmentCenter;
    label1.textColor = [UIColor colorWithWhite:232.0/255.0 alpha:1.0f];
    label1.font = [UIFont systemFontOfSize:14];
    [down addSubview:label1];
    
    UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake(40, 30, 240, 21)];
    label2.text = @"活动宝网站或活动宝App提供的二维码";
    label2.textAlignment = NSTextAlignmentCenter;
    label2.textColor = [UIColor colorWithWhite:232.0/255.0 alpha:1.0f];
    label2.font = [UIFont systemFontOfSize:14];
    [down addSubview:label2];
    
    
    
    
    
    UIView* leftup = [[UIView alloc]initWithFrame:CGRectMake(47 - 2, stdH - 2, 3, 30)];
    leftup.backgroundColor =[UIColor colorWithRed:85.0/255.0 green:203.0/255.0 blue:171.0/255.0 alpha:1.0f];;
    [_GUI addSubview:leftup];
    
    UIView* leftdown = [[UIView alloc]initWithFrame:CGRectMake(47 - 2, stdH + 216 - 30 + 2, 3, 30)];
    leftdown.backgroundColor =[UIColor colorWithRed:85.0/255.0 green:203.0/255.0 blue:171.0/255.0 alpha:1.0f];;
    [_GUI addSubview:leftdown];
    
    UIView* rightup = [[UIView alloc]initWithFrame:CGRectMake(wid - 47 -1, stdH - 2, 3, 30)];
    rightup.backgroundColor =[UIColor colorWithRed:85.0/255.0 green:203.0/255.0 blue:171.0/255.0 alpha:1.0f];;
    [_GUI addSubview:rightup];
    
    UIView* rightdown = [[UIView alloc]initWithFrame:CGRectMake(wid - 47 -1, stdH + 216 - 30 + 2, 3, 30)];
    rightdown.backgroundColor =[UIColor colorWithRed:85.0/255.0 green:203.0/255.0 blue:171.0/255.0 alpha:1.0f];;
    [_GUI addSubview:rightdown];
    
    UIView* upleft = [[UIView alloc]initWithFrame:CGRectMake(47 - 2, stdH - 2, 30, 3)];
    upleft.backgroundColor =[UIColor colorWithRed:85.0/255.0 green:203.0/255.0 blue:171.0/255.0 alpha:1.0f];;
    [_GUI addSubview:upleft];
    
    UIView* upright = [[UIView alloc]initWithFrame:CGRectMake(wid - 47 -30 + 2, stdH - 2, 30, 3)];
    upright.backgroundColor =[UIColor colorWithRed:85.0/255.0 green:203.0/255.0 blue:171.0/255.0 alpha:1.0f];;
    [_GUI addSubview:upright];
    
    UIView* downleft = [[UIView alloc]initWithFrame:CGRectMake(47 - 2, stdH + 216 - 1, 30, 3)];
    downleft.backgroundColor =[UIColor colorWithRed:85.0/255.0 green:203.0/255.0 blue:171.0/255.0 alpha:1.0f];;
    [_GUI addSubview:downleft];
    
    UIView* downright = [[UIView alloc]initWithFrame:CGRectMake(wid - 47 - 30 + 2, stdH + 216 - 1, 30, 3)];
    downright.backgroundColor =[UIColor colorWithRed:85.0/255.0 green:203.0/255.0 blue:171.0/255.0 alpha:1.0f];;
    [_GUI addSubview:downright];
    
    
    
    
    _line = [[UIImageView alloc] initWithFrame:CGRectMake(57, stdH + 10, 206, 2)];
    _line.image = [UIImage imageNamed:@"line.png"];
    [_GUI addSubview:_line];
    //定时器，设定时间过1.5秒，
    _upOrdown = YES;
    _timer = [NSTimer scheduledTimerWithTimeInterval:.02 target:self selector:@selector(animation) userInfo:nil repeats:YES];
}

- (IBAction)wantIn:(id)sender {
    if ([_type isEqualToString: @"event"]) {
        if (_need_auth) {
            UIAlertView* confirmAlert = [[UIAlertView alloc]initWithTitle:@"系统消息" message:@"请输入申请加入信息：" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
            confirmAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
            if ([MTUser sharedInstance].name && ![[MTUser sharedInstance].name isEqual:[NSNull null]]) {
                [confirmAlert textFieldAtIndex:0].text = [NSString stringWithFormat:@"我是%@",[MTUser sharedInstance].name];
            }
            [confirmAlert show];
        }else{
            [SVProgressHUD showWithStatus:@"处理中" maskType:SVProgressHUDMaskTypeClear];
            NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
            [dictionary setValue:_efid forKey:@"event_id"];
            [dictionary setValue:@0 forKey:@"type"];
            [dictionary setValue:_result forKey:@"qrcode"];
            [dictionary setValue:[MTUser sharedInstance].userid forKey:@"id"];
            NSLog(@"%@",dictionary);
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
            HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
            NSInteger operNum = ++_operationNum;
            [httpSender sendMessage:jsonData withOperationCode:QRCODE_INVITE finshedBlock:^(NSData *rData) {
                if (operNum != _operationNum) return ;
                if (rData) {
                    NSString* temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
                    NSLog(@"received Data: %@",temp);
                    NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
                    NSNumber *cmd = [response1 valueForKey:@"cmd"];
                    switch ([cmd intValue]) {
                        case NORMAL_REPLY:
                        {
                            NSLog(@"NORMAL_REPLY");
                            [SVProgressHUD dismissWithSuccess:@"成功加入活动"];
                            //更新活动中心列表：
                            [[NSNotificationCenter defaultCenter]postNotificationName:@"reloadEvent" object:nil userInfo:nil];
                            [_showView setHidden:YES];
//                            [readerView start];
//                            _isScaning = YES;
                            
                            [self toEventDetail:_efid];
                            
                        }
                            break;
                        case EVENT_NOT_EXIST:
                        {
                            NSLog(@"EVENT_NOT_EXIST");
                            [SVProgressHUD dismissWithError:@"活动不存在，加入失败"];
                            [_showView setHidden:YES];
                            [readerView start];
                            _isScaning = YES;
                        }
                            break;
                        case ALREADY_IN_EVENT:
                        {
                            NSLog(@"ALREADY_IN_EVENT");
                            [SVProgressHUD dismissWithError:@"你已在活动中"];
                            [self toEventDetail:_efid];
                            [_showView setHidden:YES];
//                            [readerView start];
//                            _isScaning = YES;
                        }
                            break;
                        default:
                        {
                            NSLog(@"error");
                            NSLog(@"ALREADY_IN_EVENT");
                            [SVProgressHUD dismissWithError:@"服务器异常"];
                            [_showView setHidden:YES];
                            [readerView start];
                            _isScaning = YES;
                        }
                    }
                }else{
                    [SVProgressHUD dismissWithError:@"网络异常"];
                    [_showView setHidden:YES];
                    [readerView start];
                    _isScaning = YES;
                }
            }];
        }
        
    }else if ([_type isEqualToString: @"user"]){
        UIAlertView* confirmAlert = [[UIAlertView alloc]initWithTitle:@"系统消息" message:@"请输入验证信息：" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
        confirmAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
        if ([MTUser sharedInstance].name && ![[MTUser sharedInstance].name isEqual:[NSNull null]]) {
            [confirmAlert textFieldAtIndex:0].text = [NSString stringWithFormat:@"我是%@",[MTUser sharedInstance].name];
        }
        [confirmAlert show];
    }

}

- (void)toEventDetail:(NSNumber*)eventId
{
    if (!eventId) return;
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle: nil];
    
    EventDetailViewController* eventDetail = [mainStoryboard instantiateViewControllerWithIdentifier: @"EventDetailViewController"];
    eventDetail.eventId = eventId;
    eventDetail.isFromQRCode = YES;
    [self.navigationController pushViewController:eventDetail animated:YES];
}

- (IBAction)scanLocalPhoto:(id)sender {
    
    [_resultView setHidden:YES];
    [_controlView setHidden:YES];
    [_showView setHidden:YES];
    [readerView stop];
    _isScaning = NO;
    
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.allowsEditing = NO;
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        imagePickerController.sourceType =UIImagePickerControllerSourceTypePhotoLibrary;
    }else imagePickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"shouldIgnoreTurnToNotifiPage"];
    [self presentViewController:imagePickerController animated:YES completion:^{}];
}



- (void) searchEvent: (NSNumber *)eventid
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:eventid forKey:@"event_id"];
    [dictionary setValue:[MTUser sharedInstance].userid forKey:@"id"];
    NSLog(@"%@",dictionary);
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    NSInteger operNum = ++_operationNum;
    [httpSender sendMessage:jsonData withOperationCode:SEARCH_EVENT finshedBlock:^(NSData *rData) {
        if (operNum != _operationNum) return ;
        if (rData) {
            [self finishWithReceivedData:rData];
        }else{
            [SVProgressHUD dismissWithError:@"网络异常"];
            [_showView setHidden:YES];
            [readerView start];
            _isScaning = YES;
        }
    }];
}

- (void) searchUser: (NSNumber *)userid
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:userid forKey:@"friendId"];
    [dictionary setValue:[MTUser sharedInstance].userid forKey:@"myId"];
    NSLog(@"%@",dictionary);
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    NSInteger operNum = ++_operationNum;
    [httpSender sendMessage:jsonData withOperationCode:SEARCH_FRIEND finshedBlock:^(NSData *rData) {
        if (operNum != _operationNum) return ;
        if (rData) {
            [self finishWithReceivedData:rData];
        }else{
            [SVProgressHUD dismissWithError:@"网络异常"];
            [_showView setHidden:YES];
            [readerView start];
            _isScaning = YES;
        }
    }];
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
        if (alias == nil || [alias isEqual:[NSNull null]] || [alias isEqualToString:@""]) {
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
        NSString* bannerPath = [MegUtils bannerImagePathWithEventId:[a valueForKey:@"event_id"]];
        [bannerGetter getBanner:[a valueForKey:@"code"] url:bannerURL path:bannerPath];
        
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
        frame.origin.y = (self.view.frame.size.height - 292 - _controlView.frame.size.height)/2;
        frame.size.height = 292;
        [_resultView setFrame:frame];
        [_resultView addSubview:cell];
        [_resultView setHidden:NO];
        frame = _controlView.frame;
        frame.origin.y = CGRectGetMaxY(_resultView.frame);
        _controlView.frame = frame;
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
        if (alias == nil || [alias isEqual:[NSNull null]] || [alias isEqualToString:@""]) {
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
        frame.size.height = 210;
        frame.origin.y = (self.view.frame.size.height - 210 - _controlView.frame.size.height)/2;
        [_resultView setFrame:frame];
        [_resultView setHidden:NO];
        frame = _controlView.frame;
        frame.origin.y = CGRectGetMaxY(_resultView.frame);;
        _controlView.frame = frame;
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


-(void)animation
{
    float stdH = (self.view.bounds.size.height)/2 - 108;
    CGRect frame = _line.frame;
    if (_upOrdown && CGRectGetMaxY(frame) + 2 > stdH + 216 - 10 ) {
        _upOrdown = NO;
    }else if(!_upOrdown && CGRectGetMinY(frame) - 2 < stdH + 10){
        _upOrdown = YES;
    }
    if (_upOrdown == YES) {
        frame.origin.y += 2.0f;
        [_line setFrame:frame];
    }
    else {
        frame.origin.y -= 2.0f;
        [_line setFrame:frame];
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
                _need_auth = YES;
                if ([response1 valueForKey:@"qr_needauth"]) {
                    _need_auth = [[response1 valueForKey:@"qr_needauth"] boolValue];
                }
                self.events = response1;
                [self showResult];
                if ([[response1 valueForKey:@"isIn"] boolValue]) {
                    [SVProgressHUD showErrorWithStatus:@"你已在活动中" duration:1];
                    [self toEventDetail:_efid];
                    [_showView setHidden:YES];
//                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                        
//                        [readerView start];
//                        _isScaning = YES;
//                    });
                    
                }else if (!_need_auth) {
                    [self wantIn:nil];
                }
                
            
            }else{
                NSString* mesg;
                if ([_type isEqualToString: @"event"]) {
                    mesg = @"请等待发起人验证";
                }else if ([_type isEqualToString: @"user"]){
                    mesg = @"添加好友请求已发送";
                }
                
                [SVProgressHUD dismissWithSuccess:mesg];
                [_showView setHidden:YES];
                [readerView start];
                _isScaning = YES;
                

            }
            
        }
            break;
        case EVENT_NOT_EXIST:
        {
            NSLog(@"EVENT_NOT_EXIST");
            UIAlertView* alert =
            [CommonUtils showSimpleAlertViewWithTitle:@"系统消息" WithMessage:@"此活动已经解散" WithDelegate:self WithCancelTitle:@"确定"];
            alert.tag = 10;
        }
            break;
        case USER_EXIST:
        {
            NSArray *friends = [response1 valueForKey:@"friend_list"];
            if (friends.count > 0) {
                self.friend = friends[0];
                [self showResult];
            }else{
                NSLog(@"ALREADY_IN_EVENT");
                UIAlertView* alert =
                [CommonUtils showSimpleAlertViewWithTitle:@"系统消息" WithMessage:@"用户不存在" WithDelegate:self WithCancelTitle:@"确定"];
                alert.tag = 10;
            }
        }
            break;
        case USER_NOT_FOUND:
        {
            UIAlertView* alert =
            [CommonUtils showSimpleAlertViewWithTitle:@"系统消息" WithMessage:@"用户不存在" WithDelegate:self WithCancelTitle:@"确定"];
            alert.tag = 10;
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
            if ([_type isEqualToString: @"event"]) {
                NSInteger cancelBtnIndex = alertView.cancelButtonIndex;
                NSInteger okBtnIndex = alertView.firstOtherButtonIndex;
                if (buttonIndex == cancelBtnIndex) {
                    ;
                }
                else if (buttonIndex == okBtnIndex)
                {
                    [SVProgressHUD showWithStatus:@"处理中" maskType:SVProgressHUDMaskTypeClear];
                    NSString* cm = [alertView textFieldAtIndex:0].text;
                    
                    NSDictionary* dictionary = [CommonUtils packParamsInDictionary:[NSNumber numberWithInt:REQUEST_EVENT],@"cmd",[MTUser sharedInstance].userid,@"id",cm,@"confirm_msg", _efid,@"event_id",nil];
                    NSLog(@"%@",dictionary);
                    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
                    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
                    NSInteger operNum = ++_operationNum;
                    [httpSender sendMessage:jsonData withOperationCode:PARTICIPATE_EVENT finshedBlock:^(NSData *rData) {
                        if (operNum != _operationNum) return ;
                        if (rData) {
                            [self finishWithReceivedData:rData];
                        }else{
                            [SVProgressHUD dismissWithError:@"网络异常"];
                            [_showView setHidden:YES];
                            [readerView start];
                            _isScaning = YES;
                        }
                    }];
                    
                }
            }else if ([_type isEqualToString: @"user"]){
                NSInteger cancelBtnIndex = alertView.cancelButtonIndex;
                NSInteger okBtnIndex = alertView.firstOtherButtonIndex;
                if (buttonIndex == cancelBtnIndex) {
                    ;
                }
                else if (buttonIndex == okBtnIndex)
                {
                    NSString* cm = [alertView textFieldAtIndex:0].text;
                    NSNumber* userId = [MTUser sharedInstance].userid;
                    NSNumber* friendId = self.efid;
                    NSDictionary* json = [CommonUtils packParamsInDictionary:[NSNumber numberWithInt:ADD_FRIEND_NOTIFICATION],@"cmd",userId,@"id",cm,@"confirm_msg", friendId,@"friend_id",[NSNumber numberWithInt:ADD_FRIEND],@"item_id",nil];
                    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:nil];
                    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
                    NSInteger operNum = ++_operationNum;
                    [httpSender sendMessage:jsonData withOperationCode:ADD_FRIEND finshedBlock:^(NSData *rData) {
                        if (operNum != _operationNum) return ;
                        if (rData) {
                            [self finishWithReceivedData:rData];
                        }else {
                            NSLog(@"ALREADY_IN_EVENT");
                            [SVProgressHUD dismissWithError:@"网络异常"];
                            [_showView setHidden:YES];
                            [readerView start];
                            _isScaning = YES;
                        }
                    }];
                    NSLog(@"add friend apply: %@",json);
                    
                }
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

#pragma mark - UIImagePickerControllerDelegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage* img = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    ZBarReaderController* reader = [[ZBarReaderController alloc]init];
    ZBarSymbol *symbol = nil;
    for (symbol in [reader scanImage:img.CGImage]) break;
    
    [picker dismissViewControllerAnimated:YES completion:^{
        if (symbol) {
            _result = symbol.data;
            if (_isScaning) {
                _isScaning = NO;
                [readerView stop];
            }
            [_showView setHidden:NO];
            [self resultAnalysis];
        }else{
            UIAlertView* alertView = [CommonUtils showSimpleAlertViewWithTitle:@"系统消息" WithMessage:@"未识别到二维码" WithDelegate:self WithCancelTitle:@"确定"];
            [alertView setTag:10];
        }
    }];
    
}
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{}];
    [_resultView setHidden:YES];
    [_controlView setHidden:YES];
    [_showView setHidden:YES];
    [readerView start];
    _isScaning = YES;
}

@end
