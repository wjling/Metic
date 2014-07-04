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
@synthesize searchFriendList;
@synthesize DB;
@synthesize addFriendBtn;

- (void)viewDidLoad
{
    [super viewDidLoad];
    //下面的if语句是为了解决iOS7上navigationbar可以和别的view重叠的问题
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0))
    {
        self.edgesForExtendedLayout= UIRectEdgeNone;
    }
    
    
//    self.sectionArray = [NSArray arrayWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z", nil];
    
    
    [self initParams];
//    [self createFriendTable];
//    NSThread* thread = [[NSThread alloc]initWithTarget:self selector:@selector(initTable) object:nil];
//    [thread start];
//    [self initTable];
    [self synchronize_friends];
//    NSLog(@"did reload friends");
//    [self.friendTableView reloadData];
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

- (void)initTable
{
    self.friendList = [self getFriendsFromDB];
    self.sortedFriendDic = [self sortFriendList];
    [self.friendTableView reloadData];
//    NSLog(@"table reloaded");

}

- (void)synchronize_friends
{
    NSNumber* userId = self.user.userid;
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    NSMutableArray* tempFriends = [self getFriendsFromDB];
    [dictionary setValue:userId forKey:@"id"];
    [dictionary setValue:[NSNumber numberWithInt:tempFriends.count] forKey:@"friends_number"];
//    NSLog(@"%@",dictionary);
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:SYNCHRONIZE_FRIEND];

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

-(void) createFriendTable
{
    [self.DB openMyDB:DB_path];
    [self.DB createTableWithTableName:@"friend" andIndexWithProperties:@"id INTEGER PRIMARY KEY UNIQUE",@"name",@"email",@"gender",nil];
    [self.DB closeMyDB];
}

- (void) insertToFriendTable:(NSArray *)friends
{
//    NSString* path = [NSString stringWithFormat:@"%@/db",user.userid];
    [self.DB openMyDB:DB_path];
    for (NSDictionary* friend in friends) {
        NSString* friendEmail = [friend objectForKey:@"email"];
        NSNumber* friendID = [friend objectForKey:@"id"];
        NSNumber* friendGender = [friend objectForKey:@"gender"];
        NSString* friendName = [friend objectForKey:@"name"];
        
//        NSLog(@"email: %@, id: %@, gender: %@, name: %@",friendEmail,friendID,friendGender,friendName);
        
        NSArray* columns = [[NSArray alloc]initWithObjects:@"'id'",@"'name'",@"'email'",@"'gender'", nil];
        NSArray* values = [[NSArray alloc]initWithObjects:
                           [NSString stringWithFormat:@"%@",[CommonUtils NSStringWithNSNumber:friendID]],
                           [NSString stringWithFormat:@"'%@'",friendName],
                           [NSString stringWithFormat:@"'%@'",friendEmail],
                           [NSString stringWithFormat:@"%@",[CommonUtils NSStringWithNSNumber:friendGender]], nil];
        [self.DB insertToTable:@"friend" withColumns:columns andValues:values];
    }
    [self.DB closeMyDB];

    NSLog(@"好友列表更新完成！");
}

- (NSMutableArray*)getFriendsFromDB
{
    NSMutableArray* friends;
    [self.DB openMyDB:DB_path];
    friends = [self.DB queryTable:@"friend" withSelect:[[NSArray alloc]initWithObjects:@"*", nil] andWhere:nil];
    [self.DB closeMyDB];
    return friends;
}

- (NSMutableDictionary*)sortFriendList
{
    NSMutableDictionary* sorted = [[NSMutableDictionary alloc]init];
//    NSLog(@"friendlist count: %d",friendList.count);
    for (NSMutableDictionary* aFriend in self.friendList) {
        NSString* fname_py = [CommonUtils pinyinFromNSString:[aFriend objectForKey:@"name"]];
//        NSLog(@"friend name: %@",fname_py);
        NSString* first_letter = [fname_py substringWithRange:NSMakeRange(0, 1)];
        NSMutableArray* groupOfFriends = [sorted objectForKey:[first_letter uppercaseString]];
        
        if (groupOfFriends) {
            [groupOfFriends addObject:aFriend];
//            NSLog(@"a friend: %@",aFriend);
        }
        else
        {
            groupOfFriends = [[NSMutableArray alloc]init];
            [groupOfFriends addObject:aFriend];
            [sorted setObject:groupOfFriends forKey:[first_letter uppercaseString]];
            [self.sectionArray addObject:[first_letter uppercaseString]];
        }
    }
   
    for (NSString* key in sorted) {
        NSMutableArray* arr = [sorted objectForKey:key];
        [self rankFriendsInArray:arr];
//        NSLog(@"sorted array: %@",arr);
    }
    [self.sectionArray sortUsingComparator:^(id obj1, id obj2)
     {
         return [(NSString*)obj1 compare:(NSString*)obj2];
     }];
    
    NSDictionary* temp_dic = [[NSDictionary alloc]initWithObjectsAndKeys:@"好友推荐",@"name", nil];
    NSArray* temp_arr = [[NSArray alloc]initWithObjects:temp_dic, nil];
    [sorted setObject:temp_arr forKey:@"🍎"];
    
    [sectionArray insertObject:@"🍎" atIndex:0];
    NSLog(@"sorted friends dictionary: %@",sorted);
    NSLog(@"section array: %@",self.sectionArray);
    return sorted;
}

- (void)rankFriendsInArray:(NSMutableArray*)friends
{
    NSComparator cmptor = ^(id obj1, id obj2)
    {
        NSString* obj1_py = [[CommonUtils pinyinFromNSString:(NSString*)[obj1 objectForKey:@"name"]] uppercaseString];
        NSString* obj2_py = [[CommonUtils pinyinFromNSString:(NSString*)[obj2 objectForKey:@"name"]] uppercaseString];
        int result = [obj1_py compare:obj2_py];
        return result;
    };
    [friends sortUsingComparator:cmptor];
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
    return groupOfFriends.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    NSArray* groupOfFriends = [sortedFriendDic objectForKey:(NSString*)[self.sectionArray objectAtIndex:section]];
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
    
//        NSLog(@"a friend: %@",aFriend);
    

        cell.avatar.image = [UIImage imageNamed:@"默认用户头像"];
//        cell.avatar.image = [UIImage imageNamed:@"default_avatar.jpg"];
        PhotoGetter* getter = [[PhotoGetter alloc]initWithData:cell.avatar path:[NSString stringWithFormat:@"/avatar/%@.jpg",fid] type:2 cache:nil ];
        [getter setTypeOption2];
        getter.mDelegate = self;
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
    
    return nil;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return sortedFriendDic.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.sectionArray objectAtIndex:section];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return sectionArray;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return index;
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
    if (cmd) {
        if ([cmd intValue] == NORMAL_REPLY) {
            NSMutableArray* tempFriends = [response1 valueForKey:@"friend_list"];
            if (tempFriends.count) {
                self.friendList = tempFriends;
                self.sortedFriendDic = [self sortFriendList];
//                [self insertToFriendTable:tempFriends];
                NSThread* thread = [[NSThread alloc]initWithTarget:self selector:@selector(insertToFriendTable:) object:tempFriends];
                
                [thread start];
                
            }
            else
            {
                NSLog(@"好友列表已经是最新的啦～");
                self.friendList = [self getFriendsFromDB];
                self.sortedFriendDic = [self sortFriendList];

            }
            NSLog(@"synchronize friends: %@",friendList);
            
        }
        else
        {
            NSLog(@"synchronize friends failed");
        }
    }
    else
    {
        NSLog(@"server error");
    }
    
    [self.friendTableView reloadData];
}

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

#pragma mark - PhotoGetterDelegate
-(void)finishwithNotification:(UIImageView*)imageView image:(UIImage*)image type:(int)type container:(id)container
{
    imageView.image = image;
}
@end
