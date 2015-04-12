//
//  EventInvitationViewController.m
//  Metic
//
//  Created by ligang_mac4 on 14-7-28.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "EventInvitationViewController.h"
#import "MenuViewController.h"
#import "../Cell/EventInvitationTableViewCell.h"
#import "PhotoGetter.h"
#import "MTUser.h"
#import "MobClick.h"
#import "../Source/SVProgressHUD/SVProgressHUD.h"

@interface EventInvitationViewController ()
{
    NSIndexPath* selectedPath;
    MySqlite* mySql;
    NSString* DB_path;
    
    NSTimer* timer;
}
//@property (nonatomic,strong) NSMutableArray* eventRequestMsg;
@end

@implementation EventInvitationViewController
@synthesize msg_arr;

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
    [CommonUtils addLeftButton:self isFirstPage:NO];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(PopToHereAndTurnToNotificationPage:) name: @"PopToFirstPageAndTurnToNotificationPage" object:nil];
//    _eventRequestMsg = [MTUser sharedInstance].eventRequestMsg;
    
    _tableView.dataSource = self;
    _tableView.delegate = self;
    selectedPath = [[NSIndexPath alloc]init];
    mySql = [[MySqlite alloc]init];
    DB_path = [[NSString alloc]initWithFormat:@"%@/db",[MTUser sharedInstance].userid];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self getMsgArray];
    [_tableView reloadData];
//    self.msg_arr = [MTUser sharedInstance].eventRequestMsg;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [MobClick beginLogPageView:@"活动邀请"];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [MobClick endLogPageView:@"活动邀请"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name: @"PopToFirstPageAndTurnToNotificationPage" object:nil];
}

//返回上一层
-(void)MTpopViewController{
    [self.navigationController popViewControllerAnimated:YES];
}

//返回本页并跳转到消息页
-(void)PopToHereAndTurnToNotificationPage:(id)sender
{
    NSLog(@"PopToHereAndTurnToNotificationPage  from  invitation");
    
    if ([[SlideNavigationController sharedInstance].viewControllers containsObject:self]){
        NSLog(@"Here");
        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"shouldIgnoreTurnToNotifiPage"]) {
            [[SlideNavigationController sharedInstance] popToViewController:self animated:NO];
            [self ToNotificationCenter];
        }
    }else{
        NSLog(@"NotHere");
    }
}

-(void)ToNotificationCenter
{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone"
                                                             bundle: nil];
    UIViewController* vc = [MenuViewController sharedInstance].notificationsViewController;
    if(!vc){
        vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"NotificationsViewController"];
        [MenuViewController sharedInstance].notificationsViewController = vc;
    }
    
    [[SlideNavigationController sharedInstance] openMenuAndSwitchToViewController:vc withCompletion:nil];
}

-(void)getMsgArray
{
    msg_arr = [[NSMutableArray alloc]init];
    for (int i = 0; i < [MTUser sharedInstance].eventRequestMsg.count; i++) {
        NSMutableDictionary* msg = [[MTUser sharedInstance].eventRequestMsg objectAtIndex:i];
        NSInteger cmd = [[msg objectForKey:@"cmd"] integerValue];
        if (cmd != REQUEST_EVENT) {
            BOOL flag = YES;
            for (int j = 0; j < msg_arr.count; j++) {
                NSMutableDictionary* temp_msg = [msg_arr objectAtIndex:j];
                NSInteger eventId1 = [[temp_msg objectForKey:@"event_id"]integerValue];
                NSInteger eventId2 = [[msg objectForKey:@"event_id"]integerValue];
                NSInteger fid1 = [[temp_msg objectForKey:@"id"]integerValue];
                NSInteger fid2 = [[msg objectForKey:@"id"]integerValue];
                if (eventId1 == eventId2 && fid1 == fid2) {
                    flag = NO;
                    break;
                }
            }
            if (flag) {
                [msg_arr addObject:msg];
            }
            
        }
    }
    NSLog(@"活动邀请列表: %@",msg_arr);
}
#pragma mark UITableViewDataSource
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return msg_arr.count==0? 80:289;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return msg_arr.count==0? 1:msg_arr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(msg_arr.count==0){
        UITableViewCell* cell = [[UITableViewCell alloc]init];
        UILabel* label = [[UILabel alloc]initWithFrame:CGRectMake(0,0,300,80)];
        cell.userInteractionEnabled = NO;
        cell.backgroundColor = [UIColor clearColor];
        

        label.text = @"暂时没有活动邀请了\n去活动广场看看吧";
        label.numberOfLines = 2;
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont systemFontOfSize:14];
        label.textColor = [UIColor colorWithWhite:147.0/255.0 alpha:1.0f];
        label.textAlignment = NSTextAlignmentCenter;
        [cell addSubview:label];
        return cell;
    }
    
    static NSString *CellIdentifier = @"eventInvitationCell";
    BOOL nibsRegistered = NO;
    if (!nibsRegistered) {
        UINib *nib = [UINib nibWithNibName:NSStringFromClass([EventInvitationTableViewCell class]) bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:CellIdentifier];
        nibsRegistered = YES;
    }
    EventInvitationTableViewCell *cell = (EventInvitationTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    
    NSDictionary *a = msg_arr[indexPath.row];
    cell.eventName.text = [a valueForKey:@"subject"];
    NSString* beginT = [a valueForKey:@"time"];
    NSString* endT = [a valueForKey:@"endTime"];
    cell.beginDate.text = [[[beginT substringWithRange:NSMakeRange(5, 5)] stringByAppendingString:@"日"] stringByReplacingOccurrencesOfString:@"-" withString:@"月"];
    cell.beginTime.text = [beginT substringWithRange:NSMakeRange(11, 5)];
    cell.endDate.text = [[[endT substringWithRange:NSMakeRange(5, 5)] stringByAppendingString:@"日"]  stringByReplacingOccurrencesOfString:@"-" withString:@"月"];
    cell.endTime.text = [endT substringWithRange:NSMakeRange(11, 5)];
    cell.timeInfo.text = [CommonUtils calculateTimeInfo:beginT endTime:endT launchTime:[a valueForKey:@"launch_time"]];
    cell.location.text = [[NSString alloc]initWithFormat:@"活动地点: %@",[a valueForKey:@"location"] ];
    
    
    NSInteger participator_count = [[a valueForKey:@"member_count"] integerValue];
    NSString* partiCount_Str = [NSString stringWithFormat:@"%ld",(long)participator_count];
    NSString* participator_Str = [NSString stringWithFormat:@"已有 %@ 人参加",partiCount_Str];
    
    cell.member_count.font = [UIFont systemFontOfSize:15];
    cell.member_count.numberOfLines = 0;
    cell.member_count.lineBreakMode = NSLineBreakByCharWrapping;
    cell.member_count.tintColor = [UIColor lightGrayColor];
    [cell.member_count setText:participator_Str afterInheritingLabelAttributesAndConfiguringWithBlock:^(NSMutableAttributedString *mutableAttributedString) {
        NSRange redRange = [participator_Str rangeOfString:partiCount_Str];
        UIFont *systemFont = [UIFont systemFontOfSize:18];
        
        if (redRange.location != NSNotFound) {
            // Core Text APIs use C functions without a direct bridge to UIFont. See Apple's "Core Text Programming Guide" to learn how to configure string attributes.
            [mutableAttributedString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(id)[CommonUtils colorWithValue:0xef7337].CGColor range:redRange];
            
            CTFontRef italicFont = CTFontCreateWithName((__bridge CFStringRef)systemFont.fontName, systemFont.pointSize, NULL);
            [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)italicFont range:redRange];
            CFRelease(italicFont);
        }
        return mutableAttributedString;
    }];
    
    //显示备注名
    NSString* alias = [[MTUser sharedInstance].alias_dic objectForKey:[NSString stringWithFormat:@"%@",[a valueForKey:@"launcher_id"]]];
    if (alias == nil || [alias isEqual:[NSNull null]]) {
        alias = [a valueForKey:@"launcher"];
    }
    cell.launcherinfo.text = [[NSString alloc]initWithFormat:@"发起人: %@",alias];
    cell.inviteInfo.text = [[NSString alloc]initWithFormat:@"%@ 邀请你加入活动",alias];
    cell.eventId = [a valueForKey:@"event_id"];
    //cell.avatar.layer.masksToBounds = YES;
    [cell.avatar.layer setCornerRadius:15];
    
    PhotoGetter* avatarGetter = [[PhotoGetter alloc]initWithData:cell.avatar authorId:[a valueForKey:@"launcher_id"]];
    [avatarGetter getAvatar];
    
    PhotoGetter* bannerGetter = [[PhotoGetter alloc]initWithData:cell.themePhoto authorId:[a valueForKey:@"event_id"]];
    NSString* bannerURL = [a valueForKey:@"banner"];
    [bannerGetter getBanner:[a valueForKey:@"code"] url:bannerURL];

    
    NSArray *memberids = [a valueForKey:@"member"];
    
    for (int i =3; i>=0; i--) {
        UIImageView *tmp = ((UIImageView*)[((UIView*)[cell viewWithTag:103]) viewWithTag:i+1]);
        //tmp.layer.masksToBounds = YES;
        [tmp.layer setCornerRadius:5];
        if (i < participator_count) {
            PhotoGetter* miniGetter = [[PhotoGetter alloc]initWithData:tmp authorId:memberids[i]];
            [miniGetter getAvatar];
        }else tmp.image = nil;
        
    }
    [cell.ok_button addTarget:self action:@selector(participate_event_okBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [cell.no_button addTarget:self action:@selector(participate_event_noBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (IBAction)participate_event_okBtnClicked:(id)sender
{
    [SVProgressHUD showWithStatus:@"正在处理" maskType:SVProgressHUDMaskTypeBlack];
    timer = [NSTimer scheduledTimerWithTimeInterval:6.0 target:self selector:@selector(dismissHud:) userInfo:nil repeats:NO];
    UIView* cell = [sender superview];
    while (![cell isKindOfClass:[EventInvitationTableViewCell class]]) {
        cell = [cell superview];
    }
    selectedPath = [_tableView indexPathForCell:(UITableViewCell*)cell];
    NSDictionary* msg_dic = [msg_arr objectAtIndex:selectedPath.row];
    NSNumber* seq = [msg_dic objectForKey:@"seq"];
    NSLog(@"participate cell seq: %@, row: %d",seq,selectedPath.row);
    
    NSNumber* eventid = [msg_dic objectForKey:@"event_id"];
    NSDictionary* item_id_dic = [CommonUtils packParamsInDictionary:
                                 [NSNumber numberWithInteger:selectedPath.row],@"item_index",
//                                 [NSNumber numberWithInt:RESPONSE_EVENT],@"response_type",
                                 [NSNumber numberWithInteger:1],@"response_result",
                                 nil];
    NSMutableDictionary* json = [CommonUtils packParamsInDictionary:
                                 [NSNumber numberWithInt:997],@"cmd",
                                 [NSNumber numberWithInt:1],@"result",
                                 [MTUser sharedInstance].userid,@"id",
                                 eventid,@"event_id",
                                 item_id_dic,@"item_id",
//                                 [NSNumber numberWithInt:RESPONSE_EVENT],@"response_type",
                                 nil];
    NSLog(@"participate event okBtn, http json : %@",json );
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:PARTICIPATE_EVENT finshedBlock:^(NSData *rData) {
        if(rData)[self finishWithReceivedData:rData];
        else{
            [SVProgressHUD dismissWithError:@"网络异常"];
        }
    }];
}

- (IBAction)participate_event_noBtnClicked:(id)sender
{
    [SVProgressHUD showWithStatus:@"正在处理" maskType:SVProgressHUDMaskTypeBlack];
    timer = [NSTimer scheduledTimerWithTimeInterval:6.0 target:self selector:@selector(dismissHud:) userInfo:nil repeats:NO];
//    [SVProgressHUD showSuccessWithStatus:@"捣乱中..." duration:3];
    UIView* cell = [sender superview];
    while (![cell isKindOfClass:[EventInvitationTableViewCell class]]) {
        cell = [cell superview];
    }
    selectedPath = [_tableView indexPathForCell:(UITableViewCell*)cell];
    NSDictionary* msg_dic = [msg_arr objectAtIndex:selectedPath.row];
    NSNumber* seq = [msg_dic objectForKey:@"seq"];
    NSLog(@"participate cell seq: %@, row: %d",seq,selectedPath.row);
    
    NSNumber* eventid = [msg_dic objectForKey:@"event_id"];
    NSDictionary* item_id_dic = [CommonUtils packParamsInDictionary:
                                 [NSNumber numberWithInteger:selectedPath.row],@"item_index",
//                                 [NSNumber numberWithInt:RESPONSE_EVENT],@"response_type",
                                 [NSNumber numberWithInteger:0],@"response_result",
                                 nil];
    NSMutableDictionary* json = [CommonUtils packParamsInDictionary:
                                 [NSNumber numberWithInt:997],@"cmd",
                                 [NSNumber numberWithInt:0],@"result",
                                 [MTUser sharedInstance].userid,@"id",
                                 eventid,@"event_id",
                                 item_id_dic,@"item_id",
//                                 [NSNumber numberWithInt:RESPONSE_EVENT],@"response_type",
                                 nil];
    NSLog(@"participate event noBtn, http json : %@",json );
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:PARTICIPATE_EVENT finshedBlock:^(NSData *rData) {
        if(rData)[self finishWithReceivedData:rData];
        else{
            [SVProgressHUD dismissWithError:@"网络异常"];
            
        }
    }];
}

-(void)dismissHud:(NSTimer*)timer
{
    [SVProgressHUD dismiss];
}


#pragma mark - HttpSenderDelegate
-(void)finishWithReceivedData:(NSData*) rData
{
    [timer invalidate];
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
//            NSNumber* response_type = [item_id_dic objectForKey:@"response_type"];
            NSNumber* result = [item_id_dic valueForKey:@"response_result"];
            NSMutableDictionary* msg_dic = [msg_arr objectAtIndex:[item_index intValue]];
            
            NSInteger seq1 = [[msg_dic objectForKey:@"seq"]integerValue];
            NSLog(@"response event, seq: %d",seq1);
            NSInteger cmd1 = [[msg_dic objectForKey:@"cmd"]integerValue];
            NSInteger event_id1 = [[msg_dic objectForKey:@"event_id"]integerValue];
//            [mySql openMyDB:DB_path];
            [mySql database: DB_path
     updateDataWitTableName:@"notification"
                   andWhere:[CommonUtils packParamsInDictionary:
                             [NSString stringWithFormat:@"%d",seq1],@"seq",nil]
                     andSet:[CommonUtils packParamsInDictionary:
                             [NSString stringWithFormat:@"%@",result],@"ishandled",nil]
                 completion:nil];
            
            for (int i = 0; i < [MTUser sharedInstance].eventRequestMsg.count; i++) {
                NSMutableDictionary* msg = [MTUser sharedInstance].eventRequestMsg[i];
                NSInteger cmd2 = [[msg objectForKey:@"cmd"]integerValue];
                NSInteger event_id2 = [[msg objectForKey:@"event_id"]integerValue];
                NSInteger seq2 = [[msg objectForKey:@"seq"]integerValue];
                if (cmd1 == cmd2 && event_id1 == event_id2 && seq1 != seq2) {
                    [mySql database:DB_path deleteTurpleFromTable:@"notification" withWhere:[[NSDictionary alloc]initWithObjectsAndKeys:[[NSString alloc]initWithFormat:@"%d", seq2],@"seq", nil] completion:nil];
                    [[MTUser sharedInstance].eventRequestMsg removeObject:msg];
                    continue;
                }
            }
            
//            [mySql closeMyDB];
            
            [msg_arr removeObject:msg_dic];
            [[MTUser sharedInstance].eventRequestMsg removeObject:msg_dic];
            [msg_dic setValue:result forKey:@"ishandled"];
            
            [[MTUser sharedInstance].historicalMsg insertObject:msg_dic atIndex:0];
            [SVProgressHUD dismissWithSuccess:@"处理成功" afterDelay:0.5];
            [self.tableView reloadData];
            NSLog(@"本次处理的活动邀请: %@",msg_dic);
            NSLog(@"处理之后的消息列表: \n MTUser.eventRequestMsg: %@ \nself.msg_arr: %@", [MTUser sharedInstance].eventRequestMsg, self.msg_arr);
            //更新活动中心列表：
            [[NSNotificationCenter defaultCenter]postNotificationName:@"reloadEvent" object:nil userInfo:nil];
        }
            break;
            case REQUEST_FAIL:
        {
            [SVProgressHUD dismissWithError:@"发送请求错误"];
            //[CommonUtils showSimpleAlertViewWithTitle:@"系统提示" WithMessage:@"发送请求错误" WithDelegate:self WithCancelTitle:@"确定"];
            
        }
            break;
        case ALREADY_IN_EVENT:
        {
            [SVProgressHUD dismissWithError:@"你已经在此活动中"];
            //[CommonUtils showSimpleAlertViewWithTitle:@"系统提示" WithMessage:@"你已经在此活动中了" WithDelegate:self WithCancelTitle:@"确定"];
//            NSMutableDictionary* aMsg = [msg_arr objectAtIndex:selectedPath.row];
            NSDictionary* item_id_dic = [response1 objectForKey:@"item_id"];
            NSInteger row = selectedPath.row;
            NSMutableDictionary* msg_dic = [msg_arr objectAtIndex:row];
            NSInteger event_id1 = [[msg_dic objectForKey:@"event_id"]integerValue];
            NSInteger cmd1 = [[msg_dic objectForKey:@"cmd"]integerValue];
            NSInteger seq1 = [[msg_dic objectForKey:@"seq"]integerValue];
            NSNumber* response_result = [item_id_dic objectForKey:@"response_result"];
            
//            [mySql openMyDB:DB_path];
            [mySql database:DB_path
     updateDataWitTableName:@"notification"
                   andWhere:[CommonUtils packParamsInDictionary:
                             [NSString stringWithFormat:@"%d",seq1],@"seq",nil]
                     andSet:[CommonUtils packParamsInDictionary:
                             [NSString stringWithFormat:@"%@",response_result],@"ishandled",nil]
                 completion:nil];
            
            for (int i = 0; i < [MTUser sharedInstance].eventRequestMsg.count; i++) {
                NSMutableDictionary* msg = [MTUser sharedInstance].eventRequestMsg[i];
                NSInteger cmd2 = [[msg objectForKey:@"cmd"]integerValue];
                NSInteger event_id2 = [[msg objectForKey:@"event_id"]integerValue];
                NSInteger seq2 = [[msg objectForKey:@"seq"]integerValue];
                if (cmd1 == cmd2 && event_id1 == event_id2 && seq1 != seq2) {
                    [mySql database:DB_path deleteTurpleFromTable:@"notification" withWhere:[[NSDictionary alloc]initWithObjectsAndKeys:[[NSString alloc]initWithFormat:@"%d", seq2],@"seq", nil] completion:nil];
                    [[MTUser sharedInstance].eventRequestMsg removeObject:msg];
                    continue;
                }
            }

//            [mySql closeMyDB];
            
            [[MTUser sharedInstance].eventRequestMsg removeObject:msg_dic];
            [msg_arr removeObjectAtIndex:row];
            [self.tableView reloadData];
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
            NSMutableDictionary* msg_dic = [msg_arr objectAtIndex:row];
            NSInteger event_id1 = [[msg_dic objectForKey:@"event_id"]integerValue];
            NSInteger cmd1 = [[msg_dic objectForKey:@"cmd"]integerValue];
            NSInteger seq1 = [[msg_dic objectForKey:@"seq"]integerValue];
            NSNumber* response_result = [item_id_dic objectForKey:@"response_result"];
            
//            [mySql openMyDB:DB_path];
            [mySql database:DB_path
     updateDataWitTableName:@"notification"
                   andWhere:[CommonUtils packParamsInDictionary:
                             [NSString stringWithFormat:@"%d",seq1],@"seq",nil]
                     andSet:[CommonUtils packParamsInDictionary:
                             [NSString stringWithFormat:@"%@",response_result],@"ishandled",nil]
                 completion:nil];
            
            for (int i = 0; i < [MTUser sharedInstance].eventRequestMsg.count; i++) {
                NSMutableDictionary* msg = [MTUser sharedInstance].eventRequestMsg[i];
                NSInteger cmd2 = [[msg objectForKey:@"cmd"]integerValue];
                NSInteger event_id2 = [[msg objectForKey:@"event_id"]integerValue];
                NSInteger seq2 = [[msg objectForKey:@"seq"]integerValue];
                if (cmd1 == cmd2 && event_id1 == event_id2 && seq1 != seq2) {
                    [mySql database:DB_path deleteTurpleFromTable:@"notification" withWhere:[[NSDictionary alloc]initWithObjectsAndKeys:[[NSString alloc]initWithFormat:@"%d", seq2],@"seq", nil] completion:nil];
                    [[MTUser sharedInstance].eventRequestMsg removeObject:msg];
                    continue;
                }
            }
            
//            [mySql closeMyDB];
            
            [[MTUser sharedInstance].eventRequestMsg removeObject:msg_dic];
            [msg_arr removeObjectAtIndex:row];
            [self.tableView reloadData];

        }
            break;
        default:
            NSLog(@"好友邀请，服务器返回错误");
            break;
    }
    
}




#pragma mark UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
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
        //self.shadowView.hidden = YES;
        //[self.view sendSubviewToBack:self.shadowView];
    }
}
@end
