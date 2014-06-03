//
//  FriendsViewController.m
//  SlideMenu
//
//  Created by Aryan Ghassemi on 12/31/13.
//  Copyright (c) 2013 Aryan Ghassemi. All rights reserved.
//

#import "FriendsViewController.h"

@implementation FriendsViewController
@synthesize user;
@synthesize friendList;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.user = [MTUser sharedInstance];
    self.friendTableView.delegate = self;
    self.friendTableView.dataSource = self;
    
    [self synchronize_friends];
}

- (void)synchronize_friends
{
    NSNumber* userId = self.user.userid;
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:userId forKey:@"id"];
    [dictionary setValue:[NSNumber numberWithInt:0] forKey:@"friends_number"];
    NSLog(@"%@",dictionary);
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:SYNCHRONIZE_FRIEND];

}

#pragma mark - UITableViewDelegate


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat height = 30;
    
    return height;
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.friendList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FriendTableViewCell* cell = [self.friendTableView dequeueReusableCellWithIdentifier:@"friendcell"];
    if (nil == cell) {
        cell = [[FriendTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"friendcell"];
    }
    NSDictionary* aFriend = [self.friendList objectAtIndex:indexPath.row];
    NSLog(@"a friend: %@",aFriend);
    NSString* name = [aFriend objectForKey:@"name"];
    if (name) {
        cell.title.text = name;
    }
    else
    {
        cell.title.text = @"default";
    }
    
//    cell.image = [[UIImage alloc]init];
    return cell;
}

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    
//}
//
//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    
//}
//
//- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
//{
//    
//}
//
//- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
//{
//    
//}

#pragma mark - HttpSenderDelegate
- (void)finishWithReceivedData:(NSData *)rData
{
    NSString* temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
    NSLog(@"Received Data: %@",temp);
    NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
    self.friendList = [response1 valueForKey:@"friend_list"];
    NSLog(@"Friend List: %@",friendList);
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

@end
