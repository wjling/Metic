//
//  FriendInfoViewController.h
//  Metic
//
//  Created by ligang5 on 14-5-28.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "MySqlite.h"
#import "HttpSender.h"
#import "CommonUtils.h"
#import "MTUser.h"
#import "PhotoGetter.h"
#import "FriendInfoEventsTableViewCell.h"
#import "FriendTableViewCell.h"


@interface FriendInfoViewController : UIViewController <UIScrollViewDelegate,HttpSenderDelegate,UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic) UIButton *del_friend_Button;
@property (strong, nonatomic) UIView* contentView;
@property (strong, nonatomic) UIScrollView* sView;
@property (strong, nonatomic) UIPageControl* pControl;
@property (strong, nonatomic) NSMutableArray* views;
@property (strong, nonatomic) UIImageView* fInfoView;
@property (strong, nonatomic) UIImageView* fDescriptionView;
@property (strong, nonatomic) UITableView *friendInfoEvents_tableView;
@property (strong, nonatomic) IBOutlet UIView *root;
@property (strong, nonatomic) NSNumber* fid;
@property (strong, nonatomic) NSMutableArray* events;
//- (IBAction)testingClicked:(id)sender;
@property (strong, nonatomic) IBOutlet UITableView *test_tableView;

@end
