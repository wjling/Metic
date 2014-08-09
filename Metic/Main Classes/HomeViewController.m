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
@property (strong, nonatomic) IBOutlet UILabel *updateInfoNumLabel;
@property (nonatomic,strong) NSMutableSet* updateEventIds;
@property (nonatomic,strong) NSMutableArray* updateEvents;
@property (nonatomic,strong) NSMutableArray* atMeEvents;
@property (nonatomic,strong) UIAlertView *Alert;
@property int type;
@property BOOL clearIds;
@property BOOL Headeropen;
@property BOOL Footeropen;
@end




@implementation HomeViewController
@synthesize listenerDelegate;

- (void)viewDidLoad
{
    [super viewDidLoad];
    _type = 0;
    _clearIds = NO;
    _Headeropen = NO;
    _Footeropen = NO;
    _updateEventIds = [MTUser sharedInstance].updateEventIds;
    _updateEvents = [MTUser sharedInstance].updateEvents;
    _atMeEvents = [MTUser sharedInstance].atMeEvents;
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    ((AppDelegate*)[UIApplication sharedApplication].delegate).homeViewController = self;

    [self createMenuButton];
    
    [_morefuctions.layer setCornerRadius:6];
    [_ArrangementView.layer setCornerRadius:6];
    _ArrangementView.
    clipsToBounds = YES;
    for (UIButton* button in _arrangementButtons) {
        
        [button setBackgroundImage:[CommonUtils createImageWithColor:[UIColor colorWithRed:232/255.0 green:232/255.0 blue:232/255.0 alpha:1.0]] forState:UIControlStateHighlighted];
    }
    [_arrangementButtons[0] setBackgroundImage:[CommonUtils createImageWithColor:[UIColor colorWithRed:232/255.0 green:232/255.0 blue:232/255.0 alpha:1.0]] forState:UIControlStateNormal];
    self.user = [MTUser sharedInstance];
    [self.user getInfo:self.user.userid myid:self.user.userid delegateId:self];
    //[self.user updateAvatarList];
    
    self.tableView.homeController= self;
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self.tableView];
    self.events = [[NSMutableArray alloc]init];
    self.tableView.eventsSource = self.events;
    
    self.sql = [[MySqlite alloc]init];
    [self pullEventsFromDB];

    //初始化下拉刷新功能
    _header = [[MJRefreshHeaderView alloc]init];
    _header.delegate = self;
    _header.scrollView = self.tableView;
    [_header beginRefreshing];

    //初始化上拉加载更多
    _footer = [[MJRefreshFooterView alloc]init];
    _footer.delegate = self;
    _footer.scrollView = _tableView;
    
    
    self.listenerDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [self.listenerDelegate connect];

    self.sql = [[MySqlite alloc]init];
    [self pullEventsFromDB];
    
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.shadowView setAlpha:0];
    
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
    long num = _updateEvents.count + _atMeEvents.count;
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
                [AppDelegate refreshMenu];
                ((AppDelegate*)[UIApplication sharedApplication].delegate).homeViewController = self;
                NSLog(@"set homeViewController");
            }
            
            else if ([response1 valueForKey:@"event_list"]) { //获取event具体信息
                if (_clearIds) [_events removeAllObjects];
                [self.events addObjectsFromArray:[response1 valueForKey:@"event_list"]];
                [_tableView reloadData];
                [self closeRJ];
                [self updateEventToDB:[response1 valueForKey:@"event_list"]];
                
                
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




#pragma mark - 数据库操作
- (void)updateEventToDB:(NSArray*)events
{
    NSString * path = [NSString stringWithFormat:@"%@/db",[MTUser sharedInstance].userid];
    [self.sql openMyDB:path];
    for (NSDictionary *event in events) {
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
    self.tableView.eventsSource = self.events;
    NSArray *seletes = [[NSArray alloc]initWithObjects:@"event_info", nil];
    NSDictionary *wheres = [[NSDictionary alloc] initWithObjectsAndKeys:@"1 order by event_id desc",@"1", nil];
    NSMutableArray *result = [self.sql queryTable:@"event" withSelect:seletes andWhere:wheres];
    for (NSDictionary *temp in result) {
        NSString *tmpa = [temp valueForKey:@"event_info"];
        tmpa = [tmpa stringByReplacingOccurrencesOfString:@"''" withString:@"'"];
        NSData *tmpb = [tmpa dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *event =  [NSJSONSerialization JSONObjectWithData:tmpb options:NSJSONReadingMutableLeaves error:nil];
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
    [dictionary setValue:[NSNumber numberWithInt:_type] forKey:@"type"];
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

-(void)showAlert
{
    _Alert = [[UIAlertView alloc] initWithTitle:@"" message:@"没有更多了" delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
    [_Alert show];
    self.Footeropen = NO;
    [_footer endRefreshing];
}
-(void)performDismiss
{
    [_Alert dismissWithClickedButtonIndex:0 animated:NO];
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
    if (refreshView == _header) {
        NSLog(@"header Begin");
        _Headeropen = YES;
        _clearIds = YES;
        [self getEventids];
        [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(closeRJ) userInfo:nil repeats:NO];
    }else if(refreshView == _footer){
        NSLog(@"footer Begin");
        _Footeropen = YES;
        _clearIds = NO;
        
        if (_eventIds_all.count <= _events.count) {
            [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(showAlert) userInfo:nil repeats:NO];
            [NSTimer scheduledTimerWithTimeInterval:1.2f target:self selector:@selector(performDismiss) userInfo:nil repeats:NO];
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
    [_header free];
    
}

- (IBAction)toDynamic:(id)sender {
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
    if (_ArrangementView.frame.size.height != 0) {
        [self chooseArrangement:nil];
    }
    
}

- (IBAction)CloseMenu:(id)sender {
    if (self.morefuctions.isHidden && _ArrangementView.frame.size.height == 0) {
        [((SlideNavigationController*)self.navigationController) closeMenuWithCompletion:nil];
    }
}

- (IBAction)chooseArrangement:(id)sender {
    [_morefuctions setHidden:YES];
    if (_ArrangementView.frame.size.height == 0) {
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
    frame.size.height = (frame.size.height == 0)? 81:0;
    self.ArrangementView.frame = frame;
    [UIView commitAnimations];
    
    
}

- (IBAction)arrangebyAddTime:(id)sender {
    [self chooseArrangement:nil];
    if (_type == 4) {
        [sender setBackgroundImage:[CommonUtils createImageWithColor:[UIColor colorWithRed:232/255.0 green:232/255.0 blue:232/255.0 alpha:1.0]] forState:UIControlStateNormal];
        [_arrangementButtons[1] setBackgroundImage:nil forState:UIControlStateNormal];
        _type = 0;
        [_header beginRefreshing];
    }
}

- (IBAction)arrangebyStartTime:(id)sender {
    [self chooseArrangement:nil];
    if (_type == 0) {
        [sender setBackgroundImage:[CommonUtils createImageWithColor:[UIColor colorWithRed:232/255.0 green:232/255.0 blue:232/255.0 alpha:1.0]] forState:UIControlStateNormal];
        [_arrangementButtons[0] setBackgroundImage:nil forState:UIControlStateNormal];
        _type = 4;
        [_header beginRefreshing];
    }
    
}



-(void)option
{
    if (self.morefuctions.isHidden) {
        if (_ArrangementView.frame.size.height != 0) {
            [UIView beginAnimations:@"ArrangementAppear" context:nil];
            [UIView setAnimationDuration:0.5];
            [UIView setAnimationDelegate:self];
            CGRect frame = _ArrangementView.frame;
            frame.size.height = (frame.size.height == 0)? 81:0;
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

