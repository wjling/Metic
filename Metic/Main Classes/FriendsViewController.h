//
//  FriendsViewController.h
//  SlideMenu
//
//  Created by Aryan Ghassemi on 12/31/13.
//  Copyright (c) 2013 Aryan Ghassemi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlideNavigationController.h"
#import "HttpSender.h"
#import "CommonUtils.h"
#import "SlideNavigationController.h"
#import "AppConstants.h"
#import "MTUser.h"
#import "AppDelegate.h"
#import "MJRefreshHeaderView.h"
#import "FriendTableViewCell.h"
#import "NotificationCenterCell.h"
#import "MySqlite.h"
#import "PhotoGetter.h"
#import "FriendInfoViewController.h"

@interface FriendsViewController : UIViewController <SlideNavigationControllerDelegate,HttpSenderDelegate,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,MJRefreshBaseViewDelegate>

@property(nonatomic,strong)MTUser *user;
@property(nonatomic,strong)NSMutableArray* friendList;
@property (strong,nonatomic)NSMutableDictionary* sortedFriendDic;
@property(nonatomic,strong)NSMutableArray* searchFriendList;
@property (strong,nonatomic) NSMutableArray* sectionArray;
@property (strong, nonatomic) IBOutlet UITableView *friendTableView;
@property (strong, nonatomic) IBOutlet UISearchBar *friendSearchBar;
@property (strong, nonatomic) MySqlite* DB;
@property (strong, nonatomic) IBOutlet UIButton *addFriendBtn;
@property (strong, nonatomic) IBOutlet UIView *shadowView;


- (void)initParams;
- (void)initTableData;
//- (void)synchronize_friends;
- (IBAction)search_friends:(id)sender;
- (IBAction)switchToAddFriendView:(id)sender;

//- (void) createFriendTable;
//- (void) insertToFriendTable:(NSArray*)friends;
//- (NSMutableArray*)getFriendsFromDB;
//- (NSMutableDictionary*)sortFriendList;
//- (void)rankFriendsInArray:(NSMutableArray*)friends;
@end
