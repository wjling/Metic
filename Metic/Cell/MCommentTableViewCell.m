//
//  MCommentTableViewCell.m
//  Metic
//
//  Created by ligang6 on 14-6-15.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "MCommentTableViewCell.h"
#import "FriendInfoViewController.h"

@implementation MCommentTableViewCell

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)delete_Comment:(id)sender {
    [_controller delete_Comment:sender];
}


- (IBAction)appreciate:(id)sender {
    [_controller appreciate:sender];
}

- (IBAction)pushToFriendView:(id)sender {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone"
															 bundle: nil];
	FriendInfoViewController *friendView = [mainStoryboard instantiateViewControllerWithIdentifier: @"FriendInfoViewController"];
    friendView.fid = self.authorId;
    [_controller.navigationController pushViewController:friendView animated:YES];
}

@end
