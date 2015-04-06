//
//  MTPhotoBrowser.h
//  WeShare
//
//  Created by 俊健 on 15/4/5.
//  Copyright (c) 2015年 WeShare. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MTPhotoBrowserDelegate;
@interface MTPhotoBrowser : UIViewController <UIScrollViewDelegate>
// 代理
@property (nonatomic, weak) id<MTPhotoBrowserDelegate> delegate;
// 所有的图片对象
@property (nonatomic, strong) NSArray *photos;
// 当前展示的图片索引
@property (nonatomic, assign) NSUInteger currentPhotoIndex;

// 显示
- (void)show;
//退出
- (void)quit;
@end

@protocol MTPhotoBrowserDelegate <NSObject>
@optional
// 切换到某一页图片
- (void)photoBrowser:(MTPhotoBrowser *)photoBrowser didChangedToPageAtIndex:(NSUInteger)index;
- (void)photoBrowser:(MTPhotoBrowser *)photoBrowser didSelectPageAtIndex:(NSUInteger)index;
- (void)willDismissBrowser:(MTPhotoBrowser *)photoBrowser;
@end