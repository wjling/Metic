//
//  FriendsViewController.m
//  SlideMenu
//
//  Created by Aryan Ghassemi on 12/31/13.
//  Copyright (c) 2013 Aryan Ghassemi. All rights reserved.
//

#import "FriendsViewController.h"



//#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
//if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
//{
//    self.edgesForExtendedLayout = UIRectEdgeNone;
//    self.extendedLayoutIncludesOpaqueBars = NO;
//    self.modalPresentationCapturesStatusBarAppearance = NO;
//}
//#endif
@implementation FriendsViewController
{
    NSString* DB_path;
    NSInteger initialSectionForFriendList;
    NSNumber* selectedFriendID;
}
@synthesize user;
@synthesize friendList;
@synthesize sortedFriendDic;
@synthesize sectionArray;
@synthesize sectionTitlesArray;
@synthesize searchFriendList;
@synthesize DB;
@synthesize addFriendBtn;
@synthesize friendTableView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    //下面的if语句是为了解决iOS7上navigationbar可以和别的view重叠的问题
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0))
    {
        self.edgesForExtendedLayout= UIRectEdgeNone;
    }
    
    
    self.sectionTitlesArray = [NSMutableArray arrayWithObjects:@"★",@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z",@"#", nil];
    
    
    [self initParams];
//    [self initTableData];
//    NSLog(@"did reload friends");
//    [self.friendTableView reloadData];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self initTableData];
}

- (void) initParams
{
    self.user = [MTUser sharedInstance];
    DB_path = [NSString stringWithFormat:@"%@/db",user.userid];
    initialSectionForFriendList = 1;
    self.sectionArray = [[NSMutableArray alloc]init];
    self.DB = [[MySqlite alloc]init];
    self.friendTableView.delegate = self;
    self.friendTableView.dataSource = self;
    self.friendSearchBar.delegate = self;
    
//    UIImage* img = [[UIImage imageNamed:@"添加好友icon.png"] stretchableImageWithLeftCapWidth:3 topCapHeight: 3];
//    [self.addFriendBtn setBackButtonBackgroundImage:img forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
}

- (void)initTableData
{
    self.friendList = [[MTUser sharedInstance] friendList];
    if (!self.friendList.count) {
        while([MTUser sharedInstance].sortedFriendDic.count == 0) {
             [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }
    }
    NSLog(@"table data init done");
    self.sortedFriendDic = [[MTUser sharedInstance] sortedFriendDic];
    self.sectionArray = [[MTUser sharedInstance] sectionArray];
//    NSLog(@"friendviewcontroller: friendList count: %d\n, sortedFriendDic: %@, sectionArray: %@",self.friendList.count, self.sortedFriendDic, self.sectionArray);
    [self.friendTableView reloadData];
    


}


- (IBAction)search_friends:(id)sender
{
//    NSString* text = self.friendSearchBar.text;
//    if ([CommonUtils isEmailValid:text]) {
//        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
//        dictionary = [CommonUtils packParamsInDictionary:text,@"email",nil];
//        NSLog(@"%@",dictionary);
//        
//        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
//        HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
//        [httpSender sendMessage:jsonData withOperationCode:SEARCH_FRIEND];
//    }
//    else
//    {
//        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
//        dictionary = [CommonUtils packParamsInDictionary:text,@"name",nil];
//        NSLog(@"%@",dictionary);
//        
//        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
//        HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
//        [httpSender sendMessage:jsonData withOperationCode:SEARCH_FRIEND];;
//    }
}


- (IBAction)switchToAddFriendView:(id)sender
{
    
}

#pragma mark - UITableViewDelegate


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat height = 25;
    
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSInteger section = indexPath.section;
//    NSInteger row = indexPath.row;
//    NSArray* groupOfFriends = [sortedFriendDic objectForKey:(NSString*)[self.sectionArray objectAtIndex:section]];
//    NSDictionary* aFriend = [groupOfFriends objectAtIndex:row];
//    selectedFriendID = [aFriend objectForKey:@"id"];
//    NSLog(@"get1 fid value: %@",selectedFriendID);
    
    
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    NSArray* groupOfFriends = [sortedFriendDic objectForKey:(NSString*)[self.sectionArray objectAtIndex:section]];
    NSDictionary* aFriend = [groupOfFriends objectAtIndex:row];
    NSLog(@"afriend: %@",aFriend);
    selectedFriendID = [CommonUtils NSNumberWithNSString:[aFriend objectForKey:@"id"]];
//    selectedFriendID = [aFriend objectForKey:@"id"];
    if ([selectedFriendID isKindOfClass:[NSString class]]) {
        NSLog(@"NSString fid value: %@",selectedFriendID);
    }
    else if([selectedFriendID isKindOfClass:[NSNumber class]])
    {
        NSLog(@"NSNumber fid value: %@",selectedFriendID);
    }
    
    return indexPath;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[FriendInfoViewController class]]) {
        FriendInfoViewController* viewController = (FriendInfoViewController*)segue.destinationViewController;
//        NSLog(@"pass fid value: %@",selectedFriendID);
        
        viewController.fid = selectedFriendID;
    }
    
    
}
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    if (0 == section) {
//        FriendTableViewCell *header = [[FriendTableViewCell alloc]init];
//        header.avatar.image = [UIImage imageNamed:@"默认用户头像"];
//        header.title.text = @"消息中心";
//        return header;
//    }
//    return nil;
//}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray* groupOfFriends = [sortedFriendDic objectForKey:(NSString*)[sectionArray objectAtIndex:section]];
    if (groupOfFriends) {
        return groupOfFriends.count;
    }
    else
        return 0;
//    return groupOfFriends.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return sectionArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    NSArray* groupOfFriends = [sortedFriendDic objectForKey:(NSString*)[self.sectionArray objectAtIndex:section]];
    if (groupOfFriends) {
    NSDictionary* aFriend = [groupOfFriends objectAtIndex:row];
    NSString* label = [aFriend objectForKey:@"name"];
    NSNumber* fid = [aFriend objectForKey:@"id"];
    
        
    
    if (section == 0) {
        if (row == 0)
        {
            NotificationCenterCell* cell = [self.friendTableView dequeueReusableCellWithIdentifier:@"notificationcentercell"];
            if (nil == cell) {
                cell = [[NotificationCenterCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"notificationcentercell"];
            }
            cell.pic.image = [UIImage imageNamed:@"好友推荐icon.png"];
//            cell.imageView
            cell.title.text = label;
            
            return cell ;
        }
    }
    else
    {
        FriendTableViewCell* cell = [self.friendTableView dequeueReusableCellWithIdentifier:@"friendcell"];
        if (nil == cell) {
            cell = [[FriendTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"friendcell"];
        }

        PhotoGetter* getter = [[PhotoGetter alloc]initWithData:cell.avatar authorId:fid];
        [getter getPhoto];
        
        if (label) {
            cell.title.text = label;
        }
        else
        {
            cell.title.text = @"default";
        }
        return cell;
    }
        
    }
    
    return nil;
    
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.sectionArray objectAtIndex:section];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return sectionTitlesArray;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    NSInteger sectionIndex = [sectionArray indexOfObject:[sectionTitlesArray objectAtIndex:index]];
    return sectionIndex;
}

#pragma mark - UISearchBarDelegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar                     // return NO to not become first responder
{
    return YES;
}
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar                     // called when text starts editing
{
    
}
- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar                        // return NO to not resign first responder
{
    return YES;
}
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar                       // called when text ends editing
{
    
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText   // called when text changes (including clear)
{
    
}

//- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar                    // called when cancel button pressed
//{
//    [searchBar resignFirstResponder];
//}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar                     // called when keyboard search button pressed
{
//    [self search_friends];
    [searchBar resignFirstResponder];
//    [self.friendTableView reloadData];
}


#pragma mark - HttpSenderDelegate
- (void)finishWithReceivedData:(NSData *)rData
{
    NSString* temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
    NSLog(@"Received Data: %@",temp);
    NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
    NSNumber* cmd = [response1 objectForKey:@"cmd"];
    NSLog(@"cmd: %@",cmd);
//    if (cmd) {
//        if ([cmd intValue] == NORMAL_REPLY) {
//            NSMutableArray* tempFriends = [response1 valueForKey:@"friend_list"];
//            if (tempFriends.count) {
//                self.friendList = tempFriends;
//                self.sortedFriendDic = [self sortFriendList];
////                [self insertToFriendTable:tempFriends];
//                NSThread* thread = [[NSThread alloc]initWithTarget:self selector:@selector(insertToFriendTable:) object:tempFriends];
//                
//                [thread start];
//                
//            }
//            else
//            {
//                NSLog(@"好友列表已经是最新的啦～");
//                self.friendList = [self getFriendsFromDB];
//                self.sortedFriendDic = [self sortFriendList];
//
//            }
//            NSLog(@"synchronize friends: %@",friendList);
//            
//        }
//        else
//        {
//            NSLog(@"synchronize friends failed");
//        }
//    }
//    else
//    {
//        NSLog(@"server error");
//    }
//    
//    [self.friendTableView reloadData];
}

#pragma mark - SlideNavigationControllerDelegate
- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
	return YES;
}

- (BOOL)slideNavigationControllerShouldDisplayRightMenu
{
	return NO;
}

-(void)sendDistance:(float)distance
{
    if (distance > 0) {
        self.shadowView.hidden = NO;
        [self.view bringSubviewToFront:self.shadowView];
        [self.shadowView setAlpha:distance/400.0];
    }else{
        self.shadowView.hidden = YES;
        [self.view sendSubviewToBack:self.shadowView];
    }
}


@end
