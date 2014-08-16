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

@interface InviteFriendViewController ()
@property (nonatomic,strong) NSMutableSet *tmp_fids;

@end
@implementation InviteFriendViewController
{
    NSString* DB_path;
    NSInteger initialSectionForFriendList;
}
@synthesize friendList;
@synthesize sortedFriendDic;
@synthesize sectionArray;
@synthesize sectionTitlesArray;
@synthesize searchFriendList;
@synthesize DB;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [CommonUtils addLeftButton:self];
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
    [self initTableData];
}

//返回上一层
-(void)MTpopViewController{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) initParams
{
    DB_path = [NSString stringWithFormat:@"%@/db",[MTUser sharedInstance].userid];
    initialSectionForFriendList = 1;
    self.sectionArray = [[NSMutableArray alloc]init];
    self.DB = [[MySqlite alloc]init];
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
    [self.friendTableView reloadData];
    
    
    
}
- (IBAction)seleteAll:(id)sender {
}

- (IBAction)confirm:(id)sender {
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
        [httpSender sendMessage:jsonData withOperationCode:INVITE_FRIENDS];
    }
    
}


#pragma mark - HttpSenderDelegate

-(void)finishWithReceivedData:(NSData *)rData
{
    NSString* temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
    rData = [temp dataUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"received Data: %@",temp);
    NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
    NSNumber *cmd = [response1 valueForKey:@"cmd"];
    switch ([cmd intValue]) {
        case NORMAL_REPLY:
        {
            [CommonUtils showSimpleAlertViewWithTitle:@"消息" WithMessage:@"邀请信息已经发送，等待对方处理" WithDelegate:self WithCancelTitle:@"确定"];
        }
            break;
    }
}

#pragma mark - Alert Delegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex;{
    // the user clicked OK
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
        NSNumber* fid = [aFriend objectForKey:@"id"];

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
