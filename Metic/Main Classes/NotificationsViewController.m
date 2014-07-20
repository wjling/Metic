//
//  NotificationsViewController.m
//  Metic
//
//  Created by mac on 14-6-23.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "NotificationsViewController.h"

@interface NotificationsViewController ()
{
    MySqlite* mySql;
    NSString* DB_path;
    NSIndexPath* selectedPath;
    NSInteger tab_index;
    CGFloat lastX;
}

enum Response_Type
{
    RESPONSE_EVENT = 0,
    RESPONSE_FRIEND,
    RESPONSE_SYSTEM
};

@end

@implementation NotificationsViewController
@synthesize msgFromDB;
@synthesize friendRequestMsg;
@synthesize eventRequestMsg;
@synthesize systemMsg;
@synthesize appListener;
@synthesize tabs;

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
    [self getMsgFromDataBase];
//    NSLog(@"hahahah");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidAppear:(BOOL)animated
{
//    NSLog(@"hennnnn");
    self.content_scrollView.contentSize = CGSizeMake(320*self.tabs.count, self.content_scrollView.frame.size.height); //不设这个contentSize的话scrollRectToVisible方法无效
    self.tabbar_scrollview.contentSize = CGSizeMake(960, 40);
    
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)initParams
{
    self.msgFromDB = [[NSMutableArray alloc]init];
    self.friendRequestMsg = [[NSMutableArray alloc]init];
    self.eventRequestMsg = [[NSMutableArray alloc]init];
    self.systemMsg = [[NSMutableArray alloc]init];
    selectedPath = [[NSIndexPath alloc]init];
    mySql = [[MySqlite alloc]init];
    DB_path = [[NSString alloc]initWithFormat:@"%@/db",[MTUser sharedInstance].userid];
    self.friendRequest_tableView.delegate = self;
    self.friendRequest_tableView.dataSource = self;
    self.eventRequest_tableView.delegate = self;
    self.eventRequest_tableView.dataSource = self;
    self.systemMessage_tableView.delegate = self;
    self.systemMessage_tableView.dataSource = self;
    
    CGRect frame = self.tabbar_scrollview.frame;
    
    int x = 0;
    CGFloat width = frame.size.width/3;
    int height = frame.size.height;
    UIButton* eventR_button = [[UIButton alloc]initWithFrame:CGRectMake(x, 0, width, height)];
    UIButton* friendR_button = [[UIButton alloc]initWithFrame:CGRectMake(x+width, 0, width, height)];
    UIButton* systemMsg_button = [[UIButton alloc]initWithFrame:CGRectMake(x+width*2, 0, width, height)];
    self.tabs = [[NSMutableArray alloc]initWithObjects:eventR_button,friendR_button,systemMsg_button, nil];
    
    UIColor* bColor_normal = [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1];
    UIColor* bColor_selected = [UIColor colorWithRed:0.577 green:0.577 blue:0.577 alpha:1];
    UIColor* tColor_normal = [UIColor colorWithRed:0.553 green:0.553 blue:0.553 alpha:1];
    UIColor* tColor_selected = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1];
    
    [eventR_button setBackgroundColor:bColor_selected];
    [friendR_button setBackgroundColor:bColor_normal];
    [systemMsg_button setBackgroundColor:bColor_normal];
    
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
    
    [eventR_button.layer setBorderWidth:0.5];
    [eventR_button.layer setBorderColor:bColor_selected.CGColor];
    [friendR_button.layer setBorderWidth:0.5];
    [friendR_button.layer setBorderColor:bColor_selected.CGColor];
    [systemMsg_button.layer setBorderWidth:0.5];
    [systemMsg_button.layer setBorderColor:bColor_selected.CGColor];
    
    [eventR_button addTarget:self action:@selector(tabBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [friendR_button addTarget:self action:@selector(tabBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [systemMsg_button addTarget:self action:@selector(tabBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.tabbar_scrollview addSubview:eventR_button];
    [self.tabbar_scrollview addSubview:friendR_button];
    [self.tabbar_scrollview addSubview:systemMsg_button];
    
    self.content_scrollView.pagingEnabled = YES;
    self.content_scrollView.scrollEnabled = YES;
    self.content_scrollView.showsHorizontalScrollIndicator = NO;
    self.content_scrollView.showsVerticalScrollIndicator = NO;
    self.content_scrollView.delegate = self;
    
    tab_index = 0;
    
    
}

- (void)tabBtnClicked:(id)sender

{
    NSInteger index = [self.tabs indexOfObject:sender];
    NSLog(@"selected button: %d",index);
    if (index == 0) {
        [self.eventRequest_tableView reloadData];
    }
    else if (index == 1)
    {
        [self.friendRequest_tableView reloadData];
    }
    else if (index == 2)
    {
        [self.systemMessage_tableView reloadData];
    }
    UIColor* bColor_normal = [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1];
    UIColor* bColor_selected = [UIColor colorWithRed:0.577 green:0.577 blue:0.577 alpha:1];
    
    [(UIButton*)sender setBackgroundColor:bColor_selected];
    [((UIButton*)sender) setSelected: YES];
    
    UIButton* lastBtn = (UIButton*)[self.tabs objectAtIndex:tab_index];
    
    [lastBtn setBackgroundColor:bColor_normal];
    lastBtn.selected = NO;
    tab_index = index;
    
//    NSLog(@"clicked, x: %f,y: %f, width: %f, height: %f",self.bgOfTabs.frame.origin.x, self.bgOfTabs.frame.origin.y,self.bgOfTabs.frame.size.width,self.bgOfTabs.frame.size.height);
//
//    [self.content_scrollView scrollRectToVisible:frame animated:YES];
    
    CGPoint point = CGPointMake(self.content_scrollView.frame.size.width * index, 0);
    [self.content_scrollView setContentOffset:point animated:YES];
   
    
}

- (void) refresh
{
    [self.view setNeedsDisplay];
}
//==========================================================================================

#pragma mark - Touches

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch* touch = [touches anyObject];
    lastX = [touch locationInView:self.view].x;
}


- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch* touch = [touches anyObject];
    CGPoint p = [touch locationInView:self.view];
    CGFloat x = p.x;
    if (tab_index == 0) {
        if (x > lastX) {
            NSLog(@"swipe right");
            self.content_scrollView.scrollEnabled = NO;
        }
        else{
            NSLog(@"swipe left");
            self.content_scrollView.scrollEnabled = YES;
        }

    }
    //    NSLog(@"touches moved,x: %f, y: %f",p.x , p.y);
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.content_scrollView.scrollEnabled = YES;
}

//==========================================================================================

- (void) getMsgFromDataBase
{
    [mySql openMyDB:DB_path];
    self.msgFromDB = [mySql queryTable:@"notification" withSelect:[[NSArray alloc]initWithObjects:@"msg",@"seq", nil] andWhere:nil];
    [mySql closeMyDB];
    NSLog(@"msg from db: %@",msgFromDB);
//    [self.notificationsTable reloadData];
    NSInteger count = self.msgFromDB.count;
    for (NSInteger i = count - 1; i >= 0; i--) {
        NSDictionary* msg = [msgFromDB objectAtIndex:i];
        NSString* msg_str = [msg objectForKey:@"msg"];
        NSMutableDictionary* msg_dic = [[NSMutableDictionary alloc]initWithDictionary:[CommonUtils NSDictionaryWithNSString:msg_str]];
        NSString* seq = [msg objectForKey:@"seq"];
        [msg_dic setValue:seq forKey:@"seq"]; //将seq放进消息里
        NSInteger cmd = [[msg_dic objectForKey:@"cmd"] intValue];
        switch (cmd) {
            case ADD_FRIEND_NOTIFICATION:
            {
                [self.friendRequestMsg addObject:msg_dic];
            }
                break;
            case ADD_FRIEND_RESULT:
            case EVENT_INVITE_RESPONSE:
            {
                [self.systemMsg addObject:msg_dic];
            }
                break;
            case NEW_EVENT_NOTIFICATION:
            {
                [self.eventRequestMsg addObject:msg_dic];
            }
                break;
                
            default:
                break;
        }
    }
    
}

#pragma mark - NotificationDelegate

-(void) notificationDidReceive:(NSArray *)messages
{
    for (NSDictionary* msg in messages) {
        NSString* msg_str = [msg objectForKey:@"msg"];
        NSMutableDictionary* msg_dic = [[NSMutableDictionary alloc]initWithDictionary:[CommonUtils NSDictionaryWithNSString:msg_str]];
        NSString* seq = [msg objectForKey:@"seq"];
        [msg_dic setValue:seq forKey:@"seq"]; //将seq放进消息里
        NSInteger cmd = [[msg_dic objectForKey:@"cmd"] intValue];
        switch (cmd) {
            case ADD_FRIEND_NOTIFICATION:
            {
                [self.friendRequestMsg insertObject:msg_dic atIndex:0];
            }
                break;
            case ADD_FRIEND_RESULT:
            case EVENT_INVITE_RESPONSE:
            {
                [self.systemMsg insertObject:msg_dic atIndex:0];
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
        return self.friendRequestMsg.count;
    }
    else if (tableView == self.eventRequest_tableView)
    {
        return self.eventRequestMsg.count;
    }
    else if (tableView == self.systemMessage_tableView)
    {
        return self.systemMsg.count;
    }
    
    return 0;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    UITableViewCell* temp_cell = [[UITableViewCell alloc]init];
    if (tableView == self.eventRequest_tableView) {
        NotificationsEventRequestTableViewCell* cell = [self.eventRequest_tableView dequeueReusableCellWithIdentifier:@"NotificationsEventRequestTableViewCell"];
        if (nil == cell) {
            cell = [[NotificationsEventRequestTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"NotificationsEventRequestTableViewCell"];
        }
        NSMutableDictionary* msg_dic = [self.eventRequestMsg objectAtIndex:indexPath.row];
        NSLog(@"event %d request: %@",indexPath.row, msg_dic);
        NSInteger cmd = [[msg_dic objectForKey:@"cmd"] intValue];
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
                
                if (cell.tag == 0) {
                    cell.okBtn.hidden = NO;
                    cell.noBtn.hidden = NO;
                    cell.remark_label.hidden = YES;
                }
                else
                {
                    cell.okBtn.hidden = YES;
                    cell.noBtn.hidden = YES;
                    cell.remark_label.hidden = NO;
                }
                [cell.okBtn addTarget:self action:@selector(participate_event_okBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
                [cell.noBtn addTarget:self action:@selector(participate_event_noBtnClicked:) forControlEvents:UIControlEventTouchUpInside];

            }
                break;
                
            default:
                break;
        }
        return cell;
    }
    else if(tableView == self.friendRequest_tableView)
    {
        NotificationsFriendRequestTableViewCell* cell = [self.friendRequest_tableView dequeueReusableCellWithIdentifier:@"NotificationsFriendRequestTableViewCell"];
        if (nil == cell) {
            cell = [[NotificationsFriendRequestTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"NotificationsFriendRequestTableViewCell"];
        }
        NSMutableDictionary* msg_dic = [self.friendRequestMsg objectAtIndex:indexPath.row];
        NSLog(@"friend %d request: %@",indexPath.row, msg_dic);
        NSInteger cmd = [[msg_dic objectForKey:@"cmd"] intValue];
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
                
                if (cell.tag == 0) {
                    cell.okBtn.hidden = NO;
                    cell.noBtn.hidden = NO;
                    cell.remark_label.hidden = YES;
                }
                else
                {
                    cell.okBtn.hidden = YES;
                    cell.noBtn.hidden = YES;
                    cell.remark_label.hidden = NO;
                }
                [cell.okBtn addTarget:self action:@selector(friend_request_okBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
                [cell.noBtn addTarget:self action:@selector(friend_request_noBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
                
            }
                break;
                
            default:
                break;
        }
        
        return cell;
    }
    else if (tableView == self.systemMessage_tableView)
    {
        NotificationsSystemMessageTableViewCell* cell = [self.systemMessage_tableView dequeueReusableCellWithIdentifier:@"NotificationsSystemMessageTableViewCell"];
        if (nil == cell) {
            cell = [[NotificationsSystemMessageTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"NotificationsSystemMessageTableViewCell"];
        }
        NSMutableDictionary* msg_dic = [self.systemMsg objectAtIndex:indexPath.row];
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
    cell.tag = 1;
    ((NotificationsFriendRequestTableViewCell*)cell).remark_label.text = @"已同意";
    selectedPath = [self.friendRequest_tableView indexPathForCell:(UITableViewCell*)cell];
    NSDictionary* msg_dic = [self.friendRequestMsg objectAtIndex:selectedPath.row];
    
    NSNumber* seq = [msg_dic objectForKey:@"seq"];
    NSLog(@"ok button row: %d, seq: %@",selectedPath.row,seq);
    
    NSNumber* userid = [MTUser sharedInstance].userid;
    NSNumber* friendid = [msg_dic objectForKey:@"id"];
    NSDictionary* item_id_dic = [CommonUtils packParamsInDictionary:
                                 [NSNumber numberWithInteger:selectedPath.row],@"item_index",
                                 [NSNumber numberWithInt:RESPONSE_FRIEND],@"response_type",
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
    cell.tag = 1;
    ((NotificationsFriendRequestTableViewCell*)cell).remark_label.text = @"已拒绝";
    selectedPath = [self.friendRequest_tableView indexPathForCell:(UITableViewCell*)cell];
    NSDictionary* msg_dic = [self.friendRequestMsg objectAtIndex:selectedPath.row];
    
    NSNumber* seq = [msg_dic objectForKey:@"seq"];
    NSLog(@"no button row: %d, seq: %@",selectedPath.row,seq);
    NSNumber* userid = [MTUser sharedInstance].userid;
    NSNumber* friendid = [msg_dic objectForKey:@"id"];
    NSDictionary* item_id_dic = [CommonUtils packParamsInDictionary:
                                 [NSNumber numberWithInteger:selectedPath.row],@"item_index",
                                 [NSNumber numberWithInt:RESPONSE_FRIEND],@"response_type",
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
    NSDictionary* msg_dic = [self.systemMsg objectAtIndex:selectedPath.row];
    NSNumber* seq = [msg_dic objectForKey:@"seq"];
    NSLog(@"del cell seq: %@, row: %d",seq,selectedPath.row);
    [mySql openMyDB:DB_path];
    [mySql deleteTurpleFromTable:@"notification" withWhere:[[NSDictionary alloc]initWithObjectsAndKeys:[[NSString alloc]initWithFormat:@"%@", seq],@"seq", nil]];
    [mySql closeMyDB];
    [self.systemMsg removeObjectAtIndex:selectedPath.row];
    cell = nil;
    [self.systemMessage_tableView reloadData];
    
}

- (IBAction)participate_event_okBtnClicked:(id)sender
{
    UIView* cell = [sender superview];
    while (![cell isKindOfClass:[NotificationsEventRequestTableViewCell class]]) {
        cell = [cell superview];
    }
    cell.tag = 1;
    ((NotificationsEventRequestTableViewCell*)cell).remark_label.text = @"已同意";
    selectedPath = [self.eventRequest_tableView indexPathForCell:(UITableViewCell*)cell];
    NSDictionary* msg_dic = [self.eventRequestMsg objectAtIndex:selectedPath.row];
    NSNumber* seq = [msg_dic objectForKey:@"seq"];
    NSLog(@"participate cell seq: %@, row: %d",seq,selectedPath.row);
    
    NSNumber* eventid = [msg_dic objectForKey:@"event_id"];
    NSDictionary* item_id_dic = [CommonUtils packParamsInDictionary:
                                 [NSNumber numberWithInteger:selectedPath.row],@"item_index",
                                 [NSNumber numberWithInt:RESPONSE_EVENT],@"response_type",
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
    cell.tag = 1;
    ((NotificationsEventRequestTableViewCell*)cell).remark_label.text = @"已拒绝";
    selectedPath = [self.eventRequest_tableView indexPathForCell:(UITableViewCell*)cell];
    NSDictionary* msg_dic = [self.eventRequestMsg objectAtIndex:selectedPath.row];
    NSNumber* seq = [msg_dic objectForKey:@"seq"];
    NSLog(@"participate cell seq: %@, row: %d",seq,selectedPath.row);
    
    NSNumber* eventid = [msg_dic objectForKey:@"event_id"];
    NSDictionary* item_id_dic = [CommonUtils packParamsInDictionary:
                                 [NSNumber numberWithInteger:selectedPath.row],@"item_index",
                                 [NSNumber numberWithInt:RESPONSE_EVENT],@"response_type",
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
            
            
//            NSLog(@"http receive, response_type: %@, item_index: %@",response_type, item_index);
            if ([response_type intValue] == RESPONSE_FRIEND) {
                NSNumber* result = [response1 valueForKey:@"result"];
                if ([result intValue] == 1) {
                    [CommonUtils showSimpleAlertViewWithTitle:@"系统提示" WithMessage:@"已成功添加好友" WithDelegate:self WithCancelTitle:@"确定"];
                    [self.friendRequest_tableView reloadData];
                    
                    NSDictionary* msg_dic = [self.friendRequestMsg objectAtIndex:[item_index intValue]];
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
                    [mySql closeMyDB];
                    
                    NSDictionary* friendJson = [CommonUtils packParamsInDictionary:
                                                fname,@"name",
                                                femail,@"email",
                                                fgender,@"gender",
                                                fid,@"id",
                                                nil];
                    [[MTUser sharedInstance].friendList addObject:friendJson];
                    [[MTUser sharedInstance] friendListDidChanged];

                }
                else
                {
                    [self.friendRequest_tableView reloadData];
                    NSDictionary* msg_dic = [self.friendRequestMsg objectAtIndex:[item_index intValue]];
                    NSNumber* seq = [msg_dic objectForKey:@"seq"];
                    NSLog(@"response friend, seq: %@",seq);
                    
//                    NSString* fname = [msg_dic objectForKey:@"name"];
//                    NSString* femail = [msg_dic objectForKey:@"email"];
//                    NSNumber* fgender = [msg_dic objectForKey:@"gender"];
//                    NSNumber* fid = [msg_dic objectForKey:@"id"];
                    [mySql openMyDB:DB_path];
                    [mySql deleteTurpleFromTable:@"notification" withWhere:[[NSDictionary alloc]initWithObjectsAndKeys:[[NSString alloc]initWithFormat:@"%@", seq],@"seq", nil]];
                    [mySql closeMyDB];
                }

            }
            else if ([response_type intValue] == RESPONSE_EVENT)
            {
                [self.eventRequest_tableView reloadData];
                NSDictionary* dataMsg = [self.eventRequestMsg objectAtIndex:[item_index intValue]];
                NSNumber* seq = [dataMsg objectForKey:@"seq"];
                NSLog(@"response event, seq: %@",seq);
                [mySql openMyDB:DB_path];
                [mySql deleteTurpleFromTable:@"notification" withWhere:[[NSDictionary alloc]initWithObjectsAndKeys:[[NSString alloc]initWithFormat:@"%@", seq],@"seq", nil]];
                [mySql closeMyDB];
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
- (void)scrollViewDidScroll:(UIScrollView *)scrollView    // any offset changes
{
    if (scrollView == self.tabbar_scrollview) {
        ;
    }
    else if(scrollView == self.content_scrollView)
    {
        CGFloat page_width = scrollView.frame.size.width;
        NSInteger last_tab_index = tab_index;
        tab_index = floor((scrollView.contentOffset.x - page_width/2) / page_width) +1;
        UIColor* bColor_normal = [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1];
        UIColor* bColor_selected = [UIColor colorWithRed:0.577 green:0.577 blue:0.577 alpha:1];
        UIButton* lastBtn = (UIButton*)[tabs objectAtIndex:last_tab_index];
        UIButton* currentBtn = (UIButton*)[tabs objectAtIndex:tab_index];
        
        [lastBtn setBackgroundColor:bColor_normal];
        lastBtn.selected = NO;
        [currentBtn setBackgroundColor:bColor_selected];
        currentBtn.selected = YES;
        
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

