//
//  KankanViewController.h
//  WeShare
//
//  Created by 俊健 on 15/11/6.
//  Copyright (c) 2015年 WeShare. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonUtils.h"
#import "HttpSender.h"
#import "PhotoGetter.h"
#import "SearchedFriendTableViewCell.h"
#import "AddFriendConfirmViewController.h"

@class MJRefreshHeaderView;
@class MJRefreshFooterView;

@interface KankanViewController : UIViewController<UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>

@property (strong, nonatomic) IBOutlet UIView *tabPage3_view;
@property (strong, nonatomic) IBOutlet UITableView *kankan_tableview;
@property (strong, nonatomic) MJRefreshHeaderView* kankan_header;
@property (strong, nonatomic) MJRefreshFooterView* kankan_footer;
@property (strong, nonatomic) NSMutableArray* kankan_arr;

@end
