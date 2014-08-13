//
//  SearchFriendViewController.h
//  Metic
//
//  Created by mac on 14-7-30.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonUtils.h"
#import "HttpSender.h"
#import "MTUser.h"
#import "AppConstants.h"
#import "SearchedFriendTableViewCell.h"
#import "FriendInfoViewController.h"
#import "PhotoGetter.h"
#import "AddFriendConfirmViewController.h"

@interface SearchFriendViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,UIAlertViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *content_tableview;
@property (strong, nonatomic) IBOutlet UISearchBar *fsearchBar;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *waiting_activityindicator;
@property (strong, nonatomic)NSString* searchName;
@property (strong, nonatomic)NSMutableArray* searchFriendList;

@end
