//
//  LocationSettingViewController.h
//  Metic
//
//  Created by mac on 14-7-18.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HttpSender.h"
#import "CommonUtils.h"
#import "MTUser.h"

@interface LocationSettingViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,HttpSenderDelegate>
@property (strong, nonatomic) IBOutlet UIScrollView *content_scrollView;
@property (strong, nonatomic) IBOutlet UITableView *province_tableView;
@property (strong, nonatomic) IBOutlet UITableView *city_tableView;
@property (strong, nonatomic) NSArray* location_arr;
@property (strong, nonatomic) IBOutlet UINavigationItem *navigationItem;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *right_barButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *left_barButton;

-(void)rightBarButtonInProvinceClicked:(id)sender;
-(void)rightBarButtonInCityClicked:(id)sender;
-(void)leftBarButtonInProvinceClicked:(id)sender;
-(void)leftBarButtonInCityClicked:(id)sender;
@end
