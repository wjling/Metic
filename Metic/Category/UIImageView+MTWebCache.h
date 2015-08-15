//
//  UIImageView+MTImageCache.h
//  WeShare
//
//  Created by 俊健 on 15/8/15.
//  Copyright (c) 2015年 WeShare. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"

@interface UIImageView (MTWebCache)

//下载后将图片的key替换成云端路径

- (void)sd_setImageWithURL:(NSURL *)url cloudPath:(NSString *)path;

- (void)sd_setImageWithURL:(NSURL *)url cloudPath:(NSString *)path completed:(SDWebImageCompletionBlock)completedBlock;

- (void)sd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder cloudPath:(NSString *)path options:(SDWebImageOptions)options;

- (void)sd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder cloudPath:(NSString *)path;

- (void)sd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder cloudPath:(NSString *)path options:(SDWebImageOptions)options completed:(SDWebImageCompletionBlock)completedBlock;

- (void)sd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder cloudPath:(NSString *)path options:(SDWebImageOptions)options progress:(SDWebImageDownloaderProgressBlock)progressBlock;

- (void)sd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder cloudPath:(NSString *)path completed:(SDWebImageCompletionBlock)completedBlock;

- (void)sd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder cloudPath:(NSString *)path options:(SDWebImageOptions)options progress:(SDWebImageDownloaderProgressBlock)progressBlock completed:(SDWebImageCompletionBlock)completedBlock;
@end
