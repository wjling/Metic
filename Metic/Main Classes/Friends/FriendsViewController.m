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
    MTLOG(@"friendviewcontroller viewdidload");
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
    MTLOG(@"touches begin");
}

//返回本页并跳转到消息页
-(void)PopToHereAndTurnToNotificationPage:(id)sender
{
    MTLOG(@"PopToHereAndTurnToNotificationPage  from  Friends");
    
    if ([[SlideNavigationController sharedInstance].viewControllers containsObject:self]){
        MTLOG(@"Here");
        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"shouldIgnoreTurnToNotifiPage"]) {
            [[SlideNavigationController sharedInstance] popToViewController:self animated:NO];
            [self ToNotificationCenter];
        }
    }else{
        MTLOG(@"NotHere");
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
    initialSectionForFriendList = 0;
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
    self.friendTableView.tableFooterView = friendCount_label;
}

- (void)initTableData
{
    @try {
        self.friendList = [[MTUser sharedInstance] friendList];
        self.sectionArray = [[MTUser sharedInstance] sectionArray];
        self.sortedFriendDic = [[MTUser sharedInstance] sortedFriendDic];
//        MTLOG(@"sectionarray: %@ \nsortedFriendDic: %@", self.sectionArray, self.sortedFriendDic);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self friendTableviewReload];
        });
        
        if (self.friendList.count > 0) {
//            MTLOG(@"好友列表初始存在好友：friendlist count: %d",friendList.count);
            if (![MTUser sharedInstance].doingSortingFriends && ![MTUser sharedInstance].sortingFriendsDone) { //如果这时不在进行好友排序 且 好友排序并没有完成, 则进行排序
                MTLOG(@"好友列表初始化：好友排序未完成且不在进行好友排序");
                dispatch_async(dispatch_get_global_queue(0, 0), ^
                               {
                                   [[MTUser sharedInstance] friendListDidChanged];
                                   dispatch_async(dispatch_get_main_queue(), ^
                                                  {
                                                      self.sectionArray = [[MTUser sharedInstance] sectionArray];
                                                      self.sortedFriendDic = [[MTUser sharedInstance] sortedFriendDic];
                                                      MTLOG(@"sortedFriendDic: %@", self.sortedFriendDic);
                                                      [self friendTableviewReload];
                                                  });
                               });
                
            }
            else //如果这时在进行好友排序或已经完成排序
            {
                MTLOG(@"好友列表初始化：正在进行好友排序或已经完成排序");
                while([MTUser sharedInstance].doingSynchronizeFriend) {
                    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
                }
                self.sectionArray = [[MTUser sharedInstance] sectionArray];
                self.sortedFriendDic = [[MTUser sharedInstance] sortedFriendDic];
//                MTLOG(@"sortedFriendDic: %@", self.sortedFriendDic);
                
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
            MTLOG(@"sortedFriendDic: %@", self.sortedFriendDic);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self friendTableviewReload];;
            });

            
        }
        else //如果好友列表为空，可能是同步好友失败，也有可能真为空
        {
            MTLOG(@"好友列表初始不存在好友：friendlist count: %ld",friendList.count);
            AppDelegate* app = (AppDelegate*)[UIApplication sharedApplication].delegate;
            
            if (app.isNetworkConnected) { //为防万一，再进行一次好友同步，前提是网络已连接
                MTLOG(@"好友列表初始化：网络连接，再进行一次好友同步");
                [[MTUser sharedInstance] synchronizeFriends];
                while(![MTUser sharedInstance].synchronizeFriendDone && [MTUser sharedInstance].doingSynchronizeFriend) {
                    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
                }
                MTLOG(@"好友列表初始化：同步之后，friendlist count: %d",[MTUser sharedInstance].friendList.count);
                if ([MTUser sharedInstance].friendList.count > 0) {
                    if ([MTUser sharedInstance].sortedFriendDic.count == 1) {  //1是必定有个“好友推荐”
                        MTLOG(@"好友列表初始化：如果好友排序列表为空，说明没有收到服务器返回的消息");
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
                        MTLOG(@"好友列表初始化：好友同步和好友排序完成");
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
                    MTLOG(@"好友列表初始化：该用户暂时没有好友");
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
                MTLOG(@"好友列表初始化：网络不联通，直接从数据库获取friendlist");
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
        MTLOG(@"table data init done");
    }
    @catch (NSException *exception) {
        MTLOG(@"init friend table exception: %@", exception);
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
        MTLOG(@"刷新好友列表");
    }
}

-(void)getRangesOfText:(NSString*)text withKeyWord:(NSString*)keyWord
{
    if (!text || !keyWord
        ||[text isEqualToString:@""] || [keyWord isEqualToString:@""]
        || [text isEqual:[NSNull null]] || [text isEqual:[NSNull null]]) {
        return;
    }
    NSRange range_zuokuohao = [text rangeOfString:@"(" options:NSCaseInsensitiveSearch];
    NSString* fname = @"";
    NSString* falias = @"";
    if (range_zuokuohao.length > 0) {
        fname = [text substringToIndex:range_zuokuohao.location - 1];
        falias = [text substringWithRange:NSMakeRange(range_zuokuohao.location + 1, text.length - range_zuokuohao.location - 1)];
    }
    else
    {
        fname = text;
    }
    NSMutableArray* ranges_arr = [[NSMutableArray alloc]init];
    NSMutableArray* textCharRange_arr = [[NSMutableArray alloc]init];
    
    NSInteger location = 0;
    NSString* temp_text_head = [CommonUtils pinyinHeadFromNSString:text];

    if ([CommonUtils isIncludeChineseInString:keyWord]) { //搜索字串包含中文
        NSRange range_text = [text rangeOfString:keyWord options:NSCaseInsensitiveSearch];
        if (range_text.length > 0 && range_text.location < text.length) {
            NSRange range_name = [fname rangeOfString:keyWord options:NSCaseInsensitiveSearch];
            if (range_name.length > 0 && range_name.location < fname.length) {
                NSValue* value = [NSValue valueWithRange:range_name];
                [ranges_arr addObject:value];
            }
        }
        
        if (![falias isEqualToString:@""]) {
            NSRange range_alias = [falias rangeOfString:keyWord options:NSCaseInsensitiveSearch];
            if (range_alias.length > 0 && range_alias.location < falias.length) {
                NSInteger begin = range_zuokuohao.location + 1 + range_alias.location;
                if (begin > 0 && begin < text.length) {
                    NSValue* value = [NSValue valueWithRange:NSMakeRange(begin, range_alias.length)];
                    [ranges_arr addObject:value];
                }
                
            }
        }
        
    }
    else //搜索字串不包含中文
    {
        NSRange range_text = [text rangeOfString:keyWord options:NSCaseInsensitiveSearch];
        
        if (range_text.length > 0) {
            NSInteger startIndex = 0;
            NSInteger count = keyWord.length;
            while (range_text.location != NSNotFound) {
                range_text.location += startIndex;
                NSValue* value = [NSValue valueWithRange:range_text];
                [ranges_arr addObject:value];
                startIndex = range_text.location + range_text.length;
                NSString* sub_text = [text substringFromIndex:startIndex];
                range_text = [sub_text rangeOfString:keyWord options:NSCaseInsensitiveSearch];
                count--;
            }
            
        }
        
        NSRange range_head = [temp_text_head rangeOfString:keyWord options:NSCaseInsensitiveSearch];
        if (range_head.length > 0) {
            NSValue* value = [NSValue valueWithRange:range_head];
            [ranges_arr addObject:value];
        }
        
        for (NSInteger i = 0;i < text.length; i++) {
            NSString* char_str = [CommonUtils pinyinFromNSString:[text substringWithRange:NSMakeRange(i, 1)]];
            NSValue* value = [NSValue valueWithRange:NSMakeRange(location, char_str.length)];
            [textCharRange_arr addObject:value];
            location = location + char_str.length;
        }
        NSInteger range_all_end = 0;
        NSString* text_pinyin = [CommonUtils pinyinFromNSString:text];
        NSInteger range_zuoKuohao = 0;
        NSInteger name_alias_flag = 0;
        while (name_alias_flag < 2) {
            NSRange range_youKuohao = [text_pinyin rangeOfString:@")"];
            NSString* temp_text_all = [text_pinyin substringWithRange:NSMakeRange(range_zuoKuohao, text_pinyin.length - range_zuoKuohao - range_youKuohao.length)];
            NSRange range_all = [temp_text_all rangeOfString:keyWord options:NSCaseInsensitiveSearch];
            if (range_all.location == NSNotFound) {
                break;
            }
            range_all.location += range_zuoKuohao;
            range_all_end = range_all.length + range_all.location;
            
            NSInteger begin = -1, end = -1;
            NSInteger checkStringEnd = 0; //检查过的字符的末尾，即下次检查的开头
            BOOL beginSet = NO;
            for (NSInteger i = 0;i < textCharRange_arr.count; i++) {
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
                    if (checkStringEnd <= range_all_end - 1  && range_all_end - 1 < checkStringEnd + range.length) {
                        end = i;
                        break;
                    }
                    else if (checkStringEnd >= range_all_end - 1)
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
            //        MTLOG(@"colored begin: %d, end: %d",begin,end);
            NSInteger final_end = end - begin + 1;
            if (final_end <= 0 || final_end > textCharRange_arr.count - 1) {
                final_end = 1;
            }
            NSValue* value = [NSValue valueWithRange:NSMakeRange(begin, final_end)];
            [ranges_arr addObject:value];
            MTLOG(@"%@, colored range2: (%ld,%ld)",text,[value rangeValue].location,[value rangeValue].length);
            
            range_zuoKuohao = [text_pinyin rangeOfString:@"(" options:NSCaseInsensitiveSearch].location + 1;
            if (range_zuoKuohao < text_pinyin.length && range_zuoKuohao >= 0) {
                name_alias_flag++;
            }
            else
            {
                break;
            }
        }
    }
    [self.searchFriendKeyWordRangeArr addObject:ranges_arr];
    
}

-(void)getHighlightedRangeUserInfo:(NSString*)user_text withKeyWord:(NSString*)keyword
{
    
}

- (IBAction)switchToAddFriendView:(id)sender
{
    
}



- (void)deleteFriendwithIndexPath:(NSIndexPath*)indexPath
{
    [SVProgressHUD showWithStatus:@"正在处理..." maskType:SVProgressHUDMaskTypeClear];
//    [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(timerCancel:) userInfo:nil repeats:NO];
    if (indexPath.section >= sectionArray.count) {
        MTLOG(@"删除好友的indexpath.section错误, section: %li", (long)indexPath.section);
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
                MTLOG(@"获取到删除好友反馈：%@", temp);
            }
            else
            {
                MTLOG(@"删除好友获取的rData为空, indexPath.section: %d, indexPath.row: %d", indexPath.section, indexPath.row);
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
                            [[MTUser sharedInstance].friendsIdSet removeObject:fid];
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
                    MTLOG(@"删除好友失败，恢复成没删除的状态");
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
        MTLOG(@"key: %@", key);
        MTLOG(@"删除好友的indexpath.row错误, row: %li \ngroupFriends: %@", (long)indexPath.row, groupFriends);
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
    if (tableView == self.friendSearchDisplayController.searchResultsTableView) {
        [self.friendSearchDisplayController setActive:NO animated:YES];
        NSMutableDictionary* aFriend = [searchFriendList objectAtIndex:indexPath.row];
        NSNumber* fID = [aFriend objectForKey:@"id"];
        if (fID) {
            selectedFriendID = fID;
            [self performSegueWithIdentifier:@"FriendToFriendInfo" sender:self];
        }
        
    }
    else if (tableView == self.friendTableView)
    {
//        if (indexPath.section == 0) {
//            if (indexPath.row == 0) {
//                [self performSegueWithIdentifier:@"friendCenter_friendRecommendation" sender:self];
//            }
//        }
//        else
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
        NSArray* groupOfFriends = [sortedFriendDic objectForKey:(NSString*)[self.sectionArray objectAtIndex:section+1]];
        NSDictionary* aFriend = [groupOfFriends objectAtIndex:row];
        MTLOG(@"afriend: %@",aFriend);
        selectedFriendID = [CommonUtils NSNumberWithNSString:[aFriend objectForKey:@"id"]];
        if ([selectedFriendID isKindOfClass:[NSString class]]) {
            MTLOG(@"NSString fid value: %@",selectedFriendID);
        }
        else if([selectedFriendID isKindOfClass:[NSNumber class]])
        {
            MTLOG(@"NSNumber fid value: %@",selectedFriendID);
        }
        else
        {
            MTLOG(@"class of selectedFriendID: %@",[selectedFriendID class]);
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
//        MTLOG(@"pass fid value: %@",selectedFriendID);
        
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
        NSArray* groupOfFriends = [sortedFriendDic objectForKey:(NSString*)[sectionArray objectAtIndex:section+1]];
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
        return sectionArray.count>0? sectionArray.count - 1:0;
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
            return [[UITableViewCell alloc]init];
        }
        NSArray* groupOfFriends = [sortedFriendDic objectForKey:(NSString*)[self.sectionArray objectAtIndex:section+1]];
        if (groupOfFriends) {
            if (row >= groupOfFriends.count) {
                return [[UITableViewCell alloc]init];
            }
            NSDictionary* aFriend = [groupOfFriends objectAtIndex:row];
            NSString* label = [aFriend objectForKey:@"name"];
            NSNumber* fid = [aFriend objectForKey:@"id"];
            
//            if (section == 0) {
//                if (row == 0)
//                {
//                    NotificationCenterCell* cell = [self.friendTableView dequeueReusableCellWithIdentifier:@"notificationcentercell"];
//                    if (nil == cell) {
//                        cell = [[NotificationCenterCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"notificationcentercell"];
//                    }
//                    cell.pic.image = [UIImage imageNamed:@"好友推荐icon.png"];
//                    cell.title.text = label;
//                    
//                    return cell ;
//                }
//            }
//            else
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
        if (row >= searchFriendList.count) {
            return cell;
        }
        NSMutableDictionary* friend_dic = [searchFriendList objectAtIndex:row];
        NSString* name = [friend_dic objectForKey:@"name"];
        NSString* alias = [friend_dic objectForKey:@"alias"];
        NSNumber* fid = [friend_dic objectForKey:@"id"];
        if (alias && ![alias isEqual:[NSNull null]] && ![alias isEqualToString:@""]) {
            name = [NSString stringWithFormat:@"%@ (%@)", alias, name];
        }

        if (!self.searchFriendKeyWordRangeArr || indexPath.row >= self.searchFriendKeyWordRangeArr.count) {
            return cell;
        }
        
        UIColor *color = [UIColor colorWithRed:0.29 green:0.76 blue:0.61 alpha:1];
        NSMutableAttributedString* attrStr = [[NSMutableAttributedString alloc]initWithString:name];
        NSMutableArray* rangeArr = [self.searchFriendKeyWordRangeArr objectAtIndex:indexPath.row];
        for (NSInteger i = 0; i < rangeArr.count; i++) {
            NSRange range = [[rangeArr objectAtIndex:i] rangeValue];
            if (range.location > attrStr.length - 1 || range.length > attrStr.length) {
                continue;
            }
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
//                MTLOG(@"remove");
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
//        MTLOG(@"cell of searched friend, name: %@",name);
        return cell;
    }
    
    
    return [[UITableViewCell alloc]init];
    
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView == friendTableView) {
        return [self.sectionArray objectAtIndex:section+1];
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
        return YES;
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
        //搜索字串不含中文
        for (int i=0; i<friendList.count; i++) {
            NSMutableDictionary* aFriend = [friendList objectAtIndex:i];
            NSString* fname = [aFriend objectForKey:@"name"];
            NSString* falias = [aFriend objectForKey:@"alias"];
            NSString* text = fname;
            if (!fname || [fname isEqual:[NSNull null]]) {
                return;
            }
            if (falias && ![falias isEqual:[NSNull null]] && ![falias isEqualToString:@""]) {
                text = [NSString stringWithFormat:@"%@ (%@)", falias, fname];
            }
            if ([CommonUtils isIncludeChineseInString:text]) { //好友名+好友备注 包含中文 | 搜索字串不包含中文
                NSString *tempPinYinStr = [CommonUtils pinyinFromNSString:text];
                NSRange titleResult=[tempPinYinStr rangeOfString:friendSearchBar.text options:NSCaseInsensitiveSearch];
                if (titleResult.length>0) //好友名+好友备注 转化成拼音
                {
                    NSInteger location = 0;
                    //比较用户名name
                    if ([CommonUtils isIncludeChineseInString:fname]) {
                        for (NSInteger j = 0; j < fname.length; j++) {
                            NSString* char_pinyin = [CommonUtils pinyinFromNSString:[fname substringWithRange:NSMakeRange(j, 1)]];
                            NSString* long_str = char_pinyin;
                            NSString* short_str = [friendSearchBar.text substringFromIndex:location];
                            if (short_str.length > long_str.length) {
                                long_str = short_str;
                                short_str = char_pinyin;
                            }
                            NSRange compareResult_range = [long_str rangeOfString:short_str options:NSCaseInsensitiveSearch];
                            if (compareResult_range.location != 0) {
                                if (location != 0) {
                                    break;
                                }
                                continue;
                            }
                            location += short_str.length;
                            if (location == friendSearchBar.text.length) {
                                [searchFriendList addObject:friendList[i]];
                                [self getRangesOfText:text withKeyWord:friendSearchBar.text];
                                break;
                            }
                            
                        }
                        if (location == friendSearchBar.text.length) {
                            continue;
                        }
                    }
                    else
                    {
                        NSRange titleResult_fname = [fname rangeOfString:friendSearchBar.text options:NSCaseInsensitiveSearch];
                        if (titleResult_fname.length != 0) {
                            [searchFriendList addObject:friendList[i]];
                            [self getRangesOfText:text withKeyWord:friendSearchBar.text];
                            continue;
                        }
                        
                    }
                    
                    //比较备注名alias
                    if (falias && ![falias isEqual:[NSNull null]]) {
                        if ([CommonUtils isIncludeChineseInString:falias]) {
                            location = 0;
                            for (NSInteger j = 0; j < falias.length; j++) {
                                NSString* char_pinyin = [CommonUtils pinyinFromNSString:[falias substringWithRange:NSMakeRange(j, 1)]];
                                NSString* long_str = char_pinyin;
                                NSString* short_str = [friendSearchBar.text substringFromIndex:location];
                                if (short_str.length > long_str.length) {
                                    long_str = short_str;
                                    short_str = char_pinyin;
                                }
                                NSRange compareResult_range = [long_str rangeOfString:short_str options:NSCaseInsensitiveSearch];
                                if (compareResult_range.location != 0) {
                                    if (location != 0) {
                                        break;
                                    }
                                    continue;
                                }
                                location += short_str.length;
                                if (location == friendSearchBar.text.length) {
                                    [searchFriendList addObject:friendList[i]];
                                    [self getRangesOfText:text withKeyWord:friendSearchBar.text];
                                    break;
                                }
                            }
                        }
                        else
                        {
                            NSRange titleResult_falias = [falias rangeOfString:friendSearchBar.text options:NSCaseInsensitiveSearch];
                            if (titleResult_falias.length != 0) {
                                [searchFriendList addObject:friendList[i]];
                                [self getRangesOfText:text withKeyWord:friendSearchBar.text];
                                continue;
                            }
                            
                        }
                        
                    }
                    

                    
//                    if (titleResult.location != 0) {
//                        if (!falias) {
//                            return;
//                        }
//                        NSRange titleResult_fname = [fname rangeOfString:friendSearchBar.text options:NSCaseInsensitiveSearch];
//                        if (titleResult_fname.length == 0 || titleResult_fname.location > 0) {
//                            return;
//                        }
//                    }
//                    [searchFriendList addObject:friendList[i]];
//                    [self getRangesOfText:text withKeyWord:friendSearchBar.text];
                }
                else //好友名+好友备注 转化成拼音首字母
                {
                    NSString *tempPinYinHeadStr = [CommonUtils pinyinHeadFromNSString:text];
                    NSRange titleHeadResult=[tempPinYinHeadStr rangeOfString:friendSearchBar.text options:NSCaseInsensitiveSearch];
                    if (titleHeadResult.length>0) {
//                        if (titleHeadResult.location != 0) {
//                            if (!falias) {
//                                continue;
//                            }
//                            NSRange titleHeadResult_fname = [fname rangeOfString:friendSearchBar.text options:NSCaseInsensitiveSearch];
//                            if (titleHeadResult_fname.length == 0 || titleHeadResult_fname.location > 0) {
//                                continue;
//                            }
//                        }
                        [searchFriendList addObject:friendList[i]];
                        [self getRangesOfText:text withKeyWord:friendSearchBar.text];
                    }

                }
            }
            else //好友信息和搜索字段都不含中文
            {
                NSRange titleResult=[text rangeOfString:friendSearchBar.text options:NSCaseInsensitiveSearch];
                if (titleResult.length>0) {
                    NSRange titleResult_fname = [fname rangeOfString:friendSearchBar.text options:NSCaseInsensitiveSearch];
                    if (titleResult_fname.length == 0) {
                        if (falias && ![falias isEqual:[NSNull null]]) {
                            NSRange titleResult_falias = [falias rangeOfString:friendSearchBar.text options:NSCaseInsensitiveSearch];
                            if (titleResult_falias.length == 0 || titleResult_falias.location > 0) {
                                continue;
                            }
                        }
                        else
                        {
                            continue;
                        }
                    }
                    
                    [searchFriendList addObject:friendList[i]];
                    [self getRangesOfText:text withKeyWord:friendSearchBar.text];
                }
            }
        }
    }
    else if (friendSearchBar.text.length>0&&[CommonUtils isIncludeChineseInString:friendSearchBar.text]) { //搜索字段包含中文
        for (int i = 0; i < friendList.count; i++) {
            NSMutableDictionary* tempDic = [friendList objectAtIndex:i];
            NSString* fname = [tempDic objectForKey:@"name"];
            NSString* falias = [tempDic objectForKey:@"alias"];
            NSString* text = fname;
            if (!fname || [fname isEqual:[NSNull null]]) {
                return;
            }
            if (falias && ![falias isEqual:[NSNull null]] && ![falias isEqualToString:@""]) {
                text = [NSString stringWithFormat:@"%@ (%@)", falias, fname];
            }
            NSRange titleResult=[text rangeOfString:friendSearchBar.text options:NSCaseInsensitiveSearch];
            if (titleResult.length>0) {
//                if (titleResult.location != 0 ) {
//                    if (!falias) {
//                        continue;
//                    }
//                    NSRange titleResult_falias = [falias rangeOfString:friendSearchBar.text options:NSCaseInsensitiveSearch];
//                    if (titleResult_falias.length == 0) {
//                        continue;
//                    }
//                }
                [searchFriendList addObject:tempDic];
                [self getRangesOfText:text withKeyWord:friendSearchBar.text];
            }
        }
    }
//    MTLOG(@"search friend list: %@",searchFriendList);
//    MTLOG(@"search_friend_display_controller: width: %f, height: %f, x: %f, y: %f", friendSearchDisplayController.searchResultsTableView.contentSize.width, friendSearchDisplayController.searchResultsTableView.contentSize.height, friendSearchDisplayController.searchResultsTableView.frame.origin.x, friendSearchDisplayController.searchResultsTableView.frame.origin.y);

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
    MTLOG(@"Received Data: %@",temp);
    NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
    NSNumber* cmd = [response1 objectForKey:@"cmd"];
    MTLOG(@"cmd: %@",cmd);
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
//                MTLOG(@"好友列表已经是最新的啦～");
//                self.friendList = [self getFriendsFromDB];
//                self.sortedFriendDic = [self sortFriendList];
//
//            }
//            MTLOG(@"synchronize friends: %@",friendList);
//            
//        }
//        else
//        {
//            MTLOG(@"synchronize friends failed");
//        }
//    }
//    else
//    {
//        MTLOG(@"server error");
//    }
//    
//    [self.friendTableView reloadData];
}

//- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
//{
////    MTLOG(@"scroll begin dragging"); 
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
