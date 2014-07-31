//
//  HomeViewController.m
//  SlideMenu
//
//  Created by Aryan Gh on 4/24/13.
//  Copyright (c) 2013 Aryan Ghassemi. All rights reserved.
//

#import "../Cell/CustomCellTableViewCell.h"
#import "HomeViewController.h"
#import "NSString+JSON.h"
#import "EventDetailViewController.h"
#import "../Cell/MTTableView.h"
#import "../Utils/PhotoGetter.h"
#import "PictureWallViewController.h"
#import "LaunchEventViewController.h"
#import "DynamicViewController.h"

@interface HomeViewController ()


@property (strong, nonatomic) IBOutlet MTTableView *tableView;
@property (strong, nonatomic) IBOutlet MTTableView *mytableView;
@property (strong, nonatomic) IBOutlet MTTableView *frtableView;
@property (strong, nonatomic) IBOutlet MTTableView *tatableView;
@property (strong, nonatomic) MTTableView *eventsTableView;
@property (strong, nonatomic) IBOutlet UILabel *updateInfoNumLabel;
@property (nonatomic,strong) NSMutableSet* updateEventIds;
@property (nonatomic,strong) NSMutableArray* updateEvents;
@property (nonatomic,strong) NSMutableArray* atMeEvents;
@end




@implementation HomeViewController
@synthesize listenerDelegate;

- (void)viewDidLoad
{
    [super viewDidLoad];
    _updateEventIds = [MTUser sharedInstance].updateEventIds;
    _updateEvents = [MTUser sharedInstance].updateEvents;
    _atMeEvents = [MTUser sharedInstance].atMeEvents;
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    ((AppDelegate*)[UIApplication sharedApplication].delegate).homeViewController = self;
    
    
    [self createMenuButton];
    self.user = [MTUser sharedInstance];
    [self.user getInfo:self.user.userid myid:self.user.userid delegateId:self];
    //[self.user updateAvatarList];
    
    self.scrollView.delegate = self;
    self.tableView.homeController= self;
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self.tableView];
    self.mytableView.homeController= self;
    [self.mytableView setDelegate:self];
    [self.mytableView setDataSource:self.mytableView];
    self.frtableView.homeController= self;
    [self.frtableView setDelegate:self];
    [self.frtableView setDataSource:self.frtableView];
    self.tatableView.homeController= self;
    [self.tatableView setDelegate:self];
    [self.tatableView setDataSource:self.tatableView];
    
    self.tableView.eventsSource = self.events;
    self.mytableView.eventsSource = self.myevents;
    self.frtableView.eventsSource = self.frevents;
    self.tatableView.eventsSource = self.taevents;
    
    self.eventsTableView = self.tableView;
    self.events = [[NSMutableArray alloc]init];
    self.myevents = [[NSMutableArray alloc]init];
    self.frevents = [[NSMutableArray alloc]init];
    self.taevents = [[NSMutableArray alloc]init];
    self.indicatior = [[UILabel alloc]initWithFrame:CGRectMake(24, 32, 48, 3)];
    [self.indicatior setBackgroundColor:[UIColor colorWithRed:20.0/255.0 green:180.0/255.0 blue:150.0/255.0 alpha:1.0]];
    [self.indicatior setHidden:NO];
    [self.controlView addSubview:self.indicatior];
    [self.controlView setScrollEnabled:YES];
    [self.controlView setShowsHorizontalScrollIndicator:NO];
    
    

    //初始化下拉刷新功能
    _header = [[MJRefreshHeaderView alloc]init];
    _header.delegate = self;
    _header.scrollView = self.tableView;
    [_header beginRefreshing];

    
    self.listenerDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [self.listenerDelegate connect];

    self.sql = [[MySqlite alloc]init];
    [self pullEventsFromDB];
    
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.view bringSubviewToFront: self.shadowView];
    [self.scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
    ((AppDelegate*)[UIApplication sharedApplication].delegate).notificationDelegate = self;
}

-(void)viewDidAppear:(BOOL)animated
{
    [self performSelector:@selector(adjustInfoView) withObject:nil afterDelay:0.3f];
}



-(void)createMenuButton
{
    UIImage* image = [UIImage imageNamed:@"dian"];
    CGRect frame = CGRectMake(1000,0,25,44);
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
    //NSLog(@"%f  %f",_scrollView.frame.origin.y ,_scrollView.frame.size.height);
    int num = _updateEvents.count + _atMeEvents.count;
    if (num > 0) {
        [_updateInfoView setHidden:NO];
        if (num < 10) {
            _updateInfoNumLabel.text = [NSString stringWithFormat:@"+%d",num];
        }else _updateInfoNumLabel.text = @"+N";
        CGRect frame = _scrollView.frame;
        if (frame.origin.y == 35) {
            frame.origin.y = 75;
            frame.size.height -= 40;
            [_scrollView setFrame:frame];
        }
    }else{
        _updateInfoNumLabel.text = @"";
        [_updateInfoView setHidden:YES];
        CGRect frame = _scrollView.frame;
        if (frame.origin.y == 75) {
            frame.origin.y = 35;
            frame.size.height += 40;
            [_scrollView setFrame:frame];
        }
    }
}
#pragma mark - UIScrollView Methods -

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSLog(@"%f",self.scrollView.contentOffset.x);
    int position = self.scrollView.contentOffset.x/310;
    switch (position) {
        case 0:
            self.header.scrollView = self.tableView;
            self.eventsTableView = self.tableView;
            break;
        case 1:
            self.header.scrollView = self.mytableView;
            self.eventsTableView = self.mytableView;
            break;
        case 2:
            self.header.scrollView = self.frtableView;
            self.eventsTableView = self.frtableView;
            break;
        case 3:
            self.header.scrollView = self.tatableView;
            self.eventsTableView = self.tatableView;
            break;
        default:
            break;
    }
    [self.eventsTableView reloadData];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //NSLog(@"%f",self.controlView.contentOffset.x);
    float position = self.scrollView.contentOffset.x;
    float newposition = position/740*190+24;
    if (newposition > 250) {
        [self more:nil];
    }else if(newposition < 100) [self.controlView setContentOffset:CGPointMake(0, 0) animated:YES];
    [self.indicatior setFrame:CGRectMake(newposition, 32, 48, 3)];
}
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (![self.morefuctions isHidden]) {
        [self closeButtonView];
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
            if ([response1 valueForKey:@"name"]) {//更新用户信息
                
                [self.user initWithData:response1];
                
            }
            
            else if ([response1 valueForKey:@"event_list"]) { //获取event具体信息
                self.events = [response1 valueForKey:@"event_list"];
                [self updateEventToDB];
                
            }
            else{//获取event id 号
                self.eventIds = [response1 valueForKey:@"sequence"];
                [self getEvents:self.eventIds];
            }
        }
            break;
    }
}




#pragma mark - 数据库操作
- (void)updateEventToDB
{
    NSString * path = [NSString stringWithFormat:@"%@/db",[MTUser sharedInstance].userid];
    [self.sql openMyDB:path];
    for (NSDictionary *event in self.events) {
        NSString *eventData = [NSString jsonStringWithDictionary:event];
        eventData = [eventData stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        NSArray *columns = [[NSArray alloc]initWithObjects:@"'event_id'",@"'event_info'", nil];
        NSArray *values = [[NSArray alloc]initWithObjects:[NSString stringWithFormat:@"%@",[event valueForKey:@"event_id"]],[NSString stringWithFormat:@"'%@'",eventData], nil];
        
        [self.sql insertToTable:@"event" withColumns:columns andValues:values];
    }
    
    [self.sql closeMyDB];
}


- (void)pullEventsFromDB
{
    NSString * path = [NSString stringWithFormat:@"%@/db",[MTUser sharedInstance].userid];
    [self.sql openMyDB:path];

    self.events = [[NSMutableArray alloc]init];
    self.myevents = [[NSMutableArray alloc]init];
    self.frevents = [[NSMutableArray alloc]init];
    self.taevents = [[NSMutableArray alloc]init];
    self.tableView.eventsSource = self.events;
    self.mytableView.eventsSource = self.myevents;
    self.frtableView.eventsSource = self.frevents;
    self.tatableView.eventsSource = self.taevents;
    NSArray *seletes = [[NSArray alloc]initWithObjects:@"event_info", nil];
    NSDictionary *wheres = [[NSDictionary alloc] initWithObjectsAndKeys:@"1 order by event_id desc",@"1", nil];
    NSMutableArray *result = [self.sql queryTable:@"event" withSelect:seletes andWhere:wheres];
    for (NSDictionary *temp in result) {
        NSString *tmpa = [temp valueForKey:@"event_info"];
        tmpa = [tmpa stringByReplacingOccurrencesOfString:@"''" withString:@"'"];
        NSData *tmpb = [tmpa dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *event =  [NSJSONSerialization JSONObjectWithData:tmpb options:NSJSONReadingMutableLeaves error:nil];
        NSNumber* launcherId = [event valueForKey:@"launcher_id"];
        if ([launcherId intValue] == [[MTUser sharedInstance].userid intValue]) {
            [self.myevents addObject:event];
            
        }else if([[MTUser sharedInstance].friendsIdSet containsObject:launcherId]){
            [self.frevents addObject:event];
        }else{
            [self.taevents addObject:event];
        }
        [self.events addObject:event];
    }
    
    [self.sql closeMyDB];
}


-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    //[self.tableView reloadData];
}


- (void) getEventids
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:_user.userid forKey:@"id"];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:GET_MY_EVENTS];
}

- (void) getEvents: (NSArray *)eventids
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:eventids forKey:@"sequence"];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:GET_EVENTS];
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
    [self performSegueWithIdentifier:@"eventDetailIdentifier" sender:self];
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
    }
    if ([segue.destinationViewController isKindOfClass:[PictureWallViewController class]]) {
            PictureWallViewController *nextViewController = segue.destinationViewController;
            nextViewController.eventId = self.selete_Eventid;

    }
    if ([segue.destinationViewController isKindOfClass:[LaunchEventViewController class]]) {
        LaunchEventViewController *nextViewController = segue.destinationViewController;
        nextViewController.controller = self;
        
    }
    if ([segue.destinationViewController isKindOfClass:[DynamicViewController class]]) {
        DynamicViewController *nextViewController = segue.destinationViewController;
        nextViewController.updateEvents = [[NSMutableArray alloc]initWithArray: _updateEvents];
        nextViewController.atMeEvents = [[NSMutableArray alloc] initWithArray:_atMeEvents];
        [self.atMeEvents removeAllObjects];
        [self.updateEventIds removeAllObjects];
        [self.updateEvents removeAllObjects];
    }
    
}


#pragma mark 代理方法-进入刷新状态就会调用
- (void)refreshViewBeginRefreshing:(MJRefreshBaseView *)refreshView
{
    self.scrollView.scrollEnabled = NO;
    NSLog(@"begin");
    [self getEventids];
    [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(tableViewReload) userInfo:nil repeats:NO];
}

#pragma mark notificationDidReceive
-(void)notificationDidReceive:(NSArray *)messages
{
    for (NSDictionary* message in messages) {
        NSLog(@"receive a message %@",message);
        NSString *eventInfo = [message valueForKey:@"msg"];
        NSData *eventData = [eventInfo dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *event =  [NSJSONSerialization JSONObjectWithData:eventData options:NSJSONReadingMutableLeaves error:nil];
        int cmd = [[event valueForKey:@"cmd"] intValue];
        if (cmd == 993 || cmd == 992 || cmd == 991 || cmd == 988 || cmd == 989) {
            [self adjustInfoView];
        }
        
    }
}




#pragma mark 代理方法-触摸scrollview开始时调用
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
}

- (void) tableViewReload
{
    [_header endRefreshing];
    self.scrollView.scrollEnabled = YES;
    [self pullEventsFromDB];
    [self.eventsTableView reloadData];
}

- (void)dealloc
{
    [_header free];
    
}
- (IBAction)showAllEvents:(id)sender
{
    if (self.scrollView.contentOffset.x!=0) {
        [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    }
    
}
- (IBAction)showMyEvents:(id)sender
{
    if (self.scrollView.contentOffset.x!=310) {
        [self.scrollView setContentOffset:CGPointMake(310, 0) animated:YES];
    }
}
- (IBAction)showFrEvents:(id)sender
{
    if (self.scrollView.contentOffset.x!=620) {
        [self.scrollView setContentOffset:CGPointMake(620, 0) animated:YES];
    }
}

- (IBAction)showTaEvents:(id)sender {
    if (self.scrollView.contentOffset.x!=930) {
        [self.scrollView setContentOffset:CGPointMake(930, 0) animated:YES];
    }
}

- (IBAction)toDynamic:(id)sender {
    [self performSegueWithIdentifier:@"toDynamics" sender:self];
}


-(void)option
{
    if (self.morefuctions.isHidden) {
        [self.morefuctions setHidden:NO];
        //[self.view bringSubviewToFront:self.morefuctions];
        //设置“更多”图层边框阴影
        [self.morefuctions.layer setShadowOffset:CGSizeMake(1,1)];
        [self.morefuctions.layer setShadowOpacity:1.0];
        [self.morefuctions.layer setShadowRadius:5];
        [self.morefuctions.layer setShadowColor:[UIColor blackColor].CGColor];
    }else{
        [self closeButtonView];
    }
}

- (IBAction)more:(id)sender {
    [self.controlView setContentOffset:CGPointMake(65, 0) animated:YES];
    
}

-(void)closeButtonView
{
    [self.morefuctions setHidden:YES];
    //[self.view sendSubviewToBack:self.morefuctions];
    
}

@end


@implementation UIScrollView(UITouchEvent)

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[self nextResponder]touchesBegan:touches withEvent:event];
    [super touchesBegan:touches withEvent:event];
}


-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[self nextResponder]touchesMoved:touches withEvent:event];
    [super touchesMoved:touches withEvent:event];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[self nextResponder]touchesEnded:touches withEvent:event];
    [super touchesEnded:touches withEvent:event];
}

@end

