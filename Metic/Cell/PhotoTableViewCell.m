//
//  PhotoTableViewCell.m
//  Metic
//
//  Created by ligang6 on 14-6-30.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "PhotoTableViewCell.h"
#import "PhotoDetailViewController.h"

@implementation PhotoTableViewCell


- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)button_DetailPressed:(id)sender {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone"
															 bundle: nil];
	PhotoDetailViewController *viewcontroller = [mainStoryboard instantiateViewControllerWithIdentifier: @"PhotoDetailViewController"]; ;
    
    viewcontroller.photoId = self.photo_id;
    viewcontroller.photo = self.imgView.image;
    viewcontroller.eventId = self.PhotoWall.eventId;
    viewcontroller.photoInfo = self.photoInfo;
    viewcontroller.eventName = _PhotoWall.eventName;
    viewcontroller.controller = self.PhotoWall;
    viewcontroller.type = 2;
    [self.PhotoWall.navigationController pushViewController:viewcontroller animated:YES];

}
@end
