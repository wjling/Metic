//
//  DynamicViewController.h
//  Metic
//
//  Created by ligang6 on 14-7-25.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DynamicViewController : UIViewController<UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UIButton *dynamics_button;
@property (strong, nonatomic) IBOutlet UIButton *atMe_button;
- (IBAction)dynamics_pressdown:(id)sender;
- (IBAction)atMe_pressdown:(id)sender;
@property (strong, nonatomic) IBOutlet UITableView *dynamic_tableView;
@property (strong, nonatomic) IBOutlet UITableView *atMe_tableView;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic,strong) NSMutableArray* updateEvents;

@end
