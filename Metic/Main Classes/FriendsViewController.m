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
@synthesize searchFriendList;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.user = [MTUser sharedInstance];
    self.friendTableView.delegate = self;
    self.friendTableView.dataSource = self;
    self.friendSearchBar.delegate = self;
    
    [self synchronize_friends];
    NSLog(@"did reload friends");
    [self.friendTableView reloadData];
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
    CGFloat height = 0;
    
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
//    NSLog(@"a friend: %@",aFriend);
    NSString* name = [aFriend objectForKey:@"name"];
    cell.avatar.image = [UIImage imageNamed:@"default_avatar.jpg"];
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
           
            self.friendList = [response1 valueForKey:@"friend_list"];
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

@end
