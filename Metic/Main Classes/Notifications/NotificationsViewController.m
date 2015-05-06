//
//  NotificationsViewController.m
//  Metic
//
//  Created by mac on 14-6-23.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "NotificationsViewController.h"
#import "MobClick.h"
#import "MenuViewController.h"
#import "FriendInfoViewController.h"
#import "KxMenu.h"
#import "MTDatabaseHelper.h"

#define MTUser_msgFromDB [MTUser sharedInstance].msgFromDB
#define MTUser_eventRequestMsg [MTUser sharedInstance].eventRequestMsg
#define MTUser_friendRequestMsg [MTUser sharedInstance].friendRequestMsg
#define MTUser_systemMsg [MTUser sharedInstance].systemMsg
#define MTUser_historicalMsg [MTUser sharedInstance].historicalMsg

@interface NotificationsViewController ()
{
    NSString* DB_path;
    NSIndexPath* selectedPath;
    
    CGFloat lastX;
    BOOL clickTab;
    UIView* tabIndicator;
    UILabel *label0,*label1,*label2;
    NSInteger num_tabs;
    
    UIView* waitingView;
    UIActivityIndicatorView* actIndicator;
    NSTimer* waitingTimer;
    
}

enum Response_Type
{
    RESPONSE_EVENT_INVITE = 0,
    RESPONSE_EVENT_REQUEST = 1,
    RESPONSE_FRIEND = 2,
    RESPONSE_SYSTEM = 3
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
@synthesize tab_index;

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
    [MenuViewController sharedInstance].notificationsViewController = self;
    [CommonUtils addLeftButton:self isFirstPage:YES];
    self.appListener = (AppDelegate*)[UIApplication sharedApplication].delegate;
//    self.appListener.notificationDelegate = self;
    [self initParams];
    
}



-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [MobClick endLogPageView:@"消息中心"];
    NSLog(@"消息中心viewdidDisappear");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"pull_message" object:nil];
}
//返回上一层
-(void)MTpopViewController{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //注册观察者接收推送
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNewMessage:) name:@"pull_message" object:nil];
    
    [self.navigationController setNavigationBarHidden:NO];
//    self.appListener.notificationDelegate = self;
    self.eventRequestMsg = [[NSMutableArray alloc]init];
    self.friendRequestMsg = [[NSMutableArray alloc]init];
    self.systemMsg = [[NSMutableArray alloc]init];
    [self.eventRequest_tableView reloadData];
    [self.friendRequest_tableView reloadData];
    [self.systemMessage_tableView reloadData];
    [self removeDuplicate_msgFromDatabase];
    
    if (eventRequestMsg.count == 0) {
        label0.hidden = NO;
    }
    else
    {
        label0.hidden = YES;
    }

    if (friendRequestMsg.count == 0) {
        label1.hidden = NO;
    }
    else
    {
        label1.hidden = YES;
    }
    
    if (systemMsg.count == 0) {
        label2.hidden = NO;
    }
    else
    {
        label2.hidden = YES;
    }
    
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [MobClick beginLogPageView:@"消息中心"];
    self.content_scrollView.contentSize = CGSizeMake(320*self.tabs.count, self.content_scrollView.frame.size.height); //不设这个contentSize的话scrollRectToVisible方法无效
    self.tabbar_scrollview.contentSize = CGSizeMake(960, 40);
    [self.view bringSubviewToFront:_shadowView];
    _shadowView.hidden = NO;
    
    NSUserDefaults *userDfs = [NSUserDefaults standardUserDefaults];
    NSString* key = [NSString stringWithFormat:@"USER%@",[MTUser sharedInstance].userid];
    NSMutableDictionary *userSettings = [[NSMutableDictionary alloc]initWithDictionary:[userDfs objectForKey:key]];
    NSMutableDictionary* unRead_dic = [[NSMutableDictionary alloc]initWithDictionary:[userSettings objectForKey:@"hasUnreadNotification1"]];
    NSNumber* index = [unRead_dic objectForKey:@"tab_show"];
    NSLog(@"消息中心viewdidappear, hasUnreadNotification1: %@", unRead_dic);
    if (index) {
        if ([index integerValue] != -1) {
            tab_index = [index integerValue];
            [self tabBtnClicked:self.tabs[tab_index]];
            clickTab = NO;
        }
    }
    
    for (int i = 0; i < num_tabs; i++) {
        NSString* key_n = [NSString stringWithFormat:@"tab_%d", i];
        NSNumber* tabn = [unRead_dic objectForKey:key_n];
        if (tabn) {
            if ([tabn integerValue] > 0) {
                if (i != tab_index) {
                    [self showDian:i];
                }
                else
                {
                    [self hideDian:i];
                }
            }
            else
            {
                [self hideDian:i];
            }
        }
    }

    [unRead_dic setValue:[NSNumber numberWithInteger:-1] forKey:@"tab_show"];
    [unRead_dic setValue:[NSNumber numberWithInteger:0] forKey:[NSString stringWithFormat:@"tab_%d", tab_index]];
    [userSettings setValue:unRead_dic forKey:@"hasUnreadNotification1"];
    [userSettings setValue:[NSNumber numberWithBool:NO] forKey:@"openWithNotificationCenter"];
    [userDfs setObject:userSettings forKey:key];
    [userDfs synchronize];
    
    [self.appListener.leftMenu hideUpdateInRow:4];
    [[SlideNavigationController sharedInstance] hideLeftBarButtonDian];
    
}

-(void)handleNewMessage:(id)sender
{
//    NSNumber* type = [[sender userInfo] objectForKey:@"type"];
    NSMutableDictionary* msg_dic = [[sender userInfo] objectForKey:@"msg"];

    NSInteger cmd = [[msg_dic objectForKey:@"cmd"] intValue];
    switch (cmd) {
        case ADD_FRIEND_NOTIFICATION:
        {
            NSInteger fid1 = [[msg_dic objectForKey:@"id"]integerValue];
            for (int i = 0; i < self.friendRequestMsg.count; i++) {
                NSMutableDictionary* msg = [self.friendRequestMsg objectAtIndex:i];
                NSInteger fid2 = [[msg objectForKey:@"id"]integerValue];
                if (fid1 == fid2) {
                    [self.friendRequestMsg removeObject:msg];
                    continue;
                }
            }
            [friendRequestMsg insertObject:msg_dic atIndex:0];
            if (!label1.hidden) {
                label1.hidden = YES;
            }
        }
            break;
        case ADD_FRIEND_RESULT:
        {
            [friendRequestMsg insertObject:msg_dic atIndex:0];
            if (!label1.hidden) {
                label1.hidden = YES;
            }
        }
            break;
        case EVENT_INVITE_RESPONSE:
        case REQUEST_EVENT_RESPONSE:
        case QUIT_EVENT_NOTIFICATION:
        case KICK_EVENT_NOTIFICATION:
        {
            for (int j = 0; j < self.systemMsg.count; j++) {
                NSDictionary* msg_dic2 = [self.systemMsg objectAtIndex:j];
                NSInteger cmd2 = [[msg_dic2 objectForKey:@"cmd"] integerValue];
                if (cmd == cmd2) {
                    NSNumber* event_id1 = [msg_dic objectForKey:@"event_id"];
                    NSNumber* event_id2 = [msg_dic2 objectForKey:@"event_id"];
                    if ([event_id1 integerValue] == [event_id2 integerValue]) {
                        [self.systemMsg removeObject:msg_dic2];
                        continue;
                    }
                }
            }
            [self.systemMsg insertObject:msg_dic atIndex:0];

            if (!label2.hidden) {
                label2.hidden = YES;
            }
        }
            break;
        case NEW_EVENT_NOTIFICATION:
        case REQUEST_EVENT:
        {
            NSInteger cmd2;
            NSInteger eventid1, eventid2;
            NSInteger fid1, fid2;
            eventid1 = [[msg_dic objectForKey:@"event_id"] integerValue];
            fid1 = [[msg_dic objectForKey:@"id"]integerValue];
            for (int i = 0; i < self.eventRequestMsg.count; i++) {
                NSMutableDictionary* aMsg = [self.eventRequestMsg objectAtIndex:i];
                cmd2 = [[aMsg objectForKey:@"cmd"] integerValue];
                eventid2 = [[aMsg objectForKey:@"event_id"] integerValue];
                fid2 = [[aMsg objectForKey:@"id"]integerValue];
                if (cmd == cmd2 && eventid1 == eventid2 && fid1 == fid2) {
                    [self.eventRequestMsg removeObject:aMsg];
                    continue;
                }
            }
            
            [self.eventRequestMsg insertObject:msg_dic atIndex:0];
            if (!label0.hidden) {
                label0.hidden = YES;
            }
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
    
    NSUserDefaults *userDfs = [NSUserDefaults standardUserDefaults];
    NSString* key = [NSString stringWithFormat:@"USER%@",[MTUser sharedInstance].userid];
    NSMutableDictionary *userSettings = [[NSMutableDictionary alloc]initWithDictionary:[userDfs objectForKey:key]];
    NSMutableDictionary* unRead_dic = [[NSMutableDictionary alloc]initWithDictionary:[userSettings objectForKey:@"hasUnreadNotification1"]];
//    NSNumber* index = [unRead_dic objectForKey:@"tab_show"];
//    NSLog(@"notification: hasUnreadNotification1: %@", index);
    for (int i = 0; i < num_tabs; i++) {
        NSString* key_n = [NSString stringWithFormat:@"tab_%d", i];
        NSNumber* tabn = [unRead_dic objectForKey:key_n];
        if (tabn) {
            if ([tabn integerValue] > 0 && i != tab_index) {
                [self showDian:i];
            }
        }
    }
    [unRead_dic setValue:[NSNumber numberWithInteger:-1] forKey:@"tab_show"];
    [unRead_dic setValue:[NSNumber numberWithInteger:0] forKey:[NSString stringWithFormat:@"tab_%d", tab_index]];
    [userSettings setValue:unRead_dic forKey:@"hasUnreadNotification1"];
    [userDfs setObject:userSettings forKey:key];
    [userDfs synchronize];

    NSLog(@"消息中心收到推送，隐藏消息中心红点");
    [[MenuViewController sharedInstance] hideUpdateInRow:4];
    [[SlideNavigationController sharedInstance] hideLeftBarButtonDian];
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
    selectedPath = [[NSIndexPath alloc]init];
    DB_path = [[NSString alloc]initWithFormat:@"%@/db",[MTUser sharedInstance].userid];
    num_tabs = 3;
    
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
    [self.tabbar_scrollview setBackgroundColor:[UIColor grayColor]];
    CGRect frame = self.tabbar_scrollview.frame;
    
    int x = 0;
    CGFloat width = frame.size.width/3;
    int height = frame.size.height;
    UIButton* eventR_button = [[UIButton alloc]initWithFrame:CGRectMake(x, 0, width, height - 1)];
    UIButton* friendR_button = [[UIButton alloc]initWithFrame:CGRectMake(x+width, 0, width, height - 1)];
    UIButton* systemMsg_button = [[UIButton alloc]initWithFrame:CGRectMake(x+width*2, 0, width, height - 1)];
    self.tabs = [[NSMutableArray alloc]initWithObjects:eventR_button,friendR_button,systemMsg_button, nil];
    
    UIColor *tabIndicatorColor = [UIColor colorWithRed:0.29 green:0.76 blue:0.61 alpha:1];
    tabIndicator = [[UIView alloc]initWithFrame:CGRectMake(10, height - 3, width - 20, 3)];
    
    
//    eventR_button.showsTouchWhenHighlighted = NO;
//    friendR_button.showsTouchWhenHighlighted = NO;
//    systemMsg_button.showsTouchWhenHighlighted = NO;
    eventR_button.adjustsImageWhenHighlighted = NO;
    friendR_button.adjustsImageWhenHighlighted = NO;
    systemMsg_button.adjustsImageWhenHighlighted = NO;
    
//    UIColor* bColor_normal = [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1];
//    UIColor* bColor_selected = [UIColor colorWithRed:0.577 green:0.577 blue:0.577 alpha:1];
    UIColor* tColor_normal = [UIColor colorWithRed:0.553 green:0.553 blue:0.553 alpha:1];
    UIColor* tColor_selected = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
    
    [eventR_button setBackgroundColor:[UIColor whiteColor]];
    [friendR_button setBackgroundColor:[UIColor whiteColor]];
    [systemMsg_button setBackgroundColor:[UIColor whiteColor]];
    
//    [eventR_button setBackgroundColor:[UIColor clearColor]];
//    [friendR_button setBackgroundColor:[UIColor clearColor]];
//    [systemMsg_button setBackgroundColor:[UIColor clearColor]];
    
    
    [eventR_button setTitle:@"活动邀请" forState:UIControlStateNormal];
    [friendR_button setTitle:@"好友消息" forState:UIControlStateNormal];
    [systemMsg_button setTitle:@"系统消息" forState:UIControlStateNormal];
    
    [eventR_button titleLabel].font = [UIFont systemFontOfSize:14];
    [friendR_button titleLabel].font = [UIFont systemFontOfSize:14];
    [systemMsg_button titleLabel].font = [UIFont systemFontOfSize:14];
    
    [eventR_button setTitleColor:tColor_normal forState:UIControlStateNormal];
    [friendR_button setTitleColor:tColor_normal forState:UIControlStateNormal];
    [systemMsg_button setTitleColor:tColor_normal forState:UIControlStateNormal];
    
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
    [self.tabbar_scrollview addSubview:tabIndicator];
    [tabIndicator setBackgroundColor:tabIndicatorColor];
    
    self.content_scrollView.pagingEnabled = YES;
    self.content_scrollView.scrollEnabled = YES;
    self.content_scrollView.showsHorizontalScrollIndicator = NO;
    self.content_scrollView.showsVerticalScrollIndicator = NO;
    self.content_scrollView.delegate = self;
    
    tab_index = 0;
    clickTab = NO;
    
    label0 = [[UILabel alloc]initWithFrame:CGRectMake(0, self.content_scrollView.frame.size.height/3, 320, 50)];
    [label0 setBackgroundColor:[UIColor clearColor]];
    label0.text = @"暂时没有消息，\n多和好友互动才有消息来哦！";
    label0.numberOfLines = 2;
    label0.textColor = [UIColor grayColor];
    label0.textAlignment = NSTextAlignmentCenter;
    label0.font = [UIFont systemFontOfSize:13];
    
    label1 = [[UILabel alloc]initWithFrame:CGRectMake(0, self.content_scrollView.frame.size.height/3, 320, 50)];
    [label1 setBackgroundColor:[UIColor clearColor]];
    label1.text = @"暂时没有消息，\n多和好友互动才有消息来哦！";
    label1.numberOfLines = 2;
    label1.textColor = [UIColor grayColor];
    label1.textAlignment = NSTextAlignmentCenter;
    label1.font = [UIFont systemFontOfSize:13];
    
    label2 = [[UILabel alloc]initWithFrame:CGRectMake(0, self.content_scrollView.frame.size.height/3, 320, 50)];
    [label2 setBackgroundColor:[UIColor clearColor]];
    label2.text = @"暂时没有消息，\n多和好友互动才有消息来哦！";
    label2.numberOfLines = 2;
    label2.textColor = [UIColor grayColor];
    label2.textAlignment = NSTextAlignmentCenter;
    label2.font = [UIFont systemFontOfSize:13];
    
    [self.eventRequest_tableView addSubview:label0];
    [self.friendRequest_tableView addSubview:label1];
    [self.systemMessage_tableView addSubview:label2];
    
}

-(void)removeDuplicate_msgFromDatabase
{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
//        NSLog(@"消息中心：从数据库取出的eventRequestMsg 去重");
        for (NSMutableDictionary* MTUser_msg_dic in MTUser_eventRequestMsg) {
            BOOL flag = YES;
            NSInteger cmd1 = [[MTUser_msg_dic objectForKey:@"cmd"]integerValue];
            NSInteger event_id1 = [[MTUser_msg_dic objectForKey:@"event_id"]integerValue];
            NSInteger fid1 = [[MTUser_msg_dic objectForKey:@"id"]integerValue];
            
            for (NSMutableDictionary* msg_dic in self.eventRequestMsg) {
                NSInteger cmd2 = [[msg_dic objectForKey:@"cmd"]integerValue];
                NSInteger event_id2 = [[msg_dic objectForKey:@"event_id"]integerValue];
                NSInteger fid2 = [[msg_dic objectForKey:@"id"]integerValue];
                
                if (cmd1 == cmd2 && event_id1 == event_id2 && fid1 == fid2) {
//                    NSLog(@"\ncmd1: %d, cmd2: %d\nevent_id1: %d, event_id2: %d\nfid1: %d, fid2: %d",cmd1,cmd2,event_id1,event_id2,fid1,fid2);
                    flag = NO;
                    break;
                }
            }
            if (flag) {
                [self.eventRequestMsg addObject:MTUser_msg_dic];
//                NSLog(@"插入eventRequestMsg: %@",MTUser_msg_dic);
            }
            
        }
        
        dispatch_async(dispatch_get_main_queue(), ^
                       {
//                           NSLog(@"消息中心：eventRequestMsg去重已经完成");
                           [self.eventRequest_tableView reloadData];
                           if (eventRequestMsg.count == 0) {
                               label0.hidden = NO;
                           }
                           else
                           {
                               label0.hidden = YES;
                           }

                       });
    });
    
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        NSLog(@"消息中心：从数据库取出的friendRequestMsg 去重");
        for (NSMutableDictionary* MTUser_msg_dic in MTUser_friendRequestMsg) {
            BOOL flag = YES;
            NSInteger cmd1 = [[MTUser_msg_dic objectForKey:@"cmd"]integerValue];
            for (NSMutableDictionary* msg_dic in self.friendRequestMsg) {
                NSInteger cmd2 = [[msg_dic objectForKey:@"cmd"]integerValue];
//                NSLog(@"MT_fri_cmd: %d, NF_fri_cmd: %d",cmd1,cmd2);
                if (cmd1 == cmd2) {
                    NSInteger fid1 = [[MTUser_msg_dic objectForKey:@"id"]integerValue];
                    NSInteger fid2 = [[msg_dic objectForKey:@"id"]integerValue];
//                    NSLog(@"MT_fid: %d, NF_fid: %d",fid1,fid2);
                    if (fid1 == fid2) {
                        flag = NO;
                        break;
                    }
                }
            }
            if (flag) {
                [self.friendRequestMsg addObject:MTUser_msg_dic];
//                NSLog(@"插入friendRequestMsg: %@",MTUser_msg_dic);
            }
        }
        
        
        dispatch_async(dispatch_get_main_queue(), ^
                       {
//                           NSLog(@"消息中心：friendRequestMsg去重已经完成");
                           [self.friendRequest_tableView reloadData];
                           if (friendRequestMsg.count == 0) {
                               label1.hidden = NO;
                           }
                           else
                           {
                               label1.hidden = YES;
                           }

                       });

    });
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
       
        NSLog(@"消息中心：对systemMsg 去重");
        for (int i = 0; i < MTUser_systemMsg.count; i++) {
            BOOL flag = YES;
            NSDictionary* MTUser_msg_dic = [MTUser_systemMsg objectAtIndex:i];
            NSLog(@"%d——消息中心, sysmsg: %@", i, MTUser_msg_dic);
            NSInteger cmd1 = [[MTUser_msg_dic objectForKey:@"cmd"]integerValue];
            for (int j = 0; j < self.systemMsg.count; j++) {
                NSDictionary* msg_dic = [self.systemMsg objectAtIndex:j];
                NSInteger cmd2 = [[msg_dic objectForKey:@"cmd"] integerValue];
                if (cmd1 == cmd2) {
                    NSNumber* event_id1 = [MTUser_msg_dic objectForKey:@"event_id"];
                    NSNumber* event_id2 = [msg_dic objectForKey:@"event_id"];
                    if ([event_id1 integerValue] == [event_id2 integerValue]) {
                        flag = NO;
                        break;
                    }
                }
            }
            
            if (flag) {
                [self.systemMsg addObject:MTUser_msg_dic];
            }
           
        }
        dispatch_async(dispatch_get_main_queue(), ^
                       {
                           [self.systemMessage_tableView reloadData];
                           if (systemMsg.count == 0) {
                               label2.hidden = NO;
                           }
                           else
                           {
                               label2.hidden = YES;
                           }
                       });
    });

}

-(void)dismissHud:(NSTimer*)timer
{
    [SVProgressHUD dismissWithError:@"服务器未响应"];
}

- (void)tabBtnClicked:(id)sender

{
//    if ([waitingView superview]) {
//        [waitingView removeFromSuperview];
//    }
//    [self.view addSubview:waitingView];
    
//    NSLog(@"cotnent scrollview, content size: width: %f, height: %f",self.content_scrollView.contentSize.width,self.content_scrollView.contentSize.height);
    NSInteger index = [self.tabs indexOfObject:sender];
    if (index == tab_index) {
        clickTab = NO;
    }
    else
    {
        clickTab = YES;
    }
    UIButton* lastBtn = (UIButton*)[self.tabs objectAtIndex:tab_index];
    UIButton* currentBtn = (UIButton*)sender;
//    NSLog(@"selected button: %d",index);
    lastBtn.selected = NO;
    currentBtn.selected = YES;
    
//    UIColor* bColor_normal = [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1];
//    UIColor* bColor_selected = [UIColor colorWithRed:0.577 green:0.577 blue:0.577 alpha:1];
//    [currentBtn setBackgroundColor:bColor_selected];
//    [lastBtn setBackgroundColor:bColor_normal];
    CGRect frame = CGRectMake(currentBtn.frame.origin.x + 10, tabIndicator.frame.origin.y, tabIndicator.frame.size.width, tabIndicator.frame.size.height) ;
    [self scrollTabIndicator:frame];
    tab_index = index;
    
    CGPoint point = CGPointMake(self.content_scrollView.frame.size.width * index, 0);
    [self.content_scrollView setScrollEnabled:YES];
    [self.content_scrollView setContentOffset:point animated:YES];
    
    if (index == 0) {
        if (self.eventRequestMsg.count == 0) {
            label0.hidden = NO;
        }
        else
        {
            label0.hidden = YES;
        }
//        NSLog(@"活动邀请：\neventRequest: %@\n============\nMT_eventRequest: %@",eventRequestMsg,MTUser_eventRequestMsg);
        [self.eventRequest_tableView reloadData];
    }
    else if (index == 1)
    {
        if (self.friendRequestMsg.count == 0) {
            label1.hidden = NO;
        }
        else
        {
            label1.hidden = YES;
        }
//        NSLog(@"好友请求：\nfriendRequest: %@\n============\nMT_friendRequest: %@",friendRequestMsg,MTUser_friendRequestMsg);
        [self.friendRequest_tableView reloadData];
    }
    else if (index == 2)
    {
        if (self.systemMsg.count == 0) {
            label2.hidden = NO;
        }
        else
        {
            label2.hidden = YES;
        }
//        NSLog(@"系统消息：\nsystemRequest: %@\n============\nMT_systemRequest: %@",systemMsg,MTUser_systemMsg);
        [self.systemMessage_tableView reloadData];
    }

    NSUserDefaults* userDfs = [NSUserDefaults standardUserDefaults];
    NSString* key = [NSString stringWithFormat:@"USER%@", [MTUser sharedInstance].userid];
    NSMutableDictionary* userSettings = [[NSMutableDictionary alloc]initWithDictionary:[userDfs objectForKey:key]];
    NSMutableDictionary* unRead_dic = [[NSMutableDictionary alloc]initWithDictionary:[userSettings objectForKey:@"hasUnreadNotification1"]];
    [unRead_dic setValue:[NSNumber numberWithInteger:0] forKey:[NSString stringWithFormat:@"tab_%d", index]];
    [userSettings setValue:unRead_dic forKey:@"hasUnreadNotification1"];
    [userDfs setObject:userSettings forKey:key];
    [userDfs synchronize];
    
    [self hideDian:index];
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
    [self showMenu];
}

-(void)showMenu
{
    NSMutableArray *menuItems = [[NSMutableArray alloc]init];
    [menuItems addObjectsFromArray:@[
                                     
                                     [KxMenuItem menuItem:@"历史动态"
                                                    image:nil
                                                   target:self
                                                   action:@selector(function1Clicked:)],
                                     
                                     [KxMenuItem menuItem:@"清空当前页"
                                                    image:nil
                                                   target:self
                                                   action:@selector(function2Clicked:)],
                                     ]];

    
    [KxMenu setTintColor:[UIColor whiteColor]];
    [KxMenu setTitleFont:[UIFont systemFontOfSize:17]];
    [KxMenu showMenuInView:self.navigationController.view
                  fromRect:CGRectMake(self.view.bounds.size.width*0.9, 60, 0, 0)
                 menuItems:menuItems];
}

- (IBAction)function1Clicked:(id)sender {
    [self performSegueWithIdentifier:@"notificationvc_historicalvc" sender:self];
}

- (IBAction)function2Clicked:(id)sender {

    [self clearCurrentPage];
}

-(void)clearCurrentPage
{
//    [mySql openMyDB:DB_path];
    if (tab_index == 0) {
        for (NSDictionary* msg in MTUser_eventRequestMsg) {
            NSNumber* seq = [msg objectForKey:@"seq"];
            [[MTDatabaseHelper sharedInstance]deleteTurpleFromTable:@"notification" withWhere:[CommonUtils packParamsInDictionary:[NSString stringWithFormat:@"%@",seq],@"seq",nil]];
        }
        [eventRequestMsg removeAllObjects];
        [MTUser_eventRequestMsg removeAllObjects];
        [self.eventRequest_tableView reloadData];
        label0.hidden = NO;
    }
    else if (tab_index == 1)
    {
        for (NSDictionary* msg in MTUser_friendRequestMsg) {
            NSNumber* seq = [msg objectForKey:@"seq"];
            [[MTDatabaseHelper sharedInstance]deleteTurpleFromTable:@"notification" withWhere:[CommonUtils packParamsInDictionary:[NSString stringWithFormat:@"%@",seq],@"seq",nil]];
        }
        [friendRequestMsg removeAllObjects];
        [MTUser_friendRequestMsg removeAllObjects];
        [self.friendRequest_tableView reloadData];
        label1.hidden = NO;
    }
    else if (tab_index == 2)
    {
        for (NSDictionary* msg in MTUser_systemMsg) {
            NSNumber* seq = [msg objectForKey:@"seq"];
            [[MTDatabaseHelper sharedInstance]deleteTurpleFromTable:@"notification" withWhere:[CommonUtils packParamsInDictionary:[NSString stringWithFormat:@"%@",seq],@"seq",nil]];
        }
        [systemMsg removeAllObjects];
        [MTUser_systemMsg removeAllObjects];
        [self.systemMessage_tableView reloadData];
        label2.hidden = NO;
    }
//    [mySql closeMyDB];

}

- (void) refresh
{
    [self.view setNeedsDisplay];
}

-(void)showDian:(NSInteger)indexOfTab
{
    NSLog(@"显示tab红点： %d", indexOfTab);
    UIButton* tab = [self.tabs objectAtIndex:indexOfTab];
    UIView* view = [tab viewWithTag:233];
    if (!view) {
        UIImage* img = [UIImage imageNamed:@"选择点图标"];
        UIImageView* dian = [[UIImageView alloc]initWithFrame:CGRectMake(tab.frame.size.width - 30, tab.frame.origin.y + 5, 18, 18)];
        dian.image = img;
        dian.tag = 233;
        [tab addSubview:dian];
    }
}

-(void)hideDian:(NSInteger)indexOfTab
{
    NSLog(@"隐藏tab红点： %d", indexOfTab);
    UIButton* tab = [self.tabs objectAtIndex:indexOfTab];
    UIImageView* dian = (UIImageView*)[tab viewWithTag:233];
    if (dian) {
        [dian removeFromSuperview];
    }
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

#pragma mark - NotificationDelegate

-(void) notificationDidReceive:(NSArray *)messages
{
    NSLog(@"消息中心，notificationDidReceive");
    for (NSDictionary* msg in messages) {
        NSString* msg_str = [msg objectForKey:@"content"];
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
                NSInteger fid1 = [[msg_dic objectForKey:@"id"]integerValue];
                for (int i = 0; i < self.friendRequestMsg.count; i++) {
                    NSMutableDictionary* msg = [self.friendRequestMsg objectAtIndex:i];
                    NSInteger fid2 = [[msg objectForKey:@"id"]integerValue];
                    if (fid1 == fid2) {
                        [self.friendRequestMsg removeObject:msg];
                        continue;
                    }
                }
                [friendRequestMsg insertObject:msg_dic atIndex:0];
                if (!label1.hidden) {
                    label1.hidden = YES;
                }
            }
                break;
            case ADD_FRIEND_RESULT:
            {
                [friendRequestMsg insertObject:msg_dic atIndex:0];
                if (!label1.hidden) {
                    label1.hidden = YES;
                }
            }
                break;
            case EVENT_INVITE_RESPONSE:
            case REQUEST_EVENT_RESPONSE:
            case QUIT_EVENT_NOTIFICATION:
            case KICK_EVENT_NOTIFICATION:
            {
                [systemMsg insertObject:msg_dic atIndex:0];
                if (!label2.hidden) {
                    label2.hidden = YES;
                }
            }
                break;
            case NEW_EVENT_NOTIFICATION:
            case REQUEST_EVENT:
            {
                NSInteger cmd2;
                NSInteger eventid1, eventid2;
                NSInteger fid1, fid2;
                eventid1 = [[msg_dic objectForKey:@"event_id"] integerValue];
                fid1 = [[msg_dic objectForKey:@"id"]integerValue];
                for (int i = 0; i < self.eventRequestMsg.count; i++) {
                    NSMutableDictionary* aMsg = [self.eventRequestMsg objectAtIndex:i];
                    cmd2 = [[aMsg objectForKey:@"cmd"] integerValue];
                    eventid2 = [[aMsg objectForKey:@"event_id"] integerValue];
                    fid2 = [[aMsg objectForKey:@"id"]integerValue];
                    if (cmd == cmd2 && eventid1 == eventid2 && fid1 == fid2) {
                        [self.eventRequestMsg removeObject:aMsg];
                        continue;
                    }
                }
                
                [self.eventRequestMsg insertObject:msg_dic atIndex:0];
                if (!label0.hidden) {
                    label0.hidden = YES;
                }
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
    
    NSUserDefaults *userDfs = [NSUserDefaults standardUserDefaults];
    NSString* key = [NSString stringWithFormat:@"USER%@",[MTUser sharedInstance].userid];
    NSMutableDictionary *userSettings = [[NSMutableDictionary alloc]initWithDictionary:[userDfs objectForKey:key]];
    NSMutableDictionary* unRead_dic = [[NSMutableDictionary alloc]initWithDictionary:[userSettings objectForKey:@"hasUnreadNotification1"]];
    NSNumber* index = [unRead_dic objectForKey:@"tab_show"];
//    NSLog(@"viewwillappear notification: hasUnreadNotification1: %@", index);
    if (index) {
        if ([index integerValue] != -1) {
            tab_index = [index integerValue];
            [self tabBtnClicked:self.tabs[tab_index]];
            clickTab = NO;
        }
    }
    
    for (int i = 0; i < num_tabs; i++) {
        NSString* key_n = [NSString stringWithFormat:@"tab_%d", i];
        NSNumber* tabn = [unRead_dic objectForKey:key_n];
        if (tabn) {
            if ([tabn integerValue] > 0) {
                if (i != tab_index) {
                    [self showDian:i];
                }
                else
                {
                    [self hideDian:i];
                }
            }
            else
            {
                [self hideDian:i];
            }
        }
    }
    
    [unRead_dic setValue:[NSNumber numberWithInteger:-1] forKey:@"tab_show"];
    [unRead_dic setValue:[NSNumber numberWithInteger:0] forKey:[NSString stringWithFormat:@"tab_%d", tab_index]];
    [userSettings setValue:unRead_dic forKey:@"hasUnreadNotification1"];
    [userDfs setObject:userSettings forKey:key];
    [userDfs synchronize];
    
    [[MenuViewController sharedInstance] hideUpdateInRow:4];
    [[SlideNavigationController sharedInstance] hideLeftBarButtonDian];
}


#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.eventRequest_tableView) {
        NSDictionary* msg_dic = [self.eventRequestMsg objectAtIndex:indexPath.row];
        NSInteger cmd = [[msg_dic objectForKey:@"cmd"]integerValue];
        if (cmd == REQUEST_EVENT) {
            return 80;
        }
    }
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (tableView == self.eventRequest_tableView) {
        NotificationsEventRequestTableViewCell* cell = (NotificationsEventRequestTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
//        NSLog(@"活动%d邀请标题实际长度: %f",indexPath.row,cell.event_name_label.frame.size.width);
//        NSLog(@"'活动'%d横坐标: %f",indexPath.row, cell.label0.frame.origin.x);
        if ([cell.text_label.text isEqualToString: @"邀请你加入"]) {
            [self eventBtnClicked:self];
        }

    }
    else if (tableView == self.friendRequest_tableView)
    {
        NSDictionary* friendrequest = [self.friendRequestMsg objectAtIndex:indexPath.row];
        NSLog(@"selected friend request: %@", friendrequest);
        NSInteger cmd = [[friendrequest objectForKey:@"cmd"]integerValue];
        if (cmd == 999) {
            NSNumber* friendID = [friendrequest objectForKey:@"id"];
            UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
            FriendInfoViewController* vc = [sb instantiateViewControllerWithIdentifier:@"FriendInfoViewController"];
            vc.fid = friendID;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
    
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.friendRequest_tableView)
    {
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
    UIColor* eventNameColor = [UIColor colorWithRed:0.33 green:0.71 blue:0.93 alpha:1];
    UIColor* label1Color = [UIColor colorWithRed:0.58 green:0.58 blue:0.58 alpha:1];
    UITableViewCell* temp_cell = [[UITableViewCell alloc]init];
    if (tableView == self.eventRequest_tableView) {
        NotificationsEventRequestTableViewCell* cell = [self.eventRequest_tableView dequeueReusableCellWithIdentifier:@"NotificationsEventRequestTableViewCell"];
        if (nil == cell) {
            cell = [[NotificationsEventRequestTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"NotificationsEventRequestTableViewCell"];
        }
        NSMutableDictionary* msg_dic = [eventRequestMsg objectAtIndex:indexPath.row];
//        NSLog(@"event %d request: %@",indexPath.row, msg_dic);
        NSInteger cmd = [[msg_dic objectForKey:@"cmd"] intValue];
//        NSInteger ishandled = [[msg_dic objectForKey:@"ishandled"] integerValue];
        switch (cmd) {
            case NEW_EVENT_NOTIFICATION: //cmd 997
            {
                NSString* subject = [msg_dic objectForKey:@"subject"];
                NSString* launcher = [msg_dic objectForKey:@"launcher"];
                NSNumber* uid = [msg_dic objectForKey:@"launcher_id"];
                
                NSString* alias = [[MTUser sharedInstance].alias_dic objectForKey:[NSString stringWithFormat:@"%@",uid]];
                
                if (alias && ![alias isEqual:[NSNull null]]) {
                    cell.name_label.text = alias;
                }
                else
                {
                    cell.name_label.text = launcher;
                }
                cell.text_label.text = @"邀请你加入";
//                cell.text_label.text = [NSString stringWithFormat:@"邀请你加入%d",indexPath.row];
//                [cell.event_name_button setTitle:subject forState:UIControlStateNormal];
                PhotoGetter* getter = [[PhotoGetter alloc]initWithData:cell.avatar_imageView authorId:uid];
                [getter getAvatar];
                
                UIFont* font = [UIFont systemFontOfSize:11];
                CGSize size = [subject sizeWithFont:font constrainedToSize:CGSizeMake(CGFLOAT_MAX, 16) lineBreakMode:NSLineBreakByWordWrapping];
                CGRect frame = CGRectMake(112, 28, 180, 16);
                if (size.width <= 180) {
                    frame.size.width = size.width;
                }
                else
                {
                    frame.size.width = 180;
                }
//                NSLog(@"活动%d邀请标题长度: %f",indexPath.row,size.width);
                if (!cell.event_name_label) {
                    cell.event_name_label = [[UILabel alloc]init];
                    [cell.event_name_label setBackgroundColor:[UIColor clearColor]];
                    [cell.contentView addSubview:cell.event_name_label];
                    cell.event_name_label.font = [UIFont systemFontOfSize:11];
                    cell.event_name_label.textColor = eventNameColor;
                }
                [cell.event_name_label setFrame:frame];
                cell.event_name_label.text = subject;
//                NSLog(@"活动%d邀请标题实际长度: %f",indexPath.row,cell.event_name_button.frame.size.width);
                if (!cell.label1) {
                    cell.label1 = [[UILabel alloc]init];
                    [cell.label1 setBackgroundColor:[UIColor clearColor]];
                    [cell.contentView addSubview:cell.label1];
                    cell.label1.font = [UIFont systemFontOfSize:11];
                    cell.label1.textColor = label1Color;
                    cell.label1.text = @"活动";
                }
                [cell.label1 setFrame:CGRectMake(frame.origin.x + frame.size.width + 1, frame.origin.y, 30, 15)];
//                NSLog(@"'活动'%d横坐标: %f",indexPath.row, cell.label1.frame.origin.x);
                
                cell.okBtn.hidden = YES;
                cell.noBtn.hidden = YES;
                cell.remark_label.hidden = YES;

            }
                break;
            case REQUEST_EVENT: //995
            {
                NSString* subject = [msg_dic objectForKey:@"subject"];
                NSNumber* uid = [msg_dic valueForKey:@"id"];
                NSString* fname = [msg_dic valueForKey:@"name"];
                NSInteger ishandled = [[msg_dic objectForKey:@"ishandled"] integerValue];
                NSString* confirm_msg = [msg_dic objectForKey:@"confirm_msg"];
                NSString* alias = [[MTUser sharedInstance].alias_dic objectForKey:[NSString stringWithFormat:@"%@",uid]];
                
                if (alias && ![alias isEqual:[NSNull null]]) {
                    cell.name_label.text = alias;
                }
                else
                {
                    cell.name_label.text = fname;
                }

                cell.text_label.text = @"请求加入";
                
                UIFont* font = [UIFont systemFontOfSize:11];
                CGSize size = [subject sizeWithFont:font constrainedToSize:CGSizeMake(CGFLOAT_MAX, 16) lineBreakMode:NSLineBreakByWordWrapping];
                CGRect frame = CGRectMake(100, 28, 180, 16);
                if (size.width <= 180) {
                    frame.size.width = size.width;
                }
                else
                {
                    frame.size.width = 180;
                }
//                NSLog(@"活动%d邀请标题长度: %f",indexPath.row,size.width);
                if (!cell.event_name_label) {
                    cell.event_name_label = [[UILabel alloc]init];
                    [cell.event_name_label setBackgroundColor:[UIColor clearColor]];
                    [cell.contentView addSubview:cell.event_name_label];
                    cell.event_name_label.font = [UIFont systemFontOfSize:11];
                    cell.event_name_label.textColor = eventNameColor;
                }
                [cell.event_name_label setFrame:frame];
                cell.event_name_label.text = subject;
//                NSLog(@"活动%d邀请标题实际长度: %f",indexPath.row,cell.event_name_button.frame.size.width);
                if (!cell.label1) {
                    cell.label1 = [[UILabel alloc]init];
                    [cell.label1 setBackgroundColor:[UIColor clearColor]];
                    [cell.contentView addSubview:cell.label1];
                    cell.label1.font = [UIFont systemFontOfSize:11];
                    cell.label1.textColor = label1Color;
                    cell.label1.text = @"活动";
                }
                [cell.label1 setFrame:CGRectMake(frame.origin.x + frame.size.width + 1, frame.origin.y, 30, 15)];
                
                if (!cell.confirm_msg_label) {
                    cell.confirm_msg_label = [[UILabel alloc]initWithFrame:CGRectMake(75, 45, 220, 30)];
                    [cell.contentView addSubview:cell.confirm_msg_label];
                    [cell.contentView setClipsToBounds:YES];
                    cell.confirm_msg_label.font = [UIFont systemFontOfSize:11];
                    cell.confirm_msg_label.textColor = [UIColor blackColor];
                    cell.confirm_msg_label.backgroundColor = [UIColor clearColor];
                    cell.confirm_msg_label.numberOfLines = 2;
                }
                cell.confirm_msg_label.text = confirm_msg;
                
                PhotoGetter* getter = [[PhotoGetter alloc]initWithData:cell.avatar_imageView authorId:uid];
                [getter getAvatar];
                
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

                [cell.okBtn addTarget:self action:@selector(event_request_okBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
                [cell.noBtn addTarget:self action:@selector(event_request_noBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
//                [cell.event_name_button addTarget:self action:@selector(eventBtnClicked:) forControlEvents:UIControlEventTouchUpInside];

            }
                break;
            default:
                break;
        }
        [cell.contentView setBackgroundColor:bgColor];
        UIColor* borderColor = [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1];
        cell.layer.borderColor = borderColor.CGColor;
        cell.layer.borderWidth = 0.3;
        
        CGRect cellFrame = cell.contentView.frame;
        if (cmd == NEW_EVENT_NOTIFICATION) {
            cellFrame.size.height = 50;
        }
        else if (cmd == REQUEST_EVENT)
        {
            cellFrame.size.height = 80;
        }
        [cell.contentView setFrame:cellFrame];
        return cell;
    }
    else if(tableView == self.friendRequest_tableView)
    {
        NSMutableDictionary* msg_dic = [friendRequestMsg objectAtIndex:indexPath.row];
//        NSLog(@"friend %d request: %@",indexPath.row, msg_dic);
        NSInteger cmd = [[msg_dic objectForKey:@"cmd"] intValue];
        NSInteger ishandled = [[msg_dic objectForKey:@"ishandled"] integerValue];
        switch (cmd) {
            case ADD_FRIEND_NOTIFICATION: //cmd 999
            {
                NotificationsFriendRequestTableViewCell* cell = [self.friendRequest_tableView dequeueReusableCellWithIdentifier:@"NotificationsFriendRequestTableViewCell"];
                if (nil == cell) {
                    cell = [[NotificationsFriendRequestTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"NotificationsFriendRequestTableViewCell"];
                }

                NSString* name = [msg_dic objectForKey:@"name"];
                NSString* confirm_msg = [msg_dic objectForKey:@"confirm_msg"];
                NSNumber* uid = [msg_dic objectForKey:@"id"];
                cell.name_label.text = name;
                cell.conform_msg_label.text = confirm_msg;
                PhotoGetter* getter = [[PhotoGetter alloc]initWithData:cell.avatar_imageView authorId:uid];
                [getter getAvatar];
                
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
                return cell;
                
            }
                break;
                
            case ADD_FRIEND_RESULT: //cmd 998
            {
                NotificationsSystemMessageTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"NotificationsSystemMessageTableViewCell"];
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
                
                return cell;
            }
                break;

            default:
                return nil;
                break;
        }
//        UIColor* borderColor = [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1];
//        cell.layer.borderColor = borderColor.CGColor;
//        cell.layer.borderWidth = 0.3;
    }
    else if (tableView == self.systemMessage_tableView)
    {
        NotificationsSystemMessageTableViewCell* cell = [self.systemMessage_tableView dequeueReusableCellWithIdentifier:@"NotificationsSystemMessageTableViewCell"];
        if (nil == cell) {
            cell = [[NotificationsSystemMessageTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"NotificationsSystemMessageTableViewCell"];
        }
        NSMutableDictionary* msg_dic = [systemMsg objectAtIndex:indexPath.row];
//        NSLog(@"system %d message: %@",indexPath.row, msg_dic);
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
                NSString* subject = [msg_dic objectForKey:@"subject"];
                NSNumber* fid = [msg_dic objectForKey:@"id"];
                NSString* name;
                NSString* alias = [[MTUser sharedInstance].alias_dic objectForKey:[NSString stringWithFormat:@"%@",fid]];
                
                if (alias && ![alias isEqual:[NSNull null]]) {
                    name = alias;
                }
                else
                {
                    name = [msg_dic objectForKey:@"name"];
                }

                NSString* text = @"";
                if (result) {
                    text = [NSString stringWithFormat:@"%@ 同意加入你的活动: %@ ",name,subject];
                }
                else
                {
                    text = [NSString stringWithFormat:@"%@ 拒绝加入你的活动: %@ ",name,subject];
                    
                }
                cell.title_label.text = @"活动消息";
                cell.sys_msg_label.text = text;
            }
                break;
            case REQUEST_EVENT_RESPONSE:  //994
            {
                NSInteger result = [[msg_dic objectForKey:@"result"] intValue];
                NSString* launcher;
                NSString* subject = [msg_dic objectForKey:@"subject"];
                NSNumber* launcher_id = [msg_dic objectForKey:@"launcher_id"];
                NSString* alias = [[MTUser sharedInstance].alias_dic objectForKey:[NSString stringWithFormat:@"%@",launcher_id]];
                
                if (alias && ![alias isEqual:[NSNull null]]) {
                    launcher = alias;
                }
                else
                {
                    launcher = [msg_dic objectForKey:@"launcher"];
                }

                NSString* text = @"";
                if (result) {
                    text = [NSString stringWithFormat:@"%@ 同意你加入活动: %@ ",launcher,subject];
                }
                else
                {
                    text = [NSString stringWithFormat:@"%@ 拒绝你加入活动: %@ ",launcher,subject];
                    
                }
                cell.title_label.text = @"活动消息";
                cell.sys_msg_label.text = text;
            }
                break;
                
            case QUIT_EVENT_NOTIFICATION:  //985
            {
                NSString* subject = [msg_dic objectForKey:@"subject"];
                NSString* text;
                text = [NSString stringWithFormat:@"%@ 活动已经被解散",subject];
                cell.title_label.text = @"活动消息";
                cell.sys_msg_label.text = text;
            }
                break;
            case KICK_EVENT_NOTIFICATION:  //984
            {
                NSString* subject = [msg_dic objectForKey:@"subject"];
                NSString* text;
                text = [NSString stringWithFormat:@"您已经被请出 %@ 活动",subject];
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
//    [self waitingViewShow:self.friendRequest_tableView];
    [SVProgressHUD showWithStatus:@"正在处理" maskType:SVProgressHUDMaskTypeGradient];
    waitingTimer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(dismissHud:) userInfo:nil repeats:NO];
    UIView* cell = [sender superview];
    while (![cell isKindOfClass:[NotificationsFriendRequestTableViewCell class]]) {
        cell = [cell superview];
    }
//    cell.tag = 1;
    ((NotificationsFriendRequestTableViewCell*)cell).remark_label.text = @"已同意";
    selectedPath = [self.friendRequest_tableView indexPathForCell:(UITableViewCell*)cell];
    NSDictionary* msg_dic = [friendRequestMsg objectAtIndex:selectedPath.row];
    
    NSNumber* seq = [msg_dic objectForKey:@"seq"];
    NSLog(@"friend, ok button row: %d, seq: %@",selectedPath.row,seq);
    
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
//    [self waitingViewShow:self.friendRequest_tableView];
    [SVProgressHUD showWithStatus:@"正在处理" maskType:SVProgressHUDMaskTypeGradient];
    waitingTimer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(dismissHud:) userInfo:nil repeats:NO];
    UIView* cell = [sender superview];
    while (![cell isKindOfClass:[NotificationsFriendRequestTableViewCell class]]) {
        cell = [cell superview];
    }
//    cell.tag = 1;
    ((NotificationsFriendRequestTableViewCell*)cell).remark_label.text = @"已拒绝";
    selectedPath = [self.friendRequest_tableView indexPathForCell:(UITableViewCell*)cell];
    NSDictionary* msg_dic = [friendRequestMsg objectAtIndex:selectedPath.row];
    
    NSNumber* seq = [msg_dic objectForKey:@"seq"];
    NSLog(@"friend, no button row: %d, seq: %@",selectedPath.row,seq);
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
    NSLog(@"del cell seq: %@, row: %ld",seq,(long)selectedPath.row);

    [[MTDatabaseHelper sharedInstance]deleteTurpleFromTable:@"notification" withWhere:[[NSDictionary alloc]initWithObjectsAndKeys:[[NSString alloc]initWithFormat:@"%@", seq],@"seq", nil]];
    [systemMsg removeObjectAtIndex:selectedPath.row];
    cell = nil;
    [self.systemMessage_tableView reloadData];
    
}

- (IBAction)event_request_okBtnClicked:(id)sender
{
//    [self waitingViewShow:self.eventRequest_tableView];
    [SVProgressHUD showWithStatus:@"正在处理" maskType:SVProgressHUDMaskTypeGradient];
    waitingTimer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(dismissHud:) userInfo:nil repeats:NO];
    UIView* cell = [sender superview];
    while (![cell isKindOfClass:[NotificationsEventRequestTableViewCell class]]) {
        cell = [cell superview];
    }
//    cell.tag = 1;
    ((NotificationsEventRequestTableViewCell*)cell).remark_label.text = @"已同意";
    selectedPath = [self.eventRequest_tableView indexPathForCell:(UITableViewCell*)cell];
    NSDictionary* msg_dic = [eventRequestMsg objectAtIndex:selectedPath.row];
    NSNumber* seq = [msg_dic objectForKey:@"seq"];
    NSLog(@"event request cell seq: %@, row: %d",seq,selectedPath.row);
    
    NSNumber* eventid = [msg_dic objectForKey:@"event_id"];
    NSNumber* requester_id = [msg_dic valueForKey:@"id"];
    NSDictionary* item_id_dic = [CommonUtils packParamsInDictionary:
                                 [NSNumber numberWithInteger:selectedPath.row],@"item_index",
                                 [NSNumber numberWithInt:RESPONSE_EVENT_REQUEST],@"response_type",
                                 [NSNumber numberWithInteger:1],@"response_result",
                                 nil];
    NSMutableDictionary* json = [CommonUtils packParamsInDictionary:
                                 [NSNumber numberWithInt:994],@"cmd",
                                 [NSNumber numberWithInt:1],@"result",
                                 [MTUser sharedInstance].userid,@"id",
                                 requester_id,@"requester_id",
                                 eventid,@"event_id",
                                 item_id_dic,@"item_id",
                                 nil];
    NSLog(@"event request okBtn, http json : %@",json );
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:PARTICIPATE_EVENT];
}

- (IBAction)event_request_noBtnClicked:(id)sender
{
//    [self waitingViewShow:self.eventRequest_tableView];
    [SVProgressHUD showWithStatus:@"正在处理" maskType:SVProgressHUDMaskTypeGradient];
    waitingTimer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(dismissHud:) userInfo:nil repeats:NO];
    UIView* cell = [sender superview];
    while (![cell isKindOfClass:[NotificationsEventRequestTableViewCell class]]) {
        cell = [cell superview];
    }
//    cell.tag = 1;
    ((NotificationsEventRequestTableViewCell*)cell).remark_label.text = @"已拒绝";
    selectedPath = [self.eventRequest_tableView indexPathForCell:(UITableViewCell*)cell];
    NSDictionary* msg_dic = [eventRequestMsg objectAtIndex:selectedPath.row];
    NSNumber* seq = [msg_dic objectForKey:@"seq"];
    NSLog(@"event request cell seq: %@, row: %ld",seq,(long)selectedPath.row);
    
    NSNumber* eventid = [msg_dic objectForKey:@"event_id"];
    NSNumber* requester_id = [msg_dic valueForKey:@"id"];
    NSDictionary* item_id_dic = [CommonUtils packParamsInDictionary:
                                 [NSNumber numberWithInteger:selectedPath.row],@"item_index",
                                 [NSNumber numberWithInt:RESPONSE_EVENT_REQUEST],@"response_type",
                                 [NSNumber numberWithInteger:0],@"response_result",
                                 nil];
    NSMutableDictionary* json = [CommonUtils packParamsInDictionary:
                                 [NSNumber numberWithInt:994],@"cmd",
                                 [NSNumber numberWithInt:0],@"result",
                                 [MTUser sharedInstance].userid,@"id",
                                 requester_id,@"requester_id",
                                 eventid,@"event_id",
                                 item_id_dic,@"item_id",
                                 nil];
    NSLog(@"event request event noBtn, http json : %@",json );
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:PARTICIPATE_EVENT];
}

-(void)eventBtnClicked:(id)sender
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
    [waitingTimer invalidate];
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
            
            if ([response_type intValue] == RESPONSE_FRIEND) {
                
                if ([result intValue] == 1) {
                    [self.friendRequest_tableView reloadData];
                    NSMutableDictionary* msg_dic = [friendRequestMsg objectAtIndex:[item_index intValue]];
                    int seq1 = [[msg_dic objectForKey:@"seq"]intValue];
                    
                    NSString* fname = [msg_dic objectForKey:@"name"];
                    NSString* femail = [msg_dic objectForKey:@"email"];
                    NSNumber* fgender = [msg_dic objectForKey:@"gender"];
                    int fid1 = [[msg_dic objectForKey:@"id"]intValue];
                    [[MTDatabaseHelper sharedInstance]deleteTurpleFromTable:@"notification" withWhere:[[NSDictionary alloc]initWithObjectsAndKeys:[[NSString alloc]initWithFormat:@"%d", seq1],@"seq", nil]];
                    [[MTDatabaseHelper sharedInstance] insertToTable:@"friend"
                     
                        withColumns:[[NSArray alloc]initWithObjects:@"id",@"name",@"email",@"gender",@"alias", nil]
                          andValues:[[NSArray alloc] initWithObjects:
                                     [NSString stringWithFormat:@"%d",fid1],
                                     [NSString stringWithFormat:@"'%@'",fname],
                                     [NSString stringWithFormat:@"'%@'",femail],
                                     [NSString stringWithFormat:@"%@",[CommonUtils NSStringWithNSNumber:fgender]],
                                     [NSNull null],nil]];
                    [[MTDatabaseHelper sharedInstance]updateDataWithTableName:@"notification"
                                                                     andWhere:[CommonUtils packParamsInDictionary:[NSString stringWithFormat:@"%d",seq1],@"seq",nil]
                                                                       andSet:[CommonUtils packParamsInDictionary:[NSString stringWithFormat:@"%d",1],@"ishandled",nil]];
                    for (int i = 0; i < MTUser_friendRequestMsg.count; i++) {
                        NSMutableDictionary* msg = [MTUser_friendRequestMsg objectAtIndex:i];
                        NSInteger cmd2 = [[msg objectForKey:@"cmd"]integerValue];
                        if (cmd2 == ADD_FRIEND_NOTIFICATION) {
                            int fid2 = [[msg objectForKey:@"id"]intValue];
                            int seq2 = [[msg objectForKey:@"seq"]intValue];
                            if (fid1 == fid2 && seq1 != seq2) {
                                [[MTDatabaseHelper sharedInstance] deleteTurpleFromTable:@"notification" withWhere:[[NSDictionary alloc]initWithObjectsAndKeys:[[NSString alloc]initWithFormat:@"%d", seq2],@"seq", nil]];
                                [MTUser_friendRequestMsg removeObject:msg];
                                i--;
                            }
                        }
                    }
                    
                    NSMutableDictionary* friendJson = [CommonUtils packParamsInDictionary:
                                                fname,@"name",
                                                femail,@"email",
                                                fgender,@"gender",
                                                [NSNumber numberWithInt:fid1],@"id",
                                                [NSNull null], @"alias",
                                                nil];
                    [[MTUser sharedInstance].friendList addObject:friendJson];
                    [[MTUser sharedInstance] friendListDidChanged];
                    
                    [MTUser_friendRequestMsg removeObject:msg_dic];
                    NSLog(@"（同意）MTuser_friendR去掉一条记录：%@ \n剩下的记录有：%@",msg_dic,MTUser_friendRequestMsg);
                    [msg_dic setValue:result forKey:@"ishandled"];
                    
                    [MTUser_historicalMsg insertObject:msg_dic atIndex:0];
                    [SVProgressHUD dismissWithSuccess:[NSString stringWithFormat:@"成功添加%@为好友",fname] afterDelay:2];
                }
                else
                {
                    [self.friendRequest_tableView reloadData];
                    NSMutableDictionary* msg_dic = [friendRequestMsg objectAtIndex:[item_index intValue]];
                    NSInteger seq1 = [[msg_dic objectForKey:@"seq"]integerValue];
                    NSInteger fid1 = [[msg_dic objectForKey:@"id"]integerValue];
                    NSString* fname = [msg_dic objectForKey:@"name"];
                    NSLog(@"response friend, seq: %ld, fid: %ld",(long)seq1,(long)fid1);
                    
                    [[MTDatabaseHelper sharedInstance] updateDataWithTableName:@"notification"
                                                                      andWhere:[CommonUtils packParamsInDictionary:[NSString stringWithFormat:@"%ld",(long)seq1],@"seq", nil]
                                                                        andSet:[CommonUtils packParamsInDictionary:[NSString stringWithFormat:@"%d",0],@"ishandled", nil]];
                    
                    for (int i = 0; i < MTUser_friendRequestMsg.count; i++) {
                        NSMutableDictionary* msg = [MTUser_friendRequestMsg objectAtIndex:i];
                        NSInteger cmd2 = [[msg objectForKey:@"cmd"]integerValue];
                        if (cmd2 == ADD_FRIEND_NOTIFICATION) {
                            int fid2 = [[msg objectForKey:@"id"]intValue];
                            int seq2 = [[msg objectForKey:@"seq"]intValue];
                            if (fid1 == fid2 && seq1 != seq2) {
                                [[MTDatabaseHelper sharedInstance]deleteTurpleFromTable:@"notification" withWhere:[[NSDictionary alloc]initWithObjectsAndKeys:[[NSString alloc]initWithFormat:@"%d", seq2],@"seq", nil]];
                                [MTUser_friendRequestMsg removeObject:msg];
                                i--;
                            }
                        }
                    }

//                    [mySql closeMyDB];

                    [MTUser_friendRequestMsg removeObject:msg_dic];
                    NSLog(@"（拒绝）MTuser_friendR去掉一条记录：%@ \n剩下的记录有：%@",msg_dic,MTUser_friendRequestMsg);
                    [msg_dic setValue:result forKey:@"ishandled"];
                    
                    [MTUser_historicalMsg insertObject:msg_dic atIndex:0];
                    
                    [SVProgressHUD dismissWithSuccess:[NSString stringWithFormat:@"成功拒绝%@为好友",fname] afterDelay:2];
                    
                }

            }
            else if ([response_type intValue] == RESPONSE_EVENT_INVITE || [response_type integerValue] == RESPONSE_EVENT_REQUEST)
            {
                [self.eventRequest_tableView reloadData];
                NSMutableDictionary* msg_dic = [eventRequestMsg objectAtIndex:[item_index intValue]];
                
                NSInteger seq1 = [[msg_dic objectForKey:@"seq"]integerValue];
                NSLog(@"response event, seq: %d",seq1);
                NSInteger cmd1 = [[msg_dic objectForKey:@"cmd"]integerValue];
                NSInteger event_id1 = [[msg_dic objectForKey:@"event_id"]integerValue];
                [[MTDatabaseHelper sharedInstance]updateDataWithTableName:@"notification"
                                                                 andWhere:[CommonUtils packParamsInDictionary:[NSString stringWithFormat:@"%d",seq1],@"seq", nil]
                                                                   andSet:[CommonUtils packParamsInDictionary:[NSString stringWithFormat:@"%@",result],@"ishandled", nil]];
                
                
                for (int i = 0; i < MTUser_eventRequestMsg.count; i++) {
                    NSMutableDictionary* msg  = [MTUser_eventRequestMsg objectAtIndex:i];
                    NSInteger cmd2 = [[msg objectForKey:@"cmd"]integerValue];
                    NSInteger event_id2 = [[msg objectForKey:@"event_id"]integerValue];
                    NSInteger seq2 = [[msg objectForKey:@"seq"]integerValue];
                    if (cmd1 == cmd2 && event_id1 == event_id2 && seq1 != seq2) {
                        [[MTDatabaseHelper sharedInstance]deleteTurpleFromTable:@"notification" withWhere:[[NSDictionary alloc]initWithObjectsAndKeys:[[NSString alloc]initWithFormat:@"%d", seq2],@"seq", nil]];
                        [MTUser_eventRequestMsg removeObject:msg];
                        continue;
                    }
                }
//                [mySql closeMyDB];
                
                
                [MTUser_eventRequestMsg removeObject:msg_dic];
                [msg_dic setValue:result forKey:@"ishandled"];

                [MTUser_historicalMsg insertObject:msg_dic atIndex:0];
                NSLog(@"处理完了一条活动请求: %@",msg_dic);
                
                [SVProgressHUD dismissWithSuccess:@"操作成功" afterDelay:2];
            }
            
        }
            break;
        case ALREADY_FRIENDS:
        {
            NSDictionary* item_id_dic = [response1 objectForKey:@"item_id"];
            NSInteger row = selectedPath.row;
            NSMutableDictionary* msg_dic = [friendRequestMsg objectAtIndex:row];
            NSInteger seq1 = [[msg_dic objectForKey:@"seq"]integerValue];
            NSInteger fid1 = [[msg_dic objectForKey:@"id"]integerValue];
            NSNumber* response_result = [item_id_dic objectForKey:@"response_result"];
            NSLog(@"response already friend, seq: %d, fid: %ld",seq1, (long)fid1);
            
            //!已经是好友的情况下修改数据库的用户操作字段ishandled，有可能会造成数据错误。当然，只是有可能。我需要修改ishandled的值使这条消息标记为已处理!
//            [mySql openMyDB:DB_path];
            [[MTDatabaseHelper sharedInstance] updateDataWithTableName:@"notification"
                   andWhere:[CommonUtils packParamsInDictionary:
                             [NSString stringWithFormat:@"%ld",(long)seq1],@"seq", nil]
                     andSet:[CommonUtils packParamsInDictionary:
                             [NSString stringWithFormat:@"%@",response_result],@"ishandled",nil]];
            
            
            for (int i = 0; i < self.friendRequestMsg.count; i++) {
                NSMutableDictionary* msg = [self.friendRequestMsg objectAtIndex:i];
                NSInteger cmd2 = [[msg objectForKey:@"cmd"]integerValue];
                if (cmd2 == ADD_FRIEND_NOTIFICATION) {
                    NSInteger fid2 = [[msg objectForKey:@"id"]integerValue];
                    //                NSInteger seq2 = [[msg objectForKey:@"seq"]integerValue];
                    if (fid1 == fid2) {
                        [self.friendRequestMsg removeObject:msg];
                        continue;
                    }
                }
            }


            for (int i = 0; i < MTUser_friendRequestMsg.count; i++) {
                NSMutableDictionary* msg = [MTUser_friendRequestMsg objectAtIndex:i];
                NSInteger cmd2 = [[msg objectForKey:@"cmd"]integerValue];
                if (cmd2 == ADD_FRIEND_NOTIFICATION) {
                    NSInteger fid2 = [[msg objectForKey:@"id"]integerValue];
                    NSInteger seq2 = [[msg objectForKey:@"seq"]integerValue];
                    if (fid1 == fid2 && seq1 != seq2) {
                        [[MTDatabaseHelper sharedInstance] deleteTurpleFromTable:@"notification" withWhere:[[NSDictionary alloc]initWithObjectsAndKeys:[[NSString alloc]initWithFormat:@"%ld", (long)seq2],@"seq", nil]];
                        [MTUser_friendRequestMsg removeObject:msg];
                        i--;
                    }

                }
                
            }
            
//            [mySql closeMyDB];

            [MTUser_friendRequestMsg removeObject:msg_dic];
            [self.friendRequest_tableView reloadData];
            
            [SVProgressHUD dismissWithError:@"你们已经是好友" afterDelay:2];
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
            [SVProgressHUD dismissWithError:@"发送请求错误" afterDelay:2];
        }
            break;
        case ALREADY_IN_EVENT:
        {
            NSDictionary* item_id_dic = [response1 objectForKey:@"item_id"];
            NSInteger row = selectedPath.row;
            NSMutableDictionary* msg_dic = [self.eventRequestMsg objectAtIndex:row];
            NSNumber* seq = [msg_dic objectForKey:@"seq"];
            NSNumber* response_result = [item_id_dic objectForKey:@"response_result"];
            
            [[MTDatabaseHelper sharedInstance] updateDataWithTableName:@"notification"
                   andWhere:[CommonUtils packParamsInDictionary:
                             [NSString stringWithFormat:@"%@",seq],@"seq", nil]
                     andSet:[CommonUtils packParamsInDictionary:
                             [NSString stringWithFormat:@"%@",response_result],@"ishandled",nil]];

            [MTUser_eventRequestMsg removeObject:msg_dic];
            [eventRequestMsg removeObjectAtIndex:row];
            [self.eventRequest_tableView reloadData];
            [SVProgressHUD dismissWithError:@"该用户已经在此活动中了" afterDelay:2];
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
        case EVENT_NOT_EXIST:
        {
            [SVProgressHUD dismissWithError:@"该活动已经解散" afterDelay:2.0];
            NSDictionary* item_id_dic = [response1 objectForKey:@"item_id"];
            NSInteger row = selectedPath.row;
            NSMutableDictionary* msg_dic = [self.eventRequestMsg objectAtIndex:row];
            NSInteger event_id1 = [[msg_dic objectForKey:@"event_id"]integerValue];
            NSInteger cmd1 = [[msg_dic objectForKey:@"cmd"]integerValue];
            NSInteger seq1 = [[msg_dic objectForKey:@"seq"]integerValue];
            NSNumber* response_result = [item_id_dic objectForKey:@"response_result"];
            
//            [mySql openMyDB:DB_path];
            [[MTDatabaseHelper sharedInstance] updateDataWithTableName:@"notification"
                   andWhere:[CommonUtils packParamsInDictionary:
                             [NSString stringWithFormat:@"%ld",(long)seq1],@"seq", nil]
                     andSet:[CommonUtils packParamsInDictionary:
                             [NSString stringWithFormat:@"%@",response_result],@"ishandled", nil]];
            
            for (int i = 0; i < [MTUser sharedInstance].eventRequestMsg.count; i++) {
                NSMutableDictionary* msg = [MTUser sharedInstance].eventRequestMsg[i];
                NSInteger cmd2 = [[msg objectForKey:@"cmd"]integerValue];
                NSInteger event_id2 = [[msg objectForKey:@"event_id"]integerValue];
                NSInteger seq2 = [[msg objectForKey:@"seq"]integerValue];
                if (cmd1 == cmd2 && event_id1 == event_id2 && seq1 != seq2) {
                    [[MTDatabaseHelper sharedInstance] deleteTurpleFromTable:@"notification" withWhere:[[NSDictionary alloc]initWithObjectsAndKeys:[[NSString alloc]initWithFormat:@"%ld", (long)seq2],@"seq", nil]];
                    [[MTUser sharedInstance].eventRequestMsg removeObject:msg];
                    continue;
                }
            }
            
//            [mySql closeMyDB];
            
            [MTUser_eventRequestMsg removeObject:msg_dic];
            [self.eventRequestMsg removeObjectAtIndex:row];
            [self.eventRequest_tableView reloadData];
            
        }
            break;

        default:
            NSLog(@"消息中心未对该cmd做处理, cmd: %@",cmd);
            break;
    }
//    [self waitingViewHide];
    if (self.eventRequestMsg.count == 0) {
        label0.hidden = NO;
    }
    if (self.friendRequestMsg.count == 0) {
        label1.hidden = NO;
    }
    if (self.systemMsg.count == 0) {
        label2.hidden = NO;
    }
}

#pragma mark - UIScrollViewDelegate
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    NSLog(@"scroll view did begin scroll");
//    if (!functions_uiview.hidden) {
//        [UIView beginAnimations:@"View shows" context:nil];
//        [UIView setAnimationDuration:0.5];
//        [UIView setAnimationDelegate:self];
//        [UIView  setAnimationCurve: UIViewAnimationCurveEaseOut];
//        [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:self.functions_uiview  cache:YES];
//        [functions_uiview setHidden:YES];
//        [UIView commitAnimations];
//    }
    
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

//        UIColor* bColor_normal = [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1];
//        UIColor* bColor_selected = [UIColor colorWithRed:0.577 green:0.577 blue:0.577 alpha:1];
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
//    NSLog(@"scroll view did scroll");
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    NSLog(@"scroll did end scroll animation");
    clickTab = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSLog(@"scrollview did end decelerating");
    if (scrollView == self.content_scrollView) {
        if (tab_index == 0) {
            [self.eventRequest_tableView reloadData];
            if (self.eventRequestMsg.count == 0) {
                label0.hidden = NO;
            }
            else
            {
                label0.hidden = YES;
            }
            NSLog(@"reload event_table");
        }
        else if (tab_index == 1)
        {
            [self.friendRequest_tableView reloadData];
            if (self.friendRequestMsg.count == 0) {
                label1.hidden = NO;
            }
            else
            {
                label1.hidden = YES;
            }
            NSLog(@"reload friend_table");
        }
        else if (tab_index == 2)
        {
            [self.systemMessage_tableView reloadData];
            if (self.systemMsg.count == 0) {
                label2.hidden = NO;
            }
            else
            {
                label2.hidden = YES;
            }
            NSLog(@"reload system_table");
        }
        
        NSUserDefaults* userDfs = [NSUserDefaults standardUserDefaults];
        NSString* key = [NSString stringWithFormat:@"USER%@", [MTUser sharedInstance].userid];
        NSMutableDictionary* userSettings = [[NSMutableDictionary alloc]initWithDictionary:[userDfs objectForKey:key]];
        NSMutableDictionary* unRead_dic = [[NSMutableDictionary alloc]initWithDictionary:[userSettings objectForKey:@"hasUnreadNotification1"]];
        [unRead_dic setValue:[NSNumber numberWithInteger:0] forKey:[NSString stringWithFormat:@"tab_%d", tab_index]];
        [userSettings setValue:unRead_dic forKey:@"hasUnreadNotification1"];
        [userDfs setObject:userSettings forKey:key];
        [userDfs synchronize];
        
        [self hideDian:tab_index];
        
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
        self.navigationController.navigationBar.alpha = 1 - distance/400.0;
    }else{
        self.shadowView.hidden = YES;
        [self.view sendSubviewToBack:self.shadowView];
    }
}
@end

