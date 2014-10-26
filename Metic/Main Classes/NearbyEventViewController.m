//
//  NearbyEventViewController.m
//  Metic
//
//  Created by ligang_mac4 on 14-8-4.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "NearbyEventViewController.h"
#import "showParticipatorsViewController.h"
#import "../Cell/nearbyEventTableViewCell.h"
#import "PhotoGetter.h"
#import "MTUser.h"
#import "MobClick.h"
#import "../Utils/Reachability.h"
#import "../Source/SDWebImage/UIImageView+WebCache.h"
#import "EventDetailViewController.h"

@interface NearbyEventViewController ()
@property (nonatomic, strong) BMKLocationService* locService;
@property CLLocationCoordinate2D coordinate;
@property(nonatomic,strong) UIView *bar;
@property(nonatomic,strong) NSMutableArray* nearbyEvents;
@property(nonatomic,strong) NSMutableArray* eventIds_all;
@property BOOL clearIds;
@property BOOL Headeropen;
@property BOOL Footeropen;

@end

@implementation NearbyEventViewController

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
    [self initData];
    [self initUI];
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSString* position;
    if (_type == 0) position = @"周边活动";
    else position = @"热门活动";
    [MobClick beginLogPageView:position];
    
    _locService.delegate = self;
    [_nearbyTableView reloadData];
    
    if (_shouldRefresh){
        [_header beginRefreshing];
        _shouldRefresh = NO;
    }
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    NSString* position;
    if (_type == 0) position = @"周边活动";
    else position = @"热门活动";
    [MobClick endLogPageView:position];
    _locService.delegate = nil;
    [_locService stopUserLocationService];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    [_header free];
    [_footer free];
}

//返回上一层
-(void)MTpopViewController{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)initData
{
    _nearbyEvents = [[NSMutableArray alloc]init];
    _eventIds_all = [[NSMutableArray alloc]init];
    
    _clearIds = NO;
    
    _nearbyTableView.delegate = self;
    _nearbyTableView.dataSource = self;
    
    //百度定位
    //_locService = [[BMKLocationService alloc]init];
    
    //初始化下拉刷新功能
    _header = [[MJRefreshHeaderView alloc]init];
    _header.delegate = self;
    _header.scrollView = self.nearbyTableView;
    
    //初始化上拉加载功能
    _footer = [[MJRefreshFooterView alloc]init];
    _footer.delegate = self;
    _footer.scrollView = self.nearbyTableView;
    
    _shouldRefresh = YES;
}

-(void)initUI
{
    [CommonUtils addLeftButton:self isFirstPage:NO];
    _emptyAlert = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.nearbyTableView.frame.size.width, 50)];
    [_emptyAlert setFont:[UIFont systemFontOfSize:15]];
    [_emptyAlert setTextAlignment:NSTextAlignmentCenter];
    [_emptyAlert setTextColor:[UIColor colorWithRed:145.0/255.0 green:145.0/255.0 blue:145.0/255.0 alpha:1]];
    
    
    if (_type == 0)
    {
        [self.navigationItem setTitle:@"周边活动"];
        _emptyAlert.text = @"附近暂时没有活动哦";
    }
    else
    {
        [self.navigationItem setTitle:@"热门活动"];
        _emptyAlert.text = @"暂时没有热门活动哦";
    }
}

-(void)renewEmptyAlert
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (!_nearbyEvents || _nearbyEvents.count == 0) {
            [_nearbyTableView addSubview:_emptyAlert];
        }else [_emptyAlert removeFromSuperview];
    });
    
}

-(void)getNearbyEventIdsFromAir
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:[NSNumber numberWithInt:_type] forKey:@"type"];
    [dictionary setValue:[MTUser sharedInstance].userid forKey:@"id"];
    [dictionary setValue:[NSNumber numberWithBool:YES] forKey:@"all"];
    if (_type == 0) {
        [dictionary setValue:[NSNumber numberWithDouble:_coordinate.latitude] forKey:@"latitude"];
        [dictionary setValue:[NSNumber numberWithDouble:_coordinate.longitude] forKey:@"longitude"];
    }
    
    NSLog(@"%@",dictionary);
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:GET_EVENT_RECOMMEND];
    
}

- (void) getEvents: (NSArray *)eventids
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:eventids forKey:@"sequence"];
    [dictionary setValue:[MTUser sharedInstance].userid forKey:@"id"];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:GET_EVENTS];
}

-(void)closeRJ
{
    if (_Headeropen) {
        _Headeropen = NO;
        [_header endRefreshing];
    }
    if (_Footeropen) {
        _Footeropen = NO;
        [_footer endRefreshing];
    }
    [self renewEmptyAlert];
    [self.nearbyTableView reloadData];
}


#pragma mark 代理方法-进入刷新状态就会调用
- (void)refreshViewBeginRefreshing:(MJRefreshBaseView *)refreshView
{
    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == 0) {
        NSLog(@"没有网络");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [refreshView endRefreshing];
            [self renewEmptyAlert];
        });
        return;
    }
    if (_Headeropen || _Footeropen) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [refreshView endRefreshing];
        });
        return;
    }
    if (refreshView == _header) {
        NSLog(@"header Begin");
        _Headeropen = YES;
        _clearIds = YES;
        if (_type == 0) {
            _locService = [[BMKLocationService alloc]init];
            _locService.delegate = self;
            [_locService startUserLocationService];
        }else{
            [self getNearbyEventIdsFromAir];
        }
        
        [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(closeRJ) userInfo:nil repeats:NO];
    }else{
        _Footeropen = YES;
        _clearIds = NO;
        NSInteger beginIndex = _nearbyEvents.count;
        if (beginIndex == _eventIds_all.count) {
            [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(closeRJ) userInfo:nil repeats:NO];
        }
        NSInteger endIndex = beginIndex + 10;
        if (endIndex > _eventIds_all.count) endIndex = _eventIds_all.count;
        [self getEvents:[_eventIds_all subarrayWithRange:NSMakeRange(beginIndex, endIndex - beginIndex)]];
        
    }
}

#pragma mark - HttpSenderDelegate

-(void)finishWithReceivedData:(NSData *)rData
{
    NSString* temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
    NSLog(@"received Data: %@",temp);
    NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
    NSNumber *cmd = [response1 valueForKey:@"cmd"];
    switch ([cmd intValue]) {
        case NORMAL_REPLY:
        {
            if ([response1 valueForKey:@"event_list"]) { //获取event具体信息
                if (_clearIds) [_nearbyEvents removeAllObjects];
                [_nearbyEvents addObjectsFromArray:[response1 valueForKey:@"event_list"]];
                [self closeRJ];
            }
            else{//获取event id 号
                self.eventIds_all = [response1 valueForKey:@"sequence"];
                //[self.eventIds removeAllObjects];
                //[_eventIds addObjectsFromArray:[_eventIds_all subarrayWithRange:NSMakeRange(0, 10)]];
                if (self.eventIds_all) {
                    int rangeLen = 10;
                    if (self.eventIds_all.count< rangeLen) {
                        rangeLen = self.eventIds_all.count;
                    }
                    [self getEvents:[_eventIds_all subarrayWithRange:NSMakeRange(0, rangeLen)]];
                }
            }
        }
            break;
    }
}

#pragma mark BaiDuMap Location Service Delegate
- (void)didUpdateUserLocation:(BMKUserLocation *)userLocation
{
    //cclocat
    _coordinate = userLocation.location.coordinate;
    NSLog(@"%f   %f",_coordinate.latitude,_coordinate.longitude);
    [_locService stopUserLocationService];
    _locService = nil;
    [self getNearbyEventIdsFromAir];
}


#pragma mark tableView dataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int tag = [tableView tag];
    switch (tag) {
        case 111:{
            return [_nearbyEvents count];
        }
            break;
        default:return 0;
            break;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int tag = [tableView tag];
    UITableViewCell* useless_cell;
    switch (tag) {
        case 111:{
            static NSString *CellIdentifier = @"nearbyEventCell";
            BOOL nibsRegistered = NO;
            if (!nibsRegistered) {
                UINib *nib = [UINib nibWithNibName:NSStringFromClass([nearbyEventTableViewCell class]) bundle:nil];
                [tableView registerNib:nib forCellReuseIdentifier:CellIdentifier];
                nibsRegistered = YES;
            }
            nearbyEventTableViewCell *cell = (nearbyEventTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            NSDictionary *a = _nearbyEvents[indexPath.row];
            cell.dict = a;
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
            cell.launcherinfo.text = [[NSString alloc]initWithFormat:@"发起人: %@",[a valueForKey:@"launcher"] ];
            cell.eventId = [a valueForKey:@"event_id"];
            cell.nearbyEventViewController = self;
            PhotoGetter* avatarGetter = [[PhotoGetter alloc]initWithData:cell.avatar authorId:[a valueForKey:@"launcher_id"]];
            [avatarGetter getAvatar];
            [cell drawOfficialFlag:[[a valueForKey:@"verify"] boolValue]];
            PhotoGetter* bannerGetter = [[PhotoGetter alloc]initWithData:cell.themePhoto authorId:[a valueForKey:@"event_id"]];
            NSString* bannerURL = [a valueForKey:@"banner"];
            [bannerGetter getBanner:[a valueForKey:@"code"] url:bannerURL];
            if ([[a valueForKey:@"isIn"] boolValue]) {
                [cell.statusLabel setHidden:NO];
                cell.statusLabel.text = @"已加入活动";
                [cell.wantInBtn setHidden:YES];
            }else if ([[a valueForKey:@"visibility"] boolValue]) {
                [cell.statusLabel setHidden:YES];
                [cell.wantInBtn setHidden:NO];
            }else{
                [cell.statusLabel setHidden:NO];
                cell.statusLabel.text = @"非公开活动";
                [cell.wantInBtn setHidden:YES];
            }
            
            NSArray *memberids = [a valueForKey:@"member"];
            
            for (int i =3; i>=0; i--) {
                UIImageView *tmp = ((UIImageView*)[((UIView*)[cell viewWithTag:103]) viewWithTag:i+1]);
                if (i < participator_count) {
                    PhotoGetter* miniGetter = [[PhotoGetter alloc]initWithData:tmp authorId:memberids[i]];
                    [miniGetter getAvatar];
                }else{
                    [tmp sd_cancelCurrentImageLoad];
                    tmp.image = nil;
                }
            }
            [cell setBackgroundColor:[UIColor whiteColor]];
            return cell;
            
            
            
        }
            break;
        default:
            break;
    }
    return useless_cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    nearbyEventTableViewCell* cell = (nearbyEventTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    NSDictionary* dict = cell.dict;
    
    if (![[dict valueForKey:@"isIn"] boolValue]) {
        return;
    }
    
    NSNumber* eventId = [CommonUtils NSNumberWithNSString:[dict valueForKey:@"event_id"]];
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle: nil];
    
    EventDetailViewController* eventDetailView = [mainStoryboard instantiateViewControllerWithIdentifier: @"EventDetailViewController"];
    eventDetailView.eventId = eventId;
    [self.navigationController pushViewController:eventDetailView animated:YES];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int tag = [tableView tag];
    switch (tag) {
        case 111:{
            return 258;
        }
            break;
        default:return 0;
            break;
    }
}


#pragma mark - 跳转前数据准备 Methods -
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[showParticipatorsViewController class]]) {
        showParticipatorsViewController *nextViewController = segue.destinationViewController;
        nextViewController.eventId = _selectedEventId;
        nextViewController.canManage = NO;
    }
}

@end
