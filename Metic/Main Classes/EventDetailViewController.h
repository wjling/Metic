//
//  EventDetailViewController.h
//  Metic
//
//  Created by ligang_mac4 on 14-5-29.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MySqlite.h"
#import "../CustomCellTableViewCell.h"

@interface EventDetailViewController : UIViewController<UIScrollViewDelegate>

//@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet CustomCellTableViewCell  *eventinfocell;
@property(nonatomic,strong)NSNumber *eventId;
@property(nonatomic,strong)MySqlite *sql;


@end
