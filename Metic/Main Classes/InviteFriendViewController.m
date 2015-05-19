//
//  FriendsViewController.m
//  SlideMenu
//
//  Created by Aryan Ghassemi on 12/31/13.
//  Copyright (c) 2013 Aryan Ghassemi. All rights reserved.
//

#import "InviteFriendViewController.h"
#import "LaunchEventViewController.h"
#import "showParticipatorsViewController.h"
#import "SVProgressHUD.h"
#import "BOAlertController.h"

@interface InviteFriendViewController ()
@property (nonatomic,strong) NSMutableSet *tmp_fids;
@property (strong, nonatomic) UIView* waitingView;
@property (strong, nonatomic) NSArray* notFriendsList;

@end
@implementation InviteFriendViewController
{
    NSInteger initialSectionForFriendList;
}
@synthesize friendList;
@synthesize sortedFriendDic;
@synthesize sectionArray;
@synthesize sectionTitlesArray;
@synthesize searchFriendList;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [CommonUtils addLeftButton:self isFirstPage:NO];
    //下面的if语句是为了解决iOS7上navigationbar可以和别的view重叠的问题
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0))
    {
        self.edgesForExtendedLayout= UIRectEdgeNone;
    }
    self.sectionTitlesArray = [NSMutableArray arrayWithObjects:@"★",@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z",@"#", nil];
    
    
    [self initParams];
    _tmp_fids = [[NSMutableSet alloc]initWithSet:_FriendsIds];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self initTableData];
}

//返回上一层
-(void)MTpopViewController{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) initParams
{
    initialSectionForFriendList = 1;
    self.sectionArray = [[NSMutableArray alloc]init];
    self.friendTableView.delegate = self;
    self.friendTableView.dataSource = self;
}

- (void)initTableData
{
    self.friendList = [[MTUser sharedInstance] friendList];
    NSLog(@"table data init done");
    self.sortedFriendDic = [[MTUser sharedInstance] sortedFriendDic];
    self.sectionArray = [[MTUser sharedInstance] sectionArray];
    //    NSLog(@"friendviewcontroller: friendList count: %d\n, sortedFriendDic: %@, sectionArray: %@",self.friendList.count, self.sortedFriendDic, self.sectionArray);
    UILabel* friendcount_label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, _friendTableView.frame.size.width, 30)];
    friendcount_label.textAlignment = NSTextAlignmentCenter;
    friendcount_label.textColor = [UIColor grayColor];
    friendcount_label.text = [NSString stringWithFormat:@"%lu位好友",(unsigned long)friendList.count];
    _friendTableView.tableFooterView = friendcount_label;
    [self.friendTableView reloadData];
    
    
    
}
- (IBAction)seleteAll:(id)sender {
}

-(void)showWaitingView
{
    if (!_waitingView) {
        CGRect frame = self.view.bounds;
        _waitingView = [[UIView alloc]initWithFrame:frame];
        [_waitingView setBackgroundColor:[UIColor blackColor]];
        [_waitingView setAlpha:0.5f];
        frame.origin.x = (frame.size.width - 100)/2.0;
        frame.origin.y = (frame.size.height - 100)/2.0;
        frame.size = CGSizeMake(100, 100);
        UIActivityIndicatorView* indicator = [[UIActivityIndicatorView alloc]initWithFrame:frame];
        [indicator startAnimating];
        [_waitingView addSubview:indicator];
        [self.view addSubview:_waitingView];
    }
}

-(void)removeWaitingView
{
    if (_waitingView) {
        [_waitingView removeFromSuperview];
        _waitingView = nil;
    }
}

-(void)inviteFriends:(NSArray*)notFriendsList
{
    _notFriendsList = notFriendsList;
    NSString* names = @"";
    for (int i = 0; i < notFriendsList.count; i++) {
        NSNumber* fid = notFriendsList[i];
        NSString* fname = [[MTUser sharedInstance].alias_dic objectForKey:[NSString stringWithFormat:@"%@",fid]];
        if (fname == nil || [fname isEqual:[NSNull null]]) {
            fname = [[MTUser sharedInstance].nameFromID_dic objectForKey:[NSString stringWithFormat:@"%@",fid]];
        }
        
        if (i == 0) {
            names = [names stringByAppendingString:[NSString stringWithFormat:@"%@",fname]];
        }else{
            names = [names stringByAppendingString:[NSString stringWithFormat:@",%@",fname]];
        }
        
    }
    
    NSString* message = [NSString stringWithFormat:@"%@ 不是你的好友，无法邀请，是否申请添加好友 ？",names];
    
    BOAlertController *alertView = [[BOAlertController alloc] initWithTitle:@"系统消息" message:message viewController:self];
    
    RIButtonItem *cancelItem = [RIButtonItem itemWithLabel:@"取消" action:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.navigationController popToViewController:self.controller animated:YES];
        });
    }];
    [alertView addButton:cancelItem type:RIButtonItemType_Cancel];
    
    RIButtonItem *okItem = [RIButtonItem itemWithLabel:@"确定" action:^{
        
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"添加好友" message:@"请填写好友申请信息：" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        if ([MTUser sharedInstance].name && ![[MTUser sharedInstance].name isEqual:[NSNull null]]) {
            [alert textFieldAtIndex:0].text = [NSString stringWithFormat:@"我是%@",[MTUser sharedInstance].name];
        }
        [alert setTag:120];
        [alert show];

    }];
    [alertView addButton:okItem type:RIButtonItemType_Other];
    [alertView show];
    
    
}

- (IBAction)confirm:(id)sender {
    [sender setEnabled:NO];
    if ([self.controller isKindOfClass:[LaunchEventViewController class]]) {
        [_FriendsIds removeAllObjects];
        for (NSNumber* f in _tmp_fids) {
            [_FriendsIds addObject:f];
        }
        [self.navigationController popToViewController:self.controller animated:YES];
    }
    if ([self.controller isKindOfClass:[showParticipatorsViewController class]]) {
        for (NSNumber* f in _FriendsIds) {
            if([_tmp_fids containsObject:f]){
                [_tmp_fids removeObject:f];
            }
        }
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];

        NSString *friends = @"[";
        BOOL flag = YES;
        for (NSNumber* friendid in _tmp_fids) {
            friends = [friends stringByAppendingString: flag? @"%@":@",%@"];
            if (flag) flag = NO;
            friends = [NSString stringWithFormat:friends,friendid];
        }
        friends = [friends stringByAppendingString:@"]"];
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
        [dictionary setValue:[MTUser sharedInstance].userid forKey:@"id"];
        [dictionary setValue:_eventId forKey:@"event_id"];
        [dictionary setValue:friends forKey:@"friends"];
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
        NSLog(@"%@",[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding]);
        HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
        [httpSender sendMessage:jsonData withOperationCode:INVITE_FRIENDS finshedBlock:^(NSData *rData) {
            if (rData) {
                NSString* temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
                NSLog(@"received Data: %@",temp);
                NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
                NSNumber *cmd = [response1 valueForKey:@"cmd"];
                switch ([cmd intValue]) {
                    case NORMAL_REPLY:
                    {
                        [SVProgressHUD showSuccessWithStatus:@"邀请信息已经发送" duration:1];
                        NSArray* notFriendsList = [response1 valueForKey:@"list"];
                        if (notFriendsList.count) {
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.9 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                [sender setEnabled:YES];
                                [self inviteFriends:notFriendsList];
                            });
                            
                        }else{
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.9 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                [self.navigationController popToViewController:self.controller animated:YES];
                                [sender setEnabled:YES];
                            });
                        }
                        
                    }
                        break;
                    default:
                    {
                        [SVProgressHUD showErrorWithStatus:@"网络异常，请重试" duration:1];
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [sender setEnabled:YES];
                        });
                    }
                }

            }else{
                [SVProgressHUD showErrorWithStatus:@"网络异常，请重试" duration:1];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [sender setEnabled:YES];
                });
            }
        }];
    }
}

#pragma mark - Alert Delegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex;{
    // the user clicked OK
    if (alertView.tag == 120) {
        //批量申请添加好友
        if(buttonIndex == 0){
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.navigationController popToViewController:self.controller animated:YES];
            });
        }else if(buttonIndex == 1){
            NSInteger cancelBtnIndex = alertView.cancelButtonIndex;
            NSInteger okBtnIndex = alertView.firstOtherButtonIndex;
            if (buttonIndex == cancelBtnIndex) {
                ;
            }
            else if (buttonIndex == okBtnIndex)
            {
                [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
                NSString* cm = [alertView textFieldAtIndex:0].text;
                NSNumber* userId = [MTUser sharedInstance].userid;
                for (int i = 0; i < _notFriendsList.count; i++) {
                    NSNumber* friendId = _notFriendsList[i];
                    NSDictionary* json = [CommonUtils packParamsInDictionary:[NSNumber numberWithInt:999],@"cmd",userId,@"id",cm,@"confirm_msg", friendId,@"friend_id",[NSNumber numberWithInt:ADD_FRIEND],@"item_id",nil];
                    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:nil];
                    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
                    [httpSender sendMessage:jsonData withOperationCode:ADD_FRIEND finshedBlock:^(NSData *rData) {
                    }];
                }
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [SVProgressHUD dismissWithSuccess:@"添加好友请求已发送"];
                    [self.navigationController popToViewController:self.controller animated:YES];
                });
                
            }
        }
        
        return;
    }
    if (buttonIndex == 0)
    {
        [self.navigationController popToViewController:self.controller animated:YES];
    }
}

#pragma mark - UITableViewDelegate


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat height = 25;
    
    return height;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

#pragma mark - UITableViewDataSource
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    FriendTableViewCell *cell = (FriendTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    if (![_ExistedIds containsObject:cell.friendid]) {
        if ([self.tmp_fids containsObject:cell.friendid]) {
            [(UIImageView*)[cell viewWithTag:3] setImage:[UIImage imageNamed:@"勾选前icon"]];
            [self.tmp_fids removeObject:cell.friendid];
            NSLog(@"remove: %d",[cell.friendid intValue]);
        }else{
            [(UIImageView*)[cell viewWithTag:3] setImage:[UIImage imageNamed:@"勾选后icon"]];
            [self.tmp_fids addObject:cell.friendid];
            NSLog(@"add: %d",[cell.friendid intValue]);
        }
    }
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray* groupOfFriends = [sortedFriendDic objectForKey:(NSString*)[sectionArray objectAtIndex:section+1]];
    if (groupOfFriends) {
        return groupOfFriends.count;
    }
    else
        return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    NSArray* groupOfFriends = [sortedFriendDic objectForKey:(NSString*)[self.sectionArray objectAtIndex:section+1]];
    if (groupOfFriends) {
        NSDictionary* aFriend = [groupOfFriends objectAtIndex:row];
        NSString* label = [aFriend objectForKey:@"name"];
        NSNumber* fid = [CommonUtils NSNumberWithNSString:[aFriend objectForKey:@"id"]];

        FriendTableViewCell* cell = [self.friendTableView dequeueReusableCellWithIdentifier:@"friendcell"];
        if (nil == cell) {
            cell = [[FriendTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"friendcell"];
        }
        
        PhotoGetter* getter = [[PhotoGetter alloc]initWithData:cell.avatar authorId:fid];
        [getter getAvatar];
        
        NSString* alias = [[MTUser sharedInstance].alias_dic objectForKey:[NSString stringWithFormat:@"%@",fid]];
        if (alias && ![alias isEqual:[NSNull null]]) {
            cell.title.text = alias;
        }
        else if (label) {
            cell.title.text = label;
        }
        else
        {
            cell.title.text = @"default";
        }
        
        cell.friendid = fid;
        
        if ([self.tmp_fids containsObject:cell.friendid]) {
            [(UIImageView*)[cell viewWithTag:3] setImage:[UIImage imageNamed:@"勾选后icon"]];
        }else{
            [(UIImageView*)[cell viewWithTag:3] setImage:[UIImage imageNamed:@"勾选前icon"]];
        }
        return cell;
    }
    return nil;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return sectionArray.count - 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.sectionArray objectAtIndex:section + 1];
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




@end
