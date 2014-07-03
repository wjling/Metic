//
//  FriendInfoViewController.m
//  Metic
//
//  Created by ligang5 on 14-5-28.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "FriendInfoViewController.h"
#import "math.h"

@interface FriendInfoViewController ()
{
    NSInteger kNumberOfPages;
}

@end

@implementation FriendInfoViewController
@synthesize del_friend_Button;
@synthesize sView;
@synthesize contentView;
@synthesize pControl;
@synthesize views;
@synthesize fInfoView;
@synthesize fDescriptionView;
@synthesize root;
@synthesize fid;
@synthesize events;
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
    kNumberOfPages = 2;
    [self initViews];
    [self getUserInfo];
     NSLog(@"friend info fid: %@",fid);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initViews
{
    CGRect screen = [UIScreen mainScreen].bounds;
    contentView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screen.size.width, 150)];
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
//    [pControl setBackgroundColor:[UIColor redColor]];
    
    
    self.fInfoView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, sv_width, sv_height)];
//    [self.fInfoView setBackgroundColor:[UIColor lightGrayColor]];
    self.fInfoView.image = [UIImage imageNamed:@"event"];
    
    UIImageView* photo = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"default_avatar.jpg"]];
    photo.frame = CGRectMake(20, 40, 50, 50);
    photo.layer.cornerRadius = 25;
    photo.layer.masksToBounds = YES;
    [photo setTag:0];
    photo.layer.borderColor = ([UIColor yellowColor].CGColor);
    photo.layer.borderWidth = 2;
    
    
    UILabel* name_label = [[UILabel alloc]initWithFrame:CGRectMake(85, 40, 100, 30)];
    name_label.text = @"喵喵喵喵星人";
    [name_label setFont:[UIFont fontWithName:@"Helvetica" size:15]];
    name_label.textColor = [UIColor whiteColor];
    [name_label setTag:1];
    
    UILabel* location_label = [[UILabel alloc]initWithFrame:CGRectMake(85, 70, 100, 25)];
    location_label.text = @"广东 广州";
    location_label.textColor = [UIColor whiteColor];
    [location_label setFont:[UIFont fontWithName:@"Helvetica" size:10]];
    [location_label setTag:2];
    
    UIImageView* gender_imageView = [[UIImageView alloc] initWithFrame:CGRectMake(185, 45, 17, 17)];
    gender_imageView.image = [UIImage imageNamed:@"女icon"];
    [gender_imageView setTag:3];
    
    self.del_friend_Button = [[UIButton alloc]initWithFrame:CGRectMake(self.fInfoView.frame.size.width-70, self.fInfoView.frame.size.height/2, 78, 25)];
//    [self.del_friend_Button setTag:4];
    UIColor* del_btn_color = [UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:0.6];
    [self.del_friend_Button setBackgroundColor:del_btn_color];
    self.del_friend_Button.layer.cornerRadius = 5;
    self.del_friend_Button.layer.masksToBounds = YES;
    UIImageView* icon = [[UIImageView alloc]initWithFrame:CGRectMake(8, 7, 10, 10)];
    icon.image = [UIImage imageNamed:@"删除好友叉"];
    UILabel* del_btn_label = [[UILabel alloc]initWithFrame:CGRectMake(23, 0, 45, 25)];
    del_btn_label.text = @"删除好友";
    del_btn_label.textColor = [UIColor whiteColor];
    [del_btn_label setFont:[UIFont fontWithName:@"ArialRoundedMTBold" size:9]];
//    del_button.titleLabel.text = @"删除好友";
    
    [self.del_friend_Button addSubview:icon];
    [self.del_friend_Button addSubview:del_btn_label];
    
//    self.fInfoView.layer.borderColor
    [self.fInfoView addSubview:photo];
    [self.fInfoView addSubview:name_label];
    [self.fInfoView addSubview:location_label];
    [self.fInfoView addSubview:gender_imageView];
//    [self.fInfoView addSubview:del_button];
    
    
    
    self.fDescriptionView = [[UIImageView alloc]initWithFrame:CGRectMake(fInfoView.frame.size.width, 0, sv_width, sv_height)];
//    [self.fDescriptionView setBackgroundColor:[UIColor yellowColor]];
    self.fDescriptionView.image = [UIImage imageNamed:@"event"];
    UILabel* title_label = [[UILabel alloc]initWithFrame:CGRectMake(30, 20, 100, 30)];
    title_label.text = @"个人描述";
    [title_label setFont:[UIFont fontWithName:@"Helvetica" size:15]];
    title_label.textColor = [UIColor whiteColor];
    
    UILabel* description_label = [[UILabel alloc]initWithFrame:CGRectMake(30, 50, 200, 25)];
    description_label.text = @"\"这个家伙很聪明什么都没有留下...\"";
    [description_label setFont:[UIFont fontWithName:@"Helvetica" size:10]];
    description_label.textColor = [UIColor whiteColor];
    [description_label setTag:4];
    
    friendInfoEvents_tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 150, screen.size.width, 330)];
    friendInfoEvents_tableView.delegate = self;
    friendInfoEvents_tableView.dataSource = self;
//    [friendInfoEvents_tableView setBackgroundColor:[UIColor blueColor]];
//    NSLog(@"x: %f, y: %f, width: %f, height: %f",friendInfoEvents_tableView.frame.origin.x,friendInfoEvents_tableView.frame.origin.y,friendInfoEvents_tableView.frame.size.width,friendInfoEvents_tableView.frame.size.height);
    
    self.test_tableView.delegate = self;
    self.test_tableView.dataSource = self;
    
    [self.fDescriptionView addSubview:title_label];
    [self.fDescriptionView addSubview:description_label];
    
    [sView addSubview:fInfoView];
    [sView addSubview:fDescriptionView];
    
    [contentView addSubview:sView];
    [contentView addSubview:pControl];
    
    [root addSubview:contentView];
    [root addSubview:self.del_friend_Button];
//    [root addSubview:friendInfoEvents_tableView];
    
}

- (IBAction)pageControlClicked:(id)sender
{
    int page = pControl.currentPage;
    
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
    NSLog(@"event_list: %@",events);
    for (UIView* v in self.fInfoView.subviews) {
        if (v.tag == 0) {
            PhotoGetter* getter = [[PhotoGetter alloc]initWithData:(UIImageView*)v path:[NSString stringWithFormat:@"/avatar/%@.jpg",fid] type:1 cache:nil isCircle:YES borderColor:[UIColor blackColor] borderWidth:5];
            [getter getPhoto];
        }
        else if (v.tag == 1)
        {
            NSString* name = [response objectForKey:@"name"];
            ((UILabel*)v).text = name;
        }
        else if (v.tag == 2)
        {
            NSString* location = [response objectForKey:@"location"];
            
            if (![location isEqual:[NSNull null]]) {
                ((UILabel*)v).text = location;
                
            }
            else
            {
                ((UILabel*)v).text = @"暂无地址信息";
            }
            
        }
        else if( v.tag == 3)
        {
            NSNumber* gender = [response objectForKey:@"gender"];
            if (0 == [gender intValue]) {
                ((UIImageView*)v).image = [UIImage imageNamed:@"女icon"];
            }
            else
            {
                ((UIImageView*)v).image = [UIImage imageNamed:@"男icon"];
            }
        }
    }
   
    for (UIView* v in self.fDescriptionView.subviews) {
        if (v.tag == 4) {
            NSString* sign = [response objectForKey:@"sign"];
            if (![sign isEqual:[NSNull null]]) {
                ((UILabel*)v).text = sign;
            }

        }
    }
    [self.test_tableView reloadData];
    
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
    NSLog(@"Received Data: %@",temp);
    NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
    NSNumber* cmd = [response1 objectForKey:@"cmd"];
    NSLog(@"cmd: %@",cmd);
    switch ([cmd intValue]) {
        case NORMAL_REPLY:
            [self handleInfo:response1];
            
            break;
            
        default:
            break;
    }
    
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.test_tableView reloadData];
    NSLog(@"reload data");
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"events count: %d",events.count);
    return 2;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary* event = [events objectAtIndex:indexPath.row];
    NSArray* member_ids = [event objectForKey:@"member"];
    NSLog(@"member_ids: %@",member_ids);
    FriendInfoEventsTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"eventCell"];
    if (nil == cell) {
        cell = [[FriendInfoEventsTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"eventCell"];
    }
    if ([cell isKindOfClass:[FriendInfoEventsTableViewCell class]]) {
        NSLog(@"friendinfoeventstableviewcell");
    }
//    cell.subject_label.text = [event objectForKey:@"subject"];
//    cell.time_label.text = [NSString stringWithFormat:@"%@ ~ %@",[event objectForKey:@"time"],[event objectForKey:@"endTime"]];
//    cell.location_label.text = [event objectForKey:@"location"];
//    cell.launcher_label.text = [event objectForKey:@"launcher"];
//    cell.remark_textView.text = [event objectForKey:@"remark"];
//    cell.numOfMember_label.text = [event objectForKey:@"member_count"];
//    int count = member_ids.count;
//    if (cell.avatars.count != 0) {
//        for (UIImageView* imgV in cell.avatars) {
//            [imgV removeFromSuperview];
//        }
//        [cell.avatars removeAllObjects];
//    }
//    for (NSInteger i = 0; i<count; i++) {
//        NSNumber* uid = [member_ids objectAtIndex:i];
//        UIImageView* avatar = [[UIImageView alloc]initWithFrame:CGRectMake(i*30+5, 160, 30, 30)];
//        PhotoGetter* getter = [[PhotoGetter alloc]initWithData:avatar path:[NSString stringWithFormat:@"/avatar/%@.jpg",uid] type:1 cache:nil isCircle:NO borderColor:[UIColor greenColor] borderWidth:1.5];
//        [getter getPhoto];
//    }
    return cell;
    
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

@end
