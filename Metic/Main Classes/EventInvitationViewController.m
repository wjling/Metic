//
//  EventInvitationViewController.m
//  Metic
//
//  Created by ligang_mac4 on 14-7-28.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "EventInvitationViewController.h"
#import "../Cell/EventInvitationTableViewCell.h"
#import "PhotoGetter.h"
#import "MTUser.h"
#import "MobClick.h"

@interface EventInvitationViewController ()
{
    NSIndexPath* selectedPath;
    MySqlite* mySql;
    NSString* DB_path;
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
//    _eventRequestMsg = [MTUser sharedInstance].eventRequestMsg;
    
    _tableView.dataSource = self;
    _tableView.delegate = self;
    selectedPath = [[NSIndexPath alloc]init];
    mySql = [[MySqlite alloc]init];
    DB_path = [[NSString alloc]initWithFormat:@"%@/db",[MTUser sharedInstance].userid];
}

-(void)viewWillAppear:(BOOL)animated
{
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

//返回上一层
-(void)MTpopViewController{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)getMsgArray
{
    msg_arr = [[NSMutableArray alloc]init];
    for (NSMutableDictionary* msg in [MTUser sharedInstance].eventRequestMsg) {
        NSInteger cmd = [[msg objectForKey:@"cmd"] integerValue];
        if (cmd != REQUEST_EVENT) {
//            BOOL flag = true;
//            for (NSMutableDictionary* temp_msg in msg_arr) {
//                NSNumber* eventId1 = [temp_msg objectForKey:@"event_id"];
//                NSNumber* eventId2 = [msg objectForKey:@"event_id"];
//                if ([eventId1 integerValue] == [eventId2 integerValue]) {
//                    flag = false;
//                    break;
//                }
//            }
//            if (flag) {
//                [msg_arr addObject:msg];
//            }
            [msg_arr addObject:msg];
            
        }
    }
    NSLog(@"活动邀请列表: %@",msg_arr);
}
#pragma mark UITableViewDataSource
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 289;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return msg_arr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"eventInvitationCell";
    BOOL nibsRegistered = NO;
    if (!nibsRegistered) {
        UINib *nib = [UINib nibWithNibName:NSStringFromClass([EventInvitationTableViewCell class]) bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:CellIdentifier];
        nibsRegistered = YES;
    }
    EventInvitationTableViewCell *cell = (EventInvitationTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    
    NSDictionary *a = msg_arr[indexPath.row];
    NSNumber* launcher_id = [a valueForKey:@"launcher_id"];
    NSString* launcher_alias = [[MTUser sharedInstance].alias_dic objectForKey:[NSString stringWithFormat:@"%@",launcher_id]];
    NSString* launcher;
    if (launcher_alias && ![launcher_alias isEqual:[NSNull null]]) {
        launcher = launcher_alias;
    }
    else
    {
        launcher = [a objectForKey:@"launcher"];
    }
    
    cell.eventName.text = [a valueForKey:@"subject"];
    NSString* beginT = [a valueForKey:@"time"];
    NSString* endT = [a valueForKey:@"endTime"];
    cell.beginDate.text = [[[beginT substringWithRange:NSMakeRange(5, 5)] stringByAppendingString:@"日"] stringByReplacingOccurrencesOfString:@"-" withString:@"月"];
    cell.beginTime.text = [beginT substringWithRange:NSMakeRange(11, 5)];
    cell.endDate.text = [[[endT substringWithRange:NSMakeRange(5, 5)] stringByAppendingString:@"日"]  stringByReplacingOccurrencesOfString:@"-" withString:@"月"];
    cell.endTime.text = [endT substringWithRange:NSMakeRange(11, 5)];
    cell.timeInfo.text = [CommonUtils calculateTimeInfo:beginT endTime:endT launchTime:[a valueForKey:@"launch_time"]];
    cell.location.text = [[NSString alloc]initWithFormat:@"活动地点: %@",[a valueForKey:@"location"] ];
    int participator_count = [[a valueForKey:@"member_count"] intValue];
    cell.member_count.text = [[NSString alloc] initWithFormat:@"已有 %d 人参加",participator_count];
    cell.launcherinfo.text = [[NSString alloc]initWithFormat:@"发起人: %@",launcher];
    cell.inviteInfo.text = [[NSString alloc]initWithFormat:@"%@ 邀请你加入活动",launcher];
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
    [httpSender sendMessage:jsonData withOperationCode:PARTICIPATE_EVENT];
}

- (IBAction)participate_event_noBtnClicked:(id)sender
{
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
//            NSNumber* response_type = [item_id_dic objectForKey:@"response_type"];
            NSNumber* result = [item_id_dic valueForKey:@"response_result"];
            NSMutableDictionary* msg_dic = [msg_arr objectAtIndex:[item_index intValue]];
            
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
            
            [msg_arr removeObject:msg_dic];
            [[MTUser sharedInstance].eventRequestMsg removeObject:msg_dic];
            [msg_dic setValue:result forKey:@"ishandled"];
            
            [[MTUser sharedInstance].historicalMsg insertObject:msg_dic atIndex:0];
            [self.tableView reloadData];
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
            NSMutableDictionary* aMsg = [msg_arr objectAtIndex:selectedPath.row];
            [[MTUser sharedInstance].eventRequestMsg removeObject:aMsg];
            [msg_arr removeObjectAtIndex:selectedPath.row];
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
