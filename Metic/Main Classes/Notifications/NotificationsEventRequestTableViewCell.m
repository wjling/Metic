//
//  NotificationsEventRequestTableViewCell.m
//  Metic
//
//  Created by mac on 14-7-5.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "NotificationsEventRequestTableViewCell.h"

@implementation NotificationsEventRequestTableViewCell

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
    UIColor* borderColor = [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1];
    self.layer.borderColor = borderColor.CGColor;
    self.layer.borderWidth = 0.3;
    self.noBtn.layer.cornerRadius = 3;
    self.noBtn.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
