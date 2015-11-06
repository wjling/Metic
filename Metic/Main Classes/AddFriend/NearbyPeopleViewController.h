//
//  NearbyPeopleViewController.h
//  WeShare
//
//  Created by 俊健 on 15/11/6.
//  Copyright (c) 2015年 WeShare. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import "CommonUtils.h"
#import "HttpSender.h"
#import "PhotoGetter.h"
#import "BMapKit.h"
#import "ContactsRecommendTableViewCell.h"
#import "SearchedFriendTableViewCell.h"
#import "AddFriendConfirmViewController.h"

@class MJRefreshHeaderView;
@class MJRefreshFooterView;

@interface NearbyPeopleViewController : UIViewController<UIScrollViewDelegate,BMKLocationServiceDelegate,UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>

@property (strong, nonatomic) IBOutlet UIView *tabPage2_view;
@property (strong, nonatomic) IBOutlet UITableView *nearbyFriends_tableview;
@property (strong, nonatomic) MJRefreshHeaderView *nearbyFriends_header;
@property (strong, nonatomic) MJRefreshFooterView *nearbyFriends_footer;

@property CLLocationCoordinate2D coordinate;
@property (strong, nonatomic) BMKLocationService *locationService;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (strong, nonatomic) NSMutableArray *nearbyFriends_arr;

@end
