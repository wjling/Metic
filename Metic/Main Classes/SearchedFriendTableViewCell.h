//
//  SearchedFriendTableViewCell.h
//  Metic
//
//  Created by mac on 14-6-3.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchedFriendTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *avatar_imageview;
@property (weak, nonatomic) IBOutlet UILabel *friendNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *location_label;
@property (strong, nonatomic) UIImageView *gender_imageview;
@property (strong, nonatomic) IBOutlet UIButton *add_button;


@end
