//
//  FriendInfoViewController.m
//  Metic
//
//  Created by ligang5 on 14-5-28.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "FriendInfoViewController.h"
#import "math.h"
#import "UIImageView+LBBlurredImage.h"
#import "BannerViewController.h"
#import "AddFriendConfirmViewController.h"
#import "MTDatabaseHelper.h"
#import "SVProgressHUD.h"
#import "MTOperation.h"
#import "MegUtils.h"

@interface FriendInfoViewController ()<UIAlertViewDelegate, UITextFieldDelegate>
{
    NSInteger kNumberOfPages;
    NSNumber* addEventID;
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
@synthesize fInfoView_imgV;
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

    [self initViews];
    [self getUserInfo];
    [self checkAvatarUpdate];
    [self.view bringSubviewToFront:moreFunction_view];
     MTLOG(@"friend info fid: %@",fid);
    
}

//返回上一层
-(void)MTpopViewController{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    MTLOG(@"view will appear");
    if ([[MTUser sharedInstance].friendsIdSet containsObject:fid])
    {
        [self.navigationItem setTitle:@"好友信息"];
        self.navigationItem.rightBarButtonItem = nil;
    }
    else
    {
        [self.navigationItem setTitle:@"用户信息"];
        UIButton* btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
        [btn setBackgroundImage:[UIImage imageNamed:@"添加好友icon白"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(addfriendClick:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem* barBtnItem = [[UIBarButtonItem alloc]initWithCustomView:btn];
        [self.navigationItem setRightBarButtonItem:barBtnItem];
    }
    [self refreshFriendInfo];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    MTLOG(@"view did appear");
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        MTLOG(@"IOS %f", [[UIDevice currentDevice].systemVersion floatValue]);
//        [friendInfoEvents_tableView setFrame:CGRectMake(10, friendInfoEvents_tableView.frame.origin.y, self.view.frame.size.width - 20, friendInfoEvents_tableView.frame.size.height)];
        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)addfriendClick:(id)sender
{
    UIStoryboard* storyBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    AddFriendConfirmViewController* vc = [storyBoard instantiateViewControllerWithIdentifier:@"AddFriendConfirmViewController"];
    vc.fid = fid;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)initViews
{
    [self getfriendInfoFromDB];
    CGRect screen = [UIScreen mainScreen].bounds;
    contentView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screen.size.width, 135)];
    contentView.clipsToBounds = YES;
    [contentView setBackgroundColor:[UIColor clearColor]];
    
    UIView* line = [[UIView alloc]initWithFrame:CGRectMake(0, 132, screen.size.width, 3)];
    [line setBackgroundColor:[UIColor orangeColor]];
    
    sView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, contentView.frame.size.width, contentView.frame.size.height-3)];
    CGFloat sv_width = sView.frame.size.width;
    CGFloat sv_height = sView.frame.size.height;
    sView.scrollEnabled = YES;
    sView.pagingEnabled =  YES;
    sView.contentSize = CGSizeMake(sv_width*kNumberOfPages, sv_height);
    sView.delegate = self;
    sView.showsHorizontalScrollIndicator = NO;
    sView.showsVerticalScrollIndicator = NO;
    [sView setBackgroundColor:[UIColor clearColor]];
    
    pControl = [[UIPageControl alloc]initWithFrame:CGRectMake(0, sv_height-15, sv_width, 10)];
    pControl.numberOfPages = kNumberOfPages;
    pControl.currentPage = 0;
    UIColor* indicatorTintColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5];
    pControl.pageIndicatorTintColor = indicatorTintColor;
    [pControl addTarget:self action:@selector(pageControlClicked:) forControlEvents:UIControlEventValueChanged];
    
    
    self.fInfoView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, sv_width, sv_height)];
//    [self.fInfoView setBackgroundColor:[UIColor lightGrayColor]];
//    self.fInfoView.image = [UIImage imageNamed:@"1星空.jpg"];
    self.fInfoView_imgV = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, sv_width, sv_height)];
    
    photo = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"default_avatar.jpg"]];
    photo.frame = CGRectMake(20, 30, 50, 50);
    photo.layer.cornerRadius = 25;
    photo.layer.masksToBounds = YES;
    [photo setTag:0];
    photo.layer.borderColor = ([UIColor yellowColor].CGColor);
    photo.layer.borderWidth = 2;
    photo.userInteractionEnabled = YES;
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showAvatar)];
    [photo addGestureRecognizer:tap];
    
    
    name_label = [[UILabel alloc]initWithFrame:CGRectMake(85, 30, 200, 25)];
    name_label.text = self.friendInfo_dic? [self.friendInfo_dic objectForKey:@"name"] : @"用户名";
    [name_label setFont:[UIFont fontWithName:@"Helvetica" size:15]];
    name_label.textColor = [UIColor whiteColor];
    [name_label setBackgroundColor:[UIColor clearColor]];
    
    alias_label = [[UILabel alloc]initWithFrame:CGRectMake(85, 60, 200, 25)];
    NSString* alias = [[MTUser sharedInstance].alias_dic objectForKey:[NSString stringWithFormat:@"%@",fid]];
    alias_label.text = (alias && ![alias isEqual:[NSNull null]])?  alias : @"备注名";
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
    if ([[MTUser sharedInstance].friendsIdSet containsObject:fid]) {
        friend_alias_button.hidden = NO;
    }
    else
    {
        friend_alias_button.hidden = YES;
    }
    
//    self.fInfoView.layer.borderColor
//    [self.fInfoView addSubview:fInfoView_imgV];
    [self.fInfoView addSubview:photo];
    [self.fInfoView addSubview:name_label];
    [self.fInfoView addSubview:alias_label];
    [self.fInfoView addSubview:location_label];
    [self.fInfoView addSubview:gender_imageView];
//    [self.fInfoView addSubview:friend_alias_button];
//    [self.fInfoView addSubview:del_button];
    
    
    
    self.fDescriptionView = [[UIView alloc]initWithFrame:CGRectMake(fInfoView.frame.size.width, 0, sv_width, sv_height)];
//    [self.fDescriptionView setBackgroundColor:[UIColor yellowColor]];
//    self.fDescriptionView.image = [UIImage imageNamed:@"1星空.jpg"];
//    self.fDescriptionView_imgV = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, sv_width, sv_height)];
    
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
//    MTLOG(@"x: %f, y: %f, width: %f, height: %f",friendInfoEvents_tableView.frame.origin.x,friendInfoEvents_tableView.frame.origin.y,friendInfoEvents_tableView.frame.size.width,friendInfoEvents_tableView.frame.size.height);
    
    self.friendInfoEvents_tableView.delegate = self;
    self.friendInfoEvents_tableView.dataSource = self;

//    [self.fDescriptionView addSubview:self.fDescriptionView_imgV];
    [self.fDescriptionView addSubview:title_label];
    [self.fDescriptionView addSubview:description_label];
    
    
    [sView addSubview:fInfoView];
    [sView addSubview:fDescriptionView];
    
    [contentView addSubview:fInfoView_imgV];
    [contentView addSubview:line];
    [contentView addSubview:sView];
    [contentView addSubview:pControl];
    
    [root addSubview:contentView];
    [root addSubview:self.friend_alias_button];
//    [root addSubview:self.del_friend_Button];
//    [root addSubview:friendInfoEvents_tableView];
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapDown)];
    [sView addGestureRecognizer:tapGesture];
}

-(void)showAvatar
{
    BannerViewController* bannerView = [[BannerViewController alloc] init];
    bannerView.banner = self.photo.image;
    if (self.fid) {
        bannerView.path = [NSString stringWithFormat:@"/avatar/%@_2.jpg",self.fid];
    }
    [self presentViewController:bannerView animated:YES completion:^{}];
}

-(void)tapDown
{
    [moreFunction_view setHidden:YES];
}

- (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size{
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(size);
    // 绘制改变大小的图片
    [img drawInRect:CGRectMake(0, 0, size.width, size.height)];
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    // 返回新的改变大小后的图片
    return scaledImage; 
}

-(void)updateAvatartoDB:(NSDictionary*)avatarInfo
{
    NSArray *columns = [[NSArray alloc]initWithObjects:@"'id'",@"'updatetime'", nil];
    NSArray *values = [[NSArray alloc]initWithObjects:[NSString stringWithFormat:@"%@",[avatarInfo valueForKey:@"id"]],[NSString stringWithFormat:@"'%@'",[avatarInfo valueForKey:@"updatetime"]], nil];
    [[MTDatabaseHelper sharedInstance]insertToTable:@"avatar" withColumns:columns andValues:values];
}

-(void)checkAvatarUpdate
{
    [SVProgressHUD showWithStatus:nil maskType:SVProgressHUDMaskTypeClear];
    self.fInfoView_imgV.contentMode = UIViewContentModeScaleAspectFill;
    self.fInfoView_imgV.clipsToBounds = YES;
    self.fInfoView_imgV.image = [UIImage imageNamed:@"默认用户头像"];
    [self.fInfoView_imgV setImageToBlur:[UIImage imageNamed:@"默认用户头像"] blurRadius:6 brightness:-0.1 completionBlock:nil];
    
    PhotoGetter* getter = [[PhotoGetter alloc]initWithData:photo authorId:fid];
    [getter getAvatarWithCompletion:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (!image) {
            image = [UIImage imageNamed:@"默认用户头像"];
        }
        [self.fInfoView_imgV setImageToBlur:image blurRadius:6 brightness:-0.1 completionBlock:nil];
    }];
    
    [[MTDatabaseHelper sharedInstance] queryTable:@"avatar" withSelect:@[@"*"] andWhere:@{@"id":fid} completion:^(NSMutableArray *resultsArray) {
        if (resultsArray && resultsArray.count > 0) {
            NSDictionary* temp_dic = [resultsArray objectAtIndex:0];
            NSNumber* f_id = [temp_dic objectForKey:@"id"];
            if ([f_id integerValue] == [fid integerValue]) {
                NSString* local_updatetime = [temp_dic objectForKey:@"updatetime"];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSDictionary* json_dic = [CommonUtils packParamsInDictionary:[MTUser sharedInstance].userid, @"id", nil];
                    NSData* json_data = [NSJSONSerialization dataWithJSONObject:json_dic options:NSJSONWritingPrettyPrinted error:nil];
                    HttpSender* http = [[HttpSender alloc]initWithDelegate:self];
                    [http sendMessage:json_data withOperationCode:GET_AVATAR_UPDATETIME finshedBlock:^(NSData *rData) {
                        NSString* temp;
                        if (rData)
                        {
                            temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
                        }
                        else
                        {
                            [SVProgressHUD dismissWithError:@"网络异常" afterDelay:1.5];
                            return;
                        }
                        MTLOG(@"查看好友头像更新时间,Received Data: %@",temp);
                        NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
                        NSInteger cmd = [[response1 objectForKey:@"cmd"]intValue];
                        switch (cmd) {
                            case NORMAL_REPLY:
                            {
                                NSArray* friends_updatetime_arr = [response1 objectForKey:@"list"];
                                for (int i = 0; i < friends_updatetime_arr.count; i++) {
                                    NSDictionary* friend_update_time_dic = [friends_updatetime_arr objectAtIndex:i];
                                    NSString* server_updatetime = [friend_update_time_dic objectForKey:@"updatetime"];
                                    NSNumber* friend_id = [friend_update_time_dic objectForKey:@"id"];
                                    if ([friend_id integerValue] == [fid integerValue]) {
                                        if (![server_updatetime isEqualToString:local_updatetime]) {
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                PhotoGetter* getter = [[PhotoGetter alloc]initWithData:photo authorId:fid];
                                                [self.fInfoView_imgV setImageToBlur:[UIImage imageNamed:@"默认用户头像"] blurRadius:6 brightness:-0.1 completionBlock:nil];
                                                NSString* avatarHDPath = [MegUtils avatarHDImagePathWithUserId:self.fid];
                                                [[SDImageCache sharedImageCache] removeImageForKey:avatarHDPath];
                                            
                                                [getter getAvatarFromServerwithCompletion:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                                    if (!image) {
                                                        image = [UIImage imageNamed:@"默认用户头像"];
                                                    }
                                                    [self.fInfoView_imgV setImageToBlur:image blurRadius:6 brightness:-0.1 completionBlock:nil];
                                                    
                                                }];
                                                
                                            });
                                            [self updateAvatartoDB:friend_update_time_dic];
                                            
                                        }
                                        break;
                                    }
                                }
                                [SVProgressHUD dismiss];
                            }
                                break;
                                
                            default:
                                [SVProgressHUD dismissWithError:@"获取头像异常" afterDelay:1.5];
                                break;
                        }
                    }];
                });
            }
        }else [SVProgressHUD dismiss];
    }];
}

-(void)refreshFriendInfo
{
    
    NSString* name = [friendInfo_dic objectForKey:@"name"];
    NSString* location = [friendInfo_dic objectForKey:@"location"];
    NSNumber* gender = [friendInfo_dic objectForKey:@"gender"];
//    NSString* email = [friendInfo_dic objectForKey:@"email"];
    NSString* sign = [friendInfo_dic objectForKey:@"sign"];
    NSString* alias = [[MTUser sharedInstance].alias_dic objectForKey:[NSString stringWithFormat:@"%@",fid]];
    
    MTLOG(@"friend info viewcontroler: name: %@", [friendInfo_dic objectForKey:@"name"]);
    name_label.text = name;
    if (alias && ![alias isEqual:[NSNull null]] && ![alias isEqualToString:@""]) {
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
    
    
    if (sign && ![sign isEqual:[NSNull null]]) {
        (description_label).text = sign;
    }
    
    [self.friendInfoEvents_tableView reloadData];

}

-(void)getfriendInfoFromDB
{
    [[MTDatabaseHelper sharedInstance] queryTable:@"friend" withSelect:[NSArray arrayWithObjects:@"*", nil] andWhere:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%@",fid], @"id", nil] completion:^(NSMutableArray *resultsArray) {
        NSArray* alias_arr;
        alias_arr = resultsArray;
        if(alias_arr.count > 0) self.friendInfo_dic = alias_arr[0];
        MTLOG(@"get alias from DB: %@",alias_arr);
    }];
}

-(IBAction)changeAlias:(id)sender
{
    ChangeAliasViewController *aliasVC = [[ChangeAliasViewController alloc]init];
    aliasVC.fid = fid;
    MTLOG(@"alias change, fid = %@",aliasVC.fid);
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
    MTLOG(@"friend info json: %@",json);
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender* httpsender = [[HttpSender alloc]initWithDelegate:self];
    [httpsender sendMessage:jsonData withOperationCode:GET_USER_INFO];
}

- (void)handleInfo:(NSDictionary*)response
{
    events = [response objectForKey:@"event_list"];
    rowHeights = [[NSMutableArray alloc]init];
    if (events) {
        for (int i = 0; i < events.count; i++) {
            [rowHeights addObject:[NSNumber numberWithFloat:110.0]];
        }
    }
    
    NSString* name = [response objectForKey:@"name"];
    NSString* location = [response objectForKey:@"location"];
    NSNumber* gender = [response objectForKey:@"gender"];
    NSString* email = [response objectForKey:@"email"];
    NSString* sign = [response objectForKey:@"sign"];
    
    if (!friendInfo_dic) {
        friendInfo_dic = [[NSMutableDictionary alloc]init];
    }
    [friendInfo_dic setValue:name forKey:@"name"];
    [friendInfo_dic setValue:location forKey:@"location"];
    [friendInfo_dic setValue:gender forKey:@"gender"];
    [friendInfo_dic setValue:email forKey:@"email"];
    [friendInfo_dic setValue:sign forKey:@"sign"];
    
    NSDictionary* wheres = [CommonUtils packParamsInDictionary:[NSString stringWithFormat:@"%@",fid],@"id",nil];
    NSDictionary* sets = [CommonUtils packParamsInDictionary:
                          [NSString stringWithFormat:@"'%@'",name],@"name",
                          [NSString stringWithFormat:@"'%@'",email],@"email",
                          [NSString stringWithFormat:@"%@",fid],@"id",
                          [NSString stringWithFormat:@"%@",gender],@"gender",
                          nil];

    [[MTDatabaseHelper sharedInstance] updateDataWithTableName:@"friend" andWhere:wheres andSet:sets];
    [[MTUser sharedInstance] getFriendsFromDBwithCompletion:^(NSMutableArray *results) {
        [MTUser sharedInstance].friendList = [NSMutableArray arrayWithArray:results];
        [[MTUser sharedInstance] friendListDidChanged];
    }];
   [self refreshFriendInfo];
}

#pragma mark - Touches
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [moreFunction_view setHidden:YES];
}


#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView               // any offset changes
{
    [moreFunction_view setHidden:YES];
    if (scrollView == sView) {
        CGFloat page_width = sView.frame.size.width;
        int page_index = floor((sView.contentOffset.x - page_width/2) / page_width) +1;
        pControl.currentPage = page_index;
    }
}

// called on start of dragging (may require some time and or distance to move)
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [moreFunction_view setHidden:YES];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView      // called when scroll view grinds to a halt
{
    
}


#pragma mark - HttpSenderDelegate
-(void)finishWithReceivedData:(NSData*) rData
{
    NSString* temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
    MTLOG(@"从服务器获得好友信息: %@",temp);
    NSMutableDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
    NSNumber* cmd = [response1 objectForKey:@"cmd"];
    MTLOG(@"cmd: %@",cmd);
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
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if(!moreFunction_view.hidden){
        moreFunction_view.hidden = YES;
        return;
    }
    
    FriendInfoEventsTableViewCell* cell = (FriendInfoEventsTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:[FriendInfoEventsTableViewCell class]]) {
        NSNumber* rowHeight = rowHeights[indexPath.section];
        MTLOG(@"%@",rowHeight);
        if (cell.isExpanded) {
            [rowHeights replaceObjectAtIndex:indexPath.section withObject:[NSNumber numberWithFloat:110]];
        }else {
            [rowHeights replaceObjectAtIndex:indexPath.section withObject:[NSNumber numberWithFloat:225]];
        }
        cell.isExpanded = !cell.isExpanded;
        
        [self.friendInfoEvents_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    
    
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
//    MTLOG(@"events count: %d",events.count);
//    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
//        MTLOG(@"IOS %f", [[UIDevice currentDevice].systemVersion floatValue]);
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
    NSDictionary* event = [events objectAtIndex:indexPath.section];
    NSArray* member_ids = [event objectForKey:@"member"];
    FriendInfoEventsTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"eventCell"];
    if (nil == cell) {
        MTLOG(@"friendinfoeventstableviewcell");
        cell = [[FriendInfoEventsTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"eventCell"];
        
    }
    BOOL isIn = [[event objectForKey:@"isIn"]boolValue];
    if (isIn) {
        cell.isIn_label.hidden = NO;
        cell.add_button.hidden = YES;
    }
    else
    {
        cell.isIn_label.hidden = YES;
        cell.add_button.hidden = NO;
    }
    cell.subject_label.text = [event objectForKey:@"subject"];
    cell.subject_label.lineBreakMode = NSLineBreakByTruncatingTail;
    cell.time_label.text = [NSString stringWithFormat:@"%@ ~ %@",[event objectForKey:@"time"],[event objectForKey:@"endTime"]];
    cell.location_label.text = [event objectForKey:@"location"];
    cell.launcher_label.text = [event objectForKey:@"launcher"];
    NSString* remark = [event objectForKey:@"remark"];
    if (![remark isEqualToString:@""]) {
        cell.remark_textView.text = remark;
    }else{
        cell.remark_textView.text = @"主人好懒都懒得描述的说～";
    }
    cell.numOfMember_label.text = [CommonUtils NSStringWithNSNumber:[event objectForKey:@"member_count"]];
    
    if (!cell.stretch_button) {
        cell.stretch_button = [[UIImageView alloc]initWithFrame:CGRectMake(155, 90, 10, 10)];
        [cell.stretch_button setImage:[UIImage imageNamed:@"箭头icon"]];
        [cell.contentView addSubview:cell.stretch_button];
    }
    
    NSNumber* rowHeight = rowHeights[indexPath.section];
    if ([rowHeight floatValue] == 225) {
        cell.isExpanded = YES;
        cell.stretch_button.frame = CGRectMake(155, 200, 10, 10);
        [cell.stretch_button setTransform:CGAffineTransformMakeRotation(3.14)];
        
    }else if([rowHeight floatValue] == 110) {
        cell.isExpanded = NO;
        cell.stretch_button.frame = CGRectMake(155, 90, 10, 10);
        [cell.stretch_button setTransform:CGAffineTransformMakeRotation(0)];
    }
    
    NSInteger count = member_ids.count;
    if (cell.avatars.count != 0) {
        for (int i = 0; i < cell.avatars.count; i++) {
            UIImageView* imgV = [cell.avatars objectAtIndex:i];
            [imgV removeFromSuperview];
        }
        [cell.avatars removeAllObjects];
    }
    for (NSInteger i = 0; i < count; i++) {
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

- (IBAction)participate_event:(id)sender
{
    FriendInfoEventsTableViewCell* cell = (FriendInfoEventsTableViewCell*)[sender superview];
    while (![cell isKindOfClass:[FriendInfoEventsTableViewCell class]]) {
        cell = (FriendInfoEventsTableViewCell*)[cell superview];
    }
    NSIndexPath* indexP = [self.friendInfoEvents_tableView indexPathForCell:cell];
    MTLOG(@"index.section: %d", indexP.section);
    NSDictionary* event = [events objectAtIndex:indexP.section];
    addEventID = [event objectForKey:@"event_id"];
    if ([addEventID isKindOfClass:[NSString class]]) {
        MTLOG(@"addEventID is string, id: %@",addEventID);
    }
    else if([addEventID isKindOfClass:[NSNumber class]])
    {
        MTLOG(@"addEventID is number, id: %@",addEventID);

    }
    UIAlertView* confirmAlert = [[UIAlertView alloc]initWithTitle:@"系统提示" message:@"请输入申请加入信息:" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    confirmAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    confirmAlert.tag = 0;
    if ([MTUser sharedInstance].name && ![[MTUser sharedInstance].name isEqual:[NSNull null]]) {
        [confirmAlert textFieldAtIndex:0].text = [NSString stringWithFormat:@"我是%@",[MTUser sharedInstance].name];
    }
    [confirmAlert textFieldAtIndex:0].delegate = self;
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
                
                NSDictionary* json = [CommonUtils packParamsInDictionary:[NSNumber numberWithInt:REQUEST_EVENT],@"cmd",userId,@"id",cm,@"confirm_msg", addEventID,@"event_id",nil];
                NSData* jsonData = [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:nil];
                HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
                [httpSender sendMessage:jsonData withOperationCode:PARTICIPATE_EVENT];
                MTLOG(@"add event apply: %@",json);
            }
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([textField.text containsString:@"我是"] && textField.text.length > 2) {
//        NSRange range = NSMakeRange(2, textField.text.length - 2);
//        UITextRange* trange = [[UITextRange alloc]init];
//        UITextPosition* pos = [[UITextPosition alloc]init];
//        [textField selectAll:textField];
    }
    MTLOG(@"yayyayayayayyayayyayayayyy");
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
