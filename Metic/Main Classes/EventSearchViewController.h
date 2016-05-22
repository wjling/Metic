//
//  EventSearchViewController.h
//  WeShare
//
//  Created by ligang6 on 14-9-21.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MJRefreshFooterView.h"

@interface EventSearchViewController : UIViewController<UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate,MJRefreshBaseViewDelegate>
@property (nonatomic,strong) NSNumber* selectedEventId;

@end
