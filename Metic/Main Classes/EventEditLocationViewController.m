//
//  EventEditLocationViewController.m
//  WeShare
//
//  Created by 俊健 on 15/5/11.
//  Copyright (c) 2015年 WeShare. All rights reserved.
//

#import "EventEditLocationViewController.h"
#import "CommonUtils.h"
#import "SVProgressHUD.h"
#import "MTUser.h"
#import "MTDatabaseAffairs.h"
#import "BMapKit.h"

@interface EventEditLocationViewController ()<BMKLocationServiceDelegate,BMKGeoCodeSearchDelegate>
@property(nonatomic,strong) UITextField* contentField;
@property(nonatomic,strong) UIView* clearLocView;
@property(nonatomic,strong) UIButton* clearLocBtn;
@property(nonatomic,strong) UIView* getLocView;
@property(nonatomic,strong) UIButton* getLocBtn;

@property (nonatomic) CLLocationCoordinate2D pt;
@property (strong, nonatomic) BMKGeoCodeSearch* geocodesearch;
@property (nonatomic, strong) BMKLocationService* locService;
@property (nonatomic, strong) CLLocationManager  *locationManager;


@end

@implementation EventEditLocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    [self initData];
    // Do any additional setup after loading the view.
}

-(void)viewWillDisappear:(BOOL)animated
{
    _geocodesearch.delegate = nil;
    _locService.delegate = nil;
    [_locService stopUserLocationService];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initUI
{
    [CommonUtils addLeftButton:self isFirstPage:NO];
    self.view.backgroundColor = [UIColor colorWithWhite:0.95f alpha:1.0f];
    self.title = @"修改活动地点";
    
    [self initRightBtn];
    
    _contentField = [[UITextField alloc]initWithFrame:CGRectMake(10, 15, CGRectGetWidth(self.view.frame) - 20, 45)];
    _contentField.font = [UIFont systemFontOfSize:16];
    _contentField.textColor = [UIColor colorWithWhite:0.3 alpha:1.0f];
    _contentField.textAlignment = NSTextAlignmentLeft;
    [_contentField setBackgroundColor:[UIColor whiteColor]];
    _contentField.layer.cornerRadius = 6;
    _contentField.layer.masksToBounds = YES;
    _contentField.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    _contentField.placeholder = @"请输入活动地点";
    UILabel *paddingView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 10, 45)];
    paddingView.text = @" ";
    paddingView.textColor = [UIColor darkGrayColor];
    paddingView.backgroundColor = [UIColor clearColor];
    _contentField.leftView = paddingView;
    _contentField.leftViewMode = UITextFieldViewModeAlways;
    [self.view addSubview:_contentField];
    
    _clearLocView = [[UIView alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(_contentField.frame)+10, CGRectGetWidth(_contentField.frame), 45)];
    _clearLocView.backgroundColor = [UIColor clearColor];
    UILabel* lab = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, 100, 25)];
    lab.text = @"已定位，你可以";
    lab.numberOfLines = 1;
    lab.textAlignment = NSTextAlignmentLeft;
    lab.font = [UIFont systemFontOfSize:14];
    lab.textColor = [UIColor colorWithWhite:0.42f alpha:1.0f];
    [_clearLocView addSubview:lab];
    
    _clearLocBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [_clearLocBtn setTitle:@"清除当前定位信息" forState:UIControlStateNormal];
    _clearLocBtn.frame = CGRectMake(CGRectGetMaxX(lab.frame), 5, 120, 35);
    [_clearLocBtn setTitleColor:[UIColor colorWithRed:30.0/255.0 green:144.0/255.0 blue:255.0/255.0 alpha:1.0f] forState:UIControlStateNormal];
    _clearLocBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [_clearLocBtn addTarget:self action:@selector(clearLoc) forControlEvents:UIControlEventTouchUpInside];
    [_clearLocView addSubview:_clearLocBtn];
    
    _getLocView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_contentField.frame)+10, CGRectGetWidth(self.view.frame), 200)];
    [_getLocView setBackgroundColor:[UIColor clearColor]];
    
    _getLocBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _getLocBtn.frame = CGRectMake(10, 0, CGRectGetWidth(self.view.frame) - 20, 45);
    _getLocBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    [_getLocBtn setTitle:@"我要定位" forState:UIControlStateNormal];
    [_getLocBtn setTitleColor:[UIColor colorWithWhite:0.97f alpha:1.0f]  forState:UIControlStateNormal];
    [_getLocBtn setBackgroundImage:[CommonUtils createImageWithColor:[UIColor colorWithRed:85.0/255.0 green:203.0/255.0 blue:171.0/255.0 alpha:1.0f]] forState:UIControlStateNormal];
    [_getLocBtn setBackgroundImage:[CommonUtils createImageWithColor:[UIColor colorWithRed:68.0/255.0 green:162.4/255.0 blue:136.8/255.0 alpha:1.0f]] forState:UIControlStateHighlighted];
    _getLocBtn.layer.cornerRadius = 6;
    _getLocBtn.layer.masksToBounds = YES;
    [_getLocBtn addTarget:self action:@selector(getLoc) forControlEvents:UIControlEventTouchUpInside];
    [_getLocView addSubview:_getLocBtn];
    
    UILabel* tips = [[UILabel alloc]initWithFrame:CGRectMake(15, CGRectGetMaxY(_getLocBtn.frame)+10, CGRectGetWidth(_getLocView.frame) - 30, 80)];
    
    tips.text = @"定位后会把活动定位在你设定的位置上，人们可以通过附近的活动找到你的活动。\n\n修改活动地点后会通知所有活动参与者";
    tips.numberOfLines = 0;
    tips.textAlignment = NSTextAlignmentLeft;
    tips.font = [UIFont systemFontOfSize:14];
    tips.textColor = [UIColor colorWithWhite:0.6f alpha:1.0f];
    [_getLocView addSubview:tips];
    
    
}

- (void)initData
{
    NSString* loc = [_eventInfo valueForKey:@"location"];
    if (loc) {
        if([loc isEqualToString: @"地点未定"])loc = @"";
        _contentField.text = loc;
    }
    
    if (!_geocodesearch) {
        _geocodesearch = [[BMKGeoCodeSearch alloc]init];
        _geocodesearch.delegate = self;
    }
    
    [self adjustView];
    
}

-(void)adjustView
{
    double latitude = [[_eventInfo valueForKey:@"latitude"] doubleValue];
    double longitude = [[_eventInfo valueForKey:@"longitude"] doubleValue];
    _pt.latitude = latitude;
    _pt.longitude = longitude;
    CGRect frame = _contentField.frame;
    if (!(latitude == 999.999999 && longitude == 999.999999)) {
        CGRect clearlocFrame = _clearLocView.frame;
        clearlocFrame.origin.y = CGRectGetMaxY(frame);
        [_clearLocView setFrame:clearlocFrame];
        [self.view addSubview:_clearLocView];
        frame = clearlocFrame;
    }else{
        [_clearLocView removeFromSuperview];
        frame.size.height += 20;
    }
    
    CGRect getlocFrame = _getLocView.frame;
    getlocFrame.origin.y = CGRectGetMaxY(frame);
    [_getLocView setFrame:getlocFrame];
    [self.view addSubview:_getLocView];
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

-(void)clearLoc
{
    [_contentField resignFirstResponder];
    [SVProgressHUD showWithStatus:@"处理中" maskType:SVProgressHUDMaskTypeClear];
    
    if (_pt.latitude == 999.999999 && _pt.longitude == 999.999999) {
        [SVProgressHUD dismissWithSuccess:@"清除成功"];
        [self adjustView];
        return;
    }
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:[_eventInfo valueForKey:@"event_id"] forKey:@"event_id"];
    [dictionary setValue:@999.999999 forKey:@"latitude"];
    [dictionary setValue:@999.999999 forKey:@"longitude"];
    [dictionary setValue:[MTUser sharedInstance].userid forKey:@"id"];
    MTLOG(@"%@",dictionary);
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:CHANGE_EVENT_INFO finshedBlock:^(NSData *rData) {
        if (rData) {
            NSDictionary *response = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableContainers error:nil];
            NSNumber *cmd = [response valueForKey:@"cmd"];
            switch ([cmd intValue]) {
                case NORMAL_REPLY:
                {
                    [_eventInfo setValue:@999.999999 forKey:@"latitude"];
                    [_eventInfo setValue:@999.999999 forKey:@"longitude"];
                    
                    [[MTDatabaseAffairs sharedInstance]saveEventToDB:_eventInfo];
                    [SVProgressHUD dismissWithSuccess:@"清除成功"];
                    [self adjustView];
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

-(void)getLoc
{
    [SVProgressHUD showWithStatus:@"定位中" maskType:SVProgressHUDMaskTypeClear];
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8 && self.locationManager == nil) {
        //由于IOS8中定位的授权机制改变 需要进行手动授权
        _locationManager = [[CLLocationManager alloc] init];
        //获取授权认证
        [_locationManager requestAlwaysAuthorization];
        [_locationManager requestWhenInUseAuthorization];
    }
    _locService = [[BMKLocationService alloc]init];
    _locService.delegate = self;
    [_locService startUserLocationService];
}

-(void)confirm
{
    [_contentField resignFirstResponder];
    [SVProgressHUD showWithStatus:@"处理中" maskType:SVProgressHUDMaskTypeClear];
    
    NSString* content = [NSString stringWithString: _contentField.text];
    if([content isEqualToString: @""])content = @"地点未定";
    if ([content isEqualToString:[_eventInfo valueForKey:@"location"]] && _pt.latitude == [[_eventInfo valueForKey:@"latitude"]doubleValue] && _pt.longitude == [[_eventInfo valueForKey:@"longitude"]doubleValue]) {
        [self.navigationController popViewControllerAnimated:YES];
        [SVProgressHUD dismissWithSuccess:@"修改成功"];
        return;
    }
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:[_eventInfo valueForKey:@"event_id"] forKey:@"event_id"];
    [dictionary setValue:content forKey:@"location"];
    [dictionary setValue:@(_pt.latitude) forKey:@"latitude"];
    [dictionary setValue:@(_pt.longitude) forKey:@"longitude"];
    [dictionary setValue:[MTUser sharedInstance].userid forKey:@"id"];
    MTLOG(@"%@",dictionary);
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
                    [_eventInfo setValue:content forKey:@"location"];
                    [_eventInfo setValue:@(_pt.latitude) forKey:@"latitude"];
                    [_eventInfo setValue:@(_pt.longitude) forKey:@"longitude"];
                    [[MTDatabaseAffairs sharedInstance]saveEventToDB:_eventInfo];
                    [self.navigationController popViewControllerAnimated:YES];
                }
                    break;
                case EVENT_NOT_EXIST:
                {
                    [SVProgressHUD dismissWithError:@"网络异常"];
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

#pragma mark - BMK Delegate
/**
 *用户位置更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    [_locService stopUserLocationService];
    _locService.delegate = nil;
    _locService = nil;
    
    BMKReverseGeoCodeOption* reverseGeocodeSearchOption = [[BMKReverseGeoCodeOption alloc]init];
    
    reverseGeocodeSearchOption.reverseGeoPoint = userLocation.location.coordinate;
    MTLOG(@"定位坐标为：%f %f",reverseGeocodeSearchOption.reverseGeoPoint.latitude,reverseGeocodeSearchOption.reverseGeoPoint.longitude);
    BOOL flag = [_geocodesearch reverseGeoCode:reverseGeocodeSearchOption];
    if(flag)
    {
        MTLOG(@"反geo检索发送成功");
    }
    else
    {
        MTLOG(@"反geo检索发送失败");
    }
}
/**
 *定位失败后，会调用此函数
 *@param mapView 地图View
 *@param error 错误号，参考CLError.h中定义的错误号
 */
-(void)didFailToLocateUserWithError:(NSError *)error
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_locService stopUserLocationService];
        _locService.delegate = nil;
        _locService = nil;
        [SVProgressHUD dismissWithError:@"定位失败，请重试"];
    });
    
}

-(void) onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error
{
    if (error == 0) {
        self.contentField.text = result.address;
        self.pt = result.location;
        [SVProgressHUD dismiss];
    }
}
@end
