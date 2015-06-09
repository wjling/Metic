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
#import "MTTableViewCellBase.h"
#import "CustomCellTableViewCell.h"
#import "MTTableView.h"
#import "MJRefresh.h"
#import "SVProgressHUD.h"
#import "MTUser.h"
#import "MTOperation.h"
#import "SquareTableViewCell.h"
#import "MTDatabaseHelper.h"
#import "MTDatabaseAffairs.h"

@interface EventLikeViewController ()<UITableViewDelegate,UISearchBarDelegate,MJRefreshBaseViewDelegate,SlideNavigationControllerDelegate>
@property (nonatomic,strong) UIView* shadowView;

@property(nonatomic,strong) MTTableView* tableView;
@property(nonatomic,strong) UISearchBar* searchBar;
@property(nonatomic,strong) NSArray* eventIds;
@property(nonatomic,strong) NSMutableArray* events;
@property(nonatomic,strong) MJRefreshFooterView* footer;
@property(nonatomic, readwrite) NSInteger type;

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
    [CommonUtils addLeftButton:self isFirstPage:_isFirstPage];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"收藏活动";
    
    if (!_tableView) {
        CGRect frame = self.view.frame;
        frame.origin.x += 10;
        frame.size.width -= 20;
        frame.origin.y = 44;
        frame.size.height -= 44;
        _tableView = [[MTTableView alloc]initWithFrame:frame];
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        [_tableView setBackgroundColor:[UIColor colorWithWhite:242.0/255.0 alpha:1.0]];
        [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [_tableView setRowHeight:166];
        [_tableView setShowsVerticalScrollIndicator:NO];
        [self.view addSubview:_tableView];
        [self.view sendSubviewToBack:_tableView];
    }

    _searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    [_searchBar setPlaceholder:@"搜索"];
    _searchBar.delegate = self;
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
    _tableView.homeController= self;
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self.tableView];
    self.tableView.cellClassName = @"CustomCellTableViewCell";
    self.tableView.emptyTips = @"暂时没有收藏活动哦";
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
            self.events = events;
            [_tableView reloadData];
        });
        
    }];
}

-(void)getLikeEventIdsForSearch
{
    self.type = 1;
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
    self.type = 0;
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

-(void)setEvents:(NSMutableArray *)events
{
    _events = events;
    _tableView.eventsSource = events;
}

-(void)setType:(NSInteger)type
{
    _type = type;
    switch (type) {
        case 0:
            _tableView.emptyTips = @"暂时没有收藏活动哦";
            break;
        case 1:
            _tableView.emptyTips = @"没有找到符合条件的活动";
            break;
            
        default:
            break;
    }
}

-(void)get_events:(BOOL)needClear
{
    NSLog(@"%lu", [_eventIds count] - [_events count]);
    NSUInteger restNum;
    if (needClear) {
        restNum = MIN(20, _eventIds.count);
    }else restNum = MIN(20, _eventIds.count - self.events.count);
    
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
                        self.events = tmp;
                    }else{
                        [self.events addObjectsFromArray:tmp];
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

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_searchBar resignFirstResponder];
    CustomCellTableViewCell* cell = (CustomCellTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
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

#pragma mark - SlideNavigationController Methods -

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
    return _isFirstPage;
}

- (BOOL)slideNavigationControllerShouldDisplayRightMenu
{
    return NO;
}

-(void)sendDistance:(float)distance
{
    if (distance > 0) {
        self.shadowView.hidden = NO;
        //[self.view bringSubviewToFront:self.shadowView];
        [self.shadowView setAlpha:distance/400.0];
        //[((SlideNavigationController*)self.navigationController) setBarAlpha:distance/400.0];
        self.navigationController.navigationBar.alpha = 1 - distance/400.0;
    }else{
        //self.shadowView.hidden = YES;
        //[self.view sendSubviewToBack:self.shadowView];
    }
}

@end
