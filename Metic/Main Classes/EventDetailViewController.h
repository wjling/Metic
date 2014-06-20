//
//  EventDetailViewController.h
//  Metic
//
//  Created by ligang_mac4 on 14-5-29.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MySqlite.h"
#import "../HttpSender.h"
#import "../CommonUtils.h"

@interface EventDetailViewController : UIViewController<UIScrollViewDelegate,UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong)NSNumber *eventId;
@property(nonatomic,strong)MySqlite *sql;
@property (strong, nonatomic)  UIView *myComment;
@property (strong, nonatomic)  UIButton *comment_button;
@property (strong, nonatomic)  UITableView *tableView;
- (void)pullMainCommentFromAir;






@end
