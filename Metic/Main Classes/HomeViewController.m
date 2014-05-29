//
//  HomeViewController.m
//  SlideMenu
//
//  Created by Aryan Gh on 4/24/13.
//  Copyright (c) 2013 Aryan Ghassemi. All rights reserved.
//

#import "../CustomCellTableViewCell.h"
#import "HomeViewController.h"



@implementation HomeViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    AppDelegate *myDelegate = [[UIApplication sharedApplication]delegate];
    self.user = myDelegate.user;
    [self.user getInfo:self.user.userid myid:self.user.userid delegateId:self];
    //self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 60, 320, 420)];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.view addSubview:self.tableView];
    //初始化下拉刷新功能
    _header = [[MJRefreshHeaderView alloc]init];
    _header.delegate = self;
    _header.scrollView = self.tableView;
    [_header beginRefreshing];
    
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


#pragma mark - HttpSenderDelegate

-(void)finishWithReceivedData:(NSData *)rData
{
    NSString* temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
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
              
            }
            else{//获取event id 号
                self.eventIds = [response1 valueForKey:@"sequence"];
                [self getEvents:self.eventIds];
            }
        }
            break;
    }
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
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.events) {
        return [self.events count];
    }
	return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	CustomCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"customcell"];
	if (cell == nil) {

        cell = [[CustomCellTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault
                                             reuseIdentifier:@"customcell"] ;
    }
    if (self.events) {
        NSDictionary *a = self.events[indexPath.row];
        NSLog(@"%@",[a valueForKey:@"subject"]);
        
        cell.eventName.text = [a valueForKey:@"subject"];
        cell.beginTime.text = [a valueForKey:@"time"];
        cell.endTime.text = [a valueForKey:@"endTime"];
        cell.location.text = [[NSString alloc]initWithFormat:@"活动地点: %@",[a valueForKey:@"location"] ];
        
        cell.member_count.text = [[NSString alloc] initWithFormat:@"已有 %@ 人参加",(NSNumber*)[a valueForKey:@"member_count"]];
        cell.launcherinfo.text = [[NSString alloc]initWithFormat:@"发起人: %@",[a valueForKey:@"launcher"] ];
        cell.eventDetail.text = [[NSString alloc]initWithFormat:@"%@",[a valueForKey:@"remark"] ];
    }

	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"eventDetailIdentifier" sender:self];
}



#pragma mark 代理方法-进入刷新状态就会调用
- (void)refreshViewBeginRefreshing:(MJRefreshBaseView *)refreshView
{
    NSLog(@"begin");
    [self getEventids];
    [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(tableViewReload) userInfo:nil repeats:NO];
}


- (void) tableViewReload
{
    [_header endRefreshing];
    [self.tableView reloadData];
}

- (void)dealloc
{
    [_header free];

}
@end
