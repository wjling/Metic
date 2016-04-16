//
//  HomeViewController.m
//  SlideMenu
//
//  Created by Aryan Gh on 4/24/13.
//  Copyright (c) 2013 Aryan Ghassemi. All rights reserved.
//

#import "CustomCellTableViewCell.h"
#import "HomeViewController.h"
#import "EventPreviewViewController.h"
#import "MenuViewController.h"
#import "NSString+JSON.h"
#import "EventDetailViewController.h"
#import "PhotoGetter.h"
#import "Video/VideoWallViewController.h"
#import "LaunchEventViewController.h"
#import "DynamicViewController.h"
#import "AdViewController.h"
#import "MobClick.h"
#import "PictureWall2.h"
#import "UploaderManager.h"
#import "MTDatabaseHelper.h"
#import "MTDatabaseAffairs.h"
#import "MTPackageControl.h"
#import "MTOperation.h"
#import "SVProgressHUD.h"

@interface HomeViewController ()



@property (strong, nonatomic) IBOutlet UILabel *updateInfoNumLabel;
@property (nonatomic,strong) NSMutableDictionary* updateEventStatus;
@property (nonatomic,strong) NSMutableArray* atMeEvents;
@property (nonatomic,strong) UIAlertView *Alert;
@property (nonatomic,strong) NSString *AdUrl;
@property NSInteger type;
@property BOOL clearIds;
@property BOOL Headeropen;
@property BOOL Footeropen;
@property BOOL hasTurntoSquare;
@property BOOL firstAppear;
@end




@implementation HomeViewController
@synthesize listenerDelegate;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadEvent:) name: @"reloadEvent" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteItem:) name: @"deleteItem" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(replaceItem:) name: @"replaceItem" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(PopToHereAndTurnToNotificationPage:) name: @"PopToFirstPageAndTurnToNotificationPage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(adjustInfoView) name: @"adjustInfoView" object:nil];
   
    [self initUI];
    [CommonUtils addLeftButton:self isFirstPage:YES];
    
    [self setSortType];
    _clearIds = NO;
    _Headeropen = NO;
    _Footeropen = NO;
    _hasTurntoSquare = NO;
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    ((AppDelegate*)[UIApplication sharedApplication].delegate).homeViewController = self;
    
    [self createMenuButton];
    
    [_morefuctions.layer setCornerRadius:6];
    [_ArrangementView.layer setCornerRadius:6];
    _ArrangementView.
    clipsToBounds = YES;
    
    [[MTUser sharedInstance] getInfo:[MTUser sharedInstance].userid myid:[MTUser sharedInstance].userid delegateId:self];
    [[MTUser sharedInstance] updateAvatarList];
    
    _tableView.homeController= self;
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self.tableView];
    self.tableView.cellClassName = @"CustomCellTableViewCell";
    self.tableView.emptyTips = @"还没有活动哦，快去发起吧";
    self.events = [[NSMutableArray alloc]init];
    self.tableView.eventsSource = self.events;
    
    [self pullEventsFromDB];
    [_tableView reloadData];
    
    //初始化下拉刷新功能
    _header = [[MJRefreshHeaderView alloc]init];
    _header.delegate = self;
    _header.scrollView = self.tableView;
    [_header beginRefreshing];
    _shouldRefresh = NO;
    _firstAppear = YES;
    
    //初始化上拉加载更多
    _footer = [[MJRefreshFooterView alloc]init];
    _footer.delegate = self;
    _footer.scrollView = _tableView;
    
    
    self.listenerDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
//    [self.listenerDelegate connect];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[UploaderManager sharedManager] checkUnfinishedTasks];
    });
}

-(void)didReceiveMemoryWarning
{
    [[SDImageCache sharedImageCache] clearMemory];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.shadowView setAlpha:0];
    
    [MTPushMessageHandler sharedInstance].notificationDelegate = self;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [MTPackageControl checkVersion];
    _updateEventStatus = [MTUser sharedInstance].updateEventStatus;
    _atMeEvents = [MTUser sharedInstance].atMeEvents;
    [MobClick beginLogPageView:@"活动主页"];
    if (_shouldRefresh && !_firstAppear) {
        _shouldRefresh = NO;
        [_header beginRefreshing];
    }
    _firstAppear = NO;
    [self performSelector:@selector(adjustInfoView) withObject:nil afterDelay:0.3f];
    NSUserDefaults* userDf = [NSUserDefaults standardUserDefaults];
    NSString *shareCode = [[MTEvent sharedInstance] getValidPasteString];
    if (shareCode) {
        [self toEventPreview:shareCode];
        [[MTEvent sharedInstance] clearPasteBoard];
        self.hasTurntoSquare = YES;
        [userDf setInteger:0 forKey:@"newNotificationCome"];
        [userDf synchronize];
    }else if (!_hasTurntoSquare && [userDf boolForKey:@"firstLaunched"]) {
        _hasTurntoSquare = YES;
        [self toSquare];
    }else if([userDf integerForKey:@"newNotificationCome"] > 0){
        [userDf setInteger:0 forKey:@"newNotificationCome"];
        [userDf synchronize];
        [self toNotificationCenter];
    }else [self initWelcomePage];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [MobClick endLogPageView:@"活动主页"];
}

//返回上一层
-(void)MTpopViewController{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)initUI
{
    self.view.autoresizesSubviews = YES;
    if (!_updateInfoView) {
        _updateInfoView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 40)];
        _updateInfoView.userInteractionEnabled = YES;
        _updateInfoView.backgroundColor = [UIColor clearColor];
        
        UIButton* toDynamicBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [toDynamicBtn setFrame:CGRectMake(10, 5, 300, 31)];
        [toDynamicBtn setImage:[UIImage imageNamed:@"新消息底块"] forState:UIControlStateNormal];
        [toDynamicBtn addTarget:self action:@selector(toDynamic:) forControlEvents:UIControlEventTouchUpInside];
        [_updateInfoView addSubview:toDynamicBtn];
        
        UILabel* label = [[UILabel alloc]initWithFrame:CGRectMake(122, 10, 100, 21)];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont systemFontOfSize:16];
        [label setTextColor:[UIColor whiteColor]];
        [label setTextAlignment:NSTextAlignmentLeft];
        [label setText:@"新动态"];
        [_updateInfoView addSubview:label];
        
        UIImageView* littleCircle = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"新消息条数底块"]];
        [littleCircle setFrame:CGRectMake(174, 8, 24, 24)];
        [_updateInfoView addSubview:littleCircle];
        
        if (!_updateInfoNumLabel) {
            _updateInfoNumLabel = [[UILabel alloc]initWithFrame:CGRectMake(173, 10, 26, 20)];
            [_updateInfoNumLabel setTextColor:[UIColor colorWithRed:240.0/255.0 green:114.0/255.0 blue:52.0/255.0 alpha:1.0]];
            [_updateInfoNumLabel setFont:[UIFont systemFontOfSize:14]];
            [_updateInfoNumLabel setTextAlignment:NSTextAlignmentCenter];
        }
        [_updateInfoView addSubview:_updateInfoNumLabel];
        [_updateInfoView setHidden:YES];
        [self.view addSubview:_updateInfoView];
        [self.view sendSubviewToBack:_updateInfoView];
    }
    
    if (!_tableView) {
        CGRect frame = self.view.frame;
        frame.origin.x += 10;
        frame.size.width -= 20;
        frame.origin.y = 0;
        _tableView = [[MTTableView alloc]initWithFrame:frame];
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        [_tableView setBackgroundColor:[UIColor colorWithWhite:242.0/255.0 alpha:1.0]];
        [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [_tableView setRowHeight:153 + 8 + (CGRectGetWidth(self.view.frame) - 20) / 300 * 150];
        [_tableView setShowsVerticalScrollIndicator:NO];
        [self.view addSubview:_tableView];
        [self.view sendSubviewToBack:_tableView];
    }
    
}

-(void)setSortType
{
    NSUserDefaults* userDfs = [NSUserDefaults standardUserDefaults];
    NSNumber* sortType = [userDfs objectForKey:[NSString stringWithFormat:@"%@sortType",[MTUser sharedInstance].userid]];
    if (!sortType) {
        _type = 0;
        [userDfs setObject:[NSNumber numberWithInteger:0] forKey:[NSString stringWithFormat:@"%@sortType",[MTUser sharedInstance].userid]];
        [userDfs synchronize];
    }else{
        _type = [sortType integerValue];
    }
    for (int i = 0; i < _arrangementButtons.count; i++) {
        UIButton* button = [_arrangementButtons objectAtIndex:i];
        [button setBackgroundImage:[CommonUtils createImageWithColor:[UIColor colorWithRed:232/255.0 green:232/255.0 blue:232/255.0 alpha:1.0]] forState:UIControlStateHighlighted];
    }
    [_arrangementButtons[(_type == 0)?0:1] setBackgroundImage:[CommonUtils createImageWithColor:[UIColor colorWithRed:232/255.0 green:232/255.0 blue:232/255.0 alpha:1.0]] forState:UIControlStateNormal];
    
}

//reloadEvent
-(void)reloadEvent:(id)sender
{
    _shouldRefresh = YES;
}

//在头部插入某个卡片
-(void)insertEventToQueue:(id)sender
{
    return;
    MTLOG(@"在头部插入某个卡片:%@",[sender userInfo]);
    if ([sender userInfo]) {
        NSMutableDictionary *newEvent = [[NSMutableDictionary alloc]initWithDictionary:[sender userInfo]];
        [newEvent removeObjectForKey:@"cmd"];
        [newEvent removeObjectForKey:@"ishandled"];
        [newEvent removeObjectForKey:@"promoter"];
        [newEvent removeObjectForKey:@"promoter_id"];
        [newEvent removeObjectForKey:@"seq"];
        MTLOG(@"经处理后的活动信息:%@",newEvent);
        
        //插入数据库
        [self updateEventToDB:@[newEvent]];
        
        //插入列表
        NSNumber* newEventId = [newEvent valueForKey:@"event_id"];
        [_events insertObject:newEvent atIndex:0];
        [_eventIds_all insertObject:newEventId atIndex:0];
        [_tableView reloadData];
    }
    
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
    [self.eventIds_all removeObject:eventId];
    
    MTLOG(@"deleteItem %@",eventId);
}

//更新某个卡片
-(void)replaceItem:(id)sender
{
    int eventId = [[[sender userInfo] objectForKey:@"eventId"] intValue];
    NSMutableArray *dict = [[sender userInfo] objectForKey:@"eventInfo"];
    for (NSInteger i = 0; i < self.events.count; i++) {
        NSMutableDictionary* dic = [self.events objectAtIndex:i];
        if ([[dic valueForKey:@"event_id"] intValue] == eventId) {
            [self.events replaceObjectAtIndex:[_events indexOfObject:dic] withObject:dict];
            [_tableView reloadData];
            break;
        }
    }
    MTLOG(@"replaceItem %d ",eventId);
}

//返回本页并跳转到消息页
- (void)PopToHereAndTurnToNotificationPage:(id)sender {
    MTLOG(@"PopToHereAndTurnToNotificationPage  from  home");
    if ([[MTEvent sharedInstance] getValidPasteString]) {
        return;
    }
    if ([[SlideNavigationController sharedInstance].viewControllers containsObject:self]){
        MTLOG(@"Here");
        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"shouldIgnoreTurnToNotifiPage"]) {
            [[SlideNavigationController sharedInstance] popToViewController:self animated:NO];
            [self toNotificationCenter];
        }
    }else{
        MTLOG(@"NotHere");
    }
}

- (void)toEventPreview:(NSString *)shareCode {
    [SVProgressHUD showWithStatus:@"载入中" maskType:SVProgressHUDMaskTypeGradient];
    [[MTOperation sharedInstance] getInfoFromShareCode:shareCode success:^(NSDictionary *codeInfo) {
        NSNumber *shareId = codeInfo[@"share_id"];
        NSNumber *eventId = codeInfo[@"event_id"];
        if (eventId) {
            //拉取活动
            [[MTOperation sharedInstance] getEventInfoWithEventId:eventId success:^(NSDictionary *eventInfo) {
                if (eventInfo) {
                    if (![[eventInfo valueForKey:@"isIn"] boolValue] && [[eventInfo valueForKey:@"visibility"] integerValue] != 2) {
                        //跳转到活动预览
                        EventPreviewViewController *viewcontroller = [[EventPreviewViewController alloc]init];
                        viewcontroller.eventInfo = eventInfo;
                        viewcontroller.shareId = shareId;
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [self.navigationController pushViewController:viewcontroller animated:YES];
                            [SVProgressHUD dismiss];
                        });

                    }else{
                        NSNumber* eventId = [CommonUtils NSNumberWithNSString:[eventInfo valueForKey:@"event_id"]];
                        NSNumber* eventLauncherId = [CommonUtils NSNumberWithNSString:[eventInfo valueForKey:@"launcher_id"]];
                        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle: nil];
                        
                        EventDetailViewController* eventDetailView = [mainStoryboard instantiateViewControllerWithIdentifier: @"EventDetailViewController"];
                        eventDetailView.eventId = eventId;
                        eventDetailView.shareId = shareId;
                        eventDetailView.eventLauncherId = eventLauncherId;
                        eventDetailView.event = [eventInfo mutableCopy];
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [self.navigationController pushViewController:eventDetailView animated:YES];
                            [SVProgressHUD dismiss];
                        });
                    }
                } else {
                    [SVProgressHUD dismiss];
                }
                
            } failure:^(NSString *message) {
                [SVProgressHUD dismissWithError:message afterDelay:2.f];
            }];
        } else {
            [SVProgressHUD dismiss];
        }
    } failure:^(NSString *message) {
        [SVProgressHUD dismissWithError:message afterDelay:2.f];
    }];
}

- (void)toSquare {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone"
                                                             bundle: nil];
    UIViewController* vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"EventSquareViewController"];

    [[SlideNavigationController sharedInstance] openMenuAndSwitchToViewController:vc withCompletion:nil];
}

- (void)toNotificationCenter{
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone"
                                                             bundle: nil];
    UIViewController* vc = [MenuViewController sharedInstance].notificationsViewController;
    if(!vc){
        vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"NotificationsViewController"];
        [MenuViewController sharedInstance].notificationsViewController = vc;
    }
    
    [[SlideNavigationController sharedInstance] openMenuAndSwitchToViewController:vc withCompletion:nil];
}

-(void)initWelcomePage
{
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendGetPosterMessage:GET_WELCOME_PAGE finshedBlock:^(NSData *rData) {
        if (rData) {
            NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
            NSString* temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
            MTLOG(@"received Data: %@",temp);
            NSNumber *cmd = [response1 valueForKey:@"cmd"];
            switch ([cmd intValue]) {
                case NORMAL_REPLY:
                {
                    NSString* title = [response1 valueForKey:@"title"];
                    NSString* url = [response1 valueForKey:@"url"];
                    NSString* method = [response1 valueForKey:@"method"];
                    NSString* expiry_time = [response1 valueForKey:@"expiry_time"];
                    
                    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
                    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
                    [dateFormatter setLocale:[NSLocale currentLocale]];
                    NSDate* expiry_date = [dateFormatter dateFromString:expiry_time];
                    NSDate* saveTime = [[NSUserDefaults standardUserDefaults] objectForKey:@"ADTime"];
                    NSDate* curTime =[NSDate date];
                    
                    if (!expiry_date || [expiry_date timeIntervalSinceDate:curTime] < 0) {
                        return;
                    }
                    if (saveTime && ((long)[curTime timeIntervalSince1970])/86400 <= ((long)[saveTime timeIntervalSince1970])/86400) {
                        return;
                    }
                    
                    [[NSUserDefaults standardUserDefaults]setObject:curTime forKey:@"ADTime"];
                    
                    NSArray*args = [response1 valueForKey:@"args"];
                    MTLOG(@"%@",args);
                    
                    
                    
                    MTLOG(@"%@",url);
                    if (url && ![url isEqualToString:@""]) {
                        AdViewController* adViewController = [[AdViewController alloc]init];
                        adViewController.args = args;
                        adViewController.AdUrl = url;
                        adViewController.method = method;
                        if (title && ![title isEqual:[NSNull null]]){
                            MTLOG(@"%@",title);
                            adViewController.URLtitle = title;
                        }
                        
                        [self.navigationController pushViewController:adViewController animated:YES];
                    }
                    
                }
                    break;
                default:
                    
                    break;
                    
            }
            
        }else{
            
        }
    }];
}

-(void)initAdvertisementView
{
    _AdUrl = [MobClick getAdURL];
    if ( _AdUrl && ![_AdUrl isEqualToString:@""]) {
        MTLOG(@"广告广告广告广告广告%f广告：%@",self.view.frame.size.height,_AdUrl);
        UIView* adView = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height - 124, 320, 60)];
        [adView setBackgroundColor:[UIColor whiteColor]];
        UIButton* ad = [UIButton buttonWithType:UIButtonTypeCustom];
        [ad setTitle:@"Advertisement" forState:UIControlStateNormal];
        [ad.titleLabel setFont:[UIFont systemFontOfSize:25]];
        [ad.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [ad setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [ad setFrame:CGRectMake(0, 0, 320, 60)];
        [adView addSubview:ad];
        [self.view addSubview:adView];
        [ad addTarget:self action:@selector(openAdView) forControlEvents:UIControlEventTouchUpInside];
    }
}


-(void)openAdView
{
    AdViewController* adViewController = [[AdViewController alloc]init];
    adViewController.AdUrl = _AdUrl;
    [self.navigationController pushViewController:adViewController animated:YES];
}
-(void)createMenuButton
{
    UIImage* image = [UIImage imageNamed:@"头部右上角图标-加号"];
    CGRect frame = CGRectMake(1000,0,31,31);
    UIButton* backButton= [[UIButton alloc] initWithFrame:frame];
    [backButton setBackgroundImage:image forState:UIControlStateNormal];
    [backButton setTitle:@"" forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(option) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationController.navigationBar addSubview:backButton];
    UIBarButtonItem* rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
}


-(void)adjustInfoView
{
    //MTLOG(@"%f  %f",_scrollView.frame.origin.y ,_scrollView.frame.size.height);
    
    long num = [MTUser sharedInstance].updateEventStatus.count + [MTUser sharedInstance].atMeEvents.count;
    MTLOG(@"有%lu条新动态",([MTUser sharedInstance].updateEventStatus.count + [MTUser sharedInstance].atMeEvents.count));
    if (num > 0) {
        [_updateInfoView setHidden:NO];
        if (num < 10) {
            _updateInfoNumLabel.text = [NSString stringWithFormat:@"+%ld",num];
        }else _updateInfoNumLabel.text = @"+N";
        CGRect frame = _tableView.frame;
        if (frame.origin.y == 0) {
            frame.origin.y = 40;
            frame.size.height -= 40;
            [_tableView setFrame:frame];
        }
    }else{
        _updateInfoNumLabel.text = @"";
        [_updateInfoView setHidden:YES];
        CGRect frame = _tableView.frame;
        if (frame.origin.y == 40) {
            frame.origin.y = 0;
            frame.size.height += 40;
            [_tableView setFrame:frame];
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
        //[self.view bringSubviewToFront:self.shadowView];
        [self.shadowView setAlpha:distance/400.0];
        //[((SlideNavigationController*)self.navigationController) setBarAlpha:distance/400.0];
        self.navigationController.navigationBar.alpha = 1 - distance/400.0;
    }else{
        //self.shadowView.hidden = YES;
        //[self.view sendSubviewToBack:self.shadowView];
    }
}

#pragma mark - HttpSenderDelegate

-(void)finishWithReceivedData:(NSData *)rData
{
    NSString* temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
    
//    MTLOG(@"received Data: %@",temp);
    NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableContainers error:nil];
    NSNumber *cmd = [response1 valueForKey:@"cmd"];
    switch ([cmd intValue]) {
        case NORMAL_REPLY:
        {
            if ([response1 valueForKey:@"event_list"]) { //获取event具体信息
                if (_clearIds) [_events removeAllObjects];
                [self.events addObjectsFromArray:[response1 valueForKey:@"event_list"]];
                [_tableView reloadData];
                [self closeRJ];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_global_queue(0, 0), ^{
                    [self updateEventToDB:[response1 valueForKey:@"event_list"]];
                });
            }
            else if([response1 valueForKey:@"sequence"]){//获取event id 号
                self.eventIds_all = [response1 valueForKey:@"sequence"];
                [self compareAndDeleteEventToDB:[NSArray arrayWithArray:_eventIds_all]];
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




#pragma mark - 数据库操作
-(void)compareAndDeleteEventToDB:(NSArray*)sequences
{
    if (!sequences || sequences.count == 0) {
        return;
    }
    
    NSString * path = [NSString stringWithFormat:@"%@/db",[MTUser sharedInstance].userid];
    NSArray *seletes = [[NSArray alloc]initWithObjects:@"event_id", nil];
    NSDictionary *wheres = [[NSDictionary alloc] initWithObjectsAndKeys:@"1 order by event_id desc",@"1", nil];
    
    [[MTDatabaseHelper sharedInstance] queryTable:@"event" withSelect:seletes andWhere:wheres completion:^(NSMutableArray *resultsArray) {
        NSMutableArray *result = resultsArray;
        
        //比较
        NSSet*eventIds = [[NSSet alloc]initWithArray:sequences];
        for (int i = 0; i < result.count; i++) {
            NSDictionary* res = [result objectAtIndex:i];
            NSString* sequence_S = [res valueForKey:@"event_id"];
            NSNumber* sequence = [CommonUtils NSNumberWithNSString:sequence_S];
            if (!sequence) continue;
            if (![eventIds containsObject:sequence]) {
                //删除
                NSDictionary *wheres0 = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%@", sequence],@"event_id", nil];
                [[MTDatabaseHelper sharedInstance] deleteTurpleFromTable:@"event" withWhere:wheres0];
            }
        }

    }];
}


- (void)updateEventToDB:(NSArray*)events
{
    for (NSInteger i = 0; i < self.events.count; i++) {
        NSMutableDictionary* event = [self.events objectAtIndex:i];
        [[MTDatabaseAffairs sharedInstance]saveEventToDB:event];
    }
}


- (void)pullEventsFromDB
{
    NSString * path = [NSString stringWithFormat:@"%@/db",[MTUser sharedInstance].userid];
//    [self.sql openMyDB:path];
    
    self.events = [[NSMutableArray alloc]init];
    self.tableView.eventsSource = self.events;
    NSArray *seletes = [[NSArray alloc]initWithObjects:@"event_info", nil];
    NSDictionary *wheres1 = [[NSDictionary alloc] initWithObjectsAndKeys:@"1 order by beginTime desc",@"1", nil];
    NSDictionary *wheres2 = [[NSDictionary alloc] initWithObjectsAndKeys:@"1 order by joinTime desc",@"1", nil];
    
//    NSMutableArray *result = [self.sql queryTable:@"event" withSelect:seletes andWhere:(_type == 4)?wheres1:wheres2];
//    for (int i = 0; i < result.count; i++) {
//        NSDictionary* temp = [result objectAtIndex:i];
//        NSString *tmpa = [temp valueForKey:@"event_info"];
//        tmpa = [tmpa stringByReplacingOccurrencesOfString:@"''" withString:@"'"];
//        NSData *tmpb = [tmpa dataUsingEncoding:NSUTF8StringEncoding];
//        NSDictionary *event =  [NSJSONSerialization JSONObjectWithData:tmpb options:NSJSONReadingMutableLeaves error:nil];
//        [self.events addObject:event];
//    }
    
    [[MTDatabaseHelper sharedInstance] queryTable:@"event" withSelect:seletes andWhere:(_type == 4)?wheres1:wheres2 completion:^(NSMutableArray *resultsArray) {
        NSMutableArray *result = resultsArray;
        for (int i = 0; i < result.count; i++) {
            NSDictionary* temp = [result objectAtIndex:i];
            NSString *tmpa = [temp valueForKey:@"event_info"];
            tmpa = [tmpa stringByReplacingOccurrencesOfString:@"''" withString:@"'"];
            NSData *tmpb = [tmpa dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *event =  [NSJSONSerialization JSONObjectWithData:tmpb options:NSJSONReadingMutableLeaves error:nil];
            [self.events addObject:event];
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [_tableView reloadData];
        });

    }];
    
}


-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    //[self.tableView reloadData];
}


- (void) getEventids
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:[MTUser sharedInstance].userid forKey:@"id"];
    [dictionary setValue:[NSNumber numberWithInteger:_type] forKey:@"type"];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:GET_MY_EVENTS];
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

-(void)showAlert
{
    _Alert = [[UIAlertView alloc] initWithTitle:@"" message:@"没有更多了" delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
    [_Alert show];
    self.Footeropen = NO;
    [_footer endRefreshing];
}
-(void)performDismiss
{
    [_Alert dismissWithClickedButtonIndex:0 animated:YES];
}

#pragma mark 代理方法-UITableView

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (![self.morefuctions isHidden]) {
        [self closeButtonView];
        return;
    }
    
    
    CustomCellTableViewCell *cell = (CustomCellTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    self.selete_Eventid = cell.eventId;
    self.selete_EventLauncherid = cell.launcherId;

//    [self performSegueWithIdentifier:@"eventDetailIdentifier" sender:self];
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone"
                                                             bundle: nil];
    EventDetailViewController *eventVC = [mainStoryboard instantiateViewControllerWithIdentifier: @"EventDetailViewController"];
    eventVC.eventId = cell.eventId;
    eventVC.eventLauncherId = cell.launcherId;
    eventVC.event = cell.eventInfo;

    [self.navigationController pushViewController:eventVC animated:YES];
    
}

#pragma mark 用segue跳转时传递参数eventid
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //这里我很谨慎的对sender和目标视图控制器作了判断
    if (![self.morefuctions isHidden]) {
        [self closeButtonView];
    }
    if ([segue.destinationViewController isKindOfClass:[EventDetailViewController class]]) {
        EventDetailViewController *nextViewController = segue.destinationViewController;
        nextViewController.eventId = self.selete_Eventid;
        nextViewController.eventLauncherId = self.selete_EventLauncherid;
    }
    if ([segue.destinationViewController isKindOfClass:[PictureWall2 class]]) {
        PictureWall2 *nextViewController = segue.destinationViewController;
        nextViewController.eventId = self.selete_Eventid;
        nextViewController.eventName = self.selete_EventName;
        nextViewController.eventLauncherId = self.selete_EventLauncherid;
    }
    if ([segue.destinationViewController isKindOfClass:[VideoWallViewController class]]) {
        VideoWallViewController *nextViewController = segue.destinationViewController;
        nextViewController.eventId = self.selete_Eventid;
        nextViewController.eventName = self.selete_EventName;
        nextViewController.eventLauncherId = self.selete_EventLauncherid;
    }
    if ([segue.destinationViewController isKindOfClass:[LaunchEventViewController class]]) {
        LaunchEventViewController *nextViewController = segue.destinationViewController;
        nextViewController.controller = self;
        
    }
    if ([segue.destinationViewController isKindOfClass:[DynamicViewController class]]) {
        DynamicViewController *nextViewController = segue.destinationViewController;
        nextViewController.atMeEvents = _atMeEvents;
        nextViewController.updateEventStatus = _updateEventStatus;
    }
    
    
}


#pragma mark 代理方法-进入刷新状态就会调用
- (void)refreshViewBeginRefreshing:(MJRefreshBaseView *)refreshView
{
    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == 0) {
        MTLOG(@"没有网络");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [SVProgressHUD showErrorWithStatus:@"网络异常" duration:1.f];
            [refreshView endRefreshing];
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
        MTLOG(@"header Begin");
        _Headeropen = YES;
        _clearIds = YES;
        [self getEventids];
        [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(closeRJ) userInfo:nil repeats:NO];
    }else if(refreshView == _footer){
        MTLOG(@"footer Begin");
        _Footeropen = YES;
        _clearIds = NO;
        
        if (_eventIds_all.count <= _events.count) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self showAlert];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.7f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self performDismiss];
                });
            });
            return;
        }
        
        NSInteger beginEventId = [_events count];
        NSInteger endEventId = beginEventId + 10;
        if (endEventId > _eventIds_all.count) {
            endEventId = _eventIds_all.count;
        }
        
        [self getEvents:[_eventIds_all subarrayWithRange:NSMakeRange(beginEventId, endEventId - beginEventId)]];
        [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(closeRJ) userInfo:nil repeats:NO];
    }
    
}

#pragma mark notificationDidReceive
-(void)notificationDidReceive:(NSArray *)messages
{
    for (NSInteger i = 0; i < messages.count; i++) {
        NSDictionary*message = [messages objectAtIndex:i];
        MTLOG(@"homeviewcontroller receive a message %@",message);
        
        NSNumber* msg_cmd = [message objectForKey:@"cmd"];
        if ([msg_cmd integerValue] == SYSTEM_PUSH) {   //cmd 666
            return;
        }
        
        NSString *eventInfo = [message valueForKey:@"content"];
        NSData *eventData = [eventInfo dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *event =  [NSJSONSerialization JSONObjectWithData:eventData options:NSJSONReadingMutableLeaves error:nil];
        int cmd = [[event valueForKey:@"cmd"] intValue];
        MTLOG(@"cmd: %d",cmd);
        if (cmd == NEW_COMMENT_NOTIFICATION || cmd == NEW_PHOTO_NOTIFICATION || cmd == NEW_VIDEO_NOTIFICATION || cmd == NEW_VIDEO_COMMENT_REPLY || cmd == NEW_PHOTO_COMMENT_REPLY || cmd == NEW_COMMENT_REPLY || cmd == NEW_LIKE_NOTIFICATION) {
            [self adjustInfoView];
        }
        
    }
}



//
//#pragma mark 代理方法-触摸scrollview开始时调用
//-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{
//}

- (void) tableViewReload
{
    [_header endRefreshing];
    //[self pullEventsFromDB];
    [self.tableView reloadData];
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
    [self.tableView reloadData];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name: @"reloadEvent" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name: @"deleteItem" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name: @"replaceItem" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name: @"PopToFirstPageAndTurnToNotificationPage" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name: @"adjustInfoView" object:nil];
    
    [_header free];
    [_footer free];
    
}

- (IBAction)toDynamic:(id)sender {
    
    _updateInfoNumLabel.text = @"";
    [_updateInfoView setHidden:YES];
    CGRect frame = _tableView.frame;
    if (frame.origin.y == 40) {
        frame.origin.y = 0;
        frame.size.height += 40;
        [_tableView setFrame:frame];
    }
    
    [self performSegueWithIdentifier:@"toDynamics" sender:self];
}

- (IBAction)closeOptionView:(id)sender {
    if (!self.morefuctions.isHidden) {
        [self closeButtonView];
        [UIView beginAnimations:@"shadowViewDisappear" context:nil];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationDelegate:self];
        self.shadowView.alpha = 0;
        [UIView commitAnimations];
    }
    if (_ArrangementView.frame.size.height != 1) {
        [self chooseArrangement:nil];
    }
    
}

- (IBAction)CloseMenu:(id)sender {
    if (self.morefuctions.isHidden && _ArrangementView.frame.size.height == 1) {
        [((SlideNavigationController*)self.navigationController) closeMenuWithCompletion:nil];
    }
}

- (IBAction)chooseArrangement:(id)sender {
    [_morefuctions setHidden:YES];
    if (_ArrangementView.frame.size.height == 1) {
        [UIView beginAnimations:@"shadowViewAppear" context:nil];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationDelegate:self];
        self.shadowView.alpha = 0.5;
        [UIView commitAnimations];
    }else{
        [UIView beginAnimations:@"shadowViewAppear" context:nil];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationDelegate:self];
        self.shadowView.alpha = 0;
        [UIView commitAnimations];
    }
    
    
    
    [UIView beginAnimations:@"ArrangementAppear" context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDelegate:self];
    CGRect frame = _ArrangementView.frame;
    frame.size.height = (frame.size.height == 1)? 81:1;
    self.ArrangementView.frame = frame;
    self.ArrangementView.alpha = (frame.size.height == 1)? 0:1;
    [UIView commitAnimations];
    
    
}

- (IBAction)arrangebyAddTime:(id)sender {
    [self chooseArrangement:nil];
    [UIView beginAnimations:@"shadowViewAppear" context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDelegate:self];
    self.shadowView.alpha = 0;
    [UIView commitAnimations];
    if (_type == 4) {
        [sender setBackgroundImage:[CommonUtils createImageWithColor:[UIColor colorWithRed:232/255.0 green:232/255.0 blue:232/255.0 alpha:1.0]] forState:UIControlStateNormal];
        [_arrangementButtons[1] setBackgroundImage:nil forState:UIControlStateNormal];
        _type = 0;
        NSUserDefaults* userDfs = [NSUserDefaults standardUserDefaults];
        [userDfs setObject:[NSNumber numberWithInteger:_type] forKey:[NSString stringWithFormat:@"%@sortType",[MTUser sharedInstance].userid]];
        [userDfs synchronize];


        [_header beginRefreshing];
    }
}

- (IBAction)arrangebyStartTime:(id)sender {
    [self chooseArrangement:nil];
    [UIView beginAnimations:@"shadowViewAppear" context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDelegate:self];
    self.shadowView.alpha = 0;
    [UIView commitAnimations];
    if (_type == 0) {
        [sender setBackgroundImage:[CommonUtils createImageWithColor:[UIColor colorWithRed:232/255.0 green:232/255.0 blue:232/255.0 alpha:1.0]] forState:UIControlStateNormal];
        [_arrangementButtons[0] setBackgroundImage:nil forState:UIControlStateNormal];
        _type = 4;
        NSUserDefaults* userDfs = [NSUserDefaults standardUserDefaults];
        [userDfs setObject:[NSNumber numberWithInteger:_type] forKey:[NSString stringWithFormat:@"%@sortType",[MTUser sharedInstance].userid]];
        [userDfs synchronize];
        [_header beginRefreshing];
    }
    
}



-(void)option
{
    if (self.morefuctions.isHidden) {
        if (_ArrangementView.frame.size.height != 1) {
            [UIView beginAnimations:@"ArrangementAppear" context:nil];
            [UIView setAnimationDuration:0.5];
            [UIView setAnimationDelegate:self];
            CGRect frame = _ArrangementView.frame;
            frame.size.height = (frame.size.height == 1)? 81:1;
            self.ArrangementView.frame = frame;
            [UIView commitAnimations];
        }
        [self.morefuctions setHidden:NO];
        [UIView beginAnimations:@"shadowViewAppear" context:nil];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationDelegate:self];
        self.shadowView.alpha = 0.5;
        [UIView commitAnimations];
        
    }else{
        [self closeOptionView:nil];
    }
}




-(void)closeButtonView
{
    [self.morefuctions setHidden:YES];
}

@end

//
//@implementation UIScrollView(UITouchEvent)
//
//-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    [[self nextResponder]touchesBegan:touches withEvent:event];
//    [super touchesBegan:touches withEvent:event];
//}
//
//
//-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    [[self nextResponder]touchesMoved:touches withEvent:event];
//    [super touchesMoved:touches withEvent:event];
//}
//
//-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    [[self nextResponder]touchesEnded:touches withEvent:event];
//    [super touchesEnded:touches withEvent:event];
//}
//
//@end

