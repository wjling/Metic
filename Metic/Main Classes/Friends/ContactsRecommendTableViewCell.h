//
//  ContactsRecommendTableViewCell.h
//  WeShare
//
//  Created by mac on 14-8-19.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactsRecommendTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *name_label;
@property (strong, nonatomic) IBOutlet UIButton *add_button;
@property (strong, nonatomic) IBOutlet UILabel *hasAdd_label;
@property (strong, nonatomic) IBOutlet UIButton *invite_button;
@property (strong, nonatomic) UIView* cellSeperator;

@end
