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
#import "../Source/SlideNavigationController.h"

@interface NearbyEventViewController : UIViewController<SlideNavigationControllerDelegate,UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate,BMKLocationServiceDelegate,MJRefreshBaseViewDelegate>

@property (strong, nonatomic) IBOutlet UIView *shadowView;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UITableView *nearbyTableView;
@property (strong, nonatomic) IBOutlet UITableView *searchTableView;
@property (strong, nonatomic) IBOutlet UIButton *nearbyButton;
@property (strong, nonatomic) IBOutlet UIButton *searchButton;
- (IBAction)nearbyButton_pressed:(id)sender;
- (IBAction)searchButton_pressed:(id)sender;

@property BOOL shouldRefresh;
@property(strong, nonatomic) MJRefreshHeaderView* header;
@property(nonatomic,strong) NSNumber* selectedEventId;
@end
