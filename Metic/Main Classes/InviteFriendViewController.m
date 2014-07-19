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
}
@synthesize user;
@synthesize friendList;
@synthesize sortedFriendDic;
@synthesize sectionArray;
@synthesize searchFriendList;
@synthesize DB;

- (void)viewDidLoad
{
    [super viewDidLoad];
    //下面的if语句是为了解决iOS7上navigationbar可以和别的view重叠的问题
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0))
    {
        self.edgesForExtendedLayout= UIRectEdgeNone;
    }
    
    self.user = [MTUser sharedInstance];
    DB_path = [NSString stringWithFormat:@"%@/db",user.userid];
    self.sectionArray = [[NSMutableArray alloc]init];
    self.DB = [[MySqlite alloc]init];
    self.friendTableView.delegate = self;
    self.friendTableView.dataSource = self;
    _tmp_fids = [[NSMutableSet alloc]initWithSet:_FriendsIds];
    self.friendList = [self getFriendsFromDB];
    self.sortedFriendDic = [self sortFriendList];
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
    NSLog(@"friendlist count: %d",friendList.count);
    for (NSMutableDictionary* aFriend in self.friendList) {
        NSString* fname_py = [CommonUtils pinyinFromNSString:[aFriend objectForKey:@"name"]];
        NSLog(@"friend name: %@",fname_py);
        NSString* first_letter = [fname_py substringWithRange:NSMakeRange(0, 1)];
        NSMutableArray* groupOfFriends = [sorted objectForKey:[first_letter uppercaseString]];
        
        if (groupOfFriends) {
            [groupOfFriends addObject:aFriend];
            NSLog(@"a friend: %@",aFriend);
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
        NSInteger result = [obj1_py compare:obj2_py];
        return result;
    };
    [friends sortUsingComparator:cmptor];
}

- (IBAction)switchToAddFriendView:(id)sender
{
    
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
    NSArray* groupOfFriends = [sortedFriendDic objectForKey:(NSString*)[sectionArray objectAtIndex:section]];
    return groupOfFriends.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FriendTableViewCell* cell = [self.friendTableView dequeueReusableCellWithIdentifier:@"friendcell"];
    if (nil == cell) {
        cell = [[FriendTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"friendcell"];
    }
    NSArray* groupOfFriends = [sortedFriendDic objectForKey:(NSString*)[self.sectionArray objectAtIndex:indexPath.section]];
    NSDictionary* aFriend = [groupOfFriends objectAtIndex:indexPath.row];
    NSString* name = [aFriend objectForKey:@"name"];
    PhotoGetter* getter = [[PhotoGetter alloc]initWithData:cell.avatar authorId:[CommonUtils NSNumberWithNSString:[aFriend valueForKey:@"id"]]];
    [getter getPhoto];
    cell.friendid = [CommonUtils NSNumberWithNSString:[aFriend valueForKey:@"id"]];
    if (name) {
        cell.title.text = name;
    }
    else
    {
        cell.title.text = @"default";
    }

    if ([self.tmp_fids containsObject:cell.friendid]) {
        [(UIImageView*)[cell viewWithTag:3] setImage:[UIImage imageNamed:@"勾选后icon"]];
    }else{
        [(UIImageView*)[cell viewWithTag:3] setImage:[UIImage imageNamed:@"勾选前icon"]];
    }
    return cell;
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




@end
