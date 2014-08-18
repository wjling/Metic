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
    UIButton *tab1, *tab2, *tab3;
    NSMutableArray* tab_arr;
    NSInteger tab_index;
    BOOL clickTab;
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
@synthesize randomFriends_tableview;

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
    nearbyFriends_arr = [[NSMutableArray alloc]init];
    kankan_arr = [[NSMutableArray alloc]init];
//    [locationService startUserLocationService];
    NSThread* locate = [[NSThread alloc]initWithTarget:locationService selector:@selector(startUserLocationService) object:nil];
    [locate start];
    
    [NSThread detachNewThreadSelector:@selector(getKanKan) toTarget:self withObject:nil];
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
//    self.tabbar_scrollview.contentSize = CGSizeMake(self.tabbar_scrollview.frame.size.width, self.content_scrollview.frame.size.height);
//    NSLog(@"friend recommendation view did appear");
//    NSLog(@"content view, width: %f, height: %f",content_scrollview.frame.size.width,content_scrollview.frame.size.height);
//    
//    NSLog(@"content size===before, width: %f, height: %f",self.content_scrollview.contentSize.width,self.content_scrollview.contentSize.height);
//    self.content_scrollview.contentSize = CGSizeMake(960, self.content_scrollview.frame.size.height);
//    NSLog(@"content size===after, width: %f, height: %f",self.content_scrollview.contentSize.width,self.content_scrollview.contentSize.height);
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

-(void)initTabBar
{
    UIColor* myGreen = [UIColor colorWithRed:0.27 green:0.80 blue:0.68 alpha:1];
    CGFloat tab_width = self.tabbar_scrollview.frame.size.width/3.0;
    CGFloat tab_height = self.tabbar_scrollview.frame.size.height - 1;
//    self.tabbar_scrollview.scrollEnabled = NO;
    [self.tabbar_scrollview setBackgroundColor:[CommonUtils colorWithValue:0xd9d9d9]];
    
    tabIndicator_view = [[UIView alloc]initWithFrame:CGRectMake(10, tab_height - 3, tab_width - 20, 3)];
    [tabIndicator_view setBackgroundColor:myGreen];
    
    
    tab1 = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, tab_width, tab_height)];
    tab2 = [[UIButton alloc]initWithFrame:CGRectMake(tab_width, 0, tab_width, tab_height)];
    tab3 = [[UIButton alloc]initWithFrame:CGRectMake(tab_width * 2, 0, tab_width, tab_height)];
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
    
    [tabbar_scrollview addSubview:tab1];
    [tabbar_scrollview addSubview:tab2];
    [tabbar_scrollview addSubview:tab3];
    [tabbar_scrollview addSubview:tabIndicator_view];
}

-(void)initContentView
{
    hasUpload_view.hidden = YES;
    self.content_scrollview.scrollEnabled = YES;
    self.content_scrollview.pagingEnabled = YES;
    self.content_scrollview.delegate = self;
    [self.addContacts_button addTarget:self action:@selector(uploadContacts:) forControlEvents:UIControlEventTouchUpInside];
    
    self.contacts_tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.nearbyFriends_tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.randomFriends_tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
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
    NSMutableArray* phoneNumbers = [[NSMutableArray alloc]init];
    if (contacts_arr) {
        for (id tmpPerson in contacts_arr) {
            ABMultiValueRef phones = ABRecordCopyValue((__bridge ABRecordRef)(tmpPerson), kABPersonPhoneProperty);
            for (NSInteger i = 0; i < ABMultiValueGetCount(phones); i++) {
                NSString* phoneNumber = (__bridge NSString *)(ABMultiValueCopyValueAtIndex(phones, i));
                [phoneNumbers addObject:phoneNumber];
            }
        }
    }
    return phoneNumbers;
}

-(void)tabClicked:(UIButton*)sender
{
    NSLog(@"cotnent scrollview, content size: width: %f, height: %f",self.content_scrollview.contentSize.width,self.content_scrollview.contentSize.height);
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
    [self getPeopleInContact];
    NSMutableArray* phoneNums = [self getFriendsPhoneNumber];
    NSLog(@"phone numbers: %@", phoneNums);
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
            
        }
    };
    NSDictionary* json_dic = [CommonUtils packParamsInDictionary:
                              [MTUser sharedInstance].userid,@"id",
                              coordinate.latitude,@"latitude",
                              coordinate.longitude,@"longitude",nil];
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:json_dic options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender* http = [[HttpSender alloc]initWithDelegate:self];
    [http sendMessage:jsonData withOperationCode:GET_NEARBY_FRIENDS finshedBlock:getNearbyFriendsDone];
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
            
        }
    };
    NSDictionary* jsonDic = [CommonUtils packParamsInDictionary:[MTUser sharedInstance].userid, @"id",nil];
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:jsonDic options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender* http = [[HttpSender alloc]initWithDelegate:self];
    [http sendMessage:jsonData withOperationCode:GET_NEARBY_FRIENDS finshedBlock:getKanKanDone];
}

#pragma mark - HttpSenderDelegate
- (void)finishWithReceivedData:(NSData *)rData
{
    NSString* temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
    NSLog(@"Received Data: %@",temp);
    NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
    NSNumber* cmd = [response1 objectForKey:@"cmd"];
    NSLog(@"cmd: %@",cmd);
    switch ([cmd integerValue]) {
    }
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
        
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    
}



@end
