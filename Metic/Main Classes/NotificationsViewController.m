//
//  NotificationsViewController.m
//  Metic
//
//  Created by mac on 14-6-23.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "NotificationsViewController.h"
#define MTUser_msgFromDB [MTUser sharedInstance].msgFromDB
#define MTUser_eventRequestMsg [MTUser sharedInstance].eventRequestMsg
#define MTUser_friendRequestMsg [MTUser sharedInstance].friendRequestMsg
#define MTUser_systemMsg [MTUser sharedInstance].systemMsg
#define MTUser_historicalMsg [MTUser sharedInstance].historicalMsg

@interface NotificationsViewController ()
{
    MySqlite* mySql;
    NSString* DB_path;
    NSIndexPath* selectedPath;
    NSInteger tab_index;
    CGFloat lastX;
    BOOL clickTab;
    UIView* tabIndicator;
}

enum Response_Type
{
    RESPONSE_EVENT = 0,
    RESPONSE_FRIEND,
    RESPONSE_SYSTEM
};

@end

@implementation NotificationsViewController
//@synthesize msgFromDB;
@synthesize friendRequestMsg;
@synthesize eventRequestMsg;
@synthesize systemMsg;
//@synthesize historicalMsg;
@synthesize appListener;
@synthesize tabs;
@synthesize rightBarButton;
@synthesize functions_uiview;
@synthesize function1_button;
@synthesize function2_button;

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
    // Do any additional setup after loading the view.
    self.appListener = (AppDelegate*)[UIApplication sharedApplication].delegate;
    self.appListener.notificationDelegate = self;
    [self initParams];
//    [self getMsgFromDataBase];
//    NSLog(@"hahahah");
//    self.msgFromDB = [MTUser sharedInstance].msgFromDB;
//    self.eventRequestMsg = [MTUser sharedInstance].eventRequestMsg;
//    self.friendRequestMsg = [MTUser sharedInstance].friendRequestMsg;
//    self.systemMsg = [MTUser sharedInstance].systemMsg;
//    self.historicalMsg = [MTUser sharedInstance].historicalMsg;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.appListener.notificationDelegate = self;
    self.eventRequestMsg = [[NSMutableArray alloc]initWithArray:[MTUser sharedInstance].eventRequestMsg];
    self.friendRequestMsg = [[NSMutableArray alloc]initWithArray:[MTUser sharedInstance].friendRequestMsg];
    self.systemMsg = [[NSMutableArray alloc]initWithArray:[MTUser sharedInstance].systemMsg];
    if (tab_index == 0) {
        [self.eventRequest_tableView reloadData];
    }
    else if (tab_index == 1)
    {
        [self.friendRequest_tableView reloadData];
    }
    else if (tab_index == 2)
    {
        [self.systemMessage_tableView reloadData];
    }
//    id temp = [eventRequestMsg objectAtIndex:0];
//    if ([temp isKindOfClass:[NSMutableDictionary class]]) {
//        NSLog(@"temp is mutable_dic");
//    }
//    else if ([temp isKindOfClass:[NSDictionary class]])
//    {
//        NSLog(@"temp is dic");
//    }
    
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    NSLog(@"hennnnn");
    self.content_scrollView.contentSize = CGSizeMake(320*self.tabs.count, self.content_scrollView.frame.size.height); //不设这个contentSize的话scrollRectToVisible方法无效
    self.tabbar_scrollview.contentSize = CGSizeMake(960, 40);
    
    
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
//    if ([segue.destinationViewController isKindOfClass:[HistoricalNotificationViewController class]]) {
//        HistoricalNotificationViewController* viewController = (HistoricalNotificationViewController*)segue.destinationViewController;
//        //        NSLog(@"pass fid value: %@",selectedFriendID);
//        
//        viewController.historicalMsgs = self.historicalMsg;
//    }

}


- (void)initParams
{
//    self.msgFromDB = [[NSMutableArray alloc]init];
//    self.friendRequestMsg = [[NSMutableArray alloc]init];
//    self.eventRequestMsg = [[NSMutableArray alloc]init];
//    self.systemMsg = [[NSMutableArray alloc]init];
//    self.historicalMsg = [[NSMutableArray alloc]init];
    selectedPath = [[NSIndexPath alloc]init];
    mySql = [[MySqlite alloc]init];
    DB_path = [[NSString alloc]initWithFormat:@"%@/db",[MTUser sharedInstance].userid];
    self.friendRequest_tableView.delegate = self;
    self.friendRequest_tableView.dataSource = self;
    self.eventRequest_tableView.delegate = self;
    self.eventRequest_tableView.dataSource = self;
    self.systemMessage_tableView.delegate = self;
    self.systemMessage_tableView.dataSource = self;
    
    
    [functions_uiview setHidden:YES];
    UIColor* color1 = [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1];
    UIColor* color2 = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
    [function1_button setBackgroundColor:color1];
    [function2_button setBackgroundColor:color2];
    
    [function1_button addTarget:self action:@selector(function1Clicked:) forControlEvents:UIControlEventTouchUpInside];
    [function2_button addTarget:self action:@selector(function2Clicked:) forControlEvents:UIControlEventTouchUpInside];
    
    self.tabbar_scrollview.scrollEnabled = NO;
    CGRect frame = self.tabbar_scrollview.frame;
    
    int x = 0;
    CGFloat width = frame.size.width/3;
    int height = frame.size.height;
    UIButton* eventR_button = [[UIButton alloc]initWithFrame:CGRectMake(x, 0, width, height)];
    UIButton* friendR_button = [[UIButton alloc]initWithFrame:CGRectMake(x+width, 0, width, height)];
    UIButton* systemMsg_button = [[UIButton alloc]initWithFrame:CGRectMake(x+width*2, 0, width, height)];
    self.tabs = [[NSMutableArray alloc]initWithObjects:eventR_button,friendR_button,systemMsg_button, nil];
    
    UIColor *tabIndicatorColor = [UIColor colorWithRed:0.29 green:0.76 blue:0.61 alpha:1];
    tabIndicator = [[UIView alloc]initWithFrame:CGRectMake(10, height - 3, width - 20, 3)];
    
    [self.tabbar_scrollview addSubview:tabIndicator];
//    eventR_button.showsTouchWhenHighlighted = NO;
//    friendR_button.showsTouchWhenHighlighted = NO;
//    systemMsg_button.showsTouchWhenHighlighted = NO;
    eventR_button.adjustsImageWhenHighlighted = NO;
    friendR_button.adjustsImageWhenHighlighted = NO;
    systemMsg_button.adjustsImageWhenHighlighted = NO;
    
    UIColor* bColor_normal = [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1];
    UIColor* bColor_selected = [UIColor colorWithRed:0.577 green:0.577 blue:0.577 alpha:1];
    UIColor* tColor_normal = [UIColor colorWithRed:0.553 green:0.553 blue:0.553 alpha:1];
    UIColor* tColor_selected = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
    
//    [eventR_button setBackgroundColor:bColor_selected];
//    [friendR_button setBackgroundColor:bColor_normal];
//    [systemMsg_button setBackgroundColor:bColor_normal];
    
//    [eventR_button setBackgroundColor:[UIColor clearColor]];
//    [friendR_button setBackgroundColor:[UIColor clearColor]];
//    [systemMsg_button setBackgroundColor:[UIColor clearColor]];
    
    
    [eventR_button setTitle:@"邀请" forState:UIControlStateNormal];
    [friendR_button setTitle:@"好友" forState:UIControlStateNormal];
    [systemMsg_button setTitle:@"系统" forState:UIControlStateNormal];
    
    [eventR_button setTitleColor:tColor_normal forState:UIControlStateNormal];
    [friendR_button setTitleColor:tColor_normal forState:UIControlStateNormal];
    [systemMsg_button setTitleColor:tColor_normal forState:UIControlStateNormal];
    
//    [eventR_button setAlpha:0.1];
//    [friendR_button setAlpha:0.1];
//    [systemMsg_button setAlpha:0.1];
    
    [eventR_button setTitleColor:tColor_selected forState:UIControlStateSelected];
    [friendR_button setTitleColor:tColor_selected forState:UIControlStateSelected];
    [systemMsg_button setTitleColor:tColor_selected forState:UIControlStateSelected];
    
//    [eventR_button backgroundRectForBounds:CGRectMake(0, eventR_button.frame.size.height - 5, eventR_button.frame.size.width, 5)];
    [eventR_button setSelected:YES];
    
//    UIColor* borderColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1];
//    [eventR_button.layer setBorderWidth:0.5];
//    [eventR_button.layer setBorderColor:borderColor.CGColor];
//    [friendR_button.layer setBorderWidth:0.5];
//    [friendR_button.layer setBorderColor:borderColor.CGColor];
//    [systemMsg_button.layer setBorderWidth:0.5];
//    [systemMsg_button.layer setBorderColor:borderColor.CGColor];
    
    [eventR_button addTarget:self action:@selector(tabBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [friendR_button addTarget:self action:@selector(tabBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [systemMsg_button addTarget:self action:@selector(tabBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.tabbar_scrollview addSubview:eventR_button];
    [self.tabbar_scrollview addSubview:friendR_button];
    [self.tabbar_scrollview addSubview:systemMsg_button];
    [tabIndicator setBackgroundColor:tabIndicatorColor];
    
    self.content_scrollView.pagingEnabled = YES;
    self.content_scrollView.scrollEnabled = YES;
    self.content_scrollView.showsHorizontalScrollIndicator = NO;
    self.content_scrollView.showsVerticalScrollIndicator = NO;
    self.content_scrollView.delegate = self;
    
    tab_index = 0;
    clickTab = NO;
}

- (void)tabBtnClicked:(id)sender

{
    clickTab = YES;
    NSInteger index = [self.tabs indexOfObject:sender];
    UIButton* lastBtn = (UIButton*)[self.tabs objectAtIndex:tab_index];
    UIButton* currentBtn = (UIButton*)sender;
    NSLog(@"selected button: %d",index);
    lastBtn.selected = NO;
    currentBtn.selected = YES;
    
    UIColor* bColor_normal = [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1];
    UIColor* bColor_selected = [UIColor colorWithRed:0.577 green:0.577 blue:0.577 alpha:1];
//    [currentBtn setBackgroundColor:bColor_selected];
//    [lastBtn setBackgroundColor:bColor_normal];
    CGRect frame = CGRectMake(currentBtn.frame.origin.x + 10, tabIndicator.frame.origin.y, tabIndicator.frame.size.width, tabIndicator.frame.size.height) ;
    [self scrollTabIndicator:frame];
    tab_index = index;
    
//    NSLog(@"clicked, x: %f,y: %f, width: %f, height: %f",self.bgOfTabs.frame.origin.x, self.bgOfTabs.frame.origin.y,self.bgOfTabs.frame.size.width,self.bgOfTabs.frame.size.height);
//
//    [self.content_scrollView scrollRectToVisible:frame animated:YES];
    
    CGPoint point = CGPointMake(self.content_scrollView.frame.size.width * index, 0);
    [self.content_scrollView setContentOffset:point animated:YES];
    [self.content_scrollView setScrollEnabled:YES];
//    if (index == 0) {
//        [self.eventRequest_tableView reloadData];
//    }
//    else if (index == 1)
//    {
//        [self.friendRequest_tableView reloadData];
//    }
//    else if (index == 2)
//    {
//        [self.systemMessage_tableView reloadData];
//    }

    
}

-(void)scrollTabIndicator:(CGRect)frame
{
    [UIView beginAnimations:@"tab indicator scrolling" context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelegate:self];
    [UIView  setAnimationCurve: UIViewAnimationCurveEaseInOut];
//    [UIView setAnimationTransition:UIViewAnimationTransitionCurlDown forView:self.functions_uiview  cache:YES];
    [tabIndicator setFrame:frame];
    [UIView commitAnimations];
}

- (IBAction)rightBarBtnClicked:(id)sender {
    if (!functions_uiview.hidden) {
        
        //UIView开始动画，第一个参数是动画的标识，第二个参数附加的应用程序信息用来传递给动画代理消息
        [UIView beginAnimations:@"View shows" context:nil];
        //动画持续时间
        [UIView setAnimationDuration:0.5];
        //设置动画的回调函数，设置后可以使用回调方法
        [UIView setAnimationDelegate:self];
        //设置动画曲线，控制动画速度
        [UIView  setAnimationCurve: UIViewAnimationCurveEaseOut];
        //设置动画方式，并指出动画发生的位置
        [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:self.functions_uiview  cache:YES];
        
        [functions_uiview setHidden:YES];
        //提交UIView动画
        [UIView commitAnimations];
        
    }
    else{
        
        [UIView beginAnimations:@"View shows" context:nil];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationDelegate:self];
        [UIView  setAnimationCurve: UIViewAnimationCurveEaseIn];
        [UIView setAnimationTransition:UIViewAnimationTransitionCurlDown forView:self.functions_uiview  cache:YES];
        [functions_uiview setHidden:NO];
        [UIView commitAnimations];

        
    }
    
}

- (IBAction)function1Clicked:(id)sender {
    [UIView beginAnimations:@"View shows" context:nil];
    [functions_uiview setHidden:YES];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDelegate:self];
    [UIView  setAnimationCurve: UIViewAnimationCurveEaseIn];
    [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:self.functions_uiview  cache:NO];
    [UIView commitAnimations];
    [self performSegueWithIdentifier:@"notificationvc_historicalvc" sender:self];
}

- (IBAction)function2Clicked:(id)sender {
    [UIView beginAnimations:@"View shows" context:nil];
    [functions_uiview setHidden:YES];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDelegate:self];
    [UIView  setAnimationCurve: UIViewAnimationCurveEaseIn];
    [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:self.functions_uiview  cache:NO];
    [UIView commitAnimations];

    //[self performSelectorOnMainThread:@selector(clearCurrentPage) withObject:nil waitUntilDone:NO];
    [self clearCurrentPage];
}

-(void)clearCurrentPage
{
    [mySql openMyDB:DB_path];
    if (tab_index == 0) {
        for (NSDictionary* msg in MTUser_eventRequestMsg) {
            NSNumber* seq = [msg objectForKey:@"seq"];
            [mySql deleteTurpleFromTable:@"notification" withWhere:[CommonUtils packParamsInDictionary:
                                                                    [NSString stringWithFormat:@"%@",seq],@"seq",nil]];
        }
        [eventRequestMsg removeAllObjects];
        [MTUser_eventRequestMsg removeAllObjects];
        [self.eventRequest_tableView reloadData];
    }
    else if (tab_index == 1)
    {
        for (NSDictionary* msg in MTUser_friendRequestMsg) {
            NSNumber* seq = [msg objectForKey:@"seq"];
            [mySql deleteTurpleFromTable:@"notification" withWhere:[CommonUtils packParamsInDictionary:
                                                                    [NSString stringWithFormat:@"%@",seq],@"seq",nil]];
        }
        [friendRequestMsg removeAllObjects];
        [MTUser_friendRequestMsg removeAllObjects];
        [self.friendRequest_tableView reloadData];
    }
    else if (tab_index == 2)
    {
        for (NSDictionary* msg in MTUser_systemMsg) {
            NSNumber* seq = [msg objectForKey:@"seq"];
            [mySql deleteTurpleFromTable:@"notification" withWhere:[CommonUtils packParamsInDictionary:
                                                                    [NSString stringWithFormat:@"%@",seq],@"seq",nil]];
        }
        [systemMsg removeAllObjects];
        [MTUser_systemMsg removeAllObjects];
        [self.systemMessage_tableView reloadData];
    }
    [mySql closeMyDB];

}

- (void) refresh
{
    [self.view setNeedsDisplay];
}
//==========================================================================================

#pragma mark - Touches

//- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    UITouch* touch = [touches anyObject];
//    lastX = [touch locationInView:self.view].x;
//    NSLog(@"touch X: %f",lastX);
//    if (lastX <= 10) {
////        self.content_scrollView.userInteractionEnabled = NO;
////        [super touchesBegan:touches withEvent:event];
////        self.content_scrollView.canCancelContentTouches = YES;
//        NSLog(@"touches begin: scrollview disabled");
//    }
//    else
//    {
////        self.content_scrollView.userInteractionEnabled = YES;
////        self.content_scrollView.canCancelContentTouches = NO;
//        NSLog(@"touches begin: scrollview enabled");
//    }
//    
//
//}


//- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    UITouch* touch = [touches anyObject];
//    CGPoint p = [touch locationInView:self.view];
//    CGFloat x = p.x;
//    if (tab_index == 0) {
//        if (x > lastX) {
//            NSLog(@"swipe right");
//            self.content_scrollView.scrollEnabled = NO;
//        }
//        else{
//            NSLog(@"swipe left");
//            self.content_scrollView.scrollEnabled = YES;
//        }
//
//    }
//    NSLog(@"touches moved,x: %f, y: %f",p.x , p.y);
//}

//- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    self.content_scrollView.scrollEnabled = YES;
//    NSLog(@"touches end: scrollview enabled");
//    
//}

//==========================================================================================

//- (void) getMsgFromDataBase
//{
//    [mySql openMyDB:DB_path];
//    msgFromDB = [mySql queryTable:@"notification" withSelect:[[NSArray alloc]initWithObjects:@"msg",@"seq",@"ishandled", nil] andWhere:nil];
//    [mySql closeMyDB];
//    NSLog(@"msg from db: %@",MTUser_msgFromDB);
////    [self.notificationsTable reloadData];
//    NSInteger count = MTUser_msgFromDB.count;
//    for (NSInteger i = count - 1; i >= 0; i--) {
//        NSDictionary* msg = [MTUser_msgFromDB objectAtIndex:i];
//        NSString* msg_str = [msg objectForKey:@"msg"];
//        NSMutableDictionary* msg_dic = [[NSMutableDictionary alloc]initWithDictionary:[CommonUtils NSDictionaryWithNSString:msg_str]];
//        NSNumber* seq = [CommonUtils NSNumberWithNSString:(NSString *)[msg objectForKey:@"seq"]];
////        if ([[msg objectForKey:@"seq"] isKindOfClass:[NSString class]]) {
////            NSLog(@"seq is string");
////        }
////        else if ([[msg objectForKey:@"seq"] isKindOfClass:[NSNumber class]])
////        {
////            NSLog(@"seq is number");
////        }
//        NSNumber* ishandled = [CommonUtils NSNumberWithNSString:(NSString *)[msg objectForKey:@"ishandled"]];
//        
//        [msg_dic setValue:seq forKey:@"seq"]; //将seq放进消息里
//        [msg_dic setValue:ishandled forKey:@"ishanled"];
//        NSInteger cmd = [[msg_dic objectForKey:@"cmd"] intValue];
//        if ([ishandled integerValue] == -1) {
//            switch (cmd) {
//                case ADD_FRIEND_NOTIFICATION:
//                {
//                    [friendRequestMsg addObject:msg_dic];
//                }
//                    break;
//                case ADD_FRIEND_RESULT:
//                case EVENT_INVITE_RESPONSE:
//                {
//                    [systemMsg addObject:msg_dic];
//                }
//                    break;
//                case NEW_EVENT_NOTIFICATION:
//                {
//                    [[MTUser sharedInstance].eventRequestMsg addObject:msg_dic];
//                }
//                    break;
//                    
//                default:
//                    break;
//            }
//
//        }
//        else
//        {
////            [historicalMsg addObject:msg_dic];
//        }
//    }
//    
//}

#pragma mark - NotificationDelegate

-(void) notificationDidReceive:(NSArray *)messages
{
    for (NSDictionary* msg in messages) {
        NSString* msg_str = [msg objectForKey:@"msg"];
        NSMutableDictionary* msg_dic = [[NSMutableDictionary alloc]initWithDictionary:[CommonUtils NSDictionaryWithNSString:msg_str]];
        NSNumber* seq = [msg objectForKey:@"seq"];
        [msg_dic setValue:seq forKey:@"seq"]; //将seq放进消息里
        [msg_dic setValue:[NSNumber numberWithInteger:-1] forKey:@"ishandled"];
//        if ([[msg objectForKey:@"seq"] isKindOfClass:[NSString class]]) {
//            NSLog(@"received seq is string");
//        }
//        else if ([[msg objectForKey:@"seq"] isKindOfClass:[NSNumber class]])
//        {
//            NSLog(@"received seq is number");
//        }

        NSInteger cmd = [[msg_dic objectForKey:@"cmd"] intValue];
        switch (cmd) {
            case ADD_FRIEND_NOTIFICATION:
            {
                [friendRequestMsg insertObject:msg_dic atIndex:0];
            }
                break;
            case ADD_FRIEND_RESULT:
            {
                [systemMsg insertObject:msg_dic atIndex:0];
//                [[MTUser sharedInstance] synchronizeFriends];
            }
                break;
            case EVENT_INVITE_RESPONSE:
            {
                [systemMsg insertObject:msg_dic atIndex:0];
            }
                break;
            case NEW_EVENT_NOTIFICATION:
            {
                [self.eventRequestMsg insertObject:msg_dic atIndex:0];
            }
                break;
                
            default:
                break;
        }
        
    }
    if (tab_index == 0) {
        [self.eventRequest_tableView reloadData];
    }
    else if (tab_index == 1)
    {
        [self.friendRequest_tableView reloadData];
    }
    else if (tab_index == 2)
    {
        [self.systemMessage_tableView reloadData];
    }

}


#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.friendRequest_tableView) {
        return friendRequestMsg.count;
    }
    else if (tableView == self.eventRequest_tableView)
    {
        return eventRequestMsg.count;
    }
    else if (tableView == self.systemMessage_tableView)
    {
        return systemMsg.count;
    }
    
    return 0;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIColor* bgColor = [UIColor colorWithRed:0.94 green:0.94 blue:0.94 alpha:1];
    UITableViewCell* temp_cell = [[UITableViewCell alloc]init];
    if (tableView == self.eventRequest_tableView) {
        NotificationsEventRequestTableViewCell* cell = [self.eventRequest_tableView dequeueReusableCellWithIdentifier:@"NotificationsEventRequestTableViewCell"];
        if (nil == cell) {
            cell = [[NotificationsEventRequestTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"NotificationsEventRequestTableViewCell"];
        }
        NSMutableDictionary* msg_dic = [eventRequestMsg objectAtIndex:indexPath.row];
        NSLog(@"event %d request: %@",indexPath.row, msg_dic);
        NSInteger cmd = [[msg_dic objectForKey:@"cmd"] intValue];
//        NSInteger ishandled = [[msg_dic objectForKey:@"ishandled"] integerValue];
        switch (cmd) {
            case NEW_EVENT_NOTIFICATION: //cmd 997
            {
                NSString* subject = [msg_dic objectForKey:@"subject"];
                NSString* launcher = [msg_dic objectForKey:@"launcher"];
                NSNumber* uid = [msg_dic objectForKey:@"launcher_id"];
                
                cell.name_label.text = launcher;
                [cell.event_name_button setTitle:subject forState:UIControlStateNormal];
                PhotoGetter* getter = [[PhotoGetter alloc]initWithData:cell.avatar_imageView authorId:uid];
                [getter getPhoto];
                
                cell.okBtn.hidden = YES;
                cell.noBtn.hidden = YES;
                cell.remark_label.hidden = YES;
                [cell.event_name_button addTarget:self action:@selector(eventBtnClicked:) forControlEvents:UIControlEventTouchUpInside];

//                if (ishandled == -1) {
//                    cell.okBtn.hidden = NO;
//                    cell.noBtn.hidden = NO;
//                    cell.remark_label.hidden = YES;
//                }
//                else if(ishandled == 0)
//                {
//                    cell.okBtn.hidden = YES;
//                    cell.noBtn.hidden = YES;
//                    cell.remark_label.hidden = NO;
//                    cell.remark_label.text = @"已拒绝";
//                }
//                else if (ishandled == 1)
//                {
//                    cell.okBtn.hidden = YES;
//                    cell.noBtn.hidden = YES;
//                    cell.remark_label.hidden = NO;
//                    cell.remark_label.text = @"已同意";
//                }
//                [cell.okBtn addTarget:self action:@selector(participate_event_okBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
//                [cell.noBtn addTarget:self action:@selector(participate_event_noBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            }
                break;
                
            default:
                break;
        }
        [cell.contentView setBackgroundColor:bgColor];
        UIColor* borderColor = [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1];
        cell.layer.borderColor = borderColor.CGColor;
        cell.layer.borderWidth = 0.3;
        return cell;
    }
    else if(tableView == self.friendRequest_tableView)
    {
        NotificationsFriendRequestTableViewCell* cell = [self.friendRequest_tableView dequeueReusableCellWithIdentifier:@"NotificationsFriendRequestTableViewCell"];
        if (nil == cell) {
            cell = [[NotificationsFriendRequestTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"NotificationsFriendRequestTableViewCell"];
        }
        NSMutableDictionary* msg_dic = [friendRequestMsg objectAtIndex:indexPath.row];
        NSLog(@"friend %d request: %@",indexPath.row, msg_dic);
        NSInteger cmd = [[msg_dic objectForKey:@"cmd"] intValue];
        NSInteger ishandled = [[msg_dic objectForKey:@"ishandled"] integerValue];
        switch (cmd) {
            case ADD_FRIEND_NOTIFICATION: //cmd 999
            {
                NSString* name = [msg_dic objectForKey:@"name"];
                NSString* confirm_msg = [msg_dic objectForKey:@"confirm_msg"];
                NSNumber* uid = [msg_dic objectForKey:@"id"];
                cell.name_label.text = name;
                cell.conform_msg_label.text = confirm_msg;
                PhotoGetter* getter = [[PhotoGetter alloc]initWithData:cell.avatar_imageView authorId:uid];
                [getter getPhoto];
                
                if (ishandled == -1) {
                    cell.okBtn.hidden = NO;
                    cell.noBtn.hidden = NO;
                    cell.remark_label.hidden = YES;
                }
                else if(ishandled == 0)
                {
                    cell.okBtn.hidden = YES;
                    cell.noBtn.hidden = YES;
                    cell.remark_label.hidden = NO;
                    cell.remark_label.text = @"已拒绝";
                }
                else if (ishandled == 1)
                {
                    cell.okBtn.hidden = YES;
                    cell.noBtn.hidden = YES;
                    cell.remark_label.hidden = NO;
                    cell.remark_label.text = @"已同意";
                }
                [cell.okBtn addTarget:self action:@selector(friend_request_okBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
                [cell.noBtn addTarget:self action:@selector(friend_request_noBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
                
            }
                break;
                
            default:
                break;
        }
        UIColor* borderColor = [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1];
        cell.layer.borderColor = borderColor.CGColor;
        cell.layer.borderWidth = 0.3;
        return cell;
    }
    else if (tableView == self.systemMessage_tableView)
    {
        NotificationsSystemMessageTableViewCell* cell = [self.systemMessage_tableView dequeueReusableCellWithIdentifier:@"NotificationsSystemMessageTableViewCell"];
        if (nil == cell) {
            cell = [[NotificationsSystemMessageTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"NotificationsSystemMessageTableViewCell"];
        }
        NSMutableDictionary* msg_dic = [systemMsg objectAtIndex:indexPath.row];
        NSLog(@"system %d message: %@",indexPath.row, msg_dic);
        NSInteger cmd = [[msg_dic objectForKey:@"cmd"] intValue];
        switch (cmd) {
            case ADD_FRIEND_RESULT: //cmd 998
            {
                NSInteger result = [[msg_dic objectForKey:@"result"] intValue];
                NSString* name = [msg_dic objectForKey:@"name"];
                NSString* text = @"";
                if (result) {
                    text = [NSString stringWithFormat:@"你已经成功添加 %@ 为好友",name];
                }
                else
                {
                    text = [NSString stringWithFormat:@" %@ 拒绝添加你为好友",name];

                }
                cell.title_label.text = @"好友消息";
                cell.sys_msg_label.text = text;
            }
                break;
            case EVENT_INVITE_RESPONSE: //996
            {
                NSInteger result = [[msg_dic objectForKey:@"result"] intValue];
                NSString* name = [msg_dic objectForKey:@"name"];
                NSString* subject = [msg_dic objectForKey:@"subject"];
                NSString* text = @"";
                if (result) {
                    text = [NSString stringWithFormat:@"%@ 同意加入你的活动 %@ ",name,subject];
                }
                else
                {
                    text = [NSString stringWithFormat:@"%@ 拒绝加入你的活动 %@ ",name,subject];
                    
                }
                cell.title_label.text = @"活动消息";
                cell.sys_msg_label.text = text;
            }
                break;
                
            default:
                break;
        }
        UIColor* borderColor = [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1];
        cell.layer.borderColor = borderColor.CGColor;
        cell.layer.borderWidth = 0.3;
        return cell;
    }
    temp_cell.textLabel.text = @"没有新的消息啦";
    return temp_cell;
}

- (IBAction)friend_request_okBtnClicked:(id)sender
{
    UIView* cell = [sender superview];
    while (![cell isKindOfClass:[NotificationsFriendRequestTableViewCell class]]) {
        cell = [cell superview];
    }
//    cell.tag = 1;
    ((NotificationsFriendRequestTableViewCell*)cell).remark_label.text = @"已同意";
    selectedPath = [self.friendRequest_tableView indexPathForCell:(UITableViewCell*)cell];
    NSDictionary* msg_dic = [friendRequestMsg objectAtIndex:selectedPath.row];
    
    NSNumber* seq = [msg_dic objectForKey:@"seq"];
    NSLog(@"ok button row: %d, seq: %@",selectedPath.row,seq);
    
    NSNumber* userid = [MTUser sharedInstance].userid;
    NSNumber* friendid = [msg_dic objectForKey:@"id"];
    NSDictionary* item_id_dic = [CommonUtils packParamsInDictionary:
                                 [NSNumber numberWithInteger:selectedPath.row],@"item_index",
                                 [NSNumber numberWithInt:RESPONSE_FRIEND],@"response_type",
                                 [NSNumber numberWithInteger:1],@"response_result",
                                 nil];
    
    NSMutableDictionary* json = [CommonUtils packParamsInDictionary:
                                 [NSNumber numberWithInt:998],@"cmd",
                                 [NSNumber numberWithInt:1],@"result",
                                 friendid,@"friend_id",
                                 userid,@"id",
                                 item_id_dic,@"item_id",
                                 [NSNumber numberWithInt:RESPONSE_FRIEND],@"response_type",
                                 nil];
    NSLog(@"agreed json: %@",json);
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:ADD_FRIEND];
    
//    [self.msgFromDB removeObjectAtIndex:selectedPath.row];
//    [mySql openMyDB:DB_path];
//    [mySql deleteTurpleFromTable:@"notification" withWhere:[[NSDictionary alloc]initWithObjectsAndKeys:[[NSString alloc]initWithFormat:@"%@", seq],@"seq", nil]];
//    [mySql closeMyDB];
    
}

- (IBAction)friend_request_noBtnClicked:(id)sender
{
    UIView* cell = [sender superview];
    while (![cell isKindOfClass:[NotificationsFriendRequestTableViewCell class]]) {
        cell = [cell superview];
    }
//    cell.tag = 1;
    ((NotificationsFriendRequestTableViewCell*)cell).remark_label.text = @"已拒绝";
    selectedPath = [self.friendRequest_tableView indexPathForCell:(UITableViewCell*)cell];
    NSDictionary* msg_dic = [friendRequestMsg objectAtIndex:selectedPath.row];
    
    NSNumber* seq = [msg_dic objectForKey:@"seq"];
    NSLog(@"no button row: %d, seq: %@",selectedPath.row,seq);
    NSNumber* userid = [MTUser sharedInstance].userid;
    NSNumber* friendid = [msg_dic objectForKey:@"id"];
    NSDictionary* item_id_dic = [CommonUtils packParamsInDictionary:
                                 [NSNumber numberWithInteger:selectedPath.row],@"item_index",
                                 [NSNumber numberWithInt:RESPONSE_FRIEND],@"response_type",
                                 [NSNumber numberWithInteger:0],@"response_result",
                                 nil];

    NSMutableDictionary* json = [CommonUtils packParamsInDictionary:
                                 [NSNumber numberWithInt:998],@"cmd",
                                 [NSNumber numberWithInt:0],@"result",
                                 friendid,@"friend_id",
                                 userid,@"id",
                                 item_id_dic,@"item_id",
                                 [NSNumber numberWithInt:RESPONSE_FRIEND],@"response_type",
                                 nil];
    NSLog(@"reject json: %@",json);
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:ADD_FRIEND];
    
//    [self.msgFromDB removeObjectAtIndex:selectedPath.row];
//    [mySql openMyDB:DB_path];
//    [mySql deleteTurpleFromTable:@"notification" withWhere:[[NSDictionary alloc]initWithObjectsAndKeys:[[NSString alloc]initWithFormat:@"%@", seq],@"seq", nil]];
//    [mySql closeMyDB];

    
}

- (IBAction)delSystemMsg:(id)sender
{
    UIView* cell = [sender superview];
    while (![cell isKindOfClass:[NotificationsSystemMessageTableViewCell class]]) {
        cell = [cell superview];
    }
    selectedPath = [self.systemMessage_tableView indexPathForCell:(UITableViewCell*)cell];
    NSDictionary* msg_dic = [systemMsg objectAtIndex:selectedPath.row];
    NSNumber* seq = [msg_dic objectForKey:@"seq"];
    NSLog(@"del cell seq: %@, row: %d",seq,selectedPath.row);
    [mySql openMyDB:DB_path];
    [mySql deleteTurpleFromTable:@"notification" withWhere:[[NSDictionary alloc]initWithObjectsAndKeys:[[NSString alloc]initWithFormat:@"%@", seq],@"seq", nil]];
    [mySql closeMyDB];
    [systemMsg removeObjectAtIndex:selectedPath.row];
    cell = nil;
    [self.systemMessage_tableView reloadData];
    
}

- (IBAction)participate_event_okBtnClicked:(id)sender
{
    UIView* cell = [sender superview];
    while (![cell isKindOfClass:[NotificationsEventRequestTableViewCell class]]) {
        cell = [cell superview];
    }
//    cell.tag = 1;
    ((NotificationsEventRequestTableViewCell*)cell).remark_label.text = @"已同意";
    selectedPath = [self.eventRequest_tableView indexPathForCell:(UITableViewCell*)cell];
    NSDictionary* msg_dic = [eventRequestMsg objectAtIndex:selectedPath.row];
    NSNumber* seq = [msg_dic objectForKey:@"seq"];
    NSLog(@"participate cell seq: %@, row: %d",seq,selectedPath.row);
    
    NSNumber* eventid = [msg_dic objectForKey:@"event_id"];
    NSDictionary* item_id_dic = [CommonUtils packParamsInDictionary:
                                 [NSNumber numberWithInteger:selectedPath.row],@"item_index",
                                 [NSNumber numberWithInt:RESPONSE_EVENT],@"response_type",
                                 [NSNumber numberWithInteger:1],@"response_result",
                                 nil];
    NSMutableDictionary* json = [CommonUtils packParamsInDictionary:
                                 [NSNumber numberWithInt:997],@"cmd",
                                 [NSNumber numberWithInt:1],@"result",
                                 [MTUser sharedInstance].userid,@"id",
                                 eventid,@"event_id",
                                 item_id_dic,@"item_id",
                                 [NSNumber numberWithInt:RESPONSE_EVENT],@"response_type",
                                 nil];
    NSLog(@"participate event okBtn, http json : %@",json );
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:PARTICIPATE_EVENT];
}

- (IBAction)participate_event_noBtnClicked:(id)sender
{
    UIView* cell = [sender superview];
    while (![cell isKindOfClass:[NotificationsEventRequestTableViewCell class]]) {
        cell = [cell superview];
    }
//    cell.tag = 1;
    ((NotificationsEventRequestTableViewCell*)cell).remark_label.text = @"已拒绝";
    selectedPath = [self.eventRequest_tableView indexPathForCell:(UITableViewCell*)cell];
    NSDictionary* msg_dic = [eventRequestMsg objectAtIndex:selectedPath.row];
    NSNumber* seq = [msg_dic objectForKey:@"seq"];
    NSLog(@"participate cell seq: %@, row: %d",seq,selectedPath.row);
    
    NSNumber* eventid = [msg_dic objectForKey:@"event_id"];
    NSDictionary* item_id_dic = [CommonUtils packParamsInDictionary:
                                 [NSNumber numberWithInteger:selectedPath.row],@"item_index",
                                 [NSNumber numberWithInt:RESPONSE_EVENT],@"response_type",
                                 [NSNumber numberWithInteger:0],@"response_result",
                                 nil];
    NSMutableDictionary* json = [CommonUtils packParamsInDictionary:
                                 [NSNumber numberWithInt:997],@"cmd",
                                 [NSNumber numberWithInt:0],@"result",
                                 [MTUser sharedInstance].userid,@"id",
                                 eventid,@"event_id",
                                 item_id_dic,@"item_id",
                                 [NSNumber numberWithInt:RESPONSE_EVENT],@"response_type",
                                 nil];
    NSLog(@"participate event noBtn, http json : %@",json );
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:PARTICIPATE_EVENT];
}

-(void)eventBtnClicked:(UIButton*)sender
{
    MenuViewController* mvc = (MenuViewController*)[SlideNavigationController sharedInstance].leftMenu;
    if (mvc.eventInvitationViewController == nil) {
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone"
                                                                 bundle: nil];
        mvc.eventInvitationViewController = [mainStoryboard instantiateViewControllerWithIdentifier: @"EventInvitationViewController"];
    }
    
    [self.navigationController pushViewController:mvc.eventInvitationViewController animated:YES];
}

#pragma mark - HttpSenderDelegate
-(void)finishWithReceivedData:(NSData*) rData
{
    NSString* temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
    NSLog(@"Received Data: %@",temp);
    NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
    NSNumber *cmd = [response1 valueForKey:@"cmd"];
    switch ([cmd intValue]) {
        case NORMAL_REPLY:
        {
            NSDictionary* item_id_dic = [response1 objectForKey:@"item_id"];
            NSLog(@"item_id_dic: %@", item_id_dic);
            NSNumber* item_index = [item_id_dic objectForKey:@"item_index"];
            NSNumber* response_type = [item_id_dic objectForKey:@"response_type"];
            NSNumber* result = [item_id_dic valueForKey:@"response_result"];
            
            
//            NSLog(@"http receive, response_type: %@, item_index: %@",response_type, item_index);
            if ([response_type intValue] == RESPONSE_FRIEND) {
                
                if ([result intValue] == 1) {
                    [CommonUtils showSimpleAlertViewWithTitle:@"系统提示" WithMessage:@"已成功添加好友" WithDelegate:self WithCancelTitle:@"确定"];
                    [self.friendRequest_tableView reloadData];
                    
                    NSMutableDictionary* msg_dic = [friendRequestMsg objectAtIndex:[item_index intValue]];
                    NSNumber* seq = [msg_dic objectForKey:@"seq"];
                    NSLog(@"response friend, seq: %@",seq);
                    
                    NSString* fname = [msg_dic objectForKey:@"name"];
                    NSString* femail = [msg_dic objectForKey:@"email"];
                    NSNumber* fgender = [msg_dic objectForKey:@"gender"];
                    NSNumber* fid = [msg_dic objectForKey:@"id"];
                    [mySql openMyDB:DB_path];
                    [mySql deleteTurpleFromTable:@"notification" withWhere:[[NSDictionary alloc]initWithObjectsAndKeys:[[NSString alloc]initWithFormat:@"%@", seq],@"seq", nil]];
                    [mySql insertToTable:@"friend"
                             withColumns:[[NSArray alloc]initWithObjects:@"id",@"name",@"email",@"gender", nil]
                               andValues:[[NSArray alloc] initWithObjects:
                                          [NSString stringWithFormat:@"%@",[CommonUtils NSStringWithNSNumber:fid]],
                                          [NSString stringWithFormat:@"'%@'",fname],
                                          [NSString stringWithFormat:@"'%@'",femail],
                                          [NSString stringWithFormat:@"%@",[CommonUtils NSStringWithNSNumber:fgender]], nil]];
                    [mySql updateDataWitTableName:@"notification"
                                         andWhere:[CommonUtils packParamsInDictionary:
                                                   [NSString stringWithFormat:@"%@",seq],@"seq",
                                                   nil]
                                           andSet:[CommonUtils packParamsInDictionary:
                                                   [NSString stringWithFormat:@"%d",1],@"ishandled",
                                                   nil]];
                    [mySql closeMyDB];
                    
                    NSDictionary* friendJson = [CommonUtils packParamsInDictionary:
                                                fname,@"name",
                                                femail,@"email",
                                                fgender,@"gender",
                                                fid,@"id",
                                                nil];
                    [[MTUser sharedInstance].friendList addObject:friendJson];
                    [[MTUser sharedInstance] friendListDidChanged];
                    
                    [MTUser_friendRequestMsg removeObject:msg_dic];
                    [msg_dic setValue:result forKey:@"ishandled"];
                    
                    [MTUser_historicalMsg insertObject:msg_dic atIndex:0];
                }
                else
                {
                    [self.friendRequest_tableView reloadData];
                    NSMutableDictionary* msg_dic = [friendRequestMsg objectAtIndex:[item_index intValue]];
                    NSNumber* seq = [msg_dic objectForKey:@"seq"];
                    NSLog(@"response friend, seq: %@",seq);
                    [mySql openMyDB:DB_path];
                    [mySql updateDataWitTableName:@"notification"
                                         andWhere:[CommonUtils packParamsInDictionary:
                                                   [NSString stringWithFormat:@"%@",seq],@"seq",
                                                   nil]
                                           andSet:[CommonUtils packParamsInDictionary:
                                                   [NSString stringWithFormat:@"%d",0],@"ishandled",
                                                   nil]];
                    [mySql closeMyDB];

                    [MTUser_friendRequestMsg removeObject:msg_dic];
                    [msg_dic setValue:result forKey:@"ishandled"];
                    
                    [MTUser_historicalMsg insertObject:msg_dic atIndex:0];
                    
//                    NSString* fname = [msg_dic objectForKey:@"name"];
//                    NSString* femail = [msg_dic objectForKey:@"email"];
//                    NSNumber* fgender = [msg_dic objectForKey:@"gender"];
//                    NSNumber* fid = [msg_dic objectForKey:@"id"];
//                    [mySql openMyDB:DB_path];
//                    [mySql deleteTurpleFromTable:@"notification" withWhere:[[NSDictionary alloc]initWithObjectsAndKeys:[[NSString alloc]initWithFormat:@"%@", seq],@"seq", nil]];
//                    [mySql closeMyDB];
                }

            }
            else if ([response_type intValue] == RESPONSE_EVENT)
            {
                [self.eventRequest_tableView reloadData];
                NSMutableDictionary* msg_dic = [eventRequestMsg objectAtIndex:[item_index intValue]];
                
                NSNumber* seq = [msg_dic objectForKey:@"seq"];
                NSLog(@"response event, seq: %@",seq);
                [mySql openMyDB:DB_path];
                [mySql updateDataWitTableName:@"notification"
                                     andWhere:[CommonUtils packParamsInDictionary:
                                               [NSString stringWithFormat:@"%@",seq],@"seq",
                                               nil]
                                       andSet:[CommonUtils packParamsInDictionary:
                                               [NSString stringWithFormat:@"%@",result],@"ishandled",
                                               nil]];
                [mySql closeMyDB];
                
                
                [MTUser_eventRequestMsg removeObject:msg_dic];
                [msg_dic setValue:result forKey:@"ishandled"];

                [MTUser_historicalMsg insertObject:msg_dic atIndex:0];
//                NSLog(@"MTUser eventRequestMsg: %@",[MTUser sharedInstance].eventRequestMsg);
//                NSLog(@"msg_dic: %@",new_msg_dic);
                
//                [mySql openMyDB:DB_path];
//                [mySql deleteTurpleFromTable:@"notification" withWhere:[[NSDictionary alloc]initWithObjectsAndKeys:[[NSString alloc]initWithFormat:@"%@", seq],@"seq", nil]];
//                [mySql closeMyDB];
            }
//            [self.msgFromDB removeObjectAtIndex:selectedPath.row];
            
        }
            break;
        case ALREADY_FRIENDS:
        {
            
            [CommonUtils showSimpleAlertViewWithTitle:@"系统提示" WithMessage:@"你们已经是好友" WithDelegate:self WithCancelTitle:@"确定"];
//            int count = self.msgFromDB.count;
//            NSDictionary* msg_dic = [self.friendRequestMsg objectAtIndex:[item_index intValue]];
//            NSNumber* seq = [msg_dic objectForKey:@"seq"];
//            NSLog(@"already friends, seq: %@",seq);
//            [mySql openMyDB:DB_path];
//            [mySql deleteTurpleFromTable:@"notification" withWhere:[[NSDictionary alloc]initWithObjectsAndKeys:[[NSString alloc]initWithFormat:@"%@", seq],@"seq", nil]];
//            [mySql closeMyDB];
//            [self.msgFromDB removeObjectAtIndex:selectedPath.row];
//            [self.notificationsTable reloadData];

        }
            break;
        case REQUEST_FAIL:
        {
            [CommonUtils showSimpleAlertViewWithTitle:@"系统提示" WithMessage:@"发送请求错误" WithDelegate:self WithCancelTitle:@"确定"];
            
        }
            break;
        case ALREADY_IN_EVENT:
        {
            [CommonUtils showSimpleAlertViewWithTitle:@"系统提示" WithMessage:@"你已经在此活动中了" WithDelegate:self WithCancelTitle:@"确定"];
//            int count = self.msgFromDB.count;
//            NSDictionary* dataMsg = [self.msgFromDB objectAtIndex:(selectedPath.row)];
//            NSNumber* seq = [dataMsg objectForKey:@"seq"];
//            NSLog(@"already in event, seq: %@",seq);
//            [mySql openMyDB:DB_path];
//            [mySql deleteTurpleFromTable:@"notification" withWhere:[[NSDictionary alloc]initWithObjectsAndKeys:[[NSString alloc]initWithFormat:@"%@", seq],@"seq", nil]];
//            [mySql closeMyDB];
//            [self.msgFromDB removeObjectAtIndex:selectedPath.row];
//            [self.notificationsTable reloadData];

        }
            break;
        default:
            break;
    }

}

#pragma mark - UIScrollViewDelegate
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (!functions_uiview.hidden) {
        [UIView beginAnimations:@"View shows" context:nil];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationDelegate:self];
        [UIView  setAnimationCurve: UIViewAnimationCurveEaseOut];
        [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:self.functions_uiview  cache:YES];
        [functions_uiview setHidden:YES];
        [UIView commitAnimations];
    }
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView    // any offset changes
{
    if (scrollView == self.tabbar_scrollview) {
        ;
    }
    else if(scrollView == self.content_scrollView)
    {
        if (clickTab) {
            return;
        }
        CGFloat page_width = scrollView.frame.size.width;
        NSInteger last_tab_index = tab_index;
        tab_index = floor((scrollView.contentOffset.x - page_width/2) / page_width) +1;

        UIColor* bColor_normal = [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1];
        UIColor* bColor_selected = [UIColor colorWithRed:0.577 green:0.577 blue:0.577 alpha:1];
        UIButton* lastBtn = (UIButton*)[tabs objectAtIndex:last_tab_index];
        UIButton* currentBtn = (UIButton*)[tabs objectAtIndex:tab_index];
        
        lastBtn.selected = NO;
        currentBtn.selected = YES;
        
//        [lastBtn setBackgroundColor:bColor_normal];
//        [currentBtn setBackgroundColor:bColor_selected];
        CGRect frame = CGRectMake(currentBtn.frame.origin.x + 10, tabIndicator.frame.origin.y, tabIndicator.frame.size.width, tabIndicator.frame.size.height);
        [self scrollTabIndicator:frame];
        
//        if (tab_index == 0) {
//            [self.eventRequest_tableView reloadData];
//        }
//        else if (tab_index == 1)
//        {
//            [self.friendRequest_tableView reloadData];
//        }
//        else if (tab_index == 2)
//        {
//            [self.systemMessage_tableView reloadData];
//        }

        
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if (scrollView == self.content_scrollView) {
        if (tab_index == 0) {
            [self.eventRequest_tableView reloadData];
            NSLog(@"reload event_table");
        }
        else if (tab_index == 1)
        {
            [self.friendRequest_tableView reloadData];
            NSLog(@"reload friend_table");
        }
        else if (tab_index == 2)
        {
            [self.systemMessage_tableView reloadData];
            NSLog(@"reload system_table");
        }

    }
    clickTab = NO;
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
        self.shadowView.hidden = YES;
        [self.view sendSubviewToBack:self.shadowView];
    }
}
@end

//@implementation UIScrollView (UITouchEvent)
//
//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//    [[self nextResponder] touchesBegan:touches withEvent:event];
//    [super touchesBegan:touches withEvent:event];
//}
//-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
//    [[self nextResponder] touchesMoved:touches withEvent:event];
//    [super touchesMoved:touches withEvent:event];
//}
//
//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
//    [[self nextResponder] touchesEnded:touches withEvent:event];
//    [super touchesEnded:touches withEvent:event];
//}

//@end

