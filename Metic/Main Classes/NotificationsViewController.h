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
#import "NotificationsTableViewCell.h"

@interface NotificationsViewController : UIViewController <HttpSenderDelegate,UITableViewDelegate,UITableViewDataSource,SlideNavigationControllerDelegate>
@property (strong,nonatomic) NSMutableArray* msgFromDB;
@property (strong, nonatomic) IBOutlet UITableView *notificationsTable;
@property (weak,nonatomic) AppDelegate* appListener;


- (void)initParams;
- (void)getMsgFromDataBase;

- (IBAction)okBtnClicked:(id)sender;
- (IBAction)noBtnClicked:(id)sender;
- (IBAction)delBtnClicked:(id)sender;
- (IBAction)participate_event_okBtnClicked:(id)sender;
- (IBAction)participate_event_noBtnClicked:(id)sender;
@end
