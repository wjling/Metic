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
@synthesize friendList;
@synthesize sortedFriendDic;
@synthesize sectionArray;
@synthesize sectionTitlesArray;
@synthesize searchFriendList;
@synthesize searchFriendKeyWordRangeArr;
@synthesize DB;
@synthesize addFriendBtn;
@synthesize friendTableView;
@synthesize friendSearchBar;
@synthesize friendSearchDisplayController;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [CommonUtils addLeftButton:self isFirstPage:YES];
    //下面的if语句是为了解决iOS7上navigationbar可以和别的view重叠的问题
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0))
    {
        self.edgesForExtendedLayout= UIRectEdgeNone;
    }
    
    
    self.sectionTitlesArray = [NSMutableArray arrayWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z",@"#", nil];
    
    [self initParams];
//    [self initTableData];
//    NSLog(@"did reload friends");
//    [self.friendTableView reloadData];
}

//返回上一层
-(void)MTpopViewController{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self initTableData];
}

- (void) initParams
{
    DB_path = [NSString stringWithFormat:@"%@/db",[MTUser sharedInstance].userid];
    initialSectionForFriendList = 1;
    self.sectionArray = [[NSMutableArray alloc]init];
    self.DB = [[MySqlite alloc]init];
    self.friendTableView.delegate = self;
    self.friendTableView.dataSource = self;
//    self.friendSearchBar.delegate = self;
    self.searchFriendList = [[NSMutableArray alloc]init];
    
    friendSearchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, 320, 40)];
    friendSearchBar.delegate = self;
    [friendSearchBar setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [friendSearchBar sizeToFit];
    [self.view addSubview:friendSearchBar];
    
    friendSearchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:friendSearchBar contentsController:self];
    self.friendSearchDisplayController.delegate = self;
    self.friendSearchDisplayController.searchResultsDelegate = self;
    self.friendSearchDisplayController.searchResultsDataSource = self;
    self.friendSearchDisplayController.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//    self.searchDisplayController.delegate = self;
//    self.searchDisplayController.searchResultsDelegate = self;
//    self.searchDisplayController.searchResultsDataSource = self;
    
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


-(void)getRangesOfText:(NSString*)text withKeyWord:(NSString*)keyWord
{
    NSMutableArray* ranges_arr = [[NSMutableArray alloc]init];
//    NSMutableArray* textChar_arr = [[NSMutableArray alloc]init];
    NSMutableArray* textCharRange_arr = [[NSMutableArray alloc]init];
    NSInteger location = 0;
    NSString* temp_text_head = [CommonUtils pinyinHeadFromNSString:text];
    NSLog(@"PINYIN head: %@",temp_text_head);
    NSRange range_head = [temp_text_head rangeOfString:keyWord options:NSCaseInsensitiveSearch];
    if (range_head.length > 0) {
        NSValue* value = [NSValue valueWithRange:range_head];
        [ranges_arr addObject:value];
        NSLog(@"colored range1: (%d,%d)",[value rangeValue].location,[value rangeValue].length);
    }
    else
    {
        NSString* temp_text_all = [CommonUtils pinyinFromNSString:text];
        NSInteger checkStringEnd = 0;
        NSLog(@"PINYIN all: %@",temp_text_all);
        for (NSInteger i = 0; i < text.length; i++) {
            NSString* char_str = [CommonUtils pinyinFromNSString:[text substringWithRange:NSMakeRange(i, 1)]];
            NSValue* value = [NSValue valueWithRange:NSMakeRange(location, char_str.length)];
            [textCharRange_arr addObject:value];
            location = location + char_str.length;
        }
        NSRange range_all = [temp_text_all rangeOfString:keyWord options:NSCaseInsensitiveSearch];
//        NSInteger range_all_begin = range_all.location;
        NSInteger range_all_end = range_all.length + range_all.location - 1;
        NSLog(@"temp_text_all range2: (%d,%d)",range_all.location,range_all.length);
        NSInteger begin = -1, end = -1;
        BOOL beginSet = NO;
        for (NSInteger i = 0; i < textCharRange_arr.count; i++) {
            NSRange range = [textCharRange_arr[i] rangeValue];
            if (!beginSet) {
                if (checkStringEnd <= range_all.location && range_all.location < checkStringEnd + range.length) {
                    begin = i;
                    beginSet = YES;
                }
//                else if (range.location == range_all.location)
//                {
//                    begin = i;
//                    beginSet = YES;
//                }
            }
            else
            {
                if (checkStringEnd <= range_all_end && range_all_end < checkStringEnd + range.length) {
                    end = i;
                    break;
                }
                else if (checkStringEnd > range_all_end)
                {
                    end = i - 1;
                    break;
                }
            }
            checkStringEnd += range.length;
            
        }
//        if (end == -1) {
//            end = textCharRange_arr.count - 1;
//        }
        NSLog(@"colored begin: %d, end: %d",begin,end);
        NSValue* value = [NSValue valueWithRange:NSMakeRange(begin, end - begin + 1)];
        [ranges_arr addObject:value];
        NSLog(@"colored range2: (%d,%d)",[value rangeValue].location,[value rangeValue].length);

    }
    [self.searchFriendKeyWordRangeArr addObject:ranges_arr];
    
    
}

- (IBAction)switchToAddFriendView:(id)sender
{
    
}

#pragma mark - UITableViewDelegate
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    
//}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView == friendTableView) {
        if (section < initialSectionForFriendList) {
            return 0;
        }
        return 23;
    }
    else
    {
        return 0;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSInteger section = indexPath.section;
//    NSInteger row = indexPath.row;
//    NSArray* groupOfFriends = [sortedFriendDic objectForKey:(NSString*)[self.sectionArray objectAtIndex:section]];
//    NSDictionary* aFriend = [groupOfFriends objectAtIndex:row];
//    selectedFriendID = [aFriend objectForKey:@"id"];
//    NSLog(@"get1 fid value: %@",selectedFriendID);
    if (tableView == self.friendSearchDisplayController.searchResultsTableView) {
        [self.friendSearchDisplayController setActive:NO animated:YES];
        NSMutableDictionary* aFriend = [searchFriendList objectAtIndex:indexPath.row];
        NSString* fname = [aFriend objectForKey:@"name"];
        NSString* fname_head = [CommonUtils pinyinHeadFromNSString:[fname substringToIndex:1]].uppercaseString;
        NSLog(@"fname head: %@",fname_head);
        NSInteger section = [sectionArray indexOfObject:fname_head];
        NSInteger row;
        NSMutableArray* friends = [sortedFriendDic objectForKey:fname_head];
        for (NSInteger i = 0; i < friends.count; i++) {
            NSMutableDictionary* friend = [friends objectAtIndex:i];
            NSString* name = [friend objectForKey:@"name"];
            if ([name isEqualToString:fname]) {
                row = i;
                break;
            }
        }
        NSIndexPath* indexP = [NSIndexPath indexPathForRow:row inSection:section];
        [self.friendTableView scrollToRowAtIndexPath:indexP atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    else if (tableView == self.friendTableView)
    {
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
                [self performSegueWithIdentifier:@"friendCenter_friendRecommendation" sender:self];
            }
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (tableView == friendTableView) {
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
    }
    else if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        
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
    if (tableView == friendTableView) {
        NSArray* groupOfFriends = [sortedFriendDic objectForKey:(NSString*)[sectionArray objectAtIndex:section]];
        if (groupOfFriends) {
            return groupOfFriends.count;
        }
        else
            return 0;
    }
    else if (tableView == self.friendSearchDisplayController.searchResultsTableView)
    {
        return searchFriendList.count;
    }
    else
    {
        return 0;
    }
//    return groupOfFriends.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == friendTableView) {
        return sectionArray.count;
    }
//    else if (tableView == searchDisplayController.searchResultsTableView)
//    {
//        return 0;
//    }
    else{
        return 1;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (tableView == friendTableView) {
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
    }
    else if (tableView == self.friendSearchDisplayController.searchResultsTableView)
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"] ;
        }
        NSMutableDictionary* friend_dic = [searchFriendList objectAtIndex:row];
        NSString* name = [friend_dic objectForKey:@"name"];
        NSNumber* fid = [friend_dic objectForKey:@"id"];
//        for(UIView * elem in [cell.contentView subviews])
//        {
//            if([elem isKindOfClass:[BDSuggestLabel class]])
//            {
//                NSLog(@"remove");
//                [elem removeFromSuperview];
//            }
//        }
//        BDSuggestLabel * richTextLabel = [[BDSuggestLabel alloc] initWithFrame:CGRectMake(10, 10, 300, 25)];
//        richTextLabel.text = [friend_dic objectForKey:@"name"];
//        richTextLabel.keyWord = friendSearchBar.text;//设置当前搜索的关键字
//        richTextLabel.backgroundColor = [UIColor clearColor];
//        richTextLabel.font = [UIFont systemFontOfSize:17.0f];
//        richTextLabel.textColor = [UIColor grayColor];
//        [cell.contentView addSubview:richTextLabel];
        UIColor *color = [UIColor colorWithRed:0.29 green:0.76 blue:0.61 alpha:1];
        NSMutableAttributedString* attrStr = [[NSMutableAttributedString alloc]initWithString:name];
        NSMutableArray* rangeArr = [self.searchFriendKeyWordRangeArr objectAtIndex:indexPath.row];
        for (NSInteger i = 0; i < rangeArr.count; i++) {
            NSRange range = [[rangeArr objectAtIndex:i] rangeValue];
            [attrStr addAttribute:(NSString *)kCTForegroundColorAttributeName
                            value:(id)color.CGColor
                            range:range];

        }
        [attrStr addAttribute:(NSString *)kCTFontAttributeName
                        value:(id)CFBridgingRelease(CTFontCreateWithName((CFStringRef)[UIFont systemFontOfSize:15].fontName, 15, NULL))
                        range:NSMakeRange(0, name.length)];
        for(UIView * elem in [cell.contentView subviews])
        {
            if([elem isKindOfClass:[TTTAttributedLabel class]])
            {
//                NSLog(@"remove");
                [elem removeFromSuperview];
            }
        }
        
        UIImageView* imgV = (UIImageView*)[cell viewWithTag:111];
        if (!imgV) {
            imgV = [[UIImageView alloc]initWithFrame:CGRectMake(15, 5, 35, 35)];
            imgV.tag = 111;
            [cell.contentView addSubview:imgV];
        }

        TTTAttributedLabel* label = [[TTTAttributedLabel alloc]initWithFrame:CGRectMake(60, 10, 300, 30)];
        [label setText:attrStr];
        [cell.contentView addSubview:label];
        
        
        
        PhotoGetter* getter = [[PhotoGetter alloc]initWithData:imgV authorId:fid];
        [getter getPhoto];
        cell.layer.borderColor = [UIColor lightGrayColor].CGColor;
        cell.layer.borderWidth = 0.3f;
//        cell.textLabel.text = name;
//        NSLog(@"cell of searched friend, name: %@",name);
        return cell;
    }
    
    
    return nil;
    
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView == friendTableView) {
        return [self.sectionArray objectAtIndex:section];
    }
    else
    {
        return nil;
    }
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if (tableView == friendTableView) {
        return sectionTitlesArray;
    }
    else
    {
        return nil;
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    if (tableView == friendTableView) {
        NSInteger sectionIndex = [sectionArray indexOfObject:[sectionTitlesArray objectAtIndex:index]];
        return sectionIndex;
    }
    else
    {
        return index;
    }
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
    searchFriendList = [[NSMutableArray alloc]init];
    searchFriendKeyWordRangeArr = [[NSMutableArray alloc]init];
    if (friendSearchBar.text.length>0&&![CommonUtils isIncludeChineseInString:friendSearchBar.text]) {
        for (int i=0; i<friendList.count; i++) {
            NSMutableDictionary* aFriend = [friendList objectAtIndex:i];
            NSString* fname = [aFriend objectForKey:@"name"];
            if ([CommonUtils isIncludeChineseInString:fname]) {
                NSString *tempPinYinStr = [CommonUtils pinyinFromNSString:fname];
                NSRange titleResult=[tempPinYinStr rangeOfString:friendSearchBar.text options:NSCaseInsensitiveSearch];
                if (titleResult.length>0) {
                    [searchFriendList addObject:friendList[i]];
                    [self getRangesOfText:fname withKeyWord:friendSearchBar.text];
                }
                else
                {
                    NSString *tempPinYinHeadStr = [CommonUtils pinyinHeadFromNSString:fname];
                    NSRange titleHeadResult=[tempPinYinHeadStr rangeOfString:friendSearchBar.text options:NSCaseInsensitiveSearch];
                    if (titleHeadResult.length>0) {
                        [searchFriendList addObject:friendList[i]];
                        [self getRangesOfText:fname withKeyWord:friendSearchBar.text];
                    }

                }
            }
            else {
                NSRange titleResult=[fname rangeOfString:friendSearchBar.text options:NSCaseInsensitiveSearch];
                if (titleResult.length>0) {
                    [searchFriendList addObject:friendList[i]];
                    [self getRangesOfText:fname withKeyWord:friendSearchBar.text];
                }
            }
        }
    } else if (friendSearchBar.text.length>0&&[CommonUtils isIncludeChineseInString:friendSearchBar.text]) {
        for (NSMutableDictionary *tempDic in friendList) {
            NSString* fname = [tempDic objectForKey:@"name"];
            NSRange titleResult=[fname rangeOfString:friendSearchBar.text options:NSCaseInsensitiveSearch];
            if (titleResult.length>0) {
                [searchFriendList addObject:tempDic];
                [self getRangesOfText:fname withKeyWord:friendSearchBar.text];
            }
        }
    }
//    NSLog(@"search friend list: %@",searchFriendList);

}

#pragma mark - UISearchDisplayDelegate
- (void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller{
	/*
     Bob: Because the searchResultsTableView will be released and allocated automatically, so each time we start to begin search, we set its delegate here.
     */
//	[friendSearchDisplayController.searchResultsTableView setDelegate:self];
//    [friendSearchDisplayController.searchResultsTableView setDataSource:self];
    
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
