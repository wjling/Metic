//
//  NotificationsFriendRequestTableViewCell.h
//  Metic
//
//  Created by mac on 14-7-5.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotificationsFriendRequestTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *avatar_imageView;
@property (strong, nonatomic) IBOutlet UILabel *name_label;
@property (strong, nonatomic) IBOutlet UILabel *conform_msg_label;
@property (strong, nonatomic) IBOutlet UIButton *okBtn;
@property (strong, nonatomic) IBOutlet UIButton *noBtn;
@property (strong, nonatomic) IBOutlet UILabel *remark_label;

@end
