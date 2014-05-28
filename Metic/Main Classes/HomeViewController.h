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


@interface HomeViewController : UIViewController <SlideNavigationControllerDelegate,HttpSenderDelegate,UITableViewDelegate,UITableViewDataSource>



@property(nonatomic,strong)MTUser *user;
@property (strong, nonatomic) IBOutlet UITableView *tableView;


@property(nonatomic,strong)NSArray *eventIds;
@property(nonatomic,strong)NSArray *events;
- (IBAction)getEvent:(id)sender;

@end
