//
//  EventLikeViewController.m
//  WeShare
//
//  Created by 俊健 on 15/5/22.
//  Copyright (c) 2015年 WeShare. All rights reserved.
//

#import "EventLikeViewController.h"
#import "EventDetailViewController.h"
#import "EventPreviewViewController.h"
#import "SlideNavigationController.h"
#import "MJRefresh.h"
#import "SVProgressHUD.h"
#import "MTUser.h"
#import "MTOperation.h"
#import "SquareTableViewCell.h"
#import "MTDatabaseHelper.h"
#import "MTDatabaseAffairs.h"

@interface EventLikeViewController ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,MJRefreshBaseViewDelegate>
@property (nonatomic,strong) UIView* shadowView;

@property(nonatomic,strong) UITableView* tableView;
@property(nonatomic,strong) UISearchBar* searchBar;
@property(nonatomic,strong) NSArray* eventIds;
@property(nonatomic,strong) NSMutableArray* events;
@property(nonatomic,strong) MJRefreshFooterView* footer;

@property NSUInteger showNum;

@end

@implementation EventLikeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    [self initData];
    // Do any additional setup after loading the view.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name: @"deleteLikeItem" object:nil];
    [_footer free];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initUI
{
    [CommonUtils addLeftButton:self isFirstPage:NO];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"收藏活动";
    
    CGRect frame = self.view.bounds;
//    frame.origin.x = frame.size.width * 1/32;
    frame.origin.y = 44;
//    frame.size.width = frame.size.width * 15/16;
    frame.size.height -= 44;
    _tableView = [[UITableView alloc]initWithFrame:frame style:UITableViewStylePlain];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [_tableView setBackgroundColor:[UIColor colorWithWhite:242.0/255.0 alpha:1.0f]];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_tableView setShowsVerticalScrollIndicator:NO];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    [_searchBar setPlaceholder:@"搜索"];
    _searchBar.delegate = self;
    [self.view addSubview:_tableView];
    [self.view addSubview:_searchBar];
    [self.view setBackgroundColor:[UIColor colorWithWhite:242.0/255.0 alpha:1.0f]];
    //初始化上拉加载功能
    _footer = [[MJRefreshFooterView alloc]init];
    _footer.delegate = self;
    _footer.scrollView = self.tableView;
    
    
    
    
    //初始化阴影页
    _shadowView = [[UIView alloc]initWithFrame:self.view.bounds];
    _shadowView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    _shadowView.tag = 101;
    _shadowView.backgroundColor = [UIColor blackColor];
    _shadowView.alpha = 0;
    [self.view addSubview:_shadowView];
}

- (void)initData
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteItem:) name: @"deleteLikeItem" object:nil];
    _showNum = 0;
    [self pullEventFromDB];
    [self getLikeEventIds];
}

- (void)pullEventFromDB
{
    NSMutableArray* events = [[NSMutableArray alloc]init];
    NSArray *seletes = [[NSArray alloc]initWithObjects:@"event_info", nil];
    NSDictionary *wheres = [[NSDictionary alloc] initWithObjectsAndKeys:@"1 order by likeTime desc",@"islike", nil];
    
    [[MTDatabaseHelper sharedInstance] queryTable:@"event" withSelect:seletes andWhere:wheres completion:^(NSMutableArray *resultsArray) {
        NSMutableArray *result = resultsArray;
        for (int i = 0; i < result.count; i++) {
            NSDictionary* temp = [result objectAtIndex:i];
            NSString *tmpa = [temp valueForKey:@"event_info"];
            tmpa = [tmpa stringByReplacingOccurrencesOfString:@"''" withString:@"'"];
            NSData *tmpb = [tmpa dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *event =  [NSJSONSerialization JSONObjectWithData:tmpb options:NSJSONReadingMutableContainers error:nil];
            [events addObject:event];
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            _events = events;
            [_tableView reloadData];
        });
        
    }];
}

-(void)getLikeEventIdsForSearch
{
    NSString* text = self.searchBar.text;
    if ([[text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]) {
        self.searchBar.text = @"";
        return;
    }
    
    [SVProgressHUD showWithStatus:@"正在搜索…" maskType:SVProgressHUDMaskTypeGradient];
    
    [self.searchBar resignFirstResponder];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:text forKey:@"subject"];
    [dictionary setValue:[MTUser sharedInstance].userid forKey:@"id"];
    [dictionary setValue:@1 forKey:@"type"];
    NSLog(@"%@",dictionary);

    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:SEARCH_EVENT finshedBlock:^(NSData *rData) {
        if (rData) {
            NSString* temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
            NSLog(@"received Data: %@",temp);
            NSDictionary *response = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableContainers error:nil];
            NSNumber *cmd = [response valueForKey:@"cmd"];
            switch ([cmd intValue]) {
                case NORMAL_REPLY:{
                    NSArray* eventids = [response valueForKey:@"sequence"];
                    _eventIds = [eventids mutableCopy];
                    [self get_events:YES];
                }
                    break;
                default:{
                    [SVProgressHUD dismissWithError:@"网络异常，请重试。"];
                }
                    break;
            }
        }else{
            [SVProgressHUD dismissWithError:@"网络异常，请重试。"];
        }
        
    }];
    
}

-(void)getLikeEventIds
{
//    [SVProgressHUD showWithStatus:@"加载中" maskType:SVProgressHUDMaskTypeGradient];
    
    [self.searchBar resignFirstResponder];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:[MTUser sharedInstance].userid forKey:@"id"];
    NSLog(@"%@",dictionary);
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:GET_LIKE_EVENT finshedBlock:^(NSData *rData) {
        if (rData) {
            NSString* temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
            NSLog(@"received Data: %@",temp);
            NSDictionary *response = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableContainers error:nil];
            NSNumber *cmd = [response valueForKey:@"cmd"];
            switch ([cmd intValue]) {
                case NORMAL_REPLY:{
                    NSArray* eventids = [response valueForKey:@"event_list"];
                    _eventIds = [[MTOperation sharedInstance] processLikeEventID:eventids];
                    [self get_events:YES];
                }
                    break;
                default:{
                    [SVProgressHUD dismissWithError:@"网络异常，请重试。"];
                }
                    break;
            }
        }else{
            [SVProgressHUD dismissWithError:@"网络异常，请重试。"];
        }
        
    }];
    
}

-(void)get_events:(BOOL)needClear
{
    NSLog(@"%lu", [_eventIds count] - [_events count]);
    NSUInteger restNum;
    if (needClear) {
        restNum = MIN(20, _eventIds.count);
    }else restNum = MIN(20, _eventIds.count - _events.count);
    
    if (restNum <= 0 && !needClear){
        [SVProgressHUD dismiss];
        [self closeRJ];
        return;
    }
    NSArray* tmp;
    if (needClear) {
        tmp = [_eventIds subarrayWithRange:NSMakeRange(0, restNum)];
    }else{
        tmp = [_eventIds subarrayWithRange:NSMakeRange(_events.count, restNum)];
    }
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:tmp forKey:@"sequence"];
    [dictionary setValue:[MTUser sharedInstance].userid forKey:@"id"];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:GET_EVENTS finshedBlock:^(NSData *rData) {
        if (rData) {
            NSString* temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
            NSLog(@"received Data: %@",temp);
            NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableContainers error:nil];
            NSNumber *cmd = [response1 valueForKey:@"cmd"];
            switch ([cmd intValue]) {
                case NORMAL_REPLY:{
                    NSMutableArray *tmp = [[NSMutableArray alloc]initWithArray:[response1 valueForKey:@"event_list"]];
                    for(int i = 0; i < tmp.count; i++)
                    {
                        NSMutableDictionary* tmpDic = [[NSMutableDictionary alloc]initWithDictionary:tmp[i]];
                        tmp[i] = tmpDic;
                        [[MTDatabaseAffairs sharedInstance]saveEventToDB:tmpDic];
                    }
                    if (!_events|| needClear) {
                        _events = tmp;
                    }else{
                        [_events addObjectsFromArray:tmp];
                    }
                    
                    [SVProgressHUD dismiss];
                    [_tableView reloadData];
                    [self closeRJ];
                }
                    break;
                default:{
                    [SVProgressHUD dismissWithError:@"网络异常，请重试。"];
                    [self closeRJ];
                }
                    break;
            }
        }else{
            [SVProgressHUD dismissWithError:@"网络异常，请重试。"];
            [self closeRJ];
        }
    }];
    
}

-(void)closeRJ
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (_footer.refreshing) {
            [_footer endRefreshing];
        }
    });
}

//删除某个卡片
-(void)deleteItem:(id)sender
{
    NSNumber* eventId = [[sender userInfo] objectForKey:@"eventId"];
    
    for (NSInteger i = 0; i < self.events.count; i++) {
        NSMutableDictionary* dict = [self.events objectAtIndex:i];
        if ([[dict valueForKey:@"event_id"] integerValue] == [eventId integerValue]) {
            [self.events removeObject:dict];
            [_tableView reloadData];
            break;
        }
    }
    NSMutableArray* eventIds = [_eventIds mutableCopy];
    [eventIds removeObject:eventId];
    _eventIds = [eventIds copy];
    
    NSLog(@"deleteItem %@",eventId);
}

#pragma mark - UISearchBar Delegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar                     // called when keyboard search button pressed
{
    [self getLikeEventIdsForSearch];
}

#pragma mark - UIScrollView Delegate
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [_searchBar resignFirstResponder];
}

#pragma UITableView Delegate & DataSource
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 190;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.events && self.events.count != 0) {
        return self.events.count;
    }else
        return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.events || self.events.count == 0) {
        UITableViewCell* cell = [[UITableViewCell alloc]init];
        UILabel* label = [[UILabel alloc]initWithFrame:CGRectMake(0,0,320,70)];
        cell.userInteractionEnabled = NO;
        cell.backgroundColor = [UIColor clearColor];
        
        
        label.text = @"暂时没有收藏活动哦";
        label.numberOfLines = 1;
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont fontWithName:@"Helvetica-Bold" size:15];
        label.textColor = [UIColor colorWithWhite:147.0/255.0 alpha:1.0f];
        label.textAlignment = NSTextAlignmentCenter;
        [cell addSubview:label];
        
        
        return cell;
    }
    
    static NSString *CellIdentifier = @"eventLikeTableViewCell";
    BOOL nibsRegistered = NO;
    if (!nibsRegistered) {
        UINib *nib = [UINib nibWithNibName:NSStringFromClass([SquareTableViewCell class]) bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:CellIdentifier];
        nibsRegistered = YES;
    }
    SquareTableViewCell *cell = (SquareTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    NSMutableDictionary *eventInfo = _events[indexPath.row];
    [eventInfo removeObjectForKey:@"pv"];

    if (eventInfo) {
        [cell applyData:eventInfo];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_searchBar resignFirstResponder];
    SquareTableViewCell* cell = (SquareTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    NSDictionary* dict = cell.eventInfo;
    
    if (![[dict valueForKey:@"isIn"] boolValue]) {
        EventPreviewViewController *viewcontroller = [[EventPreviewViewController alloc]init];
        viewcontroller.eventInfo = dict;
        [self.navigationController pushViewController:viewcontroller animated:YES];
    }else{
        NSNumber* eventId = [CommonUtils NSNumberWithNSString:[dict valueForKey:@"event_id"]];
        NSNumber* eventLauncherId = [CommonUtils NSNumberWithNSString:[dict valueForKey:@"launcher_id"]];
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle: nil];
        
        EventDetailViewController* eventDetailView = [mainStoryboard instantiateViewControllerWithIdentifier: @"EventDetailViewController"];
        eventDetailView.eventId = eventId;
        eventDetailView.eventLauncherId = eventLauncherId;
        eventDetailView.event = [dict mutableCopy];
        [self.navigationController pushViewController:eventDetailView animated:YES];
    }
    
    
}

#pragma mark 代理方法-进入刷新状态就会调用
- (void)refreshViewBeginRefreshing:(MJRefreshBaseView *)refreshView
{
    if (_footer.refreshing) {
        return;
    }
    [self get_events:NO];
}


@end
