//
//  photoRankingViewController.h
//  WeShare
//
//  Created by ligang6 on 14-9-22.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PictureWallViewController.h"
#import "../MJRefresh/MJRefresh.h"

@interface photoRankingViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,MJRefreshBaseViewDelegate>
@property(nonatomic,strong) UITableView* tableView;
@property(nonatomic,strong) NSNumber* eventId;
@property(nonatomic,strong) NSString* eventName;
@property(nonatomic,strong) PictureWallViewController* pictureWallController;
@property BOOL shouldFlash;
@end
