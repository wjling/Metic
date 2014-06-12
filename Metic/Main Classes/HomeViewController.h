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
//#import "SRWebSocket.h"



@interface HomeViewController : UIViewController <SlideNavigationControllerDelegate,HttpSenderDelegate,UITableViewDelegate,UITableViewDataSource,MJRefreshBaseViewDelegate>



@property(nonatomic,strong)MTUser *user;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong,nonatomic) MJRefreshHeaderView *header;

@property(nonatomic,strong)NSMutableArray *eventIds;
@property(nonatomic,strong)NSMutableArray *events;

@property(nonatomic,strong)MySqlite *sql;

@property(strong,nonatomic)AppDelegate* listenerDelegate;
//- (void)reconnect;


@end
