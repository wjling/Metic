//
//  NotificationsViewController.h
//  Metic
//
//  Created by mac on 14-6-23.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppConstants.h"
#import "AppDelegate.h"
#import "MySqlite.h"
#import "HttpSender.h"
#import "MTUser.h"
#import "CommonUtils.h"
#import "NotificationsEventRequestTableViewCell.h"
#import "NotificationsFriendRequestTableViewCell.h"
#import "NotificationsSystemMessageTableViewCell.h"
#import "PhotoGetter.h"


@interface NotificationsViewController : UIViewController <HttpSenderDelegate,UITableViewDelegate,UITableViewDataSource,SlideNavigationControllerDelegate,UIScrollViewDelegate,PhotoGetterDelegate>
@property (strong,nonatomic) NSMutableArray* msgFromDB;
@property (strong,nonatomic) NSMutableArray* friendRequestMsg;
@property (strong,nonatomic) NSMutableArray* eventRequestMsg;
@property (strong,nonatomic) NSMutableArray* systemMsg;
@property (strong,nonatomic) NSMutableArray* tabs;
@property (strong, nonatomic) IBOutlet UITableView *friendRequest_tableView;
@property (strong, nonatomic) IBOutlet UITableView *eventRequest_tableView;
@property (strong, nonatomic) IBOutlet UITableView *systemMessage_tableView;

@property (weak,nonatomic) AppDelegate* appListener;
@property (strong, nonatomic) IBOutlet UIView *shadowView;
@property (strong, nonatomic) IBOutlet UIScrollView *tabbar_scrollview;
@property (strong, nonatomic) IBOutlet UIScrollView *content_scrollView;
@property (strong, nonatomic) IBOutlet UIView *rootView;


- (void)initParams;
- (void)getMsgFromDataBase;

- (IBAction)okBtnClicked:(id)sender;
- (IBAction)noBtnClicked:(id)sender;
- (IBAction)delBtnClicked:(id)sender;
- (IBAction)participate_event_okBtnClicked:(id)sender;
- (IBAction)participate_event_noBtnClicked:(id)sender;
@end
