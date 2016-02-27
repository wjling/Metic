//
//  PhotoTableViewCell.h
//  Metic
//
//  Created by ligang6 on 14-6-30.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PictureWall2.h"
#import "TMQuiltViewCell.h"

@interface PhotoTableViewCell : TMQuiltViewCell
@property (strong, nonatomic) UIImageView *avatar;
@property (strong, nonatomic) UILabel *author;
@property (strong, nonatomic) UILabel *publish_date;
@property (strong, nonatomic) UIView *infoView;
@property (strong, nonatomic) UIImageView *imgView;
@property (strong, nonatomic) NSNumber *photoId;
@property (strong, nonatomic) NSMutableDictionary* photoInfo;
@property (weak, nonatomic) PictureWall2* PhotoWall;
@property (strong, nonatomic) NSString* photoName;
@property (strong, nonatomic) NSNumber *authorId;

@property (nonatomic) BOOL isZan;
@property (nonatomic) NSInteger zanNum;
@property (nonatomic) NSInteger commentNum;


@property BOOL isloading;
@property BOOL isLeft;
- (void)button_DetailPressed:(id)sender;
-(void)animationBegin;

//加载数据
- (void)applyData:(NSMutableDictionary *)data;

//刷新detailview
- (void)reloadDetailView;

//计算cell高度
+ (CGFloat)photoCellHeightForPhotoInfo:(NSDictionary *)photoInfo;
@end


@interface PhotoDetailView : UIView

- (void)setupUIWithIsZan:(BOOL)isZan zanNum:(NSInteger)zanNum commentNum:(NSInteger)commentNum;

@end
