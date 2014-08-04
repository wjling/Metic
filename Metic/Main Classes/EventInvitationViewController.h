//
//  EventInvitationViewController.h
//  Metic
//
//  Created by ligang_mac4 on 14-7-28.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlideNavigationController.h"
#import "EventInvitationTableViewCell.h"
#import "HttpSender.h"

@interface EventInvitationViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,SlideNavigationControllerDelegate,HttpSenderDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *shadowView;

@end
