//
//  MTPhotoToolbar.h
//  WeShare
//
//  Created by 俊健 on 15/4/5.
//  Copyright (c) 2015年 WeShare. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MTPhotoBrowser;

@interface MTPhotoToolbar : UIView
// 所有的图片对象
@property (nonatomic, strong) NSArray *photos;
// 当前展示的图片索引
@property (nonatomic, assign) NSUInteger currentPhotoIndex;

@property (nonatomic,weak) MTPhotoBrowser* browser;
@end
