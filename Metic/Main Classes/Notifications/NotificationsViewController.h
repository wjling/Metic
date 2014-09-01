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
#import "HistoricalNotificationViewController.h"
#import "myScrollView.h"


@interface NotificationsViewController : UIViewController <HttpSenderDelegate,UITableViewDelegate,UITableViewDataSource,SlideNavigationControllerDelegate,UIScrollViewDelegate,NotificationDelegate>
//@property (strong,nonatomic) NSMutableArray* msgFromDB;
@property (strong,nonatomic) NSMutableArray* friendRequestMsg;
@property (strong,nonatomic) NSMutableArray* eventRequestMsg;
@property (strong,nonatomic) NSMutableArray* systemMsg;
//@property (strong,nonatomic) NSMutableArray* historicalMsg;
@property (strong,nonatomic) NSMutableArray* tabs;
@property (strong, nonatomic) IBOutlet UITableView *friendRequest_tableView;
@property (strong, nonatomic) IBOutlet UITableView *eventRequest_tableView;
@property (strong, nonatomic) IBOutlet UITableView *systemMessage_tableView;

@property (weak,nonatomic) AppDelegate* appListener;
@property (strong, nonatomic) IBOutlet UIView *shadowView;
@property (strong, nonatomic) IBOutlet UIScrollView *tabbar_scrollview;
//@property (strong, nonatomic) IBOutlet UIScrollView *content_scrollView;
@property (strong, nonatomic) IBOutlet myScrollView *content_scrollView;

@property (strong, nonatomic) IBOutlet UIView *rootView;
@property (strong, nonatomic) IBOutlet UIButton *rightBarButton;
@property (strong, nonatomic) IBOutlet UIView *functions_uiview;
@property (strong, nonatomic) IBOutlet UIButton *function1_button;
@property (strong, nonatomic) IBOutlet UIButton *function2_button;



- (void)initParams;
//- (void)getMsgFromDataBase;

- (IBAction)friend_request_okBtnClicked:(id)sender;
- (IBAction)friend_request_noBtnClicked:(id)sender;
- (IBAction)delSystemMsg:(id)sender;
- (IBAction)event_request_okBtnClicked:(id)sender;
- (IBAction)event_request_noBtnClicked:(id)sender;
- (void)tabBtnClicked:(id)sender;
- (IBAction)rightBarBtnClicked:(id)sender;
- (IBAction)function1Clicked:(id)sender;
- (IBAction)function2Clicked:(id)sender;

@end
