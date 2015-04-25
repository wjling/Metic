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

#import "PhotoGetter.h"
#import "FriendInfoViewController.h"
#import "TTTAttributedLabel.h"

@interface FriendsViewController : UIViewController <SlideNavigationControllerDelegate,HttpSenderDelegate,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,MJRefreshBaseViewDelegate,UISearchDisplayDelegate,UIScrollViewDelegate>

@property(nonatomic,strong)NSMutableArray* friendList;
@property (strong,nonatomic)NSMutableDictionary* sortedFriendDic;
@property(nonatomic,strong)NSMutableArray* searchFriendList;
@property (nonatomic,strong) NSMutableArray* searchFriendKeyWordRangeArr;
@property (strong,nonatomic) NSMutableArray* sectionArray;
@property (strong, nonatomic) NSMutableArray* sectionTitlesArray;
@property (strong, nonatomic) IBOutlet UITableView *friendTableView;
@property (strong, nonatomic) IBOutlet UISearchBar *friendSearchBar;
@property (strong, nonatomic) IBOutlet UIButton *addFriendBtn;
@property (strong, nonatomic) IBOutlet UIView *shadowView;
@property (strong, nonatomic) IBOutlet UISearchDisplayController *friendSearchDisplayController;



- (void)initParams;
- (void)initTableData;
//- (void)synchronize_friends;
- (IBAction)switchToAddFriendView:(id)sender;

//- (void) createFriendTable;
//- (void) insertToFriendTable:(NSArray*)friends;
//- (NSMutableArray*)getFriendsFromDB;
//- (NSMutableDictionary*)sortFriendList;
//- (void)rankFriendsInArray:(NSMutableArray*)friends;
@end
