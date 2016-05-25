//
//  ScanViewController.m
//  Metic
//
//  Created by ligang_mac4 on 14-7-23.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "ScanViewController.h"
#import "CommonUtils.h"
#import "CustomCellTableViewCell.h"
#import "UserTableViewCell.h"
#import "SVProgressHUD.h"
#import "EventDetailViewController.h"
#import "MegUtils.h"
#import <AVFoundation/AVFoundation.h>
#import "MTOperation.h"

#define radio 0.675f

@interface ScanViewController ()<AVCaptureMetadataOutputObjectsDelegate>
@property(nonatomic,strong) AVCaptureSession *session; // 二维码生成的绘画
@property(nonatomic,strong) AVCaptureVideoPreviewLayer *previewLayer;  // 二维码生成的图层

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
    [self initScanner];
    _need_auth = YES;
    _operationNum = 0;
    [CommonUtils addLeftButton:self isFirstPage:!_needPopBack];
    _isScaning = NO;
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (!_isScaning) {
        _isScaning = YES;
        [self run];
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
        [self pause];
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
    [self run];
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
    CGFloat length = kMainScreenWidth * radio;
    CGFloat stdH = (kMainScreenHeight - 44 - length)/2 - 30;
    CGFloat wid = kMainScreenWidth;
    MTLOG(@"作图起始高度：%f",stdH);
    
    UIView* up = [[UIView alloc]initWithFrame:CGRectMake(0, 0, wid, stdH)];
    up.backgroundColor =[UIColor blackColor];
    up.alpha = 0.7;
    [_GUI addSubview:up];
    
    UIView* left = [[UIView alloc]initWithFrame:CGRectMake(0, stdH, wid/2-length/2, length)];
    left.backgroundColor =[UIColor blackColor];
    left.alpha = 0.7;
    [_GUI addSubview:left];
    
    UIView* right = [[UIView alloc]initWithFrame:CGRectMake(wid/2 + length/2, stdH, wid/2-length/2, length)];
    right.backgroundColor =[UIColor blackColor];
    right.alpha = 0.7;
    [_GUI addSubview:right];
    
    UIView* down = [[UIView alloc]initWithFrame:CGRectMake(0, stdH + length, wid, kMainScreenHeight - stdH - length)];
    down.backgroundColor =[UIColor blackColor];
    down.alpha = 0.7;
    [_GUI addSubview:down];
    
    UILabel *label1 = [[UILabel alloc]initWithFrame:CGRectMake(kMainScreenWidth/2-100, 10, 200, 21)];
    label1.text = @"请将取景器对准";
    label1.textAlignment = NSTextAlignmentCenter;
    label1.textColor = [UIColor colorWithWhite:232.0/255.0 alpha:1.0f];
    label1.font = [UIFont systemFontOfSize:14];
    [down addSubview:label1];
    
    UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake(kMainScreenWidth/2-120, 30, 240, 21)];
    label2.text = @"活动宝网站或活动宝App提供的二维码";
    label2.textAlignment = NSTextAlignmentCenter;
    label2.textColor = [UIColor colorWithWhite:232.0/255.0 alpha:1.0f];
    label2.font = [UIFont systemFontOfSize:14];
    [down addSubview:label2];
    
    CGFloat borderLength = kMainScreenWidth * 30 / 320;
    CGFloat borderWidth = 3;
    CGFloat borderPadding = -1;
    UIColor *angleColor = [UIColor colorWithRed:85.0/255.0 green:203.0/255.0 blue:171.0/255.0 alpha:1.0f];
    
    UIView* leftup = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(left.frame) - borderWidth - borderPadding, CGRectGetMaxY(up.frame) - borderWidth - borderPadding, borderWidth, borderLength)];
    leftup.backgroundColor = angleColor;
    [_GUI addSubview:leftup];
    
    UIView* leftdown = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(left.frame) - borderWidth - borderPadding, CGRectGetMinY(down.frame) - borderLength + borderPadding, borderWidth, borderLength)];
    leftdown.backgroundColor = angleColor;
    [_GUI addSubview:leftdown];
    
    UIView* rightup = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMinX(right.frame) + borderPadding, CGRectGetMaxY(up.frame) - borderWidth - borderPadding, borderWidth, borderLength)];
    rightup.backgroundColor = angleColor;
    [_GUI addSubview:rightup];
    
    UIView* rightdown = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMinX(right.frame) + borderPadding, CGRectGetMinY(down.frame) - borderLength + borderPadding, borderWidth, borderLength)];
    rightdown.backgroundColor = angleColor;
    [_GUI addSubview:rightdown];
    
    UIView* upleft = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(left.frame) - borderWidth - borderPadding, CGRectGetMaxY(up.frame) - borderWidth - borderPadding, borderLength, borderWidth)];
    upleft.backgroundColor = angleColor;
    [_GUI addSubview:upleft];
    
    UIView* upright = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMinX(right.frame) - borderLength + borderWidth + borderPadding, CGRectGetMaxY(up.frame) - borderWidth - borderPadding, borderLength, borderWidth)];
    upright.backgroundColor = angleColor;
    [_GUI addSubview:upright];
    
    UIView* downleft = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(left.frame) - borderWidth - borderPadding, CGRectGetMinY(down.frame) + borderPadding, borderLength, borderWidth)];
    downleft.backgroundColor = angleColor;
    [_GUI addSubview:downleft];
    
    UIView* downright = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMinX(right.frame) - borderLength + borderWidth + borderPadding, CGRectGetMinY(down.frame) + borderPadding, borderLength, borderWidth)];
    downright.backgroundColor = angleColor;
    [_GUI addSubview:downright];
    
    _line = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(left.frame) + 5, CGRectGetMaxY(up.frame) + 10, length - 10, 2)];
    _line.clipsToBounds = NO;
    _line.contentMode = UIViewContentModeScaleAspectFill;
    _line.image = [UIImage imageNamed:@"line.png"];
    [_GUI addSubview:_line];
    //定时器，设定时间过1.5秒，
    _upOrdown = YES;
    _timer = [NSTimer scheduledTimerWithTimeInterval:.02 target:self selector:@selector(animation) userInfo:nil repeats:YES];
}

- (void)initScanner
{
    // 1. 摄像头设备
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    // 2. 设置输入
    NSError *error = nil;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (error) {
        MTLOG(@"没有摄像头-%@", error.localizedDescription);
        return;
    }
    // 3. 设置输出(Metadata元数据)
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    
    // 3.1 设置输出的代理
    // 说明：使用主线程队列，响应比较同步，使用其他队列，响应不同步，容易让用户产生不好的体验
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    //    [output setMetadataObjectsDelegate:self queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    
    // 4. 拍摄会话
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    // 添加session的输入和输出
    [session addInput:input];
    [session addOutput:output];
    
    // 4.1 设置输出的格式
    // 提示：一定要先设置会话的输出为output之后，再指定输出的元数据类型！
    [output setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
    
    // 5. 设置预览图层（用来让用户能够看到扫描情况）
    AVCaptureVideoPreviewLayer *preview = [AVCaptureVideoPreviewLayer layerWithSession:session];
    
    // 5.1 设置preview图层的属性
    [preview setVideoGravity:AVLayerVideoGravityResizeAspect];
    
    // 5.2 设置preview图层的大小
    [preview setFrame:self.view.bounds];
    
    // 5.3 将图层添加到视图的图层
    [self.view.layer insertSublayer:preview atIndex:0];
    self.previewLayer = preview;
    
    // 6. 启动会话
    [session startRunning];
    
    self.session = session;
}

- (void)run;
{
    [self.session startRunning];
}

- (void)pause;
{
    [self.session stopRunning];
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
            MTLOG(@"%@",dictionary);
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
            HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
            NSInteger operNum = ++_operationNum;
            [httpSender sendMessage:jsonData withOperationCode:QRCODE_INVITE finshedBlock:^(NSData *rData) {
                if (operNum != _operationNum) return ;
                if (rData) {
                    NSString* temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
                    MTLOG(@"received Data: %@",temp);
                    NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
                    NSNumber *cmd = [response1 valueForKey:@"cmd"];
                    switch ([cmd intValue]) {
                        case NORMAL_REPLY:
                        {
                            MTLOG(@"NORMAL_REPLY");
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
                            MTLOG(@"EVENT_NOT_EXIST");
                            [SVProgressHUD dismissWithError:@"活动不存在，加入失败"];
                            [_showView setHidden:YES];
                            [self run];
                            _isScaning = YES;
                        }
                            break;
                        case ALREADY_IN_EVENT:
                        {
                            MTLOG(@"ALREADY_IN_EVENT");
                            [SVProgressHUD dismissWithError:@"你已在活动中"];
                            [self toEventDetail:_efid];
                            [_showView setHidden:YES];
                        }
                            break;
                        default:
                        {
                            MTLOG(@"error");
                            MTLOG(@"ALREADY_IN_EVENT");
                            [SVProgressHUD dismissWithError:@"服务器异常"];
                            [_showView setHidden:YES];
                            [self run];
                            _isScaning = YES;
                        }
                    }
                }else{
                    [SVProgressHUD dismissWithError:@"网络异常"];
                    [_showView setHidden:YES];
                    [self run];
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
    [self pause];
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
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:eventid forKey:@"event_id"];
    [dictionary setValue:[MTUser sharedInstance].userid forKey:@"id"];
    MTLOG(@"%@",dictionary);
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    NSInteger operNum = ++_operationNum;
    [httpSender sendMessage:jsonData withOperationCode:SEARCH_EVENT finshedBlock:^(NSData *rData) {
        if (operNum != _operationNum) return ;
        if (rData) {
            [SVProgressHUD dismiss];
            [self finishWithReceivedData:rData];
        }else{
            [SVProgressHUD dismissWithError:@"网络异常"];
            [_showView setHidden:YES];
            [self run];
            _isScaning = YES;
        }
    }];
}

- (void) searchUser: (NSNumber *)userid
{
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:userid forKey:@"friendId"];
    [dictionary setValue:[MTUser sharedInstance].userid forKey:@"myId"];
    MTLOG(@"%@",dictionary);
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    NSInteger operNum = ++_operationNum;
    [httpSender sendMessage:jsonData withOperationCode:SEARCH_FRIEND finshedBlock:^(NSData *rData) {
        if (operNum != _operationNum) return ;
        if (rData) {
            [SVProgressHUD dismiss];
            [self finishWithReceivedData:rData];
        }else{
            [SVProgressHUD dismissWithError:@"网络异常"];
            [_showView setHidden:YES];
            [self run];
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
        [cell setFrame:CGRectMake(0, 46, 300, 268)];
        NSDictionary *data = _events;
        if ([[data valueForKey:@"isIn"] intValue] == 1){
            [_inButton setTitle:@"已加入" forState:UIControlStateNormal];
            [_inButton setHighlighted:YES];
            [_inButton setEnabled:NO];
        }else{
            [_inButton setTitle:@"加入活动" forState:UIControlStateNormal];
            [_inButton setHighlighted:NO];
            [_inButton setEnabled:YES];
        }
        
        [cell applyData:data];
        
        CGRect frame = _resultView.frame;
        frame.origin.y = (CGRectGetHeight(self.view.frame) - 50 - CGRectGetHeight(cell.frame) - CGRectGetHeight(self.controlView.frame))/2;
        frame.size.height = 314;
        frame.origin.x = CGRectGetWidth(_showView.frame)/2 - 150;
        frame.size.width = 300;
        [_resultView setFrame:frame];
        [_resultView addSubview:cell];
        [_resultView sendSubviewToBack:cell];
        [_resultView setHidden:NO];
//        [_showView setHidden:NO];
        frame = _controlView.frame;
        frame.origin.x = CGRectGetMinX(_resultView.frame);
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
        NSDictionary *data = _friend;
        [cell applyData:data];
        
        if ([[data valueForKey:@"isFriend"] boolValue] == YES){
            [_inButton setTitle:@"已是好友" forState:UIControlStateNormal];
            [_inButton setHighlighted:YES];
            [_inButton setEnabled:NO];
        }else{
            [_inButton setTitle:@"加为好友" forState:UIControlStateNormal];
            [_inButton setHighlighted:NO];
            [_inButton setEnabled:YES];
        }
        
        [_resultView addSubview:cell];
        
        CGRect frame = _resultView.frame;
        frame.origin.x = CGRectGetWidth(_showView.frame)/2 - 150;
        frame.size.height = 210;
        frame.origin.y = (CGRectGetHeight(self.view.frame) - 50 - CGRectGetHeight(cell.frame) - CGRectGetHeight(self.controlView.frame))/2;
        [_resultView setFrame:frame];
        [_resultView setHidden:NO];
        //        [_showView setHidden:NO];
        frame = _controlView.frame;
        frame.origin.x = CGRectGetMinX(_resultView.frame);
        frame.origin.y = CGRectGetMaxY(_resultView.frame);
        _controlView.frame = frame;
        [_controlView setHidden:NO];
        
    }
    
    [UIView animateWithDuration:1.f animations:^{
        [_showView setHidden:NO];
    }];
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
    CGFloat length = kMainScreenWidth * radio;
    CGFloat stdH = (kMainScreenHeight - 44 - length)/2 - 30;
    CGRect frame = _line.frame;
    if (_upOrdown && CGRectGetMaxY(frame) + 2 > stdH + length - 10 ) {
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
    MTLOG(@"received Data: %@",temp);
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
                [self run];
                _isScaning = YES;
            }
            
        }
            break;
        case EVENT_NOT_EXIST:
        {
            MTLOG(@"EVENT_NOT_EXIST");
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
                MTLOG(@"ALREADY_IN_EVENT");
                UIAlertView* alert =
                [CommonUtils showSimpleAlertViewWithTitle:@"系统消息" WithMessage:@"用户不存在" WithDelegate:self WithCancelTitle:@"确定"];
                alert.tag = 10;
            }
        }
            break;
        case ALREADY_FRIENDS:
        {
            NSString* mesg = @"你们已经是好友了";
            
            [SVProgressHUD dismissWithSuccess:mesg];
            [_showView setHidden:YES];
            [self run];
            _isScaning = YES;
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

#pragma mark AVCaptureMetadataOutputObjectsDelegate
// 此方法是在识别到QRCode，并且完成转换
// 如果QRCode的内容越大，转换需要的时间就越长
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    for(AVMetadataObject *metadataObject in metadataObjects)
    {
        if ([metadataObject isKindOfClass:[AVMetadataMachineReadableCodeObject class]]) {
            AVMetadataMachineReadableCodeObject *readableObject = (AVMetadataMachineReadableCodeObject *)[self.previewLayer transformedMetadataObjectForMetadataObject:metadataObject];
            BOOL foundMatch = readableObject.stringValue != nil;
            NSArray *corners = readableObject.corners;
            if (corners.count == 4 && foundMatch) {
                
//                CGPoint topLeftPoint = [self pointFromArray:corners atIndex:0];
//                CGPoint bottomLeftPoint = [self pointFromArray:corners atIndex:1];
//                CGPoint bottomRightPoint = [self pointFromArray:corners atIndex:2];
//                CGPoint topRightPoint = [self pointFromArray:corners atIndex:3];
//                
//                UIView *focusBoxView = self.shadowView.focusBoxView;
//                
//                if (CGRectContainsPoint(focusBoxView.bounds, topLeftPoint) &&
//                    CGRectContainsPoint(focusBoxView.bounds, topRightPoint) &&
//                    CGRectContainsPoint(focusBoxView.bounds, bottomLeftPoint) &&
//                    CGRectContainsPoint(focusBoxView.bounds, bottomRightPoint))
//                {
                    // 1. 如果扫描完成，停止会话
                
                
                // 2. 设置界面显示扫描结果
                if (metadataObjects.count > 0) {
                    AVMetadataMachineReadableCodeObject *obj = metadataObjects[0];
                    // 提示：如果需要对url或者名片等信息进行扫描，可以在此进行扩展！
                    self.result = obj.stringValue;
                    [self pause];
                    _isScaning = NO;
                    [self resultAnalysis];
                }
            }
        }
    }
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
        self.shadowView.hidden = NO;
        
        [self.view bringSubviewToFront:self.shadowView];
        
        [self.shadowView setAlpha:distance/(kMainScreenWidth * 1.2f)];
        
        self.navigationController.navigationBar.alpha = 1 - distance/(kMainScreenWidth * 1.2f);
        
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
                    MTLOG(@"%@",dictionary);
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
                            [self run];
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
                            MTLOG(@"ALREADY_IN_EVENT");
                            [SVProgressHUD dismissWithError:@"网络异常"];
                            [_showView setHidden:YES];
                            [self run];
                            _isScaning = YES;
                        }
                    }];
                    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
                    
                }
            }
            
        }
            break;
        case 10:{
            [_showView setHidden:YES];
            [self run];
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
                [self pause];
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
    [self run];
    _isScaning = YES;
}

@end
