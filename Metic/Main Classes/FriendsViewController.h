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
//#import "MTEvent.h"
#import "AppDelegate.h"
//#import "MTEvent.h"
#import "MJRefreshHeaderView.h"
#import "FriendTableViewCell.h"

@interface FriendsViewController : UIViewController <SlideNavigationControllerDelegate,HttpSenderDelegate,UITableViewDelegate,UITableViewDataSource,MJRefreshBaseViewDelegate>

@property(nonatomic,strong)MTUser *user;
@property(nonatomic,strong)NSMutableArray* friendList;
@property (strong, nonatomic) IBOutlet UITableView *friendTableView;


- (void)synchronize_friends;
@end
