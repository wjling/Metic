//
//  AddFriendViewController.m
//  Metic
//
//  Created by mac on 14-6-3.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "AddFriendViewController.h"

@interface AddFriendViewController ()

@end

@implementation AddFriendViewController

@synthesize user;
@synthesize searchedFriendsTableView;
@synthesize friendSearchBar;
@synthesize searchFriendList;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.user = [MTUser sharedInstance];
    self.friendSearchBar.delegate = self;
    self.searchedFriendsTableView.delegate = self;
    self.searchedFriendsTableView.dataSource = self;
//    self.searchedFriendsTableView.hidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)search_friend
{
    NSString* text = self.friendSearchBar.text;
    if ([CommonUtils isEmailValid:text]) {
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
        dictionary = [CommonUtils packParamsInDictionary:text,@"email",self.user.userid,@"myId",nil];
        NSLog(@"%@",dictionary);
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
        HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
        [httpSender sendMessage:jsonData withOperationCode:SEARCH_FRIEND];
    }
    else
    {
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
        dictionary = [CommonUtils packParamsInDictionary:text,@"name",self.user.userid,@"myId",nil];
        NSLog(@"%@",dictionary);
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
        HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
        [httpSender sendMessage:jsonData withOperationCode:SEARCH_FRIEND];;
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
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar                     // called when keyboard search button pressed
{
    [self search_friend];
    [searchBar resignFirstResponder];
//    [self.searchedFriendsTableView reloadData];
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
    NSLog(@"searchFriendList.count: %lu",(unsigned long)self.searchFriendList.count);
    return self.searchFriendList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SearchedFriendTableViewCell* cell = [self.searchedFriendsTableView dequeueReusableCellWithIdentifier:@"searchedfriendcell"];
    if (nil == cell) {
        cell = [[SearchedFriendTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"searchedfriendcell"];
    }
    NSDictionary* aFriend = [self.searchFriendList objectAtIndex:indexPath.row];
    //    NSLog(@"a friend: %@",aFriend);
    NSString* name = [aFriend objectForKey:@"name"];
    NSLog(@"friend name: %@",name);
//    NSData* name = [aFriend objectForKey:@"name"];
//    NSString* str_name = [[NSString alloc]initWithData:name encoding:NSUTF8StringEncoding];
//    cell.avatar.image = [UIImage imageNamed:@"default_avatar.jpg"];
    if (name) {
        cell.friendNameLabel.text = @"omg";
    }
    else
    {
        cell.friendNameLabel.text = @"default";
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
    NSNumber* cmd = [response1 objectForKey:@"cmd"];
    NSLog(@"cmd: %@",cmd);
    if (cmd) {
        if ([cmd intValue] == USER_NOT_FOUND) {
            NSLog(@"user not found");
        }
        else if ( [cmd intValue] == USER_EXIST)
        {
            self.searchFriendList = [response1 objectForKey:@"friend_list"];
            NSLog(@"searched friend list: %@",self.searchFriendList);
//            self.searchedFriendsTableView.hidden = NO;
        }
    }
    NSLog(@"reload data.");
    [self.searchedFriendsTableView reloadData];
}






@end
