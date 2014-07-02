//
//  FriendsViewController.m
//  SlideMenu
//
//  Created by Aryan Ghassemi on 12/31/13.
//  Copyright (c) 2013 Aryan Ghassemi. All rights reserved.
//

#import "InviteFriendViewController.h"

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
    self.friendList = [self getFriendsFromDB];
    self.sortedFriendDic = [self sortFriendList];
    [self.friendTableView reloadData];
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


#pragma mark - UITableViewDataSource
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    FriendTableViewCell *cell = (FriendTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    [(UIImageView*)[cell viewWithTag:3] setHidden:!((UIImageView*)[cell viewWithTag:3]).isHidden];
    if ([self.FriendsIds containsObject:cell.friendid]) {
        [self.FriendsIds removeObject:cell.friendid];
        NSLog(@"remove: %d",[cell.friendid intValue]);
    }else{
        
        [self.FriendsIds addObject:cell.friendid];
        NSLog(@"add: %d",[cell.friendid intValue]);
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
    cell.avatar.image = [UIImage imageNamed:@"默认用户头像"];
    cell.friendid = [aFriend objectForKey:@"id"];
    if (name) {
        cell.title.text = name;
    }
    else
    {
        cell.title.text = @"default";
    }
    
    if ([self.FriendsIds containsObject:cell.friendid]) {
        [(UIImageView*)[cell viewWithTag:3] setHidden:NO];
    }else{
        
        [(UIImageView*)[cell viewWithTag:3] setHidden:YES];
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
