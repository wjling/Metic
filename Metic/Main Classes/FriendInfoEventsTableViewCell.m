//
//  FriendInfoEventsTableViewCell.m
//  Metic
//
//  Created by mac on 14-7-4.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "FriendInfoEventsTableViewCell.h"

@implementation FriendInfoEventsTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    self.avatars = [[NSMutableArray alloc]init];
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
