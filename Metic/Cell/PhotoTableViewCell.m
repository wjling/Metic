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


- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    _imgView = [[UIImageView alloc]initWithFrame:CGRectZero];
    _imgView.clipsToBounds = YES;
    [self addSubview:_imgView];
    
    _infoView = [[UIView alloc]initWithFrame:CGRectZero];
    [_infoView setBackgroundColor:[UIColor whiteColor]];
    [self addSubview:_infoView];
    
    UIView* line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 145, 3)];
    [line setBackgroundColor:[UIColor colorWithRed:246.0/255.0 green:92.0/255.0 blue:35.0/255.0 alpha:1.0]];
    [_infoView addSubview:line];
    
    _avatar = [[UIImageView alloc]initWithFrame:CGRectMake(5, 8, 20, 20)];
    [_infoView addSubview:_avatar];
    
    _author = [[UILabel alloc]initWithFrame:CGRectMake(30, 5, 110, 15)];
    _author.font = [UIFont systemFontOfSize:12];
    _author.textColor = [UIColor colorWithWhite:51.0/255.0 alpha:1.0f];
    [_infoView addSubview:_author];
    
    _publish_date = [[UILabel alloc]initWithFrame:CGRectMake(30, 20, 110, 10)];
    _publish_date.font = [UIFont systemFontOfSize:11];
    _publish_date.textColor = [UIColor colorWithWhite:145.0/255.0 alpha:1.0f];
    [_infoView addSubview:_publish_date];
    
    UITapGestureRecognizer* tapRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(button_DetailPressed:)];
    [self.infoView addGestureRecognizer:tapRecognizer];
    
    
    
    
    
    return self;
}



- (void)awakeFromNib
{
    // Initialization code
    UITapGestureRecognizer* tapRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(button_DetailPressed:)];
    [self.infoView addGestureRecognizer:tapRecognizer];
}

- (void)button_DetailPressed:(id)sender {
    NSLog(@"pressed");
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone"
															 bundle: nil];
	PhotoDetailViewController *viewcontroller = [mainStoryboard instantiateViewControllerWithIdentifier: @"PhotoDetailViewController"];
    
    viewcontroller.photoId = self.photo_id;
    viewcontroller.eventId = self.PhotoWall.eventId;
    viewcontroller.eventLauncherId = _PhotoWall.eventLauncherId;
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
