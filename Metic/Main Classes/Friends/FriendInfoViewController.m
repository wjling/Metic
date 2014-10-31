//
//  FriendInfoViewController.m
//  Metic
//
//  Created by ligang5 on 14-5-28.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "FriendInfoViewController.h"
#import "math.h"

@interface FriendInfoViewController ()<UIAlertViewDelegate>
{
    NSInteger kNumberOfPages;
    NSNumber* addEventID;
    NSString* DB_path;
}

@end

@implementation FriendInfoViewController
@synthesize del_friend_Button;
@synthesize friend_alias_button;
@synthesize sView;
@synthesize contentView;
@synthesize pControl;
@synthesize views;
@synthesize moreFunction_view;

@synthesize fInfoView;
@synthesize photo;
@synthesize name_label;
@synthesize alias_label;
@synthesize location_label;
@synthesize gender_imageView;

@synthesize fDescriptionView;
@synthesize title_label;
@synthesize description_label;

@synthesize root;
@synthesize fid;
@synthesize friendInfo_dic;
@synthesize events;
@synthesize rowHeights;
@synthesize friendInfoEvents_tableView;

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
    [CommonUtils addLeftButton:self isFirstPage:NO];
    kNumberOfPages = 2;
    DB_path = [NSString stringWithFormat:@"%@/db",[MTUser sharedInstance].userid];
    
    [self initViews];
    [self getUserInfo];
    [self.view bringSubviewToFront:moreFunction_view];
     NSLog(@"friend info fid: %@",fid);
}

//返回上一层
-(void)MTpopViewController{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewWillAppear:(BOOL)animated
{
    NSLog(@"view will appear");
    if ([[MTUser sharedInstance].friendsIdSet containsObject:fid])
    {
        [self.navigationItem setTitle:@"好友信息"];
    }
    else
    {
        [self.navigationItem setTitle:@"用户信息"];
    }
    [self refreshFriendInfo];

}

-(void)viewDidAppear:(BOOL)animated
{
    NSLog(@"view did appear");
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        NSLog(@"IOS %f", [[UIDevice currentDevice].systemVersion floatValue]);
        [friendInfoEvents_tableView setFrame:CGRectMake(10, friendInfoEvents_tableView.frame.origin.y, self.view.frame.size.width - 20, friendInfoEvents_tableView.frame.size.height)];
        
    }
    
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initViews
{
    [self getfriendInfoFromDB];
    CGRect screen = [UIScreen mainScreen].bounds;
    contentView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screen.size.width, 135)];
    [contentView setBackgroundColor:[UIColor orangeColor]];
    
    sView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, contentView.frame.size.width, contentView.frame.size.height-3)];
    CGFloat sv_width = sView.frame.size.width;
    CGFloat sv_height = sView.frame.size.height;
    sView.scrollEnabled = YES;
    sView.pagingEnabled =  YES;
    sView.contentSize = CGSizeMake(sv_width*kNumberOfPages, sv_height);
    sView.delegate = self;
    sView.showsHorizontalScrollIndicator = NO;
    sView.showsVerticalScrollIndicator = NO;
    [sView setBackgroundColor:[UIColor grayColor]];
    
    pControl = [[UIPageControl alloc]initWithFrame:CGRectMake(0, sv_height-15, sv_width, 10)];
    pControl.numberOfPages = kNumberOfPages;
    pControl.currentPage = 0;
    UIColor* indicatorTintColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5];
    pControl.pageIndicatorTintColor = indicatorTintColor;
    [pControl addTarget:self action:@selector(pageControlClicked:) forControlEvents:UIControlEventValueChanged];
    
    
    self.fInfoView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, sv_width, sv_height)];
//    [self.fInfoView setBackgroundColor:[UIColor lightGrayColor]];
    self.fInfoView.image = [UIImage imageNamed:@"1星空.jpg"];
    
    photo = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"default_avatar.jpg"]];
    photo.frame = CGRectMake(20, 30, 50, 50);
    photo.layer.cornerRadius = 25;
    photo.layer.masksToBounds = YES;
    [photo setTag:0];
    photo.layer.borderColor = ([UIColor yellowColor].CGColor);
    photo.layer.borderWidth = 2;
    
    
    name_label = [[UILabel alloc]initWithFrame:CGRectMake(85, 30, 200, 25)];
    name_label.text = self.friendInfo_dic? [self.friendInfo_dic objectForKey:@"name"] : @"用户名";
    [name_label setFont:[UIFont fontWithName:@"Helvetica" size:15]];
    name_label.textColor = [UIColor whiteColor];
    [name_label setBackgroundColor:[UIColor clearColor]];
    
    alias_label = [[UILabel alloc]initWithFrame:CGRectMake(85, 60, 200, 25)];
    alias_label.text = [MTUser sharedInstance].alias_dic? [[MTUser sharedInstance].alias_dic objectForKey:[NSString stringWithFormat:@"%@",fid]] : @"备注名";
    [alias_label setFont:[UIFont fontWithName:@"Helvetica" size:12]];
    alias_label.textColor = [UIColor whiteColor];
    [alias_label setBackgroundColor:[UIColor clearColor]];

    
    location_label = [[UILabel alloc]initWithFrame:CGRectMake(85, 90, 200, 20)];
    location_label.text = self.friendInfo_dic? [self.friendInfo_dic objectForKey:@"location"] : @"地址";
    location_label.textColor = [UIColor whiteColor];
    [location_label setFont:[UIFont fontWithName:@"Helvetica" size:11]];
    [location_label setBackgroundColor:[UIColor clearColor]];
    
    
    gender_imageView = [[UIImageView alloc] initWithFrame:CGRectMake(185, 35, 17, 17)];
    NSNumber* gender = self.friendInfo_dic? [self.friendInfo_dic objectForKey:@"gender"] : [NSNumber numberWithInt:-1];
    if ([gender integerValue] == 0) {
        gender_imageView.image = [UIImage imageNamed:@"女icon"];
    }
    else if ([gender integerValue] == 1)
    {
        gender_imageView.image = [UIImage imageNamed:@"男icon"];
    }
    
    
//    self.del_friend_Button = [[UIButton alloc]initWithFrame:CGRectMake(self.fInfoView.frame.size.width-70, self.fInfoView.frame.size.height/2, 78, 25)];
////    [self.del_friend_Button setTag:4];
//    [self.del_friend_Button setBackgroundColor:btn_color];
//    self.del_friend_Button.layer.cornerRadius = 5;
//    self.del_friend_Button.layer.masksToBounds = YES;
//    UIImageView* icon = [[UIImageView alloc]initWithFrame:CGRectMake(8, 7, 10, 10)];
//    icon.image = [UIImage imageNamed:@"删除好友叉"];
//    UILabel* del_btn_label = [[UILabel alloc]initWithFrame:CGRectMake(23, 0, 45, 25)];
//    del_btn_label.text = @"删除好友";
//    [del_btn_label setBackgroundColor:[UIColor clearColor]];
//    del_btn_label.textColor = [UIColor whiteColor];
//    [del_btn_label setFont:[UIFont fontWithName:@"ArialRoundedMTBold" size:9]];
//    del_button.titleLabel.text = @"删除好友";
    
//    [self.del_friend_Button addSubview:icon];
//    [self.del_friend_Button addSubview:del_btn_label];
//    [self.del_friend_Button setHidden:YES];
    
    UIColor* btn_color = [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:0.6];
    self.friend_alias_button = [[UIButton alloc]initWithFrame:CGRectMake(self.fInfoView.frame.size.width - 65, self.fInfoView.frame.size.height/3, 70, 25)];
    [friend_alias_button setBackgroundColor:btn_color];
    friend_alias_button.layer.cornerRadius = 5;
    friend_alias_button.layer.masksToBounds = YES;
    [friend_alias_button setTitle:@"修改备注名" forState:UIControlStateNormal];
    [friend_alias_button.titleLabel setFont:[UIFont systemFontOfSize:11]];
    [friend_alias_button addTarget:self action:@selector(changeAlias:) forControlEvents:UIControlEventTouchUpInside];
    
//    self.fInfoView.layer.borderColor
    [self.fInfoView addSubview:photo];
    [self.fInfoView addSubview:name_label];
    [self.fInfoView addSubview:alias_label];
    [self.fInfoView addSubview:location_label];
    [self.fInfoView addSubview:gender_imageView];
//    [self.fInfoView addSubview:friend_alias_button];
//    [self.fInfoView addSubview:del_button];
    
    
    
    self.fDescriptionView = [[UIImageView alloc]initWithFrame:CGRectMake(fInfoView.frame.size.width, 0, sv_width, sv_height)];
//    [self.fDescriptionView setBackgroundColor:[UIColor yellowColor]];
    self.fDescriptionView.image = [UIImage imageNamed:@"1星空.jpg"];
    title_label = [[UILabel alloc]initWithFrame:CGRectMake(30, 20, 100, 30)];
    title_label.text = @"个人描述";
    [title_label setBackgroundColor:[UIColor clearColor]];
    [title_label setFont:[UIFont fontWithName:@"Helvetica" size:15]];
    title_label.textColor = [UIColor whiteColor];
    
    description_label = [[UILabel alloc]initWithFrame:CGRectMake(30, 50, 200, 25)];
    description_label.text = @"\"这个家伙很聪明什么都没有留下...\"";
    [description_label setBackgroundColor:[UIColor clearColor]];
    [description_label setFont:[UIFont fontWithName:@"Helvetica" size:10]];
    description_label.textColor = [UIColor whiteColor];
    
//    friendInfoEvents_tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 150, screen.size.width, 330)];
//    friendInfoEvents_tableView.delegate = self;
//    friendInfoEvents_tableView.dataSource = self;
//    [friendInfoEvents_tableView setBackgroundColor:[UIColor blueColor]];
//    NSLog(@"x: %f, y: %f, width: %f, height: %f",friendInfoEvents_tableView.frame.origin.x,friendInfoEvents_tableView.frame.origin.y,friendInfoEvents_tableView.frame.size.width,friendInfoEvents_tableView.frame.size.height);
    
    self.friendInfoEvents_tableView.delegate = self;
    self.friendInfoEvents_tableView.dataSource = self;

    
    [self.fDescriptionView addSubview:title_label];
    [self.fDescriptionView addSubview:description_label];
    
    [sView addSubview:fInfoView];
    [sView addSubview:fDescriptionView];
    
    [contentView addSubview:sView];
    [contentView addSubview:pControl];
    
    [root addSubview:contentView];
    [root addSubview:self.friend_alias_button];
//    [root addSubview:self.del_friend_Button];
//    [root addSubview:friendInfoEvents_tableView];
    
}

-(void)refreshFriendInfo
{
    NSString* name = [friendInfo_dic objectForKey:@"name"];
    NSString* location = [friendInfo_dic objectForKey:@"location"];
    NSNumber* gender = [friendInfo_dic objectForKey:@"gender"];
//    NSString* email = [friendInfo_dic objectForKey:@"email"];
    NSString* alias = [[MTUser sharedInstance].alias_dic objectForKey:[NSString stringWithFormat:@"%@",fid]];
    
    PhotoGetter* getter = [[PhotoGetter alloc]initWithData:photo authorId:fid];
    [getter getAvatar];
    name_label.text = name;
    if (alias && ![alias isEqual:[NSNull null]]) {
        alias_label.text = [NSString stringWithFormat:@"备注名: %@",alias];
    }
    else
    {
        alias_label.text = @"备注名: 无";
    }
    
    UIFont* font = [UIFont systemFontOfSize:15];
    CGSize sizeOfName = [name_label.text sizeWithFont:font constrainedToSize:CGSizeMake(MAXFLOAT, 30) lineBreakMode:NSLineBreakByCharWrapping];
    CGRect frame = CGRectMake(name_label.frame.origin.x + sizeOfName.width + 5, name_label.frame.origin.y + 1, 17, 17);
    if (gender_imageView) {
        gender_imageView.frame = frame;
    }
    else
    {
        gender_imageView = [[UIImageView alloc]initWithFrame:frame];
    }
    
    if (0 == [gender intValue]) {
        gender_imageView.image = [UIImage imageNamed:@"女icon"];
    }
    else
    {
        gender_imageView.image = [UIImage imageNamed:@"男icon"];
    }
    
    if (![location isEqual:[NSNull null]]) {
        location_label.text = location;
        
    }
    else
    {
        location_label.text = @"暂无地址信息";
    }
    

}

-(void)getfriendInfoFromDB
{
    NSArray* alias_arr;
    MySqlite* sql = [[MySqlite alloc]init];
    [sql openMyDB:DB_path];
    alias_arr = [sql queryTable:@"friend" withSelect:[NSArray arrayWithObjects:@"*", nil] andWhere:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%@",fid], @"id", nil]];
    [sql closeMyDB];
    NSLog(@"get alias from DB: %@",alias_arr);
//    for (NSDictionary* temp in alias_arr) {
//        NSString* fid = [temp objectForKey:@"id"];
//        NSString* email = [temp objectForKey:@"email"];
//        NSString* location = [temp objectForKey:@"location"];
//        NSNumber* gender = [temp objectForKey:@"gender"];
//        
//    }
    self.friendInfo_dic = alias_arr[0];
}

-(IBAction)changeAlias:(id)sender
{
    ChangeAliasViewController *aliasVC = [[ChangeAliasViewController alloc]init];
    aliasVC.fid = fid;
    NSLog(@"alias change, fid = %@",aliasVC.fid);
    [self.navigationController pushViewController:aliasVC animated:YES];
}

- (IBAction)pageControlClicked:(id)sender
{
    NSInteger page = pControl.currentPage;
    
    CGRect kFrame = sView.frame;
    kFrame.origin.x = kFrame.size.width * page;
    kFrame.origin.y = 0;
    [sView scrollRectToVisible:kFrame animated:YES];
}

- (void)getUserInfo
{
    NSMutableDictionary* json = [CommonUtils packParamsInDictionary:fid,@"id",[MTUser sharedInstance].userid,@"myId",nil];
    NSLog(@"friend info json: %@",json);
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender* httpsender = [[HttpSender alloc]initWithDelegate:self];
    [httpsender sendMessage:jsonData withOperationCode:GET_USER_INFO];
}

- (void)handleInfo:(NSDictionary*)response
{
    events = [response objectForKey:@"event_list"];
    rowHeights = [[NSMutableArray alloc]init];
    for (int i = 0; i < events.count; i++) {
        [rowHeights addObject:[NSNumber numberWithFloat:110.0]];
    }
    NSString* name = [response objectForKey:@"name"];
    NSString* location = [response objectForKey:@"location"];
    NSNumber* gender = [response objectForKey:@"gender"];
    NSString* email = [response objectForKey:@"email"];
    NSString* alias = [[MTUser sharedInstance].alias_dic objectForKey:[NSString stringWithFormat:@"%@",fid]];
    NSDictionary* wheres = [CommonUtils packParamsInDictionary:[NSString stringWithFormat:@"%@",fid],@"id",nil];
    NSDictionary* sets = [CommonUtils packParamsInDictionary:
                          [NSString stringWithFormat:@"'%@'",name],@"name",
                          [NSString stringWithFormat:@"'%@'",email],@"email",
                          [NSString stringWithFormat:@"%@",fid],@"id",
                          [NSString stringWithFormat:@"%@",gender],@"gender",
                          nil];
    MySqlite* mySql = [[MySqlite alloc]init];
    [mySql openMyDB:DB_path];
    [mySql updateDataWitTableName:@"friend" andWhere:wheres andSet:sets];
    [mySql closeMyDB];
    [MTUser sharedInstance].friendList = [[MTUser sharedInstance] getFriendsFromDB];
    [[MTUser sharedInstance] friendListDidChanged];
    NSLog(@"event_list: %@",events);
    
    PhotoGetter* getter = [[PhotoGetter alloc]initWithData:photo authorId:fid];
    [getter getAvatar];
    name_label.text = name;
    if (alias && ![alias isEqual:[NSNull null]]) {
        alias_label.text = [NSString stringWithFormat:@"备注名: %@",alias];
    }
    else
    {
        alias_label.text = @"备注名: 无";
    }
    
    UIFont* font = [UIFont systemFontOfSize:15];
    CGSize sizeOfName = [name_label.text sizeWithFont:font constrainedToSize:CGSizeMake(MAXFLOAT, 30) lineBreakMode:NSLineBreakByCharWrapping];
    CGRect frame = CGRectMake(name_label.frame.origin.x + sizeOfName.width + 5, name_label.frame.origin.y + 1, 17, 17);
    if (gender_imageView) {
        gender_imageView.frame = frame;
    }
    else
    {
        gender_imageView = [[UIImageView alloc]initWithFrame:frame];
    }

    if (0 == [gender intValue]) {
        gender_imageView.image = [UIImage imageNamed:@"女icon"];
    }
    else
    {
        gender_imageView.image = [UIImage imageNamed:@"男icon"];
    }
    
    if (![location isEqual:[NSNull null]]) {
        location_label.text = location;
        
    }
    else
    {
        location_label.text = @"暂无地址信息";
    }

    NSString* sign = [response objectForKey:@"sign"];
    if (![sign isEqual:[NSNull null]]) {
        (description_label).text = sign;
    }
    
    [self.friendInfoEvents_tableView reloadData];
    
}


#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView               // any offset changes
{
    if (scrollView == sView) {
        CGFloat page_width = sView.frame.size.width;
        int page_index = floor((sView.contentOffset.x - page_width/2) / page_width) +1;
        pControl.currentPage = page_index;
    }
}

// called on start of dragging (may require some time and or distance to move)
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView      // called when scroll view grinds to a halt
{
    
}


#pragma mark - HttpSenderDelegate
-(void)finishWithReceivedData:(NSData*) rData
{
    NSString* temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
    NSLog(@"从服务器获得好友信息: %@",temp);
    NSMutableDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
    NSNumber* cmd = [response1 objectForKey:@"cmd"];
    NSLog(@"cmd: %@",cmd);
    switch ([cmd intValue]) {
        case NORMAL_REPLY:
        {
            NSNumber* uid = [response1 objectForKey:@"id"];
            if (uid) {
                [self handleInfo:response1];
                friendInfo_dic = response1;
            }
            else
            {
                
            }
            
        }
            break;
        case SERVER_ERROR:
            break;
        case ALREADY_IN_EVENT:
            break;
            
        default:
            break;
    }
    
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    [self.friendInfoEvents_tableView reloadData];
//    NSLog(@"reload data");
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [[rowHeights objectAtIndex:indexPath.section] floatValue];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    NSLog(@"events count: %d",events.count);
//    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
//        NSLog(@"IOS %f", [[UIDevice currentDevice].systemVersion floatValue]);
//        [friendInfoEvents_tableView setFrame:CGRectMake(0, friendInfoEvents_tableView.frame.origin.y, self.view.frame.size.width, friendInfoEvents_tableView.frame.size.height)];
//    }
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return events.count;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"tableview x: %f, width: %f",friendInfoEvents_tableView.frame.origin.x, friendInfoEvents_tableView.frame.size.width);
    NSDictionary* event = [events objectAtIndex:indexPath.section];
    NSArray* member_ids = [event objectForKey:@"member"];
//    NSLog(@"section index: %d",indexPath.section);
    FriendInfoEventsTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"eventCell"];
    if (nil == cell) {
        NSLog(@"friendinfoeventstableviewcell");
        cell = [[FriendInfoEventsTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"eventCell"];
        
    }
    cell.subject_label.text = [event objectForKey:@"subject"];
    cell.time_label.text = [NSString stringWithFormat:@"%@ ~ %@",[event objectForKey:@"time"],[event objectForKey:@"endTime"]];
    cell.location_label.text = [event objectForKey:@"location"];
    cell.launcher_label.text = [event objectForKey:@"launcher"];
    NSString* remark = [event objectForKey:@"remark"];
    if (![remark isEqualToString:@""]) {
        cell.remark_textView.text = remark;
    }
    cell.numOfMember_label.text = [CommonUtils NSStringWithNSNumber:[event objectForKey:@"member_count"]];
    
    
    if (!cell.stretch_button) {
        cell.stretch_button = [[UIButton alloc]initWithFrame:CGRectMake(155, 90, 10, 10)];
        [cell.stretch_button setBackgroundImage:[UIImage imageNamed:@"箭头icon"] forState:UIControlStateNormal];
        [cell.stretch_button addTarget:self action:@selector(stretchBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:cell.stretch_button];
    }
//    NSLog(@"button tag: %d",cell.stretch_button.tag);
    
    
//    if (reloadHeight<= 100) {
//        [cell.stretch_button setTransform:CGAffineTransformMakeRotation(0)];
//        cell.isExpanded = NO;
//    }
//    else
//    {
//        [cell.stretch_button setTransform:CGAffineTransformMakeRotation(3.14)];
//        cell.isExpanded = YES;
//    }
    

    
    
    
    
    
    int count = member_ids.count;
    if (cell.avatars.count != 0) {
        for (UIImageView* imgV in cell.avatars) {
            [imgV removeFromSuperview];
        }
        [cell.avatars removeAllObjects];
    }
    for (NSInteger i = 0; i<count; i++) {
        NSNumber* uid = [member_ids objectAtIndex:i];
        UIImageView* avatar = [[UIImageView alloc]initWithFrame:CGRectMake(i*35+10, 172, 25, 25)];
        PhotoGetter* getter = [[PhotoGetter alloc]initWithData:avatar authorId:uid];
        [getter getAvatar];
        [cell.avatars addObject:avatar];
        [cell.contentView addSubview:avatar];
        
//        avatar.hidden = YES;
    }
    [cell.add_button addTarget:self action:@selector(participate_event:) forControlEvents:UIControlEventTouchUpInside];
    
//    UIColor* borderColor = [UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1];
//    cell.layer.borderColor = borderColor.CGColor;
//    cell.layer.borderWidth = 0.3;
    return cell;
    
}

- (IBAction)stretchBtnClicked:(id)sender
{
    FriendInfoEventsTableViewCell* cell = (FriendInfoEventsTableViewCell*)[sender superview];
    while (![cell isKindOfClass:[FriendInfoEventsTableViewCell class]]) {
        cell = (FriendInfoEventsTableViewCell*)[cell superview];
    }
    if ([cell isKindOfClass:[FriendInfoEventsTableViewCell class]]) {
        NSLog(@"is friendINFO cell");
    }
    NSIndexPath* indexP = [self.friendInfoEvents_tableView indexPathForCell:cell];
    BOOL temp = cell.isExpanded;
    NSLog(@"clicked row: %d, if expanded: %d",indexP.section,temp);
    if (!cell.isExpanded) {
        

        [rowHeights replaceObjectAtIndex:indexP.section withObject:[NSNumber numberWithFloat:215]];
        
//        [cell.stretch_button removeFromSuperview];
//        cell.stretch_button.tag = 200;
        cell.stretch_button.frame = CGRectMake(155, 200, 10, 10);
//        cell.stretch_button.hidden = YES;
//        [cell.contentView addSubview:cell.stretch_button];
        

        //        NSLog(@"初始————x: %f, y: %f, width: %f, height: %f",cell.stretch_button.frame.origin.x,cell.stretch_button.frame.origin.y,cell.stretch_button.frame.size.width,cell.stretch_button.frame.size.height);
        
        
//             [cell.stretch_button removeFromSuperview];
//             [cell.contentView addSubview:cell.stretch_button];
             NSLog(@"x: %f, y: %f, width: %f, height: %f",cell.stretch_button.frame.origin.x,cell.stretch_button.frame.origin.y,cell.stretch_button.frame.size.width,cell.stretch_button.frame.size.height);
             NSLog(@"Yes contentView height: %f",cell.contentView.bounds.size.height);
             [cell.stretch_button setTransform:CGAffineTransformMakeRotation(3.14)];
        
//        isReload = YES;
//        reloadHeight = 200;
        

        
//        for (UIImageView* imgV in cell.avatars) {
//            imgV.hidden = NO;
//            [cell.contentView addSubview:imgV];
//        }
//        for (UIView* v in [cell subviews]) {
//            if ( [v isKindOfClass:[UIImageView class]]) {
//                NSLog(@"there is an ImageView");
//                v.hidden = NO;
//            }
//        }
        

    }
    else
    {
        [rowHeights replaceObjectAtIndex:indexP.section withObject:[NSNumber numberWithFloat:110]];
//        for (UIImageView* imgV in cell.avatars) {
//            imgV.hidden = YES;
//        }
        
        [UIView animateWithDuration:5 animations:^
         {
//             cell.stretch_button.tag = 90;
             cell.stretch_button.frame = CGRectMake(155, 90, 10, 10);
//             isReload = YES;
//             reloadHeight = 90;
//             [cell.stretch_button removeFromSuperview];
//             [cell.contentView addSubview:cell.stretch_button];
             NSLog(@"x: %f, y: %f, width: %f, height: %f",cell.stretch_button.frame.origin.x,cell.stretch_button.frame.origin.y,cell.stretch_button.frame.size.width,cell.stretch_button.frame.size.height);
             NSLog(@"NO contentView height: %f",cell.contentView.bounds.size.height);
             [cell.stretch_button setTransform:CGAffineTransformMakeRotation(0)];
         }];

    }
    cell.isExpanded = !cell.isExpanded;
//    [self.friendInfoEvents_tableView beginUpdates];
//    [self.friendInfoEvents_tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexP] withRowAnimation:UITableViewRowAnimationAutomatic];
//    [self.friendInfoEvents_tableView endUpdates];
    [self.friendInfoEvents_tableView reloadData];
    
//    [self.friendInfoEvents_tableView reloadData];

}

- (IBAction)participate_event:(id)sender
{
    FriendInfoEventsTableViewCell* cell = (FriendInfoEventsTableViewCell*)[[[sender superview]superview]superview];
    NSIndexPath* indexP = [self.friendInfoEvents_tableView indexPathForCell:cell];
    NSDictionary* event = [events objectAtIndex:indexP.row];
    addEventID = [event objectForKey:@"event_id"];
    if ([addEventID isKindOfClass:[NSString class]]) {
        NSLog(@"addEventID is string");
    }
    else if([addEventID isKindOfClass:[NSNumber class]])
    {
        NSLog(@"addEventID is number");

    }
    UIAlertView* confirmAlert = [[UIAlertView alloc]initWithTitle:@"Confrim Message" message:@"Please input confirm message:" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    confirmAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    confirmAlert.tag = 0;
    [confirmAlert show];

}


#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case 0:{
            NSInteger cancelBtnIndex = alertView.cancelButtonIndex;
            NSInteger okBtnIndex = alertView.firstOtherButtonIndex;
            if (buttonIndex == cancelBtnIndex) {
                ;
            }
            else if (buttonIndex == okBtnIndex)
            {
                NSString* cm = [alertView textFieldAtIndex:0].text;
                NSNumber* userId = [MTUser sharedInstance].userid;
                
                NSDictionary* json = [CommonUtils packParamsInDictionary:[NSNumber numberWithInt:995],@"cmd",userId,@"id",cm,@"confirm_msg", addEventID,@"event_id",nil];
                NSData* jsonData = [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:nil];
                HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
                [httpSender sendMessage:jsonData withOperationCode:PARTICIPATE_EVENT];
                NSLog(@"add event apply: %@",json);
            }
        }
            break;
            
        default:
            break;
    }
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.destinationViewController isKindOfClass:[UserQRCodeViewController class]]) {
        UserQRCodeViewController* vc = segue.destinationViewController;
        vc.friendInfo_dic = friendInfo_dic;
    }
    else if ([segue.destinationViewController isKindOfClass:[ReportViewController class]])
    {
        ReportViewController* vc = segue.destinationViewController;
        vc.type = 0;
        vc.userId = fid;
        vc.userName = [friendInfo_dic objectForKey:@"name"];
    }
}




//- (IBAction)testingClicked:(id)sender
//{
////    NSString* sql_CreateTable = @"CREATE TABLE IF NOT EXISTS USERINFO (user_id INTEGER PRIMARY KEY, user_name TEXT, gender INTEGER)";
//    MySqlite* mine = [[MySqlite alloc]init];
//    NSLog(@"db testing");
//    [mine openMyDB:@"Metis.sqlite"];
////    [mine execSql:sql_CreateTable];
//    
//    [mine createTableWithTableName:@"USERINFO" andIndexWithProperties:@"user_id INTEGER PRIMARY KEY UNIQUE",@"user_name TEXT",@"gender INTEGER",nil];
//    
//    NSArray* columns1 = [[NSArray alloc]initWithObjects:@"'user_id'", @"'user_name'", @"'gender'", nil];
//    NSArray* values1 = [[NSArray alloc]initWithObjects:@"2",@"'sb1'",@"0",nil];
//    [mine insertToTable:@"USERINFO" withColumns:columns1 andValues:values1];
//    
//    NSArray* values2 = [[NSArray alloc]initWithObjects:@"5",@"'sbhhh'",@"0",nil];
//    [mine insertToTable:@"USERINFO" withColumns:columns1 andValues:values2];
//    
//    NSArray* values3 = [[NSArray alloc]initWithObjects:@"3",@"'xxxxf'",@"1",nil];
//    [mine insertToTable:@"USERINFO" withColumns:columns1 andValues:values3];
//
//    
////    NSArray* columns2 = [[NSArray alloc]initWithObjects:@"'user_name'", @"'gender'", nil];
////    NSArray* values4 = [[NSArray alloc]initWithObjects:@"'hi,sbb'",@"0",nil];
////    [mine updateDataWitTableName:@"USERINFO" andWhere:@"user_id" andItsValue:@"5" withColumns:columns2 andValues:values4];
//    
////    NSArray* columns3 = [[NSArray alloc]initWithObjects:@"'user_id'", @"'user_name'", nil];
////    NSArray* values5 = [[NSArray alloc]initWithObjects:@"5",@"'hello,sbb'",nil];
////    [mine insertToTable:@"USERINFO" withColumns:columns3 andValues:values5];
//    
//    NSDictionary* wheres = [[NSDictionary alloc]initWithObjectsAndKeys:@"5",@"user_id", nil];
//    NSDictionary* sets = [[NSDictionary alloc]initWithObjectsAndKeys:@"'yooooosb'",@"user_name",@"1",@"gender", nil];
//    [mine updateDataWitTableName:@"'USERINFO'" andWhere:wheres andSet:sets];
//    
//    NSArray* columns4 = [[NSArray alloc]initWithObjects:@"user_id", @"user_name", nil];
//    NSDictionary* wheres1 = [[NSDictionary alloc]initWithObjectsAndKeys:@"'%sb%'",@"user_name", nil];
//    NSMutableArray* results;
//    results = [mine queryTable:@"USERINFO" withSelect:columns4 andWhere:wheres1];
//    int count = results.count;
//    for (int i = 0; i<count; i++) {
//        NSLog(@"%d: %@\n",i,[results objectAtIndex:i]);
//    }
//    
//     NSDictionary* wheres2 = [[NSDictionary alloc]initWithObjectsAndKeys:@"'sb1'",@"user_name", nil];
//    [mine deleteTurpleFromTable:@"USERINFO" withWhere:wheres2];
//
//
//    [mine closeMyDB];
//}

- (IBAction)rightBarBtnClicked:(id)sender {
    [moreFunction_view setHidden:!moreFunction_view.hidden];
}

- (IBAction)QRcodeClicked:(id)sender {
    [self performSegueWithIdentifier:@"fInfo_fQRcode" sender:self];
    [moreFunction_view setHidden:!moreFunction_view.hidden];
}

- (IBAction)reportClicked:(id)sender {
    [self performSegueWithIdentifier:@"fInfo_report" sender:self];
    [moreFunction_view setHidden:!moreFunction_view.hidden];
}
@end
