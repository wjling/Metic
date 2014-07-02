//
//  EventDetailViewController.h
//  Metic
//
//  Created by ligang_mac4 on 14-5-29.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MySqlite.h"
#import "HttpSender.h"
#import "CommonUtils.h"
#import "../Utils/PhotoGetter.h"

@interface EventDetailViewController : UIViewController<UIScrollViewDelegate,UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource,PhotoGetterDelegate>

@property(nonatomic,strong)NSNumber *eventId;
@property(nonatomic,strong)MySqlite *sql;

@property (strong, nonatomic)  UIButton *comment_button;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *commentView;
@property (strong, nonatomic) IBOutlet UITextField *inputField;
- (void)pullMainCommentFromAir;
- (IBAction)publishComment:(id)sender;






@end
