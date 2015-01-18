//
//  FriendRecommendationViewController.h
//  WeShare
//
//  Created by mac on 14-8-17.
//  Copyright (c) 2014年 dishcool. All rights reserved.
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

@interface FriendRecommendationViewController : UIViewController<UIScrollViewDelegate,BMKLocationServiceDelegate,UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>
@property (strong, nonatomic) IBOutlet UIScrollView *tabbar_scrollview;
@property (strong, nonatomic) IBOutlet UIScrollView *content_scrollview;

@property (strong, nonatomic) IBOutlet UIButton *tab1;
@property (strong, nonatomic) IBOutlet UIButton *tab2;
@property (strong, nonatomic) IBOutlet UIButton *tab3;

@property (strong, nonatomic) IBOutlet UIView *tabPage1_view;
@property (strong, nonatomic) IBOutlet UIView *noUpload_view;
@property (strong, nonatomic) IBOutlet UIButton *addContacts_button;
@property (strong, nonatomic) IBOutlet UIView *hasUpload_view;
@property (strong, nonatomic) IBOutlet UITableView *contacts_tableview;

@property (strong, nonatomic) IBOutlet UIView *tabPage2_view;
@property (strong, nonatomic) IBOutlet UITableView *nearbyFriends_tableview;
@property (strong, nonatomic) MJRefreshHeaderView* nearbyFriends_header;
@property (strong, nonatomic) MJRefreshFooterView* nearbyFriends_footer;

@property (strong, nonatomic) IBOutlet UIView *tabPage3_view;
@property (strong, nonatomic) IBOutlet UITableView *kankan_tableview;

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (strong, nonatomic) NSMutableArray* contacts_arr;
@property CLLocationCoordinate2D coordinate;
@property (strong, nonatomic) BMKLocationService* locationService;
@property (nonatomic, strong) CLLocationManager  *locationManager;
@property (strong, nonatomic) NSMutableArray* contactFriends_arr;
@property (strong, nonatomic) NSMutableArray* nearbyFriends_arr;
@property (strong, nonatomic) NSMutableArray* kankan_arr;
@property (strong, nonatomic) NSMutableArray* phoneNumbers;

@end
