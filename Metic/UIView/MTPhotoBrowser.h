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

@property (nonatomic, assign) BOOL shouldDelete;



// 显示
- (void)show;
//手动显示图片
- (void)showPhotos;
- (void)showPhotoViewAtIndex:(NSInteger)index;
//手动刷新toolbar
- (void)updateTollbarState;
//退出
- (void)quit;
#pragma mark 移除一个图片view
- (void)removePhotoViewAtIndex:(NSInteger)index;
@end

@protocol MTPhotoBrowserDelegate <NSObject>
@optional
// 切换到某一页图片
- (void)photoBrowser:(MTPhotoBrowser *)photoBrowser didChangedToPageAtIndex:(NSUInteger)index;
- (void)photoBrowser:(MTPhotoBrowser *)photoBrowser didSelectPageAtIndex:(NSUInteger)index;
- (void)willDismissBrowser:(MTPhotoBrowser *)photoBrowser;
@end