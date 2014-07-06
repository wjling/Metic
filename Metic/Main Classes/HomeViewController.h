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
#import "MySqlite.h"
#import "AppDelegate.h"
#import "../Utils/CloudOperation.h"



@interface HomeViewController : UIViewController <SlideNavigationControllerDelegate,HttpSenderDelegate,UITableViewDelegate,MJRefreshBaseViewDelegate,CloudOperationDelegate>



@property(nonatomic,strong)MTUser *user;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *shadowView;

@property (strong,nonatomic) MJRefreshHeaderView *header;
@property (strong, nonatomic) IBOutlet UIScrollView *controlView;
@property (strong, nonatomic) UILabel *indicatior;
- (IBAction)more:(id)sender;
- (void)option;
@property (strong, nonatomic) IBOutlet UIView *morefuctions;
@property (strong, nonatomic) IBOutlet UIButton *showAllEvents_button;
@property (strong, nonatomic) IBOutlet UIButton *showMyEvents_button;
@property (strong, nonatomic) IBOutlet UIButton *showFrEvents_button;
@property (strong, nonatomic) IBOutlet UIButton *showTaEvents_button;
- (IBAction)showAllEvents:(id)sender;
- (IBAction)showMyEvents:(id)sender;
- (IBAction)showFrEvents:(id)sender;
- (IBAction)showTaEvents:(id)sender;


@property (nonatomic,strong)NSNumber *selete_Eventid;
@property(nonatomic,strong)NSMutableArray *eventIds;
@property(nonatomic,strong)NSMutableArray *eventsSource;
@property(atomic,strong)NSMutableArray *events;
@property(atomic,strong)NSMutableArray *myevents;
@property(atomic,strong)NSMutableArray *frevents;
@property(atomic,strong)NSMutableArray *taevents;
@property(nonatomic,strong)MySqlite *sql;

@property(strong,nonatomic)AppDelegate* listenerDelegate;



@end
