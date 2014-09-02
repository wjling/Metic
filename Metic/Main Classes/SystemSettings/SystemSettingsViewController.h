//
//  SystemSettingsViewController.h
//  Metic
//
//  Created by mac on 14-7-27.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlideNavigationController.h"
#import "CommonUtils.h"
#import "AppDelegate.h"
#import "SDImageCache.h"
#import "MobClick.h"

@interface SystemSettingsViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,SlideNavigationControllerDelegate,UIAlertViewDelegate>
@property (strong, nonatomic) UITableView *settings_tableview;

@end
