//
//  AddFriendViewController.m
//  Metic
//
//  Created by mac on 14-6-3.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "AddFriendViewController.h"
#import "ScanViewController.h"
#import "ContactsViewController.h"
#import "NearbyPeopleViewController.h"
#import "KankanViewController.h"

@interface AddFriendViewController () <UIAlertViewDelegate>

@end

@implementation AddFriendViewController
{
    int friendPosition;
}

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
    [CommonUtils addLeftButton:self isFirstPage:NO];
    //下面的if语句是为了解决iOS7上navigationbar可以和别的view重叠的问题
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0))
    {
        self.edgesForExtendedLayout= UIRectEdgeNone;
    }

    // Do any additional setup after loading the view.
    self.friendSearchBar.delegate = self;
    self.searchedFriendsTableView.delegate = self;
    self.searchedFriendsTableView.dataSource = self;
    self.searchedFriendsTableView.scrollEnabled = NO;
//    self.searchedFriendsTableView.hidden = YES;
}

//返回上一层
-(void)MTpopViewController{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"addfriend_searchfriend"]) {
        MTLOG(@"passing searchName : %@",self.friendSearchBar.text);
        if ([segue.destinationViewController isKindOfClass: [SearchFriendViewController class]]) {
            SearchFriendViewController* vc = segue.destinationViewController;
            vc.searchName = self.friendSearchBar.text;
            
        }

    }
    if ([segue.destinationViewController isKindOfClass:[ScanViewController class]]) {
        ScanViewController *nextViewController = segue.destinationViewController;
        nextViewController.needPopBack = YES;
    }
    
}


- (void)search_friend
{
    NSString* text = self.friendSearchBar.text;
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    dictionary = [CommonUtils packParamsInDictionary:text,@"name",[MTUser sharedInstance].userid,@"myId",nil];
    MTLOG(@"%@",dictionary);
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:SEARCH_FRIEND];
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
    [self performSegueWithIdentifier:@"addfriend_searchfriend" sender:self];
}

#pragma mark - UITableViewDelegate


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat height = 0;
    
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (section == 0) {
        if (row == 0) {
            UIStoryboard* mainStoryBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
            ContactsViewController *vc = [mainStoryBoard instantiateViewControllerWithIdentifier:@"ContactsViewController"];
            [self.navigationController pushViewController:vc animated:YES];
            
        } else if (row == 1) {
            UIStoryboard* mainStoryBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
            NearbyPeopleViewController *vc = [mainStoryBoard instantiateViewControllerWithIdentifier:@"NearbyPeopleViewController"];
            [self.navigationController pushViewController:vc animated:YES];
            
        } else if (row == 2) {
            UIStoryboard* mainStoryBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
            KankanViewController *vc = [mainStoryBoard instantiateViewControllerWithIdentifier:@"KankanViewController"];
            [self.navigationController pushViewController:vc animated:YES];
        }
    } else if (section == 1) {
        [self performSegueWithIdentifier:@"addfriend_sao" sender:self];
    }
}



#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 3;
    } else if (section == 1) {
        return 1;
    } else
        return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (nil == cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    if (indexPath.section == 1) {
        cell.textLabel.text = @"扫一扫";
    }else  if (indexPath.row == 0) {
        cell.textLabel.text = @"手机联系人";
    }else  if (indexPath.row == 1) {
        cell.textLabel.text = @"附近的人";
    }else  if (indexPath.row == 2) {
        cell.textLabel.text = @"随便看看";
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
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
    MTLOG(@"Received Data: %@",temp);
    NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
    NSNumber* cmd = [response1 objectForKey:@"cmd"];
    MTLOG(@"cmd: %@",cmd);
    if (cmd) {
        if ([cmd intValue] == USER_NOT_FOUND) {
            MTLOG(@"user not found");
        }
        else if ( [cmd intValue] == USER_EXIST)
        {
            self.searchFriendList = [response1 objectForKey:@"friend_list"];
            MTLOG(@"searched friend list: %@",self.searchFriendList);
            self.searchedFriendsTableView.hidden = NO;
        }
    }
//    MTLOG(@"reload data.");
    [self.searchedFriendsTableView reloadData];
}


#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case 0:{
            NSInteger cancelBtnIndex = alertView.cancelButtonIndex;
            NSInteger okBtnIndex = alertView.firstOtherButtonIndex;
            if (buttonIndex == cancelBtnIndex) {
                ;
            }
            else if (buttonIndex == okBtnIndex)
            {
                NSString* cm = [alertView textFieldAtIndex:0].text;
                NSNumber* userId = [MTUser sharedInstance].userid;
                NSNumber* friendId = [[searchFriendList objectAtIndex:friendPosition] objectForKey:@"id"];
                NSDictionary* json = [CommonUtils packParamsInDictionary:[NSNumber numberWithInt:ADD_FRIEND_NOTIFICATION],@"cmd",userId,@"id",cm,@"confirm_msg", friendId,@"friend_id",[NSNumber numberWithInt:ADD_FRIEND],@"item_id",nil];
                NSData* jsonData = [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:nil];
                HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
                [httpSender sendMessage:jsonData withOperationCode:ADD_FRIEND];
                MTLOG(@"add friend apply: %@",json);
            }
        }
            break;
            
        default:
            break;
    }
}
@end
