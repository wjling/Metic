//
//  UserInfoViewController.h
//  Metic
//
//  Created by mac on 14-7-16.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserInfoTableViewCell.h"
#import "PhotoGetter.h"

@interface UserInfoViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UIView *banner_UIview;
@property (strong, nonatomic) IBOutlet UIImageView *banner_imageView;
@property (strong, nonatomic) IBOutlet UIImageView *avatar_imageView;
@property (strong, nonatomic) IBOutlet UILabel *name_label;
@property (strong, nonatomic) IBOutlet UIImageView *gender_imageView;
@property (strong, nonatomic) IBOutlet UILabel *email_label;
@property (strong, nonatomic) IBOutlet UITableView *info_tableView;

@end
