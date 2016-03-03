//
//  MTPhotoInfoView.h
//  WeShare
//
//  Created by 俊健 on 16/3/3.
//  Copyright © 2016年 WeShare. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MTOperation.h"

@interface MTMediaInfoView : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *photoView;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) IBOutlet UIButton *shareBtn;
@property (strong, nonatomic) IBOutlet UIButton *likeBtn;

@property (strong, nonatomic) UIImage *photo;


//刷新点赞按钮
- (void)setupLikeButton;
//加载数据
- (void)applyData:(NSMutableDictionary *)data type:(MTMediaType)type containerWidth:(CGFloat)width;
//计算cell高度
+ (float)calculateCellHeightwithMediaInfo:(NSMutableDictionary *)mediaInfo type:(MTMediaType)type containerWidth:(CGFloat)width;
@end
