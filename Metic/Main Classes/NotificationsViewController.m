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
    int width = frame.size.width/3;
    int height = frame.size.height;
    UIButton* eventR_button = [[UIButton alloc]initWithFrame:CGRectMake(x, 0, width, height)];
    UIButton* friendR_button = [[UIButton alloc]initWithFrame:CGRectMake(x+width, 0, width, height)];
    UIButton* systemMsg_button = [[UIButton alloc]initWithFrame:CGRectMake(x+width*2, 0, width, height)];
    self.tabs = [[NSMutableArray alloc]initWithObjects:eventR_button,friendR_button,systemMsg_button, nil];
    
//    UIColor* color = [UIColor darkGrayColor];
    [eventR_button setBackgroundColor:[UIColor grayColor]];
    [friendR_button setBackgroundColor:[UIColor clearColor]];
    [systemMsg_button setBackgroundColor:[UIColor clearColor]];
    
    [eventR_button setTitle:@"邀请" forState:UIControlStateNormal];
    [friendR_button setTitle:@"好友" forState:UIControlStateNormal];
    [systemMsg_button setTitle:@"系统" forState:UIControlStateNormal];
    [eventR_button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [friendR_button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [systemMsg_button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [eventR_button setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [friendR_button setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [systemMsg_button setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    
    [eventR_button backgroundRectForBounds:CGRectMake(0, eventR_button.frame.size.height - 5, eventR_button.frame.size.width, 5)];
    [eventR_button setSelected:YES];
    
//    [eventR_button.layer setBorderWidth:2];
//    [eventR_button.layer setBorderColor:[UIColor greenColor].CGColor];
    
    [eventR_button addTarget:self action:@selector(tabBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [friendR_button addTarget:self action:@selector(tabBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [systemMsg_button addTarget:self action:@selector(tabBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.tabbar_scrollview addSubview:eventR_button];
    [self.tabbar_scrollview addSubview:friendR_button];
    [self.tabbar_scrollview addSubview:systemMsg_button];
    
    self.content_scrollView.pagingEnabled = YES;
    self.content_scrollView.scrollEnabled = YES;
    self.content_scrollView.delegate = self;
    
    tab_index = 0;
    
    
}

- (IBAction)tabBtnClicked:(id)sender

{
    int index = [self.tabs indexOfObject:sender];
    NSLog(@"selected button: %d",index);
    [(UIButton*)sender setBackgroundColor:[UIColor lightGrayColor]];
    [((UIButton*)sender) setSelected: YES];
    UIButton* lastBtn = (UIButton*)[self.tabs objectAtIndex:tab_index];
    [lastBtn setBackgroundColor:[UIColor clearColor]];
    lastBtn.selected = NO;
    tab_index = index;
    CGRect frame = self.content_scrollView.frame;
    frame.origin.x = frame.size.width*index;
    
    [self.content_scrollView scrollRectToVisible:frame animated:YES];
//    [self.content_scrollView setContentOffset:CGPointMake(frame.size.width*index, 0) animated:YES];
//    NSLog(@"x: %f,y: %f, width: %f, height: %f",frame.origin.x, frame.origin.y,frame.size.width,frame.size.height);
    
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


- (void) getMsgFromDataBase
{
    [mySql openMyDB:DB_path];
    self.msgFromDB = [mySql queryTable:@"notification" withSelect:[[NSArray alloc]initWithObjects:@"msg",@"seq", nil] andWhere:nil];
    [mySql closeMyDB];
    NSLog(@"msg from db: %@",msgFromDB);
//    [self.notificationsTable reloadData];
    int count = self.msgFromDB.count;
    for (int i = count - 1; i >= 0; i--) {
        NSDictionary* msg = [msgFromDB objectAtIndex:i];
        NSString* msg_str = [msg objectForKey:@"msg"];
        NSDictionary* msg_dic = [CommonUtils NSDictionaryWithNSString:msg_str];
        NSInteger cmd = [[msg_dic objectForKey:@"cmd"] intValue];
        switch (cmd) {
            case ADD_FRIEND_NOTIFICATION:
            {
                [self.friendRequestMsg addObject:msg_dic];
            }
                break;
            case ADD_FRIEND_RESULT:
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
    int count = self.msgFromDB.count;
    NSDictionary* msg = [self.msgFromDB objectAtIndex:(count-1-indexPath.row)];
    NSString* msg_str = [msg objectForKey:@"msg"];
//    NSLog(@"msg_str: %@",msg_str);
    NSDictionary* msg_dic = [CommonUtils NSDictionaryWithNSString:msg_str];
    NSInteger cmd = [[msg_dic objectForKey:@"cmd"] intValue];
    UITableViewCell* temp_cell = [[UITableViewCell alloc]init];
//    NSLog(@"notification table cmd: %d",cmd);
//    switch (cmd) {
//        case ADD_FRIEND_NOTIFICATION:
//        {
//            NotificationsTableViewCell* cell = [self.notificationsTable dequeueReusableCellWithIdentifier:@"requestnotification"];
//            if (nil == cell) {
//                cell = [[NotificationsTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"requestnotification"];
//            }
//            NSString* name = [msg_dic objectForKey:@"name"];
//            NSString* confirm_msg = [msg_dic objectForKey:@"confirm_msg"];
//            NSString* label = [[NSString alloc]initWithFormat:@"%@ 想要加你为好友\n验证信息：%@",name,confirm_msg ];
//            cell.textView.text =  label;
//            cell.okBtn.hidden = NO;
//            [cell.okBtn setTitle:@"同意" forState:UIControlStateNormal];
//            [cell.noBtn setTitle:@"拒绝" forState:UIControlStateNormal];
//            [cell.okBtn addTarget:self action:@selector(okBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
//            [cell.noBtn addTarget:self action:@selector(noBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
////            NSLog(@"return add friend notification cell");
//            return cell ;
//            
//        }
//            break;
//        case ADD_FRIEND_RESULT:
//        {
//            NotificationsTableViewCell* cell = [self.notificationsTable dequeueReusableCellWithIdentifier:@"requestnotification"];
//            if (nil == cell) {
//                cell = [[NotificationsTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"requestnotification"];
//            }
//            NSString* name = [msg_dic objectForKey:@"name"];
//            NSNumber* result = [msg_dic objectForKey:@"result"];
//            NSString* label;
//            if (result) {
//                label = [NSString stringWithFormat:@"%@ 同意添加你为好友",name];
//            }
//            else
//                label = [NSString stringWithFormat:@"%@ 拒绝添加你为好友",name];
//            cell.textView.text = label;
//            cell.okBtn.hidden = YES;
//            [cell.noBtn setTitle:@"删除" forState:UIControlStateNormal];
//            [cell.noBtn addTarget:self action:@selector(delBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
//            return cell ;
//            
//        }
//            break;
//        case NEW_EVENT_NOTIFICATION:
//        {
//            NotificationsTableViewCell* cell = [self.notificationsTable dequeueReusableCellWithIdentifier:@"requestnotification"];
//            if (nil == cell) {
//                cell = [[NotificationsTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"requestnotification"];
//            }
//            NSString* subject = [msg_dic objectForKey:@"subject"];
//            NSString* launcher = [msg_dic objectForKey:@"launcher"];
//            NSString* time = [msg_dic objectForKey:@"time"];
//            NSString* label = [NSString stringWithFormat:@"活动邀请\n主题：%@\n发起者：%@\n开始时间：%@",subject,launcher,time];
//            cell.textView.text = label;
//            cell.okBtn.hidden = NO;
//            [cell.okBtn setTitle:@"同意" forState:UIControlStateNormal];
//            [cell.noBtn setTitle:@"拒绝" forState:UIControlStateNormal];
//            [cell.okBtn addTarget:self action:@selector(participate_event_okBtnClicked:) forControlEvents:UIControlEventTouchUpInside ];
//            [cell.noBtn addTarget:self action:@selector(participate_event_noBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
//            
//            return cell ;
//;
//        }
//            break;
//            
//        default:
//            break;
//    }
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
                PhotoGetter* getter = [[PhotoGetter alloc]initWithData:cell.avatar_imageView path:[NSString stringWithFormat:@"/avatar/%@.jpg",uid] type:2 cache:nil];
                getter.mDelegate = self;
                [getter setTypeOption2:uid];
                [getter getPhoto];
//                NSString* time = [msg_dic objectForKey:@"time"];

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
                PhotoGetter* getter = [[PhotoGetter alloc]initWithData:cell.avatar_imageView path:[NSString stringWithFormat:@"/avatar/%@.jpg",uid] type:2 cache:nil];
                getter.mDelegate = self;
                [getter setTypeOption2:uid];
                [getter getPhoto];
                
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
                cell.sys_msg_label.text = text;
            }
                break;
                
            default:
                break;
        }
        
        return cell;
    }
    return temp_cell;
}

- (IBAction)okBtnClicked:(id)sender
{
    int count = self.msgFromDB.count;
    UITableViewCell* cell = (UITableViewCell*)[[[(UIButton*)sender superview] superview]superview];
//    selectedPath = [self.notificationsTable indexPathForCell:cell];
    NSDictionary* dataMsg = [self.msgFromDB objectAtIndex:(count - 1 -selectedPath.row)];
    NSString* msg_str = [dataMsg objectForKey:@"msg" ];
    NSDictionary* msg_dic = [CommonUtils NSDictionaryWithNSString:msg_str];
    NSNumber* seq = [dataMsg objectForKey:@"seq"];
    NSLog(@"ok button row: %d, seq: %@",selectedPath.row,seq);
    NSNumber* userid = [MTUser sharedInstance].userid;
    NSNumber* friendid = [msg_dic objectForKey:@"id"];
//    UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"好友申请" message:@"请输入验证信息：" delegate:self cancelButtonTitle:@"拒绝" otherButtonTitles:@"同意", nil];
//    [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
//    [alertView show];
//    NSLog(@"cmd: %@, result: %@, id: %@, friend_id: %@",[NSNumber numberWithInt:998],[NSNumber numberWithInt:1],userid,friendid);
    NSMutableDictionary* json = [CommonUtils packParamsInDictionary:[NSNumber numberWithInt:998],@"cmd",[NSNumber numberWithInt:1],@"result",friendid,@"friend_id",userid,@"id",[NSNumber numberWithInt:ADD_FRIEND],@"item_id",nil];
    NSLog(@"agreed json: %@",json);
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:ADD_FRIEND];
    
//    [self.msgFromDB removeObjectAtIndex:selectedPath.row];
//    [mySql openMyDB:DB_path];
//    [mySql deleteTurpleFromTable:@"notification" withWhere:[[NSDictionary alloc]initWithObjectsAndKeys:[[NSString alloc]initWithFormat:@"%@", seq],@"seq", nil]];
//    [mySql closeMyDB];
    
}

- (IBAction)noBtnClicked:(id)sender
{
    int count = self.msgFromDB.count;
    UITableViewCell* cell = (UITableViewCell*)[[[sender superview]superview]superview];
//    selectedPath = [self.notificationsTable indexPathForCell:cell];
    NSDictionary* dataMsg = [self.msgFromDB objectAtIndex:(count - 1 -selectedPath.row)];
    NSString* msg_str = [dataMsg objectForKey:@"msg" ];
    NSDictionary* msg_dic = [CommonUtils NSDictionaryWithNSString:msg_str];
    NSNumber* seq = [dataMsg objectForKey:@"seq"];
    NSLog(@"no button row: %d, seq: %@",selectedPath.row,seq);
    NSNumber* userid = [MTUser sharedInstance].userid;
    NSNumber* friendid = [msg_dic objectForKey:@"id"];
    NSMutableDictionary* json = [CommonUtils packParamsInDictionary:[NSNumber numberWithInt:998],@"cmd",[NSNumber numberWithInt:0],@"result",userid,@"id",friendid,@"friend_id",[NSNumber numberWithInt:ADD_FRIEND],@"item_id",nil];
    NSLog(@"reject json: %@",json);
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:ADD_FRIEND];
    
//    [self.msgFromDB removeObjectAtIndex:selectedPath.row];
//    [mySql openMyDB:DB_path];
//    [mySql deleteTurpleFromTable:@"notification" withWhere:[[NSDictionary alloc]initWithObjectsAndKeys:[[NSString alloc]initWithFormat:@"%@", seq],@"seq", nil]];
//    [mySql closeMyDB];

    
}

- (IBAction)delBtnClicked:(id)sender
{
    int count = self.msgFromDB.count;
    UITableViewCell* cell = (UITableViewCell*)[[[sender superview]superview]superview] ;
//    selectedPath = [self.notificationsTable indexPathForCell:cell];
    
    NSDictionary* dataMsg = [self.msgFromDB objectAtIndex:(count - 1 -selectedPath.row)];
    NSNumber* seq = [dataMsg objectForKey:@"seq"];
    NSLog(@"del cell seq: %@, row: %d",seq,selectedPath.row);
    [mySql openMyDB:DB_path];
    [mySql deleteTurpleFromTable:@"notification" withWhere:[[NSDictionary alloc]initWithObjectsAndKeys:[[NSString alloc]initWithFormat:@"%@", seq],@"seq", nil]];
    [mySql closeMyDB];
    [self.msgFromDB removeObjectAtIndex:(count - 1 - selectedPath.row)];
    cell = nil;
//    [self.notificationsTable reloadData];
    
}

- (IBAction)participate_event_okBtnClicked:(id)sender
{
    int count = self.msgFromDB.count;
    UITableViewCell* cell = (UITableViewCell*)[[[sender superview]superview]superview];
//    selectedPath = [self.notificationsTable indexPathForCell:cell];
    NSDictionary* dataMsg = [self.msgFromDB objectAtIndex:(count - 1 -selectedPath.row)];
    NSNumber* seq = [dataMsg objectForKey:@"seq"];
    NSLog(@"participate cell seq: %@, row: %d",seq,selectedPath.row);
    NSString* msg_str = [dataMsg objectForKey:@"msg" ];
    NSDictionary* msg_dic = [CommonUtils NSDictionaryWithNSString:msg_str];
    NSNumber* eventid = [msg_dic objectForKey:@"event_id"];
    NSMutableDictionary* json = [CommonUtils packParamsInDictionary:[NSNumber numberWithInt:997],@"cmd",[NSNumber numberWithInt:1],@"result",[MTUser sharedInstance].userid,@"id",eventid,@"event_id",[NSNumber numberWithInt:PARTICIPATE_EVENT],@"item_id",nil];
    NSLog(@"participate event okBtn, http json : %@",json );
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:PARTICIPATE_EVENT];
}

- (IBAction)participate_event_noBtnClicked:(id)sender
{
    int count = self.msgFromDB.count;
    UITableViewCell* cell = (UITableViewCell*)[[[sender superview]superview]superview];
//    selectedPath = [self.notificationsTable indexPathForCell:cell];
    NSDictionary* dataMsg = [self.msgFromDB objectAtIndex:(count - 1 -selectedPath.row)];
    NSNumber* seq = [dataMsg objectForKey:@"seq"];
    NSLog(@"participate cell seq: %@, row: %d",seq,selectedPath.row);
    NSString* msg_str = [dataMsg objectForKey:@"msg" ];
    NSDictionary* msg_dic = [CommonUtils NSDictionaryWithNSString:msg_str];
    NSNumber* eventid = [msg_dic objectForKey:@"event_id"];
    NSMutableDictionary* json = [CommonUtils packParamsInDictionary:[NSNumber numberWithInt:997],@"cmd",[NSNumber numberWithInt:0],@"result",[MTUser sharedInstance].userid,@"id",eventid,@"event_id",[NSNumber numberWithInt:PARTICIPATE_EVENT],@"item_id",nil];
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
            NSNumber* item_id = [response1 valueForKey:@"item_id"];
            NSNumber* result = [response1 valueForKey:@"result"];
            int count = self.msgFromDB.count;
            if ([item_id intValue] == ADD_FRIEND && [result intValue] == 1) {
                [CommonUtils showSimpleAlertViewWithTitle:@"系统提示" WithMessage:@"已成功添加好友" WithDelegate:self WithCancelTitle:@"确定"];
                
                
                NSDictionary* dataMsg = [self.msgFromDB objectAtIndex:(count - 1 -selectedPath.row)];
                NSNumber* seq = [dataMsg objectForKey:@"seq"];
                NSLog(@"normal reply, seq: %@",seq);
                NSString* msg_str = [dataMsg objectForKey:@"msg" ];
                NSDictionary* msg_dic = [CommonUtils NSDictionaryWithNSString:msg_str];
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
                

            }
            else if ([item_id intValue] == PARTICIPATE_EVENT)
            {
                NSDictionary* dataMsg = [self.msgFromDB objectAtIndex:(count - 1 -selectedPath.row)];
                NSNumber* seq = [dataMsg objectForKey:@"seq"];
                NSLog(@"normal reply, seq: %@",seq);
                [mySql openMyDB:DB_path];
                [mySql deleteTurpleFromTable:@"notification" withWhere:[[NSDictionary alloc]initWithObjectsAndKeys:[[NSString alloc]initWithFormat:@"%@", seq],@"seq", nil]];
                [mySql closeMyDB];
            }
            [self.msgFromDB removeObjectAtIndex:selectedPath.row];
//            [self.notificationsTable reloadData];
        }
            break;
        case ALREADY_FRIENDS:
        {
            
            [CommonUtils showSimpleAlertViewWithTitle:@"系统提示" WithMessage:@"你们已经是好友" WithDelegate:self WithCancelTitle:@"确定"];
            int count = self.msgFromDB.count;
            NSDictionary* dataMsg = [self.msgFromDB objectAtIndex:(count - 1 -selectedPath.row)];
            NSNumber* seq = [dataMsg objectForKey:@"seq"];
            NSLog(@"already friends, seq: %@",seq);
            [mySql openMyDB:DB_path];
            [mySql deleteTurpleFromTable:@"notification" withWhere:[[NSDictionary alloc]initWithObjectsAndKeys:[[NSString alloc]initWithFormat:@"%@", seq],@"seq", nil]];
            [mySql closeMyDB];
            [self.msgFromDB removeObjectAtIndex:selectedPath.row];
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
            int count = self.msgFromDB.count;
            NSDictionary* dataMsg = [self.msgFromDB objectAtIndex:(count - 1 -selectedPath.row)];
            NSNumber* seq = [dataMsg objectForKey:@"seq"];
            NSLog(@"already in event, seq: %@",seq);
            [mySql openMyDB:DB_path];
            [mySql deleteTurpleFromTable:@"notification" withWhere:[[NSDictionary alloc]initWithObjectsAndKeys:[[NSString alloc]initWithFormat:@"%@", seq],@"seq", nil]];
            [mySql closeMyDB];
            [self.msgFromDB removeObjectAtIndex:selectedPath.row];
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
        UIButton* lastBtn = (UIButton*)[tabs objectAtIndex:last_tab_index];
        UIButton* currentBtn = (UIButton*)[tabs objectAtIndex:tab_index];
        [lastBtn setBackgroundColor:[UIColor clearColor]];
        lastBtn.selected = NO;
        [currentBtn setBackgroundColor:[UIColor lightGrayColor]];
        currentBtn.selected = YES;
        
    }
}

#pragma mark - PhotoGetterDelegate
-(void)finishwithNotification:(UIImageView*)imageView image:(UIImage*)image type:(int)type container:(id)container
{
    imageView.image = image;
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

