//
//  AddFriendViewController.h
//  Metic
//
//  Created by mac on 14-6-3.
//  Copyright (c) 2014年 dishcool. All rights reserved.
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
#import "SearchedFriendTableViewCell.h"
#import "SearchFriendViewController.h"

@interface AddFriendViewController : UIViewController<HttpSenderDelegate,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,MJRefreshBaseViewDelegate>
@property (strong, nonatomic) IBOutlet UISearchBar *friendSearchBar;
@property(nonatomic,strong)NSMutableArray* searchFriendList;
@property (strong, nonatomic) IBOutlet UITableView *searchedFriendsTableView;

- (void)search_friend;
@end
