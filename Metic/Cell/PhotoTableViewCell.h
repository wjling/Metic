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
@property (strong, nonatomic) IBOutlet UIImageView *avatar;
@property (strong, nonatomic) IBOutlet UILabel *author;
@property (strong, nonatomic) IBOutlet UILabel *publish_date;
@property (strong, nonatomic) IBOutlet UIView *infoView;
@property (strong, nonatomic) IBOutlet UIImageView *imgView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
//@property (strong, nonatomic) IBOutlet UIButton *button_Detail;
@property (strong, nonatomic) NSNumber *photo_id;
@property (strong, nonatomic) NSMutableDictionary* photoInfo;
@property (weak, nonatomic) PictureWall2* PhotoWall;
@property BOOL isloading;
@property BOOL isLeft;
- (void)button_DetailPressed:(id)sender;
-(void)animationBegin;
@end
