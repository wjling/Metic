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
    UITapGestureRecognizer* tapRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(button_DetailPressed:)];
    [self.infoView addGestureRecognizer:tapRecognizer];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)button_DetailPressed:(id)sender {
    NSLog(@"pressed");
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

-(void)animationBegin
{
    if (_isloading) return;
    [self setAlpha:0.5];
    [UIView beginAnimations:@"shadowViewDisappear" context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDelegate:self];
    self.alpha = 1;
    [UIView commitAnimations];
}
@end
