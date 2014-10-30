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
#import "UserQRCodeViewController.h"
#import "ReportViewController.h"
#import "ChangeAliasViewController.h"


@interface FriendInfoViewController : UIViewController <UIScrollViewDelegate,HttpSenderDelegate,UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic) UIButton *del_friend_Button;
@property (strong, nonatomic) UIButton *friend_alias_button;
@property (strong, nonatomic) UIView* contentView;
@property (strong, nonatomic) UIScrollView* sView;
@property (strong, nonatomic) UIPageControl* pControl;
@property (strong, nonatomic) NSMutableArray* views;
@property (strong, nonatomic) IBOutlet UIView *moreFunction_view;


@property (strong, nonatomic) UIImageView* fInfoView;
@property (strong, nonatomic) UIImageView* photo;
@property (strong, nonatomic) UILabel* name_label;
@property (strong, nonatomic) UILabel* alias_label;
@property (strong, nonatomic) UILabel* location_label;
@property (strong, nonatomic) UIImageView* gender_imageView;

@property (strong, nonatomic) UIImageView* fDescriptionView;
@property (strong, nonatomic) UILabel* title_label;
@property (strong, nonatomic) UILabel* description_label;

@property (strong, nonatomic) IBOutlet UITableView *friendInfoEvents_tableView;
@property (strong, nonatomic) IBOutlet UIView *root;
@property (strong, nonatomic) NSNumber* fid;
@property (strong, nonatomic) NSMutableDictionary* friendInfo_dic;
@property (strong, nonatomic) NSMutableArray* events;
@property (strong, nonatomic) NSMutableArray* rowHeights;
//- (IBAction)testingClicked:(id)sender;

- (IBAction)stretchBtnClicked:(id)sender;
- (IBAction)rightBarBtnClicked:(id)sender;
- (IBAction)QRcodeClicked:(id)sender;
- (IBAction)reportClicked:(id)sender;
@end
