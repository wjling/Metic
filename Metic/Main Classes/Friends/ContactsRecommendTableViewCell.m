//
//  ContactsRecommendTableViewCell.m
//  WeShare
//
//  Created by mac on 14-8-19.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "ContactsRecommendTableViewCell.h"

@implementation ContactsRecommendTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
    self.avatar.layer.masksToBounds = YES;
    self.avatar.layer.cornerRadius = 3;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
