//
//  SearchFriendViewController.m
//  Metic
//
//  Created by mac on 14-7-30.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "SearchFriendViewController.h"

@interface SearchFriendViewController ()
{
    NSInteger friendPosition;
}

@end

@implementation SearchFriendViewController
@synthesize searchName;
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
    [CommonUtils addLeftButton:self isFirstPage:NO];
//    self.content_tableview.hidden = YES;
    self.waiting_activityindicator.hidden = NO;
    [self.waiting_activityindicator startAnimating];
    self.fsearchBar.delegate = self;
    self.fsearchBar.text = searchName;
    self.content_tableview.delegate = self;
    self.content_tableview.dataSource = self;
    
    NSLog(@"search friend name: %@, my ID : %@",searchName,[MTUser sharedInstance].userid);
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    dictionary = [CommonUtils packParamsInDictionary:self.searchName,@"name",[MTUser sharedInstance].userid,@"myId",nil];
    NSLog(@"search friend: %@",dictionary);
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:SEARCH_FRIEND];
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
    if ([[segue identifier] isEqualToString:@"searchfriend_friendinfo"]) {
        if ([sender isKindOfClass:[NSIndexPath class]]) {
            if ([[segue destinationViewController] isKindOfClass:[FriendInfoViewController class]]) {
                FriendInfoViewController* vc = segue.destinationViewController;
                vc.fid = [[self.searchFriendList objectAtIndex:((NSIndexPath*)sender).row] objectForKey:@"id"];
            }
        }
    }
    else if ([[segue identifier] isEqualToString:@"searchfriend_comfirmMsg"])
    {
        if ([[segue destinationViewController] isKindOfClass:[AddFriendConfirmViewController class]]) {
            AddFriendConfirmViewController* vc = segue.destinationViewController;
            vc.fid = [[self.searchFriendList objectAtIndex:friendPosition] objectForKey:@"id"];;
        }
    }
}

-(void)startIndicator
{
    self.waiting_activityindicator.hidden = NO;
    [self.waiting_activityindicator startAnimating];
}



- (void)search_friend
{
    NSString* text = self.fsearchBar.text;
    //    if ([CommonUtils isEmailValid:text]) {
    //        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    //        dictionary = [CommonUtils packParamsInDictionary:text,@"email",self.user.userid,@"myId",nil];
    //        NSLog(@"%@",dictionary);
    //
    //        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    //        HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    //        [httpSender sendMessage:jsonData withOperationCode:SEARCH_FRIEND];
    //    }
    //    else
    //    {
    //        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    //        dictionary = [CommonUtils packParamsInDictionary:text,@"name",self.user.userid,@"myId",nil];
    //        NSLog(@"%@",dictionary);
    //
    //        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    //        HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    //        [httpSender sendMessage:jsonData withOperationCode:SEARCH_FRIEND];;
    //    }
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    dictionary = [CommonUtils packParamsInDictionary:text,@"name",[MTUser sharedInstance].userid,@"myId",nil];
    NSLog(@"%@",dictionary);
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:SEARCH_FRIEND];
    self.waiting_activityindicator.hidden = NO;
}

-(void)addFriendBtnClicked:(UIButton*)sender
{
    friendPosition = sender.tag;
    [self performSegueWithIdentifier:@"searchfriend_comfirmMsg" sender:sender];
}

//=======================================================================
#pragma  mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"searchFriendList.count: %lu",(unsigned long)self.searchFriendList.count);
    return self.searchFriendList.count;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SearchedFriendTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"searchedfriendcell"];
    if (nil == cell) {
        //        NSLog(@"create cell");
        cell = [[SearchedFriendTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"searchedfriendcell"];
    }
    NSDictionary* aFriend = [self.searchFriendList objectAtIndex:indexPath.row];
    NSLog(@"a friend: %@",aFriend);
    NSString* name = [aFriend objectForKey:@"name"];
    NSString* location = [aFriend objectForKey:@"location"];
    NSInteger gender = [[aFriend objectForKey:@"gender"] integerValue];
    NSNumber* fid = [aFriend objectForKey:@"id"];
    BOOL isFriend = [[aFriend objectForKey:@"isFriend"]boolValue];
    NSLog(@"is friend ?: %@",isFriend? @"YES":@"NO");
    if (isFriend) {
        cell.theLabel.hidden = NO;
        cell.add_button.hidden = YES;
    }
    else
    {
        cell.theLabel.hidden = YES;
        cell.add_button.hidden = NO;
    }
    if (![name isEqual:[NSNull null]]) {
        cell.friendNameLabel.text = name;
    }
    else
    {
        cell.friendNameLabel.text = @"default";
    }
    if (![location isEqual:[NSNull null]]) {
        cell.location_label.text = location;
    }
    else
    {
        cell.location_label.text = @"";
    }
    
    PhotoGetter* getter = [[PhotoGetter alloc]initWithData:cell.avatar_imageview authorId:fid];
    [getter getAvatar];
    
    UIFont* mFont = [UIFont systemFontOfSize:15];
    CGSize sizeOfName = [cell.friendNameLabel.text sizeWithFont:mFont constrainedToSize:CGSizeMake(MAXFLOAT, 0) lineBreakMode:NSLineBreakByCharWrapping];
    if (cell.gender_imageview) {
        [cell.gender_imageview removeFromSuperview];
    }
    else
    {
        cell.gender_imageview = [[UIImageView alloc]init];
    }
    cell.gender_imageview.frame = CGRectMake(cell.friendNameLabel.frame.origin.x + sizeOfName.width + 5, 5, 16, 16);
    if (gender == 0) {
        cell.gender_imageview.image = [UIImage imageNamed:@"女icon"];
    }
    else{
        cell.gender_imageview.image = [UIImage imageNamed:@"男icon"];
    }
    [cell.contentView addSubview:cell.gender_imageview];
    
    NSLog(@"gender frame: x: %f, y: %f, width: %f, height: %f",cell.gender_imageview.frame.origin.x,cell.gender_imageview.frame.origin.y,cell.gender_imageview.frame.size.width,cell.gender_imageview.frame.size.height);
    cell.add_button.tag = indexPath.row;
    [cell.add_button addTarget:self action:@selector(addFriendBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
//==============================================================================
#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self performSegueWithIdentifier:@"searchfriend_friendinfo" sender:indexPath];
   
}

//======================================================================
#pragma mark - UISearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar                     // called when keyboard search button pressed
{
    [self search_friend];
    [searchBar resignFirstResponder];
    
    //    [self.searchedFriendsTableView reloadData];
}


#pragma mark - HttpSenderDelegate
- (void)finishWithReceivedData:(NSData *)rData
{
    NSString* temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
    NSLog(@"Received Data: %@",temp);
    NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
    NSNumber* cmd = [response1 objectForKey:@"cmd"];
    NSLog(@"cmd: %@",cmd);
    self.waiting_activityindicator.hidden = YES;
    if (cmd) {
        if ([cmd intValue] == USER_NOT_FOUND) {
            NSLog(@"user not found");
        }
        else if ( [cmd intValue] == USER_EXIST)
        {
            self.searchFriendList = [response1 objectForKey:@"friend_list"];
            NSLog(@"searched friend list: %@",self.searchFriendList);
//            self.content_tableview.hidden = NO;
        }
    }
    //    NSLog(@"reload data.");
    [self.content_tableview reloadData];
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
                NSDictionary* json = [CommonUtils packParamsInDictionary:[NSNumber numberWithInt:999],@"cmd",userId,@"id",cm,@"confirm_msg", friendId,@"friend_id",[NSNumber numberWithInt:ADD_FRIEND],@"item_id",nil];
                NSData* jsonData = [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:nil];
                HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
                [httpSender sendMessage:jsonData withOperationCode:ADD_FRIEND];
                NSLog(@"add friend apply: %@",json);
            }
        }
            break;
            
        default:
            break;
    }
}



@end
