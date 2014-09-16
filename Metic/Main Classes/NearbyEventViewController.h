//
//  NearbyEventViewController.h
//  Metic
//
//  Created by ligang_mac4 on 14-8-4.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BMapKit.h"
#import "MJRefreshHeaderView.h"
#import "MJRefreshFooterView.h"
#import "../Source/SlideNavigationController.h"

@interface NearbyEventViewController : UIViewController<UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate,BMKLocationServiceDelegate,MJRefreshBaseViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *nearbyTableView;
@property (strong, nonatomic) UILabel *emptyAlert;
@property BOOL shouldRefresh;
@property(strong, nonatomic) MJRefreshHeaderView* header;
@property(strong, nonatomic) MJRefreshFooterView* footer;
@property(nonatomic,strong) NSNumber* selectedEventId;
@property int type;
@end
