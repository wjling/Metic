//
//  NearbyPeopleViewController.m
//  WeShare
//
//  Created by 俊健 on 15/11/6.
//  Copyright (c) 2015年 WeShare. All rights reserved.
//

#import "NearbyPeopleViewController.h"
#import "MJRefreshHeaderView.h"
#import "MJRefreshFooterView.h"
#import "FriendInfoViewController.h"

@interface NearbyPeopleViewController ()<MJRefreshBaseViewDelegate>
@property (nonatomic, strong) NSNumber* selectedFriendID;
@end

@implementation NearbyPeopleViewController

@synthesize tabPage2_view;
@synthesize nearbyFriends_tableview;
@synthesize nearbyFriends_header;
@synthesize nearbyFriends_footer;

@synthesize locationService;
@synthesize coordinate;
@synthesize nearbyFriends_arr;
@synthesize selectedFriendID;

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"附近的人";
    [CommonUtils addLeftButton:self isFirstPage:NO];
    
    nearbyFriends_arr = [[NSMutableArray alloc]init];
    nearbyFriends_tableview.delegate = self;
    nearbyFriends_tableview.dataSource = self;
    [self initContentView];
    [self.nearbyFriends_header beginRefreshing];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    MTLOG(@"friend recommandation viewdiddisappear");
    locationService.delegate = nil;
    [locationService stopUserLocationService];
    locationService = nil;
}

-(void)dealloc
{
    [nearbyFriends_header free];
    [nearbyFriends_footer free];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Method
//返回上一层
-(void)MTpopViewController{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)initContentView
{
    UIColor* bgColor = [UIColor colorWithRed:0.949 green:0.949 blue:0.949 alpha:1];

    self.nearbyFriends_tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.nearbyFriends_tableview setBackgroundColor:bgColor];
    self.nearbyFriends_header = [[MJRefreshHeaderView alloc]init];
    self.nearbyFriends_header.scrollView = self.nearbyFriends_tableview;
    self.nearbyFriends_header.delegate = self;
}

- (void)locate
{
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8 && self.locationManager == nil) {
        //由于IOS8中定位的授权机制改变 需要进行手动授权
        _locationManager = [[CLLocationManager alloc] init];
        //获取授权认证
        [_locationManager requestAlwaysAuthorization];
        [_locationManager requestWhenInUseAuthorization];
    }
    if (!locationService) {
        locationService = [[BMKLocationService alloc]init];
        locationService.delegate = self;
    }
    [locationService startUserLocationService];
}

-(void)getNearbyFriends:(void(^)()) didGetReceived
{
    void (^getNearbyFriendsDone)(NSData*) = ^(NSData* rData)
    {
        NSString* temp = @"";
        if (rData) {
            temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
        }
        else
        {
            MTLOG(@"获取附近好友，收到的rData为空");
            UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"系统提示" message:@"服务器未响应，有可能是网络未连接" delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
            [alertView show];
            [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(dismissAlert:) userInfo:alertView repeats:NO];
            return;
        }
        MTLOG(@"get nearbyfriends done, received Data: %@",temp);
        NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
        NSNumber* cmd = [response1 objectForKey:@"cmd"];
        if ([cmd integerValue] == 100) {
            nearbyFriends_arr = [response1 objectForKey:@"friend_list"];
            [nearbyFriends_tableview reloadData];
        }
        if (didGetReceived) {
            didGetReceived();
        }
    };
    NSDictionary* json_dic = [CommonUtils packParamsInDictionary:
                              [MTUser sharedInstance].userid,@"id",
                              [NSNumber numberWithDouble:coordinate.latitude],@"latitude",
                              [NSNumber numberWithDouble:coordinate.longitude],@"longitude",nil];
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:json_dic options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender* http = [[HttpSender alloc]initWithDelegate:self];
    [http sendMessage:jsonData withOperationCode:GET_NEARBY_FRIENDS finshedBlock:getNearbyFriendsDone];
    MTLOG(@"doing getNearbyFriends, json: %@",json_dic);
}

-(void)dismissAlert:(NSTimer*)timer
{
    UIAlertView* alert = [timer userInfo];
    [alert dismissWithClickedButtonIndex:0 animated:YES];
}

//返回两个坐标（coordinateA和coordinateB)之间的距离(单位：m)
-(double)getDistanceWithCoordinateA:(CLLocationCoordinate2D)coordinateA andCoordinateB:(CLLocationCoordinate2D)coordinateB
{
    double EARTH_RADIUS = 6371.393 * 1000.0;
    double PI = 3.141592654;
    double distance = EARTH_RADIUS * acos(cos(coordinateA.latitude * PI / 180.0) * cos(coordinateB.latitude * PI / 180.0) *
                                          cos(coordinateA.longitude * PI / 180.0 - coordinateB.longitude * PI / 180.0) +
                                          sin(coordinateA.latitude * PI / 180.0) * sin(coordinateB.latitude * PI / 180.0));
    return distance;
}

-(void)addFriendBtnClicked:(UIButton*)sender
{
    UIStoryboard* mainStoryBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    AddFriendConfirmViewController *vc = [mainStoryBoard instantiateViewControllerWithIdentifier:@"AddFriendConfirmViewController"];
    vc.fid = [NSNumber numberWithInteger:sender.tag];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary* friend;
    if (tableView == self.nearbyFriends_tableview) {
        friend = [nearbyFriends_arr objectAtIndex:indexPath.row];
    }
    if ([friend isKindOfClass:[NSDictionary class]]) {
        selectedFriendID = [friend valueForKey:@"id"];
        UIStoryboard* mainStoryBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
        FriendInfoViewController* vc = [mainStoryBoard instantiateViewControllerWithIdentifier:@"FriendInfoViewController"];
        vc.fid = selectedFriendID;
        [self.navigationController pushViewController:vc animated:YES];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    if (tableView == self.nearbyFriends_tableview) {
        return nearbyFriends_arr.count;
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIColor* bgColor = [UIColor colorWithRed:0.949 green:0.949 blue:0.949 alpha:1];
    if (tableView == nearbyFriends_tableview)
    {
        SearchedFriendTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"searchedfriendcell"];
        if (nil == cell) {
            cell = [[SearchedFriendTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"searchedfriendcell"];
        }
        NSMutableDictionary* friend = [nearbyFriends_arr objectAtIndex:indexPath.row];
        NSNumber* fid = [friend objectForKey:@"id"];
        NSNumber* latitude = [friend objectForKey:@"latitude"];
        NSNumber* longitude = [friend objectForKey:@"longitude"];
        NSString* fname = [friend objectForKey:@"name"];
        NSNumber* gender = [friend objectForKey:@"gender"];
        NSNumber* isFriend = [friend objectForKey:@"isFriend"];
        CLLocationCoordinate2D fcoordinate;
        fcoordinate.latitude = [latitude doubleValue];
        fcoordinate.longitude = [longitude doubleValue];
        //        double distance = [self getDistanceWithCoordinateA:coordinate andCoordinateB:fcoordinate];
        double distance = [CommonUtils GetDistance:coordinate.latitude lng1:coordinate.longitude lat2:fcoordinate.latitude lng2:fcoordinate.longitude];
        cell.friendNameLabel.text = fname;
        if (distance / 1000.0 >= 1) {
            cell.location_label.text = [NSString stringWithFormat:@"%.2f公里 以内", distance / 1000.0];
        }
        else
        {
            cell.location_label.text = [NSString stringWithFormat:@"%.2f米 以内", distance];
        }
        PhotoGetter* getter = [[PhotoGetter alloc]initWithData:cell.avatar_imageview authorId:fid];
        [getter getAvatar];
        
        UIFont* mFont = [UIFont systemFontOfSize:15];
        CGSize sizeOfName = [cell.friendNameLabel.text sizeWithFont:mFont constrainedToSize:CGSizeMake(MAXFLOAT, 0) lineBreakMode:NSLineBreakByCharWrapping];
        if (cell.gender_imageview) {
            [cell.gender_imageview removeFromSuperview];
        }
        else
        {
            cell.gender_imageview = [[UIImageView alloc]init];
        }
        cell.gender_imageview.frame = CGRectMake(cell.friendNameLabel.frame.origin.x + sizeOfName.width + 5, 5, 16, 16);
        if ([gender integerValue] == 0) {
            cell.gender_imageview.image = [UIImage imageNamed:@"女icon"];
        }
        else{
            cell.gender_imageview.image = [UIImage imageNamed:@"男icon"];
        }
        [cell.contentView addSubview:cell.gender_imageview];
        
        if ([isFriend intValue] == 0) {
            cell.theLabel.hidden = YES;
            cell.add_button.hidden = NO;
        }
        else{
            cell.theLabel.hidden = NO;
            cell.add_button.hidden = YES;
        }
        
        cell.add_button.tag = [fid integerValue];
        [cell.add_button addTarget:self action:@selector(addFriendBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        
        [cell setBackgroundColor:bgColor];
        
        UIColor* borderColor = [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1];
        cell.layer.borderColor = borderColor.CGColor;
        cell.layer.borderWidth = 0.3;
        return cell;
    }
    return nil;
}

#pragma mark BaiDuMap Location Service Delegate
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    //cclocat
    coordinate = userLocation.location.coordinate;
    MTLOG(@"%f   %f",coordinate.latitude,coordinate.longitude);
    [locationService stopUserLocationService];
    [self getNearbyFriends:^{
        [self.nearbyFriends_header endRefreshing];
    }];
}

-(void)didFailToLocateUserWithError:(NSError *)error
{
//    [SVProgressHUD dismissWithError:@"定位失败"];
}

#pragma mark - MJRefreshBaseViewDelegate
- (void)refreshViewBeginRefreshing:(MJRefreshBaseView *)refreshView
{
    if (refreshView == self.nearbyFriends_header) {
        [self locate];
    }
}

@end
