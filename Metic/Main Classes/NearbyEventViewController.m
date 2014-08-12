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

@interface NearbyEventViewController ()
@property (nonatomic, strong) BMKLocationService* locService;
@property CLLocationCoordinate2D coordinate;
@property(nonatomic,strong) UIView *bar;
@property(nonatomic,strong) NSMutableArray* nearbyEvents;
@property(nonatomic,strong) NSMutableArray* eventIds_all;
@property BOOL clearIds;
@property BOOL Headeropen;
@property BOOL Footeropen;

@property(nonatomic,strong) NSMutableArray* searchEvents;
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
    _nearbyEvents = [[NSMutableArray alloc]init];
    _searchEvents = [[NSMutableArray alloc]init];
    _eventIds_all = [[NSMutableArray alloc]init];

    _clearIds = NO;
    
    _scrollView.delegate = self;
    _nearbyTableView.delegate = self;
    _nearbyTableView.dataSource = self;
    _searchTableView.delegate = self;
    _searchTableView.dataSource = self;
    [self createScrollingBar];
    [_nearbyButton setHighlighted:YES];
    
    //百度定位
    _locService = [[BMKLocationService alloc]init];
    
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


-(void)viewDidAppear:(BOOL)animated
{
    [self.shadowView setAlpha:0];
    _locService.delegate = self;
    [_nearbyTableView reloadData];
    [_searchTableView reloadData];
    
    if (_shouldRefresh){
        [_header beginRefreshing];
        _shouldRefresh = NO;
    }
}

-(void)viewDidDisappear:(BOOL)animated
{
    _locService.delegate = nil;
    [_locService stopUserLocationService];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)createScrollingBar
{
    _bar = [[UIView alloc]initWithFrame:CGRectMake(0, 32, 160, 3)];
    [_bar setBackgroundColor:[UIColor colorWithRed:85/255.0 green:203/255.0 blue:171/255.0 alpha:1.0f]];
    [self.view addSubview:_bar];
    [self.view bringSubviewToFront:_shadowView];
}

-(void)getNearbyEventIdsFromAir
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:[MTUser sharedInstance].userid forKey:@"id"];
    [dictionary setValue:[NSNumber numberWithDouble:_coordinate.latitude] forKey:@"latitude"];
    [dictionary setValue:[NSNumber numberWithDouble:_coordinate.longitude] forKey:@"longitude"];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:GET_EVENT_RECOMMEND];

}

- (void) getEvents: (NSArray *)eventids
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:eventids forKey:@"sequence"];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:GET_EVENTS];
}



- (IBAction)nearbyButton_pressed:(id)sender {
    [_scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}

- (IBAction)searchButton_pressed:(id)sender {
    [_scrollView setContentOffset:CGPointMake(310, 0) animated:YES];
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
    [self.nearbyTableView reloadData];
}


#pragma mark 代理方法-进入刷新状态就会调用
- (void)refreshViewBeginRefreshing:(MJRefreshBaseView *)refreshView
{
    if (refreshView == _header) {
        NSLog(@"header Begin");
        _Headeropen = YES;
        _clearIds = YES;
        [_locService startUserLocationService];
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
    rData = [temp dataUsingEncoding:NSUTF8StringEncoding];
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
        case 112:{
            return [_searchEvents count];
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
            [avatarGetter getPhoto];
            
            PhotoGetter* bannerGetter = [[PhotoGetter alloc]initWithData:cell.themePhoto authorId:[a valueForKey:@"event_id"]];
            [bannerGetter getBanner:[a valueForKey:@"code"]];
            
            
            NSArray *memberids = [a valueForKey:@"member"];
            
            for (int i =3; i>=0; i--) {
                UIImageView *tmp = ((UIImageView*)[((UIView*)[cell viewWithTag:103]) viewWithTag:i+1]);
                if (i < participator_count) {
                    PhotoGetter* miniGetter = [[PhotoGetter alloc]initWithData:tmp authorId:memberids[i]];
                    [miniGetter getPhoto];
                }else tmp.image = nil;
            }
            [cell setBackgroundColor:[UIColor whiteColor]];
            return cell;
            
            
            
        }
            break;
        case 112:{
            
        }
            break;
            
        default:
            break;
    }
    return useless_cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int tag = [tableView tag];
    switch (tag) {
        case 111:{
            return 258;
        }
            break;
        case 112:{
            return 100;
        }
            break;
            
        default:return 0;
            break;
    }
}

#pragma mark scrollView Delegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.tag == 100) {
        CGRect frame =_bar.frame;
        frame.origin.x = scrollView.contentOffset.x / 2 *32.0/31.0;
        [_bar setFrame:frame];
        if (scrollView.contentOffset.x > 155) {
            [_searchButton setHighlighted:YES];
            [_nearbyButton setHighlighted:NO];
        }else{
            [_searchButton setHighlighted:NO];
            [_nearbyButton setHighlighted:YES];
        }
    }
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
    if (distance > 0) {
        self.shadowView.hidden = NO;
        [self.view bringSubviewToFront:self.shadowView];
        [self.shadowView setAlpha:distance/400.0];
    }else{
        //self.shadowView.hidden = YES;
        //[self.view sendSubviewToBack:self.shadowView];
    }
}


#pragma mark - 跳转前数据准备 Methods -
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[showParticipatorsViewController class]]) {
        showParticipatorsViewController *nextViewController = segue.destinationViewController;
        nextViewController.eventId = _selectedEventId;
        nextViewController.visibility = NO;
    }
}

@end
