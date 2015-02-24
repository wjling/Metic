//
//  PhotoTableViewCell.h
//  Metic
//
//  Created by ligang6 on 14-6-30.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PictureWall2.h"
#import "../Source/TMQuiltView/TMQuiltViewCell.h"

@interface PhotoTableViewCell : TMQuiltViewCell
@property (strong, nonatomic) UIImageView *avatar;
@property (strong, nonatomic) UILabel *author;
@property (strong, nonatomic) UILabel *publish_date;
@property (strong, nonatomic) UIView *infoView;
@property (strong, nonatomic) UIImageView *imgView;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
//@property (strong, nonatomic) UIButton *button_Detail;
@property (strong, nonatomic) NSNumber *photo_id;
@property (strong, nonatomic) NSMutableDictionary* photoInfo;
@property (weak, nonatomic) PictureWall2* PhotoWall;
@property BOOL isloading;
@property BOOL isLeft;
- (void)button_DetailPressed:(id)sender;
-(void)animationBegin;
@end
