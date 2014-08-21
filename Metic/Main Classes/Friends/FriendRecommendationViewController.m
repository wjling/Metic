//
//  FriendRecommendationViewController.m
//  WeShare
//
//  Created by mac on 14-8-17.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "FriendRecommendationViewController.h"

@interface FriendRecommendationViewController ()
{
    UIView* tabIndicator_view;
//    UIButton *tab1, *tab2, *tab3;
    NSMutableArray* tab_arr;
    NSInteger tab_index;
    BOOL clickTab;
    NSNumber* selectedFriendID;
}


@end

@implementation FriendRecommendationViewController
@synthesize tabbar_scrollview;
@synthesize content_scrollview;

@synthesize tabPage1_view;
@synthesize noUpload_view;
@synthesize addContacts_button;
@synthesize hasUpload_view;
@synthesize contacts_tableview;

@synthesize tabPage2_view;
@synthesize nearbyFriends_tableview;

@synthesize tabPage3_view;
@synthesize kankan_tableview;

@synthesize activityIndicator;

@synthesize contacts_arr;
@synthesize locationService;
@synthesize coordinate;
@synthesize nearbyFriends_arr;
@synthesize kankan_arr;


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
    [self initTabBar];
    [self initContentView];
    
    locationService = [[BMKLocationService alloc]init];
    contacts_arr = [[NSMutableArray alloc]init];
    nearbyFriends_arr = [[NSMutableArray alloc]init];
    kankan_arr = [[NSMutableArray alloc]init];
    
    contacts_tableview.delegate = self;
    contacts_tableview.dataSource = self;
    nearbyFriends_tableview.delegate = self;
    nearbyFriends_tableview.dataSource = self;
    kankan_tableview.delegate = self;
    kankan_tableview.dataSource = self;
//    [locationService startUserLocationService];
    
    
}

//返回上一层
-(void)MTpopViewController{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    NSLog(@"friend recommendation view will appear");
//    
//    NSLog(@"content size===before, width: %f, height: %f",self.content_scrollview.contentSize.width,self.content_scrollview.contentSize.height);
//    self.content_scrollview.contentSize = CGSizeMake(960, 450);
//    NSLog(@"content size===after, width: %f, height: %f",self.content_scrollview.contentSize.width,self.content_scrollview.contentSize.height);

}

-(void)viewDidAppear:(BOOL)animated
{

    [super viewDidAppear:animated];
    locationService.delegate = self;
    self.tabbar_scrollview.contentSize = CGSizeMake(self.tabbar_scrollview.frame.size.width, self.content_scrollview.frame.size.height);
//    NSLog(@"friend recommendation view did appear");
    NSLog(@"tabbar view, width: %f, height: %f",tabbar_scrollview.frame.size.width,tabbar_scrollview.frame.size.height);
    NSLog(@"tabbar content size, width: %f, height: %f",self.tabbar_scrollview.contentSize.width,self.tabbar_scrollview.contentSize.height);
//    NSLog(@"content size===before, width: %f, height: %f",self.content_scrollview.contentSize.width,self.content_scrollview.contentSize.height);
//    self.content_scrollview.contentSize = CGSizeMake(960, self.content_scrollview.frame.size.height);
//    NSLog(@"content size===after, width: %f, height: %f",self.content_scrollview.contentSize.width,self.content_scrollview.contentSize.height);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"friendRecommend_addFriend"]) {
        AddFriendConfirmViewController* vc = segue.destinationViewController;
        vc.fid = selectedFriendID;
    }
}


-(void)initTabBar
{
    UIColor* myGreen = [UIColor colorWithRed:0.27 green:0.80 blue:0.68 alpha:1];
    CGFloat tab_width = self.tabbar_scrollview.frame.size.width/3.0;
    CGFloat tab_height = self.tabbar_scrollview.frame.size.height - 1;
//    self.tabbar_scrollview.scrollEnabled = NO;
    [self.tabbar_scrollview setBackgroundColor:[CommonUtils colorWithValue:0xd9d9d9]];
    
    tabIndicator_view = [[UIView alloc]initWithFrame:CGRectMake(10, tab_height - 3, tab_width - 20, 3)];
    [tabIndicator_view setBackgroundColor:myGreen];
    
    
    UIButton* tab1 = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, tab_width, tab_height)];
    UIButton* tab2 = [[UIButton alloc]initWithFrame:CGRectMake(tab_width, 0, tab_width, tab_height)];
    UIButton* tab3 = [[UIButton alloc]initWithFrame:CGRectMake(tab_width * 2, 0, tab_width, tab_height)];
//    tab1 = [UIButton buttonWithType:UIButtonTypeCustom];
//    tab2 = [UIButton buttonWithType:UIButtonTypeCustom];
//    tab3 = [UIButton buttonWithType:UIButtonTypeCustom];
//    [tab1 setFrame:CGRectMake(0, 0, tab_width, tab_height)];
//    [tab2 setFrame:CGRectMake(tab_width, 0, tab_width, tab_height)];
//    [tab3 setFrame:CGRectMake(tab_width * 2, 0, tab_width, tab_height)];
    tab_arr = [[NSMutableArray alloc]initWithObjects:tab1,tab2,tab3, nil];
    
    UIColor* tColor_normal = [UIColor colorWithRed:0.553 green:0.553 blue:0.553 alpha:1];
    UIColor* tColor_selected = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
    UIColor* bgColor = [UIColor whiteColor];
    [tab1 setTitle:@"通讯录" forState:UIControlStateNormal];
    [tab2 setTitle:@"附近的人" forState:UIControlStateNormal];
    [tab3 setTitle:@"随便看看" forState:UIControlStateNormal];
    [tab1 setTitleColor:tColor_normal forState:UIControlStateNormal];
    [tab2 setTitleColor:tColor_normal forState:UIControlStateNormal];
    [tab3 setTitleColor:tColor_normal forState:UIControlStateNormal];
    [tab1 setTitleColor:tColor_selected forState:UIControlStateSelected];
    [tab2 setTitleColor:tColor_selected forState:UIControlStateSelected];
    [tab3 setTitleColor:tColor_selected forState:UIControlStateSelected];
    [tab1 setBackgroundColor:bgColor];
    [tab2 setBackgroundColor:bgColor];
    [tab3 setBackgroundColor:bgColor];
    
    [tab1 addTarget:self action:@selector(tabClicked:) forControlEvents:UIControlEventTouchUpInside];
    [tab2 addTarget:self action:@selector(tabClicked:) forControlEvents:UIControlEventTouchUpInside];
    [tab3 addTarget:self action:@selector(tabClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [tab1 setSelected:YES];
    tab_index = 0;
    clickTab = NO;
//    [self.tabbar_scrollview setBackgroundColor:[UIColor clearColor]];
    [self.tabbar_scrollview addSubview:tab1];
    [self.tabbar_scrollview addSubview:tab2];
    [self.tabbar_scrollview addSubview:tab3];
//    [tab1 setNeedsDisplay];
    [self.tabbar_scrollview addSubview:tabIndicator_view];
}

-(void)initContentView
{
    UIColor* bgColor = [UIColor colorWithRed:0.949 green:0.949 blue:0.949 alpha:1];
    self.content_scrollview.scrollEnabled = YES;
    self.content_scrollview.pagingEnabled = YES;
    self.content_scrollview.bounces = NO;
    self.content_scrollview.showsHorizontalScrollIndicator = NO;
    self.content_scrollview.showsVerticalScrollIndicator = NO;
    self.content_scrollview.delegate = self;
    [self.addContacts_button addTarget:self action:@selector(uploadContacts:) forControlEvents:UIControlEventTouchUpInside];
    
    self.contacts_tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.nearbyFriends_tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.kankan_tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.tabPage1_view setBackgroundColor:bgColor];
    [self.contacts_tableview setBackgroundColor:bgColor];
    [self.nearbyFriends_tableview setBackgroundColor:bgColor];
    [self.kankan_tableview setBackgroundColor:bgColor];
    
    NSUserDefaults* userDf = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary* userSettings = [[NSMutableDictionary alloc]initWithDictionary:[userDf objectForKey:[NSString stringWithFormat:@"USER%@",[MTUser sharedInstance].userid]]];
    NSNumber* hasUploadContact = [userSettings objectForKey:@"hasUploadPhoneNumber"];
    if (![hasUploadContact boolValue]) {
        self.noUpload_view.hidden = NO;
        self.hasUpload_view.hidden = YES;
//        [userDf setBool:NO forKey:@"hasUploadContact"];
    }
    else
    {
        self.noUpload_view.hidden = YES;
        self.hasUpload_view.hidden = NO;
//        [userDf setBool:YES forKey:@"hasUploadContact"];
        
    }
    
    
}

-(void)getPeopleInContact
{
    ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
    NSLog(@"address book authorization status: %ld",status);
    ABAddressBookRef addressBook = nil;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 6.0) {
        addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            dispatch_semaphore_signal(sema);
        });
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    }
    else
    {
        addressBook = ABAddressBookCreate();
    }
    if (status == kABAuthorizationStatusDenied) {
        [CommonUtils showSimpleAlertViewWithTitle:@"温馨提示" WithMessage:@"您曾经拒绝了活动宝的通讯录访问，请您在\n设置->隐私->通讯录\n里面授权活动宝获取您的通讯录内容" WithDelegate:self WithCancelTitle:@"确定"];
    }
    
    if (addressBook == nil) {
        return;
    }
    contacts_arr = (__bridge NSMutableArray*)ABAddressBookCopyArrayOfAllPeople(addressBook);
}

-(NSMutableArray*)getFriendsPhoneNumber
{
    NSMutableArray* phoneNumbers = [[NSMutableArray alloc]init];
    if (contacts_arr) {
        for (id tmpPerson in contacts_arr) {
            ABMultiValueRef phones = ABRecordCopyValue((__bridge ABRecordRef)(tmpPerson), kABPersonPhoneProperty);
            for (NSInteger i = 0; i < ABMultiValueGetCount(phones); i++) {
                NSMutableString* phoneNumber = (__bridge NSMutableString *)(ABMultiValueCopyValueAtIndex(phones, i));
                [phoneNumbers addObject:[phoneNumber stringByReplacingOccurrencesOfString:@"-" withString:@""]];
            }
        }
    }
    return phoneNumbers;
}

-(void)tabClicked:(UIButton*)sender
{
//    NSLog(@"cotnent scrollview, content size: width: %f, height: %f",self.content_scrollview.contentSize.width,self.content_scrollview.contentSize.height);
    clickTab = YES;
    NSInteger index = [tab_arr indexOfObject:sender];
    UIButton* lastBtn = [tab_arr objectAtIndex:tab_index];
    UIButton* currentBtn = sender;
    [lastBtn setSelected:NO];
    [currentBtn setSelected:YES];
    
    CGRect frame = CGRectMake(currentBtn.frame.origin.x + 10, tabIndicator_view.frame.origin.y, tabIndicator_view.frame.size.width, tabIndicator_view.frame.size.height);
    [self scrollTabIndicator:frame];
    
    CGPoint point = CGPointMake(self.contacts_tableview.frame.size.width * index, currentBtn.frame.origin.y);
    [self.content_scrollview setContentOffset:point animated:YES];
    tab_index = index;
    if (tab_index == 0) {
        
    }
    else if (tab_index == 1)
    {
        NSLog(@"tab 1");
        NSThread* locate = [[NSThread alloc]initWithTarget:locationService selector:@selector(startUserLocationService) object:nil];
        [locate start];
    }
    else if (tab_index == 2)
    {
        NSLog(@"tab 2");
//        [NSThread detachNewThreadSelector:@selector(getKanKan) toTarget:self withObject:nil];
        [self getKanKan];
    }
    
}

-(void)scrollTabIndicator:(CGRect)frame
{
    [UIView beginAnimations:@"tab indicator scrolling" context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelegate:self];
    [UIView  setAnimationCurve: UIViewAnimationCurveEaseInOut];
    //    [UIView setAnimationTransition:UIViewAnimationTransitionCurlDown forView:self.functions_uiview  cache:YES];
    [tabIndicator_view setFrame:frame];
    [UIView commitAnimations];
}

-(void)uploadContacts:(id)sender
{
    NSLog(@"cotnent scrollview, content size: width: %f, height: %f",self.content_scrollview.contentSize.width,self.content_scrollview.contentSize.height);
    UIAlertView* alertview = [[UIAlertView alloc]initWithTitle:@"请绑定您的手机号码" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alertview.alertViewStyle = UIAlertViewStylePlainTextInput;
    alertview.delegate = self;
    alertview.tag = 119;
    [alertview show];
    
}

-(void)getNearbyFriends
{
    void (^getNearbyFriendsDone)(NSData*) = ^(NSData* rData)
    {
        NSString* temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
        NSLog(@"get nearbyfriends done, received Data: %@",temp);
        NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
        NSNumber* cmd = [response1 objectForKey:@"cmd"];
        if ([cmd integerValue] == 100) {
            nearbyFriends_arr = [response1 objectForKey:@"friend_list"];
            [nearbyFriends_tableview reloadData];
        }
    };
    NSDictionary* json_dic = [CommonUtils packParamsInDictionary:
                              [MTUser sharedInstance].userid,@"id",
                              [NSNumber numberWithDouble:coordinate.latitude],@"latitude",
                              [NSNumber numberWithDouble:coordinate.longitude],@"longitude",nil];
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:json_dic options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender* http = [[HttpSender alloc]initWithDelegate:self];
    [http sendMessage:jsonData withOperationCode:GET_NEARBY_FRIENDS finshedBlock:getNearbyFriendsDone];
    NSLog(@"doing getNearbyFriends, json: %@",json_dic);
}

-(void)getKanKan
{
    void (^getKanKanDone)(NSData*) = ^(NSData* rData)
    {
        NSString* temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
        NSLog(@"get kankan done, received Data: %@",temp);
        NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
        NSNumber* cmd = [response1 objectForKey:@"cmd"];
        if ([cmd integerValue] == 100) {
            kankan_arr = [response1 objectForKey:@"friend_list"];
            [kankan_tableview reloadData];
        }
    };
    NSDictionary* jsonDic = [CommonUtils packParamsInDictionary:[MTUser sharedInstance].userid, @"id",nil];
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:jsonDic options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender* http = [[HttpSender alloc]initWithDelegate:self];
    [http sendMessage:jsonData withOperationCode:KANKAN finshedBlock:getKanKanDone];
    NSLog(@"doing getKanKan, json: %@",jsonDic);
}

//返回两个坐标（coordinateA和coordinateB)之间的距离(单位：m)
-(double)getDistanceWithCoordinateA:(CLLocationCoordinate2D)coordinateA andCoordinateB:(CLLocationCoordinate2D)coordinateB
{
    double EARTH_RADIUS = 6371.393 * 1000.0;
    double PI = 3.141592654;
    double distance = EARTH_RADIUS * acos(cos(coordinateA.latitude * PI / 180.0) * cos(coordinateB.latitude * PI / 180.0) *
                                          cos(coordinateA.longitude * PI / 180.0 - coordinateB.longitude * PI / 180.0) +
                                          sin(coordinateA.latitude * PI / 180.0) * sin(coordinateB.latitude * PI / 180.0));
    return distance;
}

-(void)addFriendBtnClicked:(UIButton*)sender
{
    selectedFriendID = [NSNumber numberWithInteger:sender.tag];
    [self performSegueWithIdentifier:@"friendRecommend_addFriend" sender:self];
    
}

#pragma mark - HttpSenderDelegate
//- (void)finishWithReceivedData:(NSData *)rData
//{
//    NSString* temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
//    NSLog(@"Received Data: %@",temp);
//    NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
//    NSNumber* cmd = [response1 objectForKey:@"cmd"];
//    NSLog(@"cmd: %@",cmd);
//    switch ([cmd integerValue]) {
//    }
//}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == contacts_tableview) {
        return contacts_arr.count;
    }
    else if (tableView == self.nearbyFriends_tableview)
    {
        return nearbyFriends_arr.count;
    }
    else if (tableView == self.kankan_tableview)
    {
        return kankan_arr.count;
    }
    return 0;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIColor* bgColor = [UIColor colorWithRed:0.949 green:0.949 blue:0.949 alpha:1];
    UIColor* seperatorColor = [UIColor colorWithRed:0.913 green:0.913 blue:0.913 alpha:1];
    
    if (tableView == contacts_tableview) {
        ContactsRecommendTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"ContactsRecommendTableViewCell"];
        if (nil == cell) {
            cell = [[ContactsRecommendTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ContactsRecommendTableViewCell"];
            
        }
    }
    else if (tableView == nearbyFriends_tableview)
    {
        SearchedFriendTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"searchedfriendcell"];
        if (nil == cell) {
            cell = [[SearchedFriendTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"searchedfriendcell"];
        }
        NSMutableDictionary* friend = [nearbyFriends_arr objectAtIndex:indexPath.row];
        NSNumber* fid = [friend objectForKey:@"id"];
        NSNumber* latitude = [friend objectForKey:@"latitude"];
        NSNumber* longitude = [friend objectForKey:@"longitude"];
        NSString* fname = [friend objectForKey:@"name"];
        NSNumber* gender = [friend objectForKey:@"gender"];
        NSNumber* isFriend = [friend objectForKey:@"isFriend"];
        NSLog(@"is friend: %@",isFriend);
        CLLocationCoordinate2D fcoordinate;
        fcoordinate.latitude = [latitude doubleValue];
        fcoordinate.longitude = [longitude doubleValue];
//        double distance = [self getDistanceWithCoordinateA:coordinate andCoordinateB:fcoordinate];
        double distance = [CommonUtils GetDistance:coordinate.latitude lng1:coordinate.longitude lat2:fcoordinate.latitude lng2:fcoordinate.longitude];
        cell.friendNameLabel.text = fname;
        if (distance / 1000.0 >= 1) {
            cell.location_label.text = [NSString stringWithFormat:@"%.2f公里 以内", distance / 1000.0];
        }
        else
        {
            cell.location_label.text = [NSString stringWithFormat:@"%.2f米 以内", distance];
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
        if (gender == 0) {
            cell.gender_imageview.image = [UIImage imageNamed:@"女icon"];
        }
        else{
            cell.gender_imageview.image = [UIImage imageNamed:@"男icon"];
        }
        [cell.contentView addSubview:cell.gender_imageview];
        
        if ([isFriend intValue] == 0) {
            cell.theLabel.hidden = YES;
            cell.add_button.hidden = NO;
        }
        else{
            cell.theLabel.hidden = NO;
            cell.add_button.hidden = YES;
        }
        
        cell.add_button.tag = [fid integerValue];
        [cell.add_button addTarget:self action:@selector(addFriendBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        
        [cell setBackgroundColor:bgColor];
        
        if (!cell.cellSeperator) {
            cell.cellSeperator = [[UIView alloc]initWithFrame:CGRectMake(0, cell.frame.size.height - 1, cell.frame.size.width, 1)];
            [cell.cellSeperator setBackgroundColor:[UIColor lightGrayColor]];
            [cell.contentView addSubview:cell.cellSeperator];
        }
        
        return cell;
    }
    else if (tableView == kankan_tableview)
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
        if (gender == 0) {
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
        
//        UIColor* seperatorColor = [UIColor colorWithRed:0.913 green:0.913 blue:0.913 alpha:1];
        [cell setBackgroundColor:bgColor];
        
        if (!cell.cellSeperator) {
            cell.cellSeperator = [[UIView alloc]initWithFrame:CGRectMake(0, cell.frame.size.height - 1, cell.frame.size.width, 1)];
            [cell.cellSeperator setBackgroundColor:seperatorColor];
            [cell.contentView addSubview:cell.cellSeperator];
        }

        return cell;
        
    }
    return nil;
}



#pragma mark - Touches
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
//    NSLog(@"touches begin");
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

#pragma mark BaiDuMap Location Service Delegate
- (void)didUpdateUserLocation:(BMKUserLocation *)userLocation
{
    //cclocat
    coordinate = userLocation.location.coordinate;
    NSLog(@"%f   %f",coordinate.latitude,coordinate.longitude);
    [locationService stopUserLocationService];
    [self getNearbyFriends];
}


#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
//    NSLog(@"scroll begin drag");
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView    // any offset changes
{
//    NSLog(@"scroll did scroll");
    if (scrollView == self.tabbar_scrollview) {
        ;
    }
    else if(scrollView == self.content_scrollview)
    {
        if (clickTab) {
            return;
        }
        CGFloat page_width = scrollView.frame.size.width;
        NSInteger last_tab_index = tab_index;
        tab_index = floor((scrollView.contentOffset.x - page_width/2) / page_width) +1;
        
        UIButton* lastBtn = (UIButton*)[tab_arr objectAtIndex:last_tab_index];
        UIButton* currentBtn = (UIButton*)[tab_arr objectAtIndex:tab_index];
        
        lastBtn.selected = NO;
        currentBtn.selected = YES;
        
        CGRect frame = CGRectMake(currentBtn.frame.origin.x + 10, tabIndicator_view.frame.origin.y, tabIndicator_view.frame.size.width, tabIndicator_view.frame.size.height);
        [self scrollTabIndicator:frame];
        if (tab_index == 1) {
            NSThread* locate = [[NSThread alloc]initWithTarget:locationService selector:@selector(startUserLocationService) object:nil];
            [locate start];
        }
        
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    clickTab = NO;
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 119) {
        if (buttonIndex == 0) //cancel button
        {
            
        }
        else if (buttonIndex == 1)
        {
            NSString* phone = [alertView textFieldAtIndex:0].text;
            if ([phone isEqualToString:@""]) {
                [CommonUtils showSimpleAlertViewWithTitle:@"温馨提示" WithMessage:@"您不可以绑定一个空号哦" WithDelegate:self WithCancelTitle:@"确定"];
            }
            else
            {
                NSUserDefaults* userDf = [NSUserDefaults standardUserDefaults];
                NSString* key = [NSString stringWithFormat:@"USER%@",[MTUser sharedInstance].userid];
                NSMutableDictionary* userSettings = [[NSMutableDictionary alloc]initWithDictionary:[userDf objectForKey:key]];
                [userSettings setValue:phone forKey:@"userPhoneNumber"];
                [userSettings setValue:[NSNumber numberWithBool:YES] forKey:@"hasUploadPhoneNumber"];
                [userDf setObject:userSettings forKey:key];
                [userDf synchronize];
                NSLog(@"user settings : %@",userSettings);
                
                [self getPeopleInContact];
                NSMutableArray* phoneNums = [self getFriendsPhoneNumber];
                NSLog(@"phone numbers: %@", phoneNums);
                
                void (^uploadContactsDone)(NSData*) = ^(NSData *rData)
                {
                    NSString* temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
                    NSLog(@"upload contact done, received Data: %@",temp);
                    NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
                    NSNumber* cmd = [response1 objectForKey:@"cmd"];
                    if ([cmd integerValue] == 100)
                    {
                        contacts_arr = [response1 objectForKey:@"friend_list"];
                        [contacts_tableview reloadData];
                    }

                };
                NSDictionary* jsonDic = [CommonUtils packParamsInDictionary:
                                         [MTUser sharedInstance].userid, @"id",
                                         phone, @"my_phone_number",
                                         phoneNums, @"friends_phone",nil];
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDic options:NSJSONWritingPrettyPrinted error:nil];
                HttpSender* http = [[HttpSender alloc]initWithDelegate:self];
                [http sendMessage:jsonData withOperationCode:UPLOAD_PHONEBOOK finshedBlock:uploadContactsDone];
                self.noUpload_view.hidden = YES;
                self.hasUpload_view.hidden = NO;
            }
            
        }

    }
}



@end
