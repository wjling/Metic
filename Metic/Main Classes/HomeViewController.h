//
//  HomeViewController.h
//  SlideMenu
//
//  Created by Aryan Gh on 4/24/13.
//  Copyright (c) 2013 Aryan Ghassemi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HttpSender.h"
#import "CommonUtils.h"
#import "SlideNavigationController.h"
#import "AppConstants.h"
#import "MTUser.h"
#import "MTEvent.h"
#import "AppDelegate.h"
#import "MTEvent.h"
#import "MJRefreshHeaderView.h"
#import "MJRefreshFooterView.h"

#import "MTPushMessageHandler.h"
#import "CloudOperation.h"
#import "MTTableView.h"



@interface HomeViewController : UIViewController <SlideNavigationControllerDelegate,HttpSenderDelegate,UITableViewDelegate,MJRefreshBaseViewDelegate,CloudOperationDelegate,NotificationDelegate>




@property (strong, nonatomic) IBOutlet UIView *updateInfoView;
@property (strong, nonatomic) IBOutlet UIView *shadowView;
@property (strong, nonatomic) IBOutlet UIView *ArrangementView;
@property (strong, nonatomic) IBOutlet MTTableView *tableView;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *arrangementButtons;

@property (strong,nonatomic) MJRefreshHeaderView *header;
@property (strong,nonatomic) MJRefreshFooterView *footer;
- (void)option;
@property (strong, nonatomic) IBOutlet UIView *morefuctions;
- (IBAction)toDynamic:(id)sender;
- (IBAction)closeOptionView:(id)sender;
- (IBAction)CloseMenu:(id)sender;
- (IBAction)chooseArrangement:(id)sender;
- (IBAction)arrangebyAddTime:(id)sender;
- (IBAction)arrangebyStartTime:(id)sender;


@property (nonatomic,strong)NSNumber *selete_Eventid;
@property (nonatomic,strong)NSNumber *selete_EventLauncherid;
@property (nonatomic,strong)NSString *selete_EventName;
//@property(nonatomic,strong)NSMutableArray *eventIds;
@property(nonatomic,strong)NSMutableArray *eventIds_all;
@property(nonatomic,strong)NSMutableArray *eventsSource;
@property(atomic,strong)NSMutableArray *events;
@property BOOL shouldRefresh;
@property(strong,nonatomic)AppDelegate* listenerDelegate;



@end
