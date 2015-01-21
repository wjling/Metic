//
//  FriendRecommendationViewController.m
//  WeShare
//
//  Created by mac on 14-8-17.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "FriendRecommendationViewController.h"
#import "MJRefreshHeaderView.h"
#import "MJRefreshFooterView.h"

@interface FriendRecommendationViewController ()<MJRefreshBaseViewDelegate>
{
    UIView* tabIndicator_view;
//    UIButton *tab1, *tab2, *tab3;
    NSMutableArray* tab_arr;
    NSInteger tab_index;
    BOOL clickTab;
    NSNumber* selectedFriendID;
    UIActivityIndicatorView* actIndicator;
    UIView* waitingView;
}


@end

@implementation FriendRecommendationViewController
@synthesize tabbar_scrollview;
@synthesize content_scrollview;

@synthesize tab1;
@synthesize tab2;
@synthesize tab3;

@synthesize tabPage1_view;
@synthesize noUpload_view;
@synthesize addContacts_button;
@synthesize hasUpload_view;
@synthesize contacts_tableview;

@synthesize tabPage2_view;
@synthesize nearbyFriends_tableview;
@synthesize nearbyFriends_header;
@synthesize nearbyFriends_footer;

@synthesize tabPage3_view;
@synthesize kankan_tableview;

@synthesize activityIndicator;

@synthesize contacts_arr;
@synthesize locationService;
@synthesize coordinate;
@synthesize contactFriends_arr;
@synthesize nearbyFriends_arr;
@synthesize kankan_arr;
@synthesize phoneNumbers;


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
//    [CommonUtils addLeftButton:self isFirstPage:NO];
    
    
    contacts_arr = [[NSMutableArray alloc]init];
    contactFriends_arr = [[NSMutableArray alloc]init];
    nearbyFriends_arr = [[NSMutableArray alloc]init];
    kankan_arr = [[NSMutableArray alloc]init];
    
    contacts_tableview.delegate = self;
    contacts_tableview.dataSource = self;
    nearbyFriends_tableview.delegate = self;
    nearbyFriends_tableview.dataSource = self;
    kankan_tableview.delegate = self;
    kankan_tableview.dataSource = self;
    
    [self initTabBar];
    [self initContentView];
    
    

//    [locationService startUserLocationService];
    
    
}

//返回上一层
//-(void)MTpopViewController{
//    [self.navigationController popViewControllerAnimated:YES];
//}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSLog(@"friend recommendation view will appear");
    
    NSUserDefaults* userDf = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary* userSettings = [[NSMutableDictionary alloc]initWithDictionary:[userDf objectForKey:[NSString stringWithFormat:@"USER%@",[MTUser sharedInstance].userid]]];
    NSNumber* hasUploadContact = [userSettings objectForKey:@"hasUploadPhoneNumber"];
    if (![hasUploadContact boolValue]) {
        self.noUpload_view.hidden = NO;
        self.hasUpload_view.hidden = YES;
    }
    else
    {
        self.noUpload_view.hidden = YES;
        self.hasUpload_view.hidden = NO;
        [self getContactFriends];
    }


}


-(void)viewDidAppear:(BOOL)animated
{

    [super viewDidAppear:animated];

    self.tabbar_scrollview.contentSize = CGSizeMake(self.tabbar_scrollview.frame.size.width, self.content_scrollview.frame.size.height);
    waitingView.frame = CGRectMake(0, 0, self.content_scrollview.frame.size.width, self.content_scrollview.frame.size.height);
    actIndicator.center = waitingView.center;
    
    [self.content_scrollview setContentSize: CGSizeMake(960, self.content_scrollview.frame.size.height)];
}

-(void)viewDidDisappear:(BOOL)animated
{
    NSLog(@"friend recommandation viewdiddisappear");
    locationService.delegate = nil;
    [locationService stopUserLocationService];
    [super viewDidDisappear:animated];
}

-(void)dealloc
{
    [nearbyFriends_header free];
    [nearbyFriends_footer free];
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
    NSLog(@"tab_height: %f, tab_width: %f",tab_height,tab_width);
//    self.tabbar_scrollview.scrollEnabled = NO;
    self.tabbar_scrollview = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    [self.view addSubview:self.tabbar_scrollview];
    [self.tabbar_scrollview setBackgroundColor:[CommonUtils colorWithValue:0xd9d9d9]];
    
    tabIndicator_view = [[UIView alloc]initWithFrame:CGRectMake(10, tab_height - 3, tab_width - 20, 3)];
    [tabIndicator_view setBackgroundColor:myGreen];
    
    
    tab1 = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, tab_width, tab_height)];
    tab2 = [[UIButton alloc]initWithFrame:CGRectMake(tab_width, 0, tab_width, tab_height)];
    tab3 = [[UIButton alloc]initWithFrame:CGRectMake(tab_width * 2, 0, tab_width, tab_height)];
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
    
    self.tabbar_scrollview.scrollEnabled = NO;
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
    
    self.nearbyFriends_header = [[MJRefreshHeaderView alloc]init];
    self.nearbyFriends_header.scrollView = self.nearbyFriends_tableview;
    self.nearbyFriends_header.delegate = self;
    
//    self.nearbyFriends_footer = [[MJRefreshFooterView alloc]init];
//    self.nearbyFriends_footer.scrollView = self.nearbyFriends_tableview;
//    self.nearbyFriends_footer.delegate = self;
    
    UIColor* waitingBgColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:0.7];
    waitingView = [[UIView alloc]init];
    waitingView.frame = CGRectMake(0, 0, self.content_scrollview.frame.size.width, self.content_scrollview.frame.size.height);
    NSLog(@"content_scrollview, width: %f, height: %f",self.content_scrollview.frame.size.width,self.content_scrollview.frame.size.height);
    [waitingView setBackgroundColor:waitingBgColor];
    [waitingView setAlpha:0.5];
    actIndicator = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(140, 180, 40, 40)];
    [waitingView addSubview:actIndicator];
    [actIndicator startAnimating];
//    [tabPage1_view addSubview:waitingView];
    
}

-(void)getPeopleInContact
{
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
    
    if (addressBook == nil) {
        return;
    }
    contacts_arr = (__bridge NSMutableArray*)ABAddressBookCopyArrayOfAllPeople(addressBook);
}

-(NSMutableArray*)getFriendsPhoneNumber
{
    NSMutableArray* tels = [[NSMutableArray alloc]init];
    if (contacts_arr) {
        for (id tmpPerson in contacts_arr) {
            ABMultiValueRef phones = ABRecordCopyValue((__bridge ABRecordRef)(tmpPerson), kABPersonPhoneProperty);
            for (NSInteger i = 0; i < ABMultiValueGetCount(phones); i++) {
                NSMutableString* phoneNumber = (__bridge NSMutableString *)(ABMultiValueCopyValueAtIndex(phones, i));
                [tels addObject:[phoneNumber stringByReplacingOccurrencesOfString:@"-" withString:@""]];
            }
        }
    }
    return tels;
}

-(void)tabClicked:(UIButton*)sender
{
//    NSLog(@"cotnent scrollview, content size: width: %f, height: %f",self.content_scrollview.contentSize.width,self.content_scrollview.contentSize.height);
    
    NSInteger index = [tab_arr indexOfObject:sender];
    if (index == tab_index) {
        clickTab = NO;
    }
    else
    {
        clickTab = YES;
    }
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
        if ([[UIDevice currentDevice].systemVersion floatValue] >= 8 && self.locationManager == nil) {
            //由于IOS8中定位的授权机制改变 需要进行手动授权
            _locationManager = [[CLLocationManager alloc] init];
            //获取授权认证
            [_locationManager requestAlwaysAuthorization];
            [_locationManager requestWhenInUseAuthorization];
        }
        locationService = [[BMKLocationService alloc]init];
        locationService.delegate = self;
//        NSThread* locate = [[NSThread alloc]initWithTarget:locationService selector:@selector(startUserLocationService) object:nil];
//        [locate start];
        
        [locationService startUserLocationService];
    }
    else if (tab_index == 2)
    {
        NSLog(@"tab 2");
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
    [self getPeopleInContact];
    phoneNumbers = [self getFriendsPhoneNumber];
    NSLog(@"phone numbers: %@", phoneNumbers);
    NSLog(@"cotnent scrollview, content size: width: %f, height: %f",self.content_scrollview.contentSize.width,self.content_scrollview.contentSize.height);
    ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
    NSLog(@"address book authorization status: %ld",status);
    if (status == kABAuthorizationStatusDenied) {
        [CommonUtils showSimpleAlertViewWithTitle:@"温馨提示" WithMessage:@"您曾经拒绝了活动宝的通讯录访问，请您在\n设置->隐私->通讯录\n里面授权活动宝获取您的通讯录内容" WithDelegate:self WithCancelTitle:@"确定"];
    }
    else
    {
        UIAlertView* alertview = [[UIAlertView alloc]initWithTitle:@"请绑定您的手机号码" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alertview.alertViewStyle = UIAlertViewStylePlainTextInput;
        alertview.delegate = self;
        alertview.tag = 119;
        [alertview show];
    }
}

-(void)getContactFriends
{
    [self getPeopleInContact];
    phoneNumbers = [self getFriendsPhoneNumber];
    NSLog(@"phone numbers: %@", phoneNumbers);
    void (^getContactFriendsDone)(NSData*) = ^(NSData* rData)
    {
        NSString* temp = @"";
        if (rData) {
            temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
        }
        else
        {
            NSLog(@"获取通讯录好友，收到的rData为空");
            UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"系统提示" message:@"服务器未响应，有可能是网络未连接" delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
            [alertView show];
            [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(dismissAlert:) userInfo:alertView repeats:NO];
            return;
        }
        NSLog(@"get contactfriends done, received Data: %@",temp);
        NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
        NSNumber* cmd = [response1 objectForKey:@"cmd"];
        if ([cmd integerValue] == 100) {
            contactFriends_arr = [response1 objectForKey:@"friend_recom"];
            NSLog(@"contact friend array: %@",contactFriends_arr);
            if (contactFriends_arr) {
                [contacts_tableview reloadData];
            }
            
        }
        [waitingView removeFromSuperview];

    };
    
    NSDictionary* json_dic = [CommonUtils packParamsInDictionary:
                              [MTUser sharedInstance].userid,@"id",
                              phoneNumbers,@"friends_phone",nil];
    NSLog(@"upload number json: %@",json_dic);
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:json_dic options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender* http = [[HttpSender alloc]initWithDelegate:self];
    [http sendMessage:jsonData withOperationCode:UPLOAD_PHONEBOOK finshedBlock:getContactFriendsDone];
    NSLog(@"doing getContactFriends, json: %@",json_dic);
    [waitingView removeFromSuperview];
    [tabPage1_view addSubview:waitingView];
    [NSTimer scheduledTimerWithTimeInterval:6.0 target:self selector:@selector(hideWaitingView) userInfo:nil repeats:NO];

}

-(void)getNearbyFriends:(void(^)()) didGetReceived
{
    void (^getNearbyFriendsDone)(NSData*) = ^(NSData* rData)
    {
        NSString* temp = @"";
        if (rData) {
            temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
        }
        else
        {
            NSLog(@"获取附近好友，收到的rData为空");
            UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"系统提示" message:@"服务器未响应，有可能是网络未连接" delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
            [alertView show];
            [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(dismissAlert:) userInfo:alertView repeats:NO];
            return;
        }
        NSLog(@"get nearbyfriends done, received Data: %@",temp);
        NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
        NSNumber* cmd = [response1 objectForKey:@"cmd"];
        if ([cmd integerValue] == 100) {
            nearbyFriends_arr = [response1 objectForKey:@"friend_list"];
            [nearbyFriends_tableview reloadData];
        }
        if (didGetReceived) {
            didGetReceived();
        }
        [waitingView removeFromSuperview];
    };
    NSDictionary* json_dic = [CommonUtils packParamsInDictionary:
                              [MTUser sharedInstance].userid,@"id",
                              [NSNumber numberWithDouble:coordinate.latitude],@"latitude",
                              [NSNumber numberWithDouble:coordinate.longitude],@"longitude",nil];
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:json_dic options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender* http = [[HttpSender alloc]initWithDelegate:self];
    [http sendMessage:jsonData withOperationCode:GET_NEARBY_FRIENDS finshedBlock:getNearbyFriendsDone];
    NSLog(@"doing getNearbyFriends, json: %@",json_dic);
    [waitingView removeFromSuperview];
    [tabPage2_view addSubview:waitingView];
    [NSTimer scheduledTimerWithTimeInterval:6.0 target:self selector:@selector(hideWaitingView) userInfo:nil repeats:NO];
}

-(void)getKanKan
{
    void (^getKanKanDone)(NSData*) = ^(NSData* rData)
    {
        NSString* temp = @"";
        if (rData) {
            temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
        }
        else
        {
            NSLog(@"获取随便看看，收到的rData为空");
            UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"系统提示" message:@"服务器未响应，有可能是网络未连接" delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
            [alertView show];
            [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(dismissAlert:) userInfo:alertView repeats:NO];
            return;
        }
        NSLog(@"get kankan done, received Data: %@",temp);
        NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
        NSNumber* cmd = [response1 objectForKey:@"cmd"];
        if ([cmd integerValue] == 100) {
            kankan_arr = [response1 objectForKey:@"friend_list"];
            [kankan_tableview reloadData];
        }
        [waitingView removeFromSuperview];
    };
    NSDictionary* jsonDic = [CommonUtils packParamsInDictionary:[MTUser sharedInstance].userid, @"id",nil];
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:jsonDic options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender* http = [[HttpSender alloc]initWithDelegate:self];
    [http sendMessage:jsonData withOperationCode:KANKAN finshedBlock:getKanKanDone];
    NSLog(@"doing getKanKan, json: %@",jsonDic);
    [waitingView removeFromSuperview];
    [tabPage3_view addSubview:waitingView];
    [NSTimer scheduledTimerWithTimeInterval:6.0 target:self selector:@selector(hideWaitingView) userInfo:nil repeats:NO];
}

-(void)dismissAlert:(NSTimer*)timer
{
    UIAlertView* alert = [timer userInfo];
    [alert dismissWithClickedButtonIndex:0 animated:YES];
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
//    UIStoryboard* main_storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
//    AddFriendConfirmViewController* vc = [main_storyboard instantiateViewControllerWithIdentifier:@"AddFriendConfirmViewController"];
//    vc.fid = selectedFriendID;
//    [self.navigationController pushViewController:vc animated:YES];
    
}

-(void)showWaitingView
{
    
}

-(void)hideWaitingView
{
    [waitingView removeFromSuperview];
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

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.contacts_tableview) {
        return contactFriends_arr.count;
    }
    else if (tableView == self.nearbyFriends_tableview)
    {
        return nearbyFriends_arr.count;
    }
    else if (tableView == self.kankan_tableview)
    {
        return kankan_arr.count;
    }
    else
    {
        return 0;
    }
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIColor* bgColor = [UIColor colorWithRed:0.949 green:0.949 blue:0.949 alpha:1];
    UIColor* seperatorColor = [UIColor colorWithRed:0.913 green:0.913 blue:0.913 alpha:1];
    
    if (tableView == contacts_tableview) {
        ContactsRecommendTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"ContactsRecommendTableViewCell" forIndexPath:indexPath];
        if (nil == cell) {
            cell = [[ContactsRecommendTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ContactsRecommendTableViewCell"];
            
        }
        NSMutableDictionary* friend = [contactFriends_arr objectAtIndex:indexPath.row];
        NSLog(@"a contact friend: %@",friend);
        NSNumber* fid = [friend valueForKey:@"id"];
        NSString* fname = [friend valueForKey:@"name"];
        NSNumber* isFriend = [friend valueForKey:@"isFriend"];
        NSLog(@"isFriend: %hhd",[isFriend boolValue]);
        cell.name_label.text = fname;
        if ([isFriend boolValue]) {
            cell.add_button.hidden = YES;
            cell.invite_button.hidden = YES;
            cell.hasAdd_label.hidden = NO;
        }
        else
        {
            cell.add_button.hidden = NO;
            cell.invite_button.hidden = YES;
            cell.hasAdd_label.hidden = YES;
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
    [self getNearbyFriends:nil];
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
        
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if (clickTab) {
        clickTab = NO;
        NSLog(@"scrollviewdidendscrollingAnimation: clicktab NO");
        return;
    }
   
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;
{
    if (scrollView == self.content_scrollview) {
        if (clickTab) {
            clickTab = NO;
            NSLog(@"scrollviewdidenddecelerating: clicktab NO");
            return;
        }
        NSLog(@"滚动停止");
        if (tab_index == 1) {
            if ([[UIDevice currentDevice].systemVersion floatValue] >= 8 && self.locationManager == nil) {
                //由于IOS8中定位的授权机制改变 需要进行手动授权
                _locationManager = [[CLLocationManager alloc] init];
                //获取授权认证
                [_locationManager requestAlwaysAuthorization];
                [_locationManager requestWhenInUseAuthorization];
            }
            NSThread* locate = [[NSThread alloc]initWithTarget:locationService selector:@selector(startUserLocationService) object:nil];
            [locate start];
        }
        else if (tab_index == 2)
        {
            [self getKanKan];
        }

    }
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
                
                void (^uploadContactsDone)(NSData*) = ^(NSData* rData)
                {
                    NSString* temp;
                    if (rData)
                    {
                        temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
                    }
                    else
                    {
                        NSLog(@"上传通讯录，收到的rData为空");
                        UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"系统提示" message:@"服务器未响应，有可能是网络未连接" delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
                        [alertView show];
                        [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(dismissAlert:) userInfo:alertView repeats:NO];
                        return;
                    }
                    NSLog(@"upload contact done, received Data: %@",temp);
                    NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
                    NSNumber* cmd = [response1 objectForKey:@"cmd"];
                    if ([cmd integerValue] == 100)
                    {
                        contactFriends_arr = [response1 objectForKey:@"friend_recom"];
                        [contacts_tableview reloadData];
                    }

                };
                NSDictionary* jsonDic = [CommonUtils packParamsInDictionary:
                                         [MTUser sharedInstance].userid, @"id",
                                         phone, @"my_phone_number",
                                         phoneNumbers, @"friends_phone",nil];
                NSLog(@"upload number json: %@",jsonDic);
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDic options:NSJSONWritingPrettyPrinted error:nil];
                HttpSender* http = [[HttpSender alloc]initWithDelegate:self];
                [http sendMessage:jsonData withOperationCode:UPLOAD_PHONEBOOK finshedBlock:uploadContactsDone];
                self.noUpload_view.hidden = YES;
                self.hasUpload_view.hidden = NO;
            }
            
        }

    }
}

#pragma mark - MJRefreshBaseViewDelegate
- (void)refreshViewBeginRefreshing:(MJRefreshBaseView *)refreshView
{
    if (refreshView == self.nearbyFriends_header) {
        [self getNearbyFriends:^{
            [refreshView endRefreshing];
        }];
    }
}


@end
