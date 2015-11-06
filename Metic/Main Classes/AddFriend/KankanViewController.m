//
//  KankanViewController.m
//  WeShare
//
//  Created by 俊健 on 15/11/6.
//  Copyright (c) 2015年 WeShare. All rights reserved.
//

#import "KankanViewController.h"
#import "MJRefreshHeaderView.h"
#import "MJRefreshFooterView.h"
#import "FriendInfoViewController.h"

@interface KankanViewController ()<MJRefreshBaseViewDelegate>
@property (nonatomic, strong) NSNumber* selectedFriendID;
@end

@implementation KankanViewController

@synthesize tabPage3_view;
@synthesize kankan_tableview;
@synthesize kankan_header;
@synthesize kankan_footer;
@synthesize kankan_arr;
@synthesize selectedFriendID;

#pragma mark - Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"随便看看";
    [CommonUtils addLeftButton:self isFirstPage:NO];
    
    kankan_arr = [[NSMutableArray alloc]init];
    kankan_tableview.delegate = self;
    kankan_tableview.dataSource = self;
    
    [self initContentView];
    [self.kankan_header beginRefreshing];
}

-(void)dealloc
{
    [kankan_header free];
    [kankan_footer free];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Method
-(void)initContentView
{
    UIColor* bgColor = [UIColor colorWithRed:0.949 green:0.949 blue:0.949 alpha:1];
    
    self.kankan_tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.kankan_tableview setBackgroundColor:bgColor];

    self.kankan_header = [[MJRefreshHeaderView alloc]init];
    self.kankan_header.scrollView = self.kankan_tableview;
    self.kankan_header.delegate = self;
}

-(void)addFriendBtnClicked:(UIButton*)sender
{
    UIStoryboard* mainStoryBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    AddFriendConfirmViewController *vc = [mainStoryBoard instantiateViewControllerWithIdentifier:@"AddFriendConfirmViewController"];
    vc.fid = [NSNumber numberWithInteger:sender.tag];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)getKanKan:(void(^)()) didGetReceived
{
    void (^getKanKanDone)(NSData*) = ^(NSData* rData)
    {
        NSString* temp = @"";
        if (rData) {
            temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
        }
        else
        {
            MTLOG(@"获取随便看看，收到的rData为空");
            UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"系统提示" message:@"服务器未响应，有可能是网络未连接" delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
            [alertView show];
            [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(dismissAlert:) userInfo:alertView repeats:NO];
            return;
        }
        MTLOG(@"get kankan done, received Data: %@",temp);
        NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
        NSNumber* cmd = [response1 objectForKey:@"cmd"];
        if ([cmd integerValue] == 100) {
            kankan_arr = [response1 objectForKey:@"friend_list"];
            [kankan_tableview reloadData];
        }
        if (didGetReceived) {
            didGetReceived();
        }
    };
    NSDictionary* jsonDic = [CommonUtils packParamsInDictionary:[MTUser sharedInstance].userid, @"id",nil];
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:jsonDic options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender* http = [[HttpSender alloc]initWithDelegate:self];
    [http sendMessage:jsonData withOperationCode:KANKAN finshedBlock:getKanKanDone];
    MTLOG(@"doing getKanKan, json: %@",jsonDic);
}

-(void)dismissAlert:(NSTimer*)timer
{
    UIAlertView* alert = [timer userInfo];
    [alert dismissWithClickedButtonIndex:0 animated:YES];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary* friend;
    if (tableView == self.kankan_tableview) {
        friend = [kankan_arr objectAtIndex:indexPath.row];
    }
    
    if ([friend isKindOfClass:[NSDictionary class]]) {
        selectedFriendID = [friend valueForKey:@"id"];
        UIStoryboard* mainStoryBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
        FriendInfoViewController* vc = [mainStoryBoard instantiateViewControllerWithIdentifier:@"FriendInfoViewController"];
        vc.fid = selectedFriendID;
        [self.navigationController pushViewController:vc animated:YES];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.kankan_tableview) {
        return kankan_arr.count;
    } else {
        return 0;
    }
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIColor* bgColor = [UIColor colorWithRed:0.949 green:0.949 blue:0.949 alpha:1];
    if (tableView == kankan_tableview)
    {
        SearchedFriendTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"searchedfriendcell"];
        if (nil == cell) {
            cell = [[SearchedFriendTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"searchedfriendcell"];
        }
        NSMutableDictionary* friend = [kankan_arr objectAtIndex:indexPath.row];
        NSNumber* fid = [friend objectForKey:@"id"];
        NSString* fname = [friend objectForKey:@"name"];
        NSNumber* gender = [friend objectForKey:@"gender"];
        NSString* location = [friend objectForKey:@"location"];
        
        cell.friendNameLabel.text = fname;
        if ([location isEqual: [NSNull null]]) {
            cell.location_label.text = @"暂无地址信息";
        }
        else
        {
            cell.location_label.text = location;
        }
        
        PhotoGetter* getter = [[PhotoGetter alloc]initWithData:cell.avatar_imageview authorId:fid];
        [getter getAvatar];
        
        UIFont* mFont = [UIFont systemFontOfSize:15];
        CGSize sizeOfName = [cell.friendNameLabel.text sizeWithFont:mFont constrainedToSize:CGSizeMake(MAXFLOAT, 0) lineBreakMode:NSLineBreakByCharWrapping];
        if (cell.gender_imageview) {
            [cell.gender_imageview removeFromSuperview];
        }
        else
        {
            cell.gender_imageview = [[UIImageView alloc]init];
        }
        cell.gender_imageview.frame = CGRectMake(cell.friendNameLabel.frame.origin.x + sizeOfName.width + 5, 5, 16, 16);
        if ([gender integerValue] == 0) {
            cell.gender_imageview.image = [UIImage imageNamed:@"女icon"];
        }
        else{
            cell.gender_imageview.image = [UIImage imageNamed:@"男icon"];
        }
        [cell.contentView addSubview:cell.gender_imageview];
        
        cell.add_button.hidden = NO;
        cell.theLabel.hidden = YES;
        
        cell.add_button.tag = [fid integerValue];
        [cell.add_button addTarget:self action:@selector(addFriendBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [cell setBackgroundColor:bgColor];
        UIColor* borderColor = [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1];
        cell.layer.borderColor = borderColor.CGColor;
        cell.layer.borderWidth = 0.3;
        return cell;
    }
    return nil;
}

#pragma mark - MJRefreshBaseViewDelegate
- (void)refreshViewBeginRefreshing:(MJRefreshBaseView *)refreshView
{
    if (refreshView == self.kankan_header)
    {
        [self getKanKan:^{
             [refreshView endRefreshing];
         }];
    }
}

@end
