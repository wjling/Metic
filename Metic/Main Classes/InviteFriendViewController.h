//
//  InviteFriendViewController.h
//  Metic
//
//  Created by ligang6 on 14-6-24.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlideNavigationController.h"
#import "HttpSender.h"
#import "CommonUtils.h"
#import "AppConstants.h"
#import "MTUser.h"
//#import "MTEvent.h"
#import "AppDelegate.h"
//#import "MTEvent.h"
#import "MJRefreshHeaderView.h"
#import "FriendTableViewCell.h"
#import "MySqlite.h"

@interface InviteFriendViewController : UIViewController <SlideNavigationControllerDelegate,HttpSenderDelegate,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,MJRefreshBaseViewDelegate>

@property(nonatomic,strong)MTUser *user;
@property(nonatomic,strong)NSMutableArray* friendList;
@property (strong,nonatomic)NSMutableDictionary* sortedFriendDic;
@property(nonatomic,strong)NSMutableArray* searchFriendList;
@property (strong,nonatomic) NSMutableArray* sectionArray;
@property (strong, nonatomic) IBOutlet UITableView *friendTableView;
@property (strong, nonatomic) MySqlite* DB;
@property (strong, nonatomic) NSMutableSet *FriendsIds;
@property (strong, nonatomic) UIViewController* controller;
@property (strong, nonatomic) NSNumber* eventId;

- (IBAction)seleteAll:(id)sender;
- (IBAction)confirm:(id)sender;
- (NSMutableArray*)getFriendsFromDB;
- (NSMutableDictionary*)sortFriendList;
- (void)rankFriendsInArray:(NSMutableArray*)friends;
@end
