//
//  SearchedFriendTableViewCell.m
//  Metic
//
//  Created by mac on 14-6-3.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "SearchedFriendTableViewCell.h"

@implementation SearchedFriendTableViewCell

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
    NSLog(@"awake from NIB");
//    if (!_alreadyFriend_label) {
//        _alreadyFriend_label = [[UILabel alloc]initWithFrame:CGRectMake(250, 7, 60, 30)];
//        _alreadyFriend_label.font = [UIFont systemFontOfSize:12];
//        UIColor* textColor = [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1];
//        self.alreadyFriend_label.textColor = textColor;
//        self.alreadyFriend_label.text = @"已经是好友";
//        [self.contentView addSubview:self.alreadyFriend_label];
//    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
