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
}

@end

@implementation NotificationsViewController
@synthesize msgFromDB;
@synthesize notificationsTable;
@synthesize appListener;

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    mySql = [[MySqlite alloc]init];
    DB_path = [[NSString alloc]initWithFormat:@"%@/db",[MTUser sharedInstance].userid];
    self.notificationsTable.delegate = self;
    self.notificationsTable.dataSource = self;
    
    
}

- (void) getMsgFromDataBase
{
    [mySql openMyDB:DB_path];
    self.msgFromDB = [mySql queryTable:@"notification" withSelect:[[NSArray alloc]initWithObjects:@"msg",@"seq", nil] andWhere:nil];
    [mySql closeMyDB];
    NSLog(@"msg from db: %@",msgFromDB);
    [self.notificationsTable reloadData];
}


#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.msgFromDB.count;
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
    switch (cmd) {
        case ADD_FRIEND_NOTIFICATION:
        {
            NotificationsTableViewCell* cell = [self.notificationsTable dequeueReusableCellWithIdentifier:@"requestnotification"];
            if (nil == cell) {
                cell = [[NotificationsTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"requestnotification"];
            }
            NSString* name = [msg_dic objectForKey:@"name"];
            NSString* confirm_msg = [msg_dic objectForKey:@"confirm_msg"];
            NSString* label = [[NSString alloc]initWithFormat:@"%@ 想要加你为好友\n验证信息：%@",name,confirm_msg ];
            cell.textView.text =  label;
            [cell.okBtn addTarget:self action:@selector(okBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [cell.noBtn addTarget:self action:@selector(noBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
//            NSLog(@"return add friend notification cell");
            return cell ;
            
        }
            break;
        case ADD_FRIEND_RESULT:
        {
            NotificationsTableViewCell* cell = [self.notificationsTable dequeueReusableCellWithIdentifier:@"requestnotification"];
            if (nil == cell) {
                cell = [[NotificationsTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"requestnotification"];
            }
            NSString* name = [msg_dic objectForKey:@"name"];
            NSNumber* result = [msg_dic objectForKey:@"result"];
            NSString* label;
            if (result) {
                label = [NSString stringWithFormat:@"%@ 同意添加你为好友",name];
            }
            else
                label = [NSString stringWithFormat:@"%@ 拒绝添加你为好友",name];
            cell.textView.text = label;
            cell.okBtn.hidden = YES;
            [cell.noBtn setTitle:@"删除" forState:UIControlStateNormal];
            [cell.noBtn addTarget:self action:@selector(delBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            return cell ;
            
        }
            break;
        case NEW_EVENT_NOTIFICATION:
        {
            NotificationsTableViewCell* cell = [self.notificationsTable dequeueReusableCellWithIdentifier:@"requestnotification"];
            if (nil == cell) {
                cell = [[NotificationsTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"requestnotification"];
            }
            NSString* subject = [msg_dic objectForKey:@"subject"];
            NSString* launcher = [msg_dic objectForKey:@"launcher"];
            NSString* time = [msg_dic objectForKey:@"time"];
            NSString* label = [NSString stringWithFormat:@"活动邀请\n主题：%@\n发起者：%@\n开始时间：%@",subject,launcher,time];
            cell.textView.text = label;
            
            return cell ;
;
        }
            break;
            
        default:
            break;
    }
    return temp_cell;
}

- (IBAction)okBtnClicked:(id)sender
{
    UITableViewCell* cell = (UITableViewCell*)[[(UIButton*)sender superview] superview];
    selectedPath = [self.notificationsTable indexPathForCell:cell];
    NSDictionary* dataMsg = [self.msgFromDB objectAtIndex:selectedPath.row];
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
    NSMutableDictionary* json = [CommonUtils packParamsInDictionary:[NSNumber numberWithInt:998],@"cmd",[NSNumber numberWithInt:1],@"result",friendid,@"friend_id",userid,@"id",nil];
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
    UITableViewCell* cell = (UITableViewCell*)[[(UIButton*)sender superview] superview];
    selectedPath = [self.notificationsTable indexPathForCell:cell];
    NSDictionary* dataMsg = [self.msgFromDB objectAtIndex:selectedPath.row];
    NSString* msg_str = [dataMsg objectForKey:@"msg" ];
    NSDictionary* msg_dic = [CommonUtils NSDictionaryWithNSString:msg_str];
    NSNumber* seq = [dataMsg objectForKey:@"seq"];
    NSLog(@"no button row: %d, seq: %@",selectedPath.row,seq);
    NSNumber* userid = [MTUser sharedInstance].userid;
    NSNumber* friendid = [msg_dic objectForKey:@"id"];
    NSMutableDictionary* json = [CommonUtils packParamsInDictionary:[NSNumber numberWithInt:998],@"cmd",[NSNumber numberWithInt:0],@"result",userid,@"id",friendid,@"friend_id",nil];
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
    UITableViewCell* cell = (UITableViewCell*)[[(UIButton*)sender superview] superview];
    selectedPath = [self.notificationsTable indexPathForCell:cell];
    NSDictionary* dataMsg = [self.msgFromDB objectAtIndex:selectedPath.row];
    NSNumber* seq = [dataMsg objectForKey:@"seq"];
    [mySql openMyDB:DB_path];
    [mySql deleteTurpleFromTable:@"notification" withWhere:[[NSDictionary alloc]initWithObjectsAndKeys:[[NSString alloc]initWithFormat:@"%@", seq],@"seq", nil]];
    [mySql closeMyDB];
    [self.msgFromDB removeObjectAtIndex:selectedPath.row];
    [self.notificationsTable reloadData];
}

- (IBAction)participate_event_okBtnClicked:(id)sender
{
    UITableViewCell* cell = (UITableViewCell*)[[(UIButton*)sender superview] superview];
    selectedPath = [self.notificationsTable indexPathForCell:cell];
    NSDictionary* dataMsg = [self.msgFromDB objectAtIndex:selectedPath.row];
    NSString* msg_str = [dataMsg objectForKey:@"msg" ];
    NSDictionary* msg_dic = [CommonUtils NSDictionaryWithNSString:msg_str];
    NSNumber* eventid = [msg_dic objectForKey:@"event_id"];
    NSMutableDictionary* json = [CommonUtils packParamsInDictionary:[NSNumber numberWithInt:997],@"cmd",[NSNumber numberWithInt:1],@"result",[MTUser sharedInstance].userid,@"id",eventid,@"event_id",nil];
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:PARTICIPATE_EVENT];
}

- (IBAction)participate_event_noBtnClicked:(id)sender
{
    
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
            [CommonUtils showSimpleAlertViewWithTitle:@"系统提示" WithMessage:@"已成功添加好友" WithDelegate:self WithCancelTitle:@"确定"];
            
            
            NSDictionary* dataMsg = [self.msgFromDB objectAtIndex:selectedPath.row];
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
            [self.msgFromDB removeObjectAtIndex:selectedPath.row];
            [self.notificationsTable reloadData];
        }
            break;
        case ALREADY_FRIENDS:
        {
            [CommonUtils showSimpleAlertViewWithTitle:@"系统提示" WithMessage:@"你们已经是好友" WithDelegate:self WithCancelTitle:@"确定"];
            NSDictionary* dataMsg = [self.msgFromDB objectAtIndex:selectedPath.row];
            NSNumber* seq = [dataMsg objectForKey:@"seq"];
            NSLog(@"already friends, seq: %@",seq);
            [mySql openMyDB:DB_path];
            [mySql deleteTurpleFromTable:@"notification" withWhere:[[NSDictionary alloc]initWithObjectsAndKeys:[[NSString alloc]initWithFormat:@"%@", seq],@"seq", nil]];
            [mySql closeMyDB];
            [self.msgFromDB removeObjectAtIndex:selectedPath.row];
            [self.notificationsTable reloadData];

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
        }
            break;
        default:
            break;
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


@end
