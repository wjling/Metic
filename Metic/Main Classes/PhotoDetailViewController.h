//
//  PhotoDetailViewController.h
//  Metic
//
//  Created by ligang6 on 14-7-4.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoGetter.h"
#import "../MJRefresh/MJRefreshFooterView.h"
#import "../Source/UMSocial_Sdk_4.0/Header/UMSocial.h"

@interface PhotoDetailViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UMSocialUIDelegate,UIScrollViewDelegate,MJRefreshBaseViewDelegate>
@property(nonatomic,strong) UIImage* photo;
@property (nonatomic,strong)NSNumber* photoId;
@property(nonatomic,strong)NSNumber* eventId;
@property (nonatomic,strong) NSDictionary * photoInfo;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UIViewController* photoDisplayController;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttons;
@property (strong, nonatomic) MJRefreshFooterView* footer;
@property int type;
- (IBAction)good:(id)sender;
- (IBAction)comment:(id)sender;
- (IBAction)share:(id)sender;
- (IBAction)download:(id)sender;
- (IBAction)publishComment:(id)sender;

@end
