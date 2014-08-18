//
//  HistoricalNotificationViewController.m
//  Metic
//
//  Created by mac on 14-7-23.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "HistoricalNotificationViewController.h"

@interface HistoricalNotificationViewController ()
{
    NSString* DB_path;
}

@end

@implementation HistoricalNotificationViewController
@synthesize historicalMsgs;
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
    self.historicalNF_tableview.delegate = self;
    self.historicalNF_tableview.dataSource = self;
    self.historicalNF_tableview.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    DB_path = [NSString stringWithFormat:@"%@/db",[MTUser sharedInstance].userid];
    self.functions_view.hidden = YES;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.historicalMsgs = [MTUser sharedInstance].historicalMsg;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    CGRect frame = [self.historicalNF_tableview.tableHeaderView frame];
//    frame.size.height = 0;
//    [self.historicalNF_tableview.tableHeaderView setFrame:frame];
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

- (IBAction)rightBarBtnClicked:(id)sender {
    if (!self.functions_view.hidden) {
        [self.functions_view setHidden:YES];
        //UIView开始动画，第一个参数是动画的标识，第二个参数附加的应用程序信息用来传递给动画代理消息
        [UIView beginAnimations:@"View shows" context:nil];
        //动画持续时间
        [UIView setAnimationDuration:0.5];
        //设置动画的回调函数，设置后可以使用回调方法
        [UIView setAnimationDelegate:self];
        //设置动画曲线，控制动画速度
        [UIView  setAnimationCurve: UIViewAnimationCurveEaseOut];
        //设置动画方式，并指出动画发生的位置
        [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:self.self.functions_view  cache:YES];
        
        //提交UIView动画
        [UIView commitAnimations];
        
    }
    else{
        
        [UIView beginAnimations:@"View shows" context:nil];
        [self.functions_view setHidden:NO];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationDelegate:self];
        [UIView  setAnimationCurve: UIViewAnimationCurveEaseIn];
        [UIView setAnimationTransition:UIViewAnimationTransitionCurlDown forView:self.self.functions_view  cache:YES];
        [UIView commitAnimations];
        
        
    }

}

- (IBAction)function1Clicked:(id)sender {
    [UIView beginAnimations:@"View shows" context:nil];
    [self.functions_view setHidden:YES];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDelegate:self];
    [UIView  setAnimationCurve: UIViewAnimationCurveEaseIn];
    [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:self.self.functions_view  cache:YES];
    [UIView commitAnimations];
    
    MySqlite* mySql = [[MySqlite alloc]init];
    [mySql openMyDB:DB_path];
    for (NSDictionary* msg in self.historicalMsgs) {
        NSNumber* seq = [msg objectForKey:@"seq"];
        [mySql deleteTurpleFromTable:@"notification" withWhere:[CommonUtils packParamsInDictionary:
                                                                [NSString stringWithFormat:@"%@",seq],@"seq",nil]];
    }
    [mySql closeMyDB];
    [[MTUser sharedInstance].historicalMsg removeAllObjects];
    [self.historicalNF_tableview reloadData];

}

- (IBAction)function2Clicked:(id)sender {
    [UIView beginAnimations:@"View shows" context:nil];
    [self.functions_view setHidden:YES];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDelegate:self];
    [UIView  setAnimationCurve: UIViewAnimationCurveEaseIn];
    [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:self.self.functions_view  cache:YES];
    [UIView commitAnimations];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.historicalMsgs.count;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger index = indexPath.row;
    NSDictionary* msg_dic = [historicalMsgs objectAtIndex:index];
    NSNumber* cmd = [msg_dic objectForKey:@"cmd"];
    NSNumber* ishandled = [CommonUtils NSNumberWithNSString:[msg_dic objectForKey:@"ishandled"]];
    if ([cmd integerValue] == ADD_FRIEND_NOTIFICATION) {
        NotificationsFriendRequestTableViewCell* cell = [self.historicalNF_tableview dequeueReusableCellWithIdentifier:@"NotificationsFriendRequestTableViewCell"];
        if (nil == cell) {
            cell = [[NotificationsFriendRequestTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"NotificationsFriendRequestTableViewCell"];
        }
        NSString* name = [msg_dic objectForKey:@"name"];
        NSString* confirm_msg = [msg_dic objectForKey:@"confirm_msg"];
        NSNumber* uid = [msg_dic objectForKey:@"id"];
        cell.name_label.text = name;
        cell.conform_msg_label.text = confirm_msg;
        PhotoGetter* getter = [[PhotoGetter alloc]initWithData:cell.avatar_imageView authorId:uid];
        [getter getPhoto];

        if ([ishandled integerValue] == 0) {
            cell.remark_label.text = @"已拒绝";
        }
        else if ([ishandled integerValue] == 1)
        {
            cell.remark_label.text = @"已同意";
        }
        
        cell.okBtn.hidden = YES;
        cell.noBtn.hidden = YES;
        cell.remark_label.hidden = NO;
        return cell;
        
    }
    else if ([cmd integerValue] == NEW_EVENT_NOTIFICATION)
    {
        NotificationsEventRequestTableViewCell* cell = [self.historicalNF_tableview dequeueReusableCellWithIdentifier:@"NotificationsEventRequestTableViewCell"];
        if (nil == cell) {
            cell = [[NotificationsEventRequestTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"NotificationsEventRequestTableViewCell"];
        }
        NSString* subject = [msg_dic objectForKey:@"subject"];
        NSString* launcher = [msg_dic objectForKey:@"launcher"];
        NSNumber* uid = [msg_dic objectForKey:@"launcher_id"];
        
        cell.name_label.text = launcher;
        [cell.event_name_button setTitle:subject forState:UIControlStateNormal];
        PhotoGetter* getter = [[PhotoGetter alloc]initWithData:cell.avatar_imageView authorId:uid];
        [getter getPhoto];
        
        if ([ishandled integerValue] == 0) {
            cell.remark_label.text = @"已拒绝";
        }
        else if ([ishandled integerValue] == 1)
        {
            cell.remark_label.text = @"已同意";
        }
        
        cell.okBtn.hidden = YES;
        cell.noBtn.hidden = YES;
        cell.remark_label.hidden = NO;
        return cell;

    }

    return nil;
}


#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}
@end
