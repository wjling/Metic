//
//  HistoricalNotificationViewController.h
//  Metic
//
//  Created by mac on 14-7-23.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NotificationsEventRequestTableViewCell.h"
#import "NotificationsFriendRequestTableViewCell.h"
#import "AppConstants.h"
#import "PhotoGetter.h"

@interface HistoricalNotificationViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *historicalNF_tableview;
@property (strong, nonatomic) IBOutlet UIButton *right_barbutton;
@property (strong, nonatomic) IBOutlet UIView *functions_view;
@property (strong, nonatomic) IBOutlet UIButton *function1_button;
@property (strong, nonatomic) IBOutlet UIButton *function2_button;
@property (strong, nonatomic) NSMutableArray* historicalMsgs;

- (IBAction)rightBarBtnClicked:(id)sender;
- (IBAction)function1Clicked:(id)sender;
- (IBAction)function2Clicked:(id)sender;
@end
