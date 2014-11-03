//
//  PhotoRankingTableViewCell.h
//  WeShare
//
//  Created by ligang6 on 14-9-23.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "../Main Classes/photoRankingViewController.h"
#import "PictureWallViewController.h"


@interface PhotoRankingTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *photo;
@property (strong, nonatomic) IBOutlet UIImageView *avatar;
@property (strong, nonatomic) IBOutlet UILabel *author;
@property (strong, nonatomic) IBOutlet UILabel *time;
@property (strong, nonatomic) IBOutlet UIButton *good_Btn;
@property (strong, nonatomic) IBOutlet UIImageView *good_Img;
@property (strong, nonatomic) IBOutlet UILabel *good_Num;
- (IBAction)addGood:(id)sender;
- (IBAction)toUserInfo:(id)sender;

@property (strong, nonatomic) NSNumber* eventId;
@property (weak, nonatomic) photoRankingViewController* controller;
@property (strong, nonatomic) NSMutableDictionary* photoInfo;
@property (strong, nonatomic) NSNumber* authorId;
@property BOOL isZan;
-(void)refresh;
-(void)animationBegin;
-(void)toPhotoDetail;
@end
