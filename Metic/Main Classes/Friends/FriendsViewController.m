//  FriendsViewController.m
//  SlideMenu
//
//  Created by Aryan Ghassemi on 12/31/13.
//  Copyright (c) 2013 Aryan Ghassemi. All rights reserved.
//

#import "FriendsViewController.h"
#import "FriendRecommendationViewController.h"
#import "MenuViewController.h"
#import "MobClick.h"
#import "MTDatabaseHelper.h"
#import "SVProgressHUD.h"



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
    NSInteger initialSectionForFriendList;
    NSNumber* selectedFriendID;
}
@synthesize friendList;
@synthesize sortedFriendDic;
@synthesize sectionArray;
@synthesize sectionTitlesArray;
@synthesize searchFriendList;
@synthesize searchFriendKeyWordRangeArr;
@synthesize addFriendBtn;
@synthesize friendTableView;
@synthesize friendSearchBar;
@synthesize friendSearchDisplayController;

- (void)viewDidLoad
{
    [super viewDidLoad];
//    [[SlideNavigationController sharedInstance] setEnableSwipeGesture:NO];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(PopToHereAndTurnToNotificationPage:) name: @"PopToFirstPageAndTurnToNotificationPage" object:nil];
    NSLog(@"friendviewcontroller viewdidload");
    //下面的if语句是为了解决iOS7上navigationbar可以和别的view重叠的问题
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0))
    {
        self.edgesForExtendedLayout= UIRectEdgeNone;
    }
    
    
    self.sectionTitlesArray = [NSMutableArray arrayWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z",@"#", nil];
    
    [self initParams];
    [CommonUtils addLeftButton:self isFirstPage:YES];
}

//返回上一层
-(void)MTpopViewController{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self initTableData];
    });
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [MobClick beginLogPageView:@"好友中心"];
    [self.view bringSubviewToFront:_shadowView];
    _shadowView.hidden = NO;
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [MobClick endLogPageView:@"好友中心"];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name: @"PopToFirstPageAndTurnToNotificationPage" object:nil];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touches begin");
}

//返回本页并跳转到消息页
-(void)PopToHereAndTurnToNotificationPage:(id)sender
{
    NSLog(@"PopToHereAndTurnToNotificationPage  from  Friends");
    
    if ([[SlideNavigationController sharedInstance].viewControllers containsObject:self]){
        NSLog(@"Here");
        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"shouldIgnoreTurnToNotifiPage"]) {
            [[SlideNavigationController sharedInstance] popToViewController:self animated:NO];
            [self ToNotificationCenter];
        }
    }else{
        NSLog(@"NotHere");
    }
}

-(void)ToNotificationCenter
{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone"
                                                             bundle: nil];
    UIViewController* vc = [MenuViewController sharedInstance].notificationsViewController;
    if(!vc){
        vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"NotificationsViewController"];
        [MenuViewController sharedInstance].notificationsViewController = vc;
    }
    
    [[SlideNavigationController sharedInstance] openMenuAndSwitchToViewController:vc withCompletion:nil];
}


- (void) initParams
{
    initialSectionForFriendList = 1;
    self.friendList = [[NSMutableArray alloc]init];
    self.sortedFriendDic = [[NSMutableDictionary alloc]init];
    self.sectionArray = [[NSMutableArray alloc]init];
    self.friendTableView.delegate = self;
    self.friendTableView.dataSource = self;
    self.searchFriendList = [[NSMutableArray alloc]init];
    
    friendSearchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, 320, 40)];
    friendSearchBar.placeholder = @"本地搜索";
    friendSearchBar.delegate = self;
    [friendSearchBar setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [friendSearchBar sizeToFit];
    [self.view addSubview:friendSearchBar];
    
    friendSearchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:friendSearchBar contentsController:self];
    self.friendSearchDisplayController.delegate = self;
    self.friendSearchDisplayController.searchResultsDelegate = self;
    self.friendSearchDisplayController.searchResultsDataSource = self;
    self.friendSearchDisplayController.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    UILabel* friendCount_label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 20)];
    friendCount_label.textAlignment = NSTextAlignmentCenter;
    friendCount_label.text = @"";
    friendCount_label.textColor = [UIColor grayColor];
//    UIActivityIndicatorView* indicator = [[UIActivityIndicatorView alloc]init];
//    indicator.center = friendCount_label.center;
//    indicator.tag = 111;
//    [friendCount_label addSubview:indicator];
//    [indicator startAnimating];
    self.friendTableView.tableFooterView = friendCount_label;
//    self.searchDisplayController.delegate = self;
//    self.searchDisplayController.searchResultsDelegate = self;
//    self.searchDisplayController.searchResultsDataSource = self;
    
//    UIImage* img = [[UIImage imageNamed:@"添加好友icon.png"] stretchableImageWithLeftCapWidth:3 topCapHeight: 3];
//    [self.addFriendBtn setBackButtonBackgroundImage:img forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
}

- (void)initTableData
{
    @try {
        self.friendList = [[MTUser sharedInstance] friendList];
        self.sectionArray = [[MTUser sharedInstance] sectionArray];
        self.sortedFriendDic = [[MTUser sharedInstance] sortedFriendDic];
        NSLog(@"sectionarray: %@ \nsortedFriendDic: %@", self.sectionArray, self.sortedFriendDic);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self friendTableviewReload];
        });
        
        if (self.friendList.count > 0) {
            NSLog(@"好友列表初始存在好友：friendlist count: %d",friendList.count);
            if (![MTUser sharedInstance].doingSortingFriends && ![MTUser sharedInstance].sortingFriendsDone) { //如果这时不在进行好友排序 且 好友排序并没有完成, 则进行排序
                NSLog(@"好友列表初始化：好友排序未完成且不在进行好友排序");
                dispatch_async(dispatch_get_global_queue(0, 0), ^
                               {
                                   [[MTUser sharedInstance] friendListDidChanged];
                                   dispatch_async(dispatch_get_main_queue(), ^
                                                  {
                                                      self.sectionArray = [[MTUser sharedInstance] sectionArray];
                                                      self.sortedFriendDic = [[MTUser sharedInstance] sortedFriendDic];
                                                      NSLog(@"sortedFriendDic: %@", self.sortedFriendDic);
                                                      [self friendTableviewReload];
                                                  });
                               });
                
            }
            else //如果这时在进行好友排序或已经完成排序
            {
                NSLog(@"好友列表初始化：正在进行好友排序或已经完成排序");
                while([MTUser sharedInstance].doingSynchronizeFriend) {
                    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
                }
                self.sectionArray = [[MTUser sharedInstance] sectionArray];
                self.sortedFriendDic = [[MTUser sharedInstance] sortedFriendDic];
                NSLog(@"sortedFriendDic: %@", self.sortedFriendDic);
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self friendTableviewReload];;
                });
            }
            
            [[MTUser sharedInstance] synchronizeFriends]; //进行一次好友同步
            while([MTUser sharedInstance].doingSynchronizeFriend) {
                [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
            }
            self.sectionArray = [[MTUser sharedInstance] sectionArray];
            self.sortedFriendDic = [[MTUser sharedInstance] sortedFriendDic];
            NSLog(@"sortedFriendDic: %@", self.sortedFriendDic);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self friendTableviewReload];;
            });

            
        }
        else //如果好友列表为空，可能是同步好友失败，也有可能真为空
        {
            NSLog(@"好友列表初始不存在好友：friendlist count: %ld",friendList.count);
            AppDelegate* app = (AppDelegate*)[UIApplication sharedApplication].delegate;
            
            if (app.isNetworkConnected) { //为防万一，再进行一次好友同步，前提是网络已连接
                NSLog(@"好友列表初始化：网络连接，再进行一次好友同步");
                [[MTUser sharedInstance] synchronizeFriends];
                while(![MTUser sharedInstance].synchronizeFriendDone && [MTUser sharedInstance].doingSynchronizeFriend) {
                    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
                }
                NSLog(@"好友列表初始化：同步之后，friendlist count: %d",[MTUser sharedInstance].friendList.count);
                if ([MTUser sharedInstance].friendList.count > 0) {
                    if ([MTUser sharedInstance].sortedFriendDic.count == 1) {  //1是必定有个“好友推荐”
                        NSLog(@"好友列表初始化：如果好友排序列表为空，说明没有收到服务器返回的消息");
                        dispatch_async(dispatch_get_global_queue(0, 0), ^
                                       {
                                           [[MTUser sharedInstance] friendListDidChanged];
                                           dispatch_async(dispatch_get_main_queue(), ^
                                                          {
                                                              self.friendList = [[MTUser sharedInstance] friendList];
                                                              self.sectionArray = [[MTUser sharedInstance] sectionArray];
                                                              self.sortedFriendDic = [[MTUser sharedInstance] sortedFriendDic];
                                                              [self friendTableviewReload];
                                                          });
                                       });
                    }
                    else
                    {
                        NSLog(@"好友列表初始化：好友同步和好友排序完成");
                        self.friendList = [[MTUser sharedInstance] friendList];
                        self.sortedFriendDic = [[MTUser sharedInstance] sortedFriendDic];
                        self.sectionArray = [[MTUser sharedInstance] sectionArray];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self friendTableviewReload];
                        });
                        
                    }
                }
                else
                {
                    NSLog(@"好友列表初始化：该用户暂时没有好友");
                    self.friendList = [[MTUser sharedInstance] friendList];
                    self.sectionArray = [[MTUser sharedInstance] sectionArray];
                    self.sortedFriendDic = [[MTUser sharedInstance] sortedFriendDic];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self friendTableviewReload];
                    });
                    
                }
            }
            else //网络不连通，直接从数据库取
            {
                NSLog(@"好友列表初始化：网络不联通，直接从数据库获取friendlist");
                dispatch_async(dispatch_get_global_queue(0, 0), ^
                               {
//                                   [MTUser sharedInstance].friendList = [[MTUser sharedInstance] getFriendsFromDB];
                                   [[MTUser sharedInstance] getFriendsFromDBwithCompletion:^(NSMutableArray *results) {
                                       [MTUser sharedInstance].friendList = [NSMutableArray arrayWithArray:results];
                                       [[MTUser sharedInstance] friendListDidChanged];
                                       dispatch_async(dispatch_get_main_queue(), ^
                                                      {
                                                          self.friendList = [[MTUser sharedInstance] friendList];
                                                          self.sectionArray = [[MTUser sharedInstance] sectionArray];
                                                          self.sortedFriendDic = [[MTUser sharedInstance] sortedFriendDic];
                                                          [self friendTableviewReload];
                                                      });
                                   }];
                                   
                               });
                
            }
        }
        NSLog(@"table data init done");
        //    self.sortedFriendDic = [[MTUser sharedInstance] sortedFriendDic];
        //    self.sectionArray = [[MTUser sharedInstance] sectionArray];
        //    NSLog(@"friendviewcontroller: friendList count: %d\n, sortedFriendDic: %@, sectionArray: %@",self.friendList.count, self.sortedFriendDic, self.sectionArray);
        //    [self.friendTableView reloadData];
        
        

    }
    @catch (NSException *exception) {
        NSLog(@"init friend table exception: %@", exception);
    }
    @finally {
        
    }
    
}

- (void)friendTableviewReload
{
    [self.friendTableView reloadData];
    @autoreleasepool {
        UILabel* lab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 20)];
        lab.textAlignment = NSTextAlignmentCenter;
        lab.textColor = [UIColor grayColor];
        lab.text = [NSString stringWithFormat:@"%lu位好友", (unsigned long)self.friendList.count];
        [self.friendTableView setTableFooterView:lab];
        NSLog(@"刷新好友列表");
    }
}

-(void)getRangesOfText:(NSString*)text withKeyWord:(NSString*)keyWord
{
    NSMutableArray* ranges_arr = [[NSMutableArray alloc]init];
//    NSMutableArray* textChar_arr = [[NSMutableArray alloc]init];
    NSMutableArray* textCharRange_arr = [[NSMutableArray alloc]init];
    NSInteger location = 0;
    NSString* temp_text_head = [CommonUtils pinyinHeadFromNSString:text];
//    NSLog(@"PINYIN head: %@",temp_text_head);
    NSRange range_text = [text rangeOfString:keyWord options:NSCaseInsensitiveSearch];
//    NSLog(@"text: %@, keyword: %@", text, keyWord);
    if (range_text.length > 0) {
        NSValue* value = [NSValue valueWithRange:range_text];
        [ranges_arr addObject:value];
//        NSLog(@"colored range1: (%d,%d)",[value rangeValue].location,[value rangeValue].length);
    }
    else
    {
        NSRange range_head = [temp_text_head rangeOfString:keyWord options:NSCaseInsensitiveSearch];
        if (range_head.length > 0) {
            NSValue* value = [NSValue valueWithRange:range_head];
            [ranges_arr addObject:value];
        }
        else
        {
            NSString* temp_text_all = [CommonUtils pinyinFromNSString:text];
            NSInteger checkStringEnd = 0;
            //        NSLog(@"PINYIN all: %@",temp_text_all);
            for (NSInteger i = 0; i < text.length; i++) {
                NSString* char_str = [CommonUtils pinyinFromNSString:[text substringWithRange:NSMakeRange(i, 1)]];
                NSValue* value = [NSValue valueWithRange:NSMakeRange(location, char_str.length)];
                [textCharRange_arr addObject:value];
                location = location + char_str.length;
            }
            NSRange range_all = [temp_text_all rangeOfString:keyWord options:NSCaseInsensitiveSearch];
            if (range_all.location >= temp_text_all.length) {
                return;
            }
            //        NSInteger range_all_begin = range_all.location;
            NSInteger range_all_end = range_all.length + range_all.location - 1;
            //        NSLog(@"temp_text_all range2: (%d,%d)",range_all.location,range_all.length);
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
                if(beginSet)
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
            //        NSLog(@"colored begin: %d, end: %d",begin,end);
            NSValue* value = [NSValue valueWithRange:NSMakeRange(begin, end - begin + 1)];
            [ranges_arr addObject:value];
//                    NSLog(@"colored range2: (%d,%d)",[value rangeValue].location,[value rangeValue].length);
            
        }
        
    }
    [self.searchFriendKeyWordRangeArr addObject:ranges_arr];
    
    
}

- (IBAction)switchToAddFriendView:(id)sender
{
    
}



- (void)deleteFriendwithIndexPath:(NSIndexPath*)indexPath
{
    [SVProgressHUD showWithStatus:@"正在处理..." maskType:SVProgressHUDMaskTypeClear];
//    [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(timerCancel:) userInfo:nil repeats:NO];
    if (indexPath.section >= sectionArray.count) {
        NSLog(@"删除好友的indexpath.section错误, section: %li", (long)indexPath.section);
        return;
    }
    NSString* key = (NSString*)[sectionArray objectAtIndex:indexPath.section];
    __block NSMutableArray* groupFriends = [sortedFriendDic objectForKey:key];
    if (indexPath.row < groupFriends.count) {
        NSMutableDictionary* friend = [groupFriends objectAtIndex:indexPath.row];
        NSNumber* fid = [friend objectForKey:@"id"];
        HttpSender* http = [[HttpSender alloc]initWithDelegate:self];
        NSDictionary* json_dic = [CommonUtils packParamsInDictionary:
                                  fid, @"friend_id",
                                  [MTUser sharedInstance].userid, @"id", nil];
        NSData* json_data = [NSJSONSerialization dataWithJSONObject:json_dic options:NSJSONWritingPrettyPrinted error:nil];
        [http sendMessage:json_data withOperationCode:DELETE_FRIEND finshedBlock:^(NSData *rData) {
            if (rData) {
                NSString* temp  = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
                NSLog(@"获取到删除好友反馈：%@", temp);
            }
            else
            {
                NSLog(@"删除好友获取的rData为空, indexPath.section: %d, indexPath.row: %d", indexPath.section, indexPath.row);
                [SVProgressHUD dismissWithError:@"网络异常"];
//                [groupFriends insertObject:friend atIndex:indexPath.row];
//                [friendTableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
                return;
            }
            NSDictionary* response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
            NSInteger cmd = [[response1 objectForKey:@"cmd"] integerValue];
            switch (cmd) {
                case NORMAL_REPLY:   //100
                {
                    NSInteger count = [MTUser sharedInstance].friendList.count;
                    NSMutableArray* arraycopy = [[MTUser sharedInstance].friendList mutableCopy];
                    [groupFriends removeObjectAtIndex:indexPath.row];
                    [friendTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
                    if (groupFriends.count == 0)
                    {
                        [sortedFriendDic removeObjectForKey:key];
                        __block __weak FriendsViewController* Fvc = self;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [Fvc friendTableviewReload];
                        });
                    }
                    for (NSInteger i = count - 1; i >= 0; i--) {
                        NSMutableDictionary* friend_copy = [arraycopy objectAtIndex:i];
                        NSInteger fid_copy = [[friend_copy objectForKey:@"id"]integerValue];
                        if ([fid integerValue] == fid_copy) {
                            [[MTUser sharedInstance].friendList removeObjectAtIndex:i];
                            [[MTUser sharedInstance].alias_dic removeObjectForKey:[NSString stringWithFormat:@"%@",fid]];
                            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                [[MTUser sharedInstance] aliasDicDidChanged];
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    friendList = [MTUser sharedInstance].friendList;
                                    sectionArray = [MTUser sharedInstance].sectionArray;
                                    sortedFriendDic = [MTUser sharedInstance].sortedFriendDic;
                                    [self friendTableviewReload];
                                });
                            });
                            break;
                        }
                    }
                    [[MTDatabaseHelper sharedInstance] deleteTurpleFromTable:@"friend" withWhere:@{@"id":[NSString stringWithFormat:@"%@", fid]}];
                    [SVProgressHUD dismissWithSuccess:@"删除好友成功" afterDelay:1.5];

                }
                    break;
                case SERVER_ERROR:   //106
                case REQUEST_FAIL:  //108
                default:
                {
                    NSLog(@"删除好友失败，恢复成没删除的状态");
//                    [groupFriends insertObject:friend atIndex:indexPath.row];
//                    [friendTableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
                    [SVProgressHUD dismissWithError:@"删除好友失败" afterDelay:1.5];
                }
                    break;
            }

        }];
        
//        [groupFriends removeObjectAtIndex:indexPath.row];
//        [friendTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
//        if (groupFriends.count == 0)
//        {
//            [sortedFriendDic removeObjectForKey:key];
//            __block __weak FriendsViewController* Fvc = self;
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [Fvc friendTableviewReload];
//            });
//        }
        
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 2.0), dispatch_get_main_queue(), ^{
//            [groupFriends insertObject:friend atIndex:indexPath.row];
//            [friendTableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
//        });
        
    }
    else{
        NSLog(@"key: %@", key);
        NSLog(@"删除好友的indexpath.row错误, row: %li \ngroupFriends: %@", (long)indexPath.row, groupFriends);
    }
    
}

- (void)timerCancel:(NSTimer*)timer
{
    [timer invalidate];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView == friendTableView) {
        if (section < initialSectionForFriendList) {
            return 0;
        }
        return 22;
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
//        NSString* fname;
//        NSString* falias = [aFriend objectForKey:@"alias"];
//        if (falias && ![falias isEqual:[NSNull null]]) {
//            fname = falias;
//        }
//        else
//        {
//            fname = [aFriend objectForKey:@"name"];
//        }
//        NSString* fname_head = [CommonUtils pinyinHeadFromNSString:[fname substringToIndex:1]].uppercaseString;
////        NSLog(@"fname head: %@",fname_head);
//        NSInteger section = [sectionArray indexOfObject:fname_head];
//        if (section >= sectionArray.count)
//        {
//            section = sectionArray.count - 1;
//        }
//        NSInteger row;
//        NSMutableArray* friends = [sortedFriendDic objectForKey:(NSString*)[sectionArray objectAtIndex:section]];
//        for (NSInteger i = 0; i < friends.count; i++) {
//            NSMutableDictionary* friend = [friends objectAtIndex:i];
//            NSString* name;
//            NSString* alias = [friend objectForKey:@"alias"];
//            if (alias && ![alias isEqual:[NSNull null]]) {
//                name = alias;
//            }
//            else
//            {
//                name = [friend objectForKey:@"name"];
//            }
//            if ([name isEqualToString:fname]) {
//                row = i;
//                break;
//            }
//        }
//        NSIndexPath* indexP = [NSIndexPath indexPathForRow:row inSection:section];
////        NSLog(@"searched friend in section %d row %d", section, row);
//        [self.friendTableView scrollToRowAtIndexPath:indexP atScrollPosition:UITableViewScrollPositionTop animated:YES];
        NSNumber* fID = [aFriend objectForKey:@"id"];
        selectedFriendID = fID;
        [self performSegueWithIdentifier:@"FriendToFriendInfo" sender:self]; 
    }
    else if (tableView == self.friendTableView)
    {
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
                [self performSegueWithIdentifier:@"friendCenter_friendRecommendation" sender:self];
//                UIStoryboard* mainStoryBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
//                FriendRecommendationViewController* vc = [mainStoryBoard instantiateViewControllerWithIdentifier:@"FriendRecommendationViewController"];
//                [self.navigationController pushViewController:vc animated:YES];
            }
        }
        else
        {
            [self performSegueWithIdentifier:@"FriendToFriendInfo" sender:self];
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
        else
        {
            NSLog(@"class of selectedFriendID: %@",[selectedFriendID class]);
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
        if (section >= self.sectionArray.count) {
            return nil;
        }
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
                [getter getAvatar];
                
                NSString* alias = [[MTUser sharedInstance].alias_dic objectForKey:[NSString stringWithFormat:@"%@",fid]];
                if (alias && ![alias isEqual:[NSNull null]] && ![alias isEqualToString:@""]) {
                    cell.title.text = alias;
                }
                else if (label) {
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
        NSString* alias = [friend_dic objectForKey:@"alias"];
        NSNumber* fid = [friend_dic objectForKey:@"id"];
        if (alias && ![alias isEqual:[NSNull null]]) {
            name = [NSString stringWithFormat:@"%@ (%@)", alias, name];
        }
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
            [attrStr addAttribute:NSForegroundColorAttributeName
                            value:color
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
        [getter getAvatar];
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

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == friendTableView) {
        if (indexPath.section != 0) {
            return YES;
        }
    }
    return NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == friendTableView) {
        return UITableViewCellEditingStyleDelete;
    }
    return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == friendTableView) {
        if (editingStyle == UITableViewCellEditingStyleDelete)
        {
            [self deleteFriendwithIndexPath:indexPath];
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
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
            NSString* falias = [aFriend objectForKey:@"alias"];
            if (falias && ![falias isEqual:[NSNull null]]) {
                fname = [NSString stringWithFormat:@"%@ (%@)", falias, fname];
            }
            if ([CommonUtils isIncludeChineseInString:fname]) {
                NSString *tempPinYinStr = [CommonUtils pinyinFromNSString:fname];
                NSRange titleResult=[tempPinYinStr rangeOfString:friendSearchBar.text options:NSCaseInsensitiveSearch];
                if (titleResult.length>0 && titleResult.location == 0) {
                    [searchFriendList addObject:friendList[i]];
                    [self getRangesOfText:fname withKeyWord:friendSearchBar.text];
                }
                else
                {
                    NSString *tempPinYinHeadStr = [CommonUtils pinyinHeadFromNSString:fname];
                    NSRange titleHeadResult=[tempPinYinHeadStr rangeOfString:friendSearchBar.text options:NSCaseInsensitiveSearch];
                    if (titleHeadResult.length>0 && titleHeadResult.location == 0) {
                        [searchFriendList addObject:friendList[i]];
                        [self getRangesOfText:fname withKeyWord:friendSearchBar.text];
                    }

                }
            }
            else {
                NSRange titleResult=[fname rangeOfString:friendSearchBar.text options:NSCaseInsensitiveSearch];
                if (titleResult.length>0 && titleResult.location == 0) {
                    [searchFriendList addObject:friendList[i]];
                    [self getRangesOfText:fname withKeyWord:friendSearchBar.text];
                }
            }
        }
    } else if (friendSearchBar.text.length>0&&[CommonUtils isIncludeChineseInString:friendSearchBar.text]) {
        for (int i = 0; i < friendList.count; i++) {
            NSMutableDictionary* tempDic = [friendList objectAtIndex:i];
            NSString* fname = [tempDic objectForKey:@"name"];
            NSString* falias = [tempDic objectForKey:@"alias"];
            if (falias && ![falias isEqual:[NSNull null]]) {
                fname = [NSString stringWithFormat:@"%@ (%@)", falias, fname];
            }
            NSRange titleResult=[fname rangeOfString:friendSearchBar.text options:NSCaseInsensitiveSearch];
            if (titleResult.length>0 && titleResult.location == 0) {
                [searchFriendList addObject:tempDic];
                [self getRangesOfText:fname withKeyWord:friendSearchBar.text];
            }
        }
    }
//    NSLog(@"search friend list: %@",searchFriendList);
    NSLog(@"search_friend_display_controller: width: %f, height: %f, x: %f, y: %f", friendSearchDisplayController.searchResultsTableView.contentSize.width, friendSearchDisplayController.searchResultsTableView.contentSize.height, friendSearchDisplayController.searchResultsTableView.frame.origin.x, friendSearchDisplayController.searchResultsTableView.frame.origin.y);

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

- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView
{
    [tableView setContentInset:UIEdgeInsetsZero];
    [tableView setScrollIndicatorInsets:UIEdgeInsetsZero];
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

//- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
//{
////    NSLog(@"scroll begin dragging"); 
//}

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
        self.navigationController.navigationBar.alpha = 1 - distance/400.0;
    }else{
        self.shadowView.hidden = YES;
        [self.view sendSubviewToBack:self.shadowView];
    }
}


@end
