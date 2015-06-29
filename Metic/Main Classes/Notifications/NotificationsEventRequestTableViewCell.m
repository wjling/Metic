//
//  NotificationsEventRequestTableViewCell.m
//  Metic
//
//  Created by mac on 14-7-5.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "NotificationsEventRequestTableViewCell.h"
#import "FriendInfoViewController.h"

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
    [self.avatar_imageView setUserInteractionEnabled:YES];
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(avatarClick)];
    [self.avatar_imageView addGestureRecognizer:tap];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)avatarClick
{
    NSLog(@"avatar click");
    UIStoryboard* mainSB = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    FriendInfoViewController* fInfoV = [mainSB instantiateViewControllerWithIdentifier:@"FriendInfoViewController"];
    if (self.tag) {
        fInfoV.fid = [NSNumber numberWithInteger:self.tag];
        if (self.context_weak) {
            [[self.context_weak navigationController] pushViewController:fInfoV animated:YES];
        }
    }
}

@end
