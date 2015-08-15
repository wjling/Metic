//
//  UIImageView+MTImageCache.m
//  WeShare
//
//  Created by 俊健 on 15/8/15.
//  Copyright (c) 2015年 WeShare. All rights reserved.
//

#import "UIImageView+MTWebCache.h"

@implementation UIImageView (MTWebCache)

//下载后将图片的key替换成云端路径



- (void)sd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder cloudPath:(NSString *)path options:(SDWebImageOptions)options completed:(SDWebImageCompletionBlock)completedBlock
{
    [self sd_setImageWithURL:url placeholderImage:placeholder cloudPath:path options:options progress:nil completed:completedBlock];
}

- (void)sd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder cloudPath:(NSString *)path completed:(SDWebImageCompletionBlock)completedBlock
{
    [self sd_setImageWithURL:url placeholderImage:placeholder cloudPath:path options:SDWebImageRetryFailed progress:nil completed:completedBlock];
}

- (void)sd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder cloudPath:(NSString *)path
{
    [self sd_setImageWithURL:url placeholderImage:placeholder cloudPath:path options:SDWebImageRetryFailed progress:nil completed:nil];
}

- (void)sd_setImageWithURL:(NSURL *)url cloudPath:(NSString *)path
{
    [self sd_setImageWithURL:url placeholderImage:nil cloudPath:path options:SDWebImageRetryFailed progress:nil completed:nil];
}

- (void)sd_setImageWithURL:(NSURL *)url cloudPath:(NSString *)path completed:(SDWebImageCompletionBlock)completedBlock
{
    [self sd_setImageWithURL:url placeholderImage:nil cloudPath:path options:SDWebImageRetryFailed progress:nil completed:completedBlock];
}

- (void)sd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder cloudPath:(NSString *)path options:(SDWebImageOptions)options
{
    [self sd_setImageWithURL:url placeholderImage:placeholder cloudPath:path options:SDWebImageRetryFailed progress:nil completed:nil];
}

- (void)sd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder cloudPath:(NSString *)path options:(SDWebImageOptions)options progress:(SDWebImageDownloaderProgressBlock)progressBlock
{
    [self sd_setImageWithURL:url placeholderImage:placeholder cloudPath:path options:SDWebImageRetryFailed progress:progressBlock completed:nil];
}



- (void)sd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder  cloudPath:(NSString *)path options:(SDWebImageOptions)options progress:(SDWebImageDownloaderProgressBlock)progressBlock completed:(SDWebImageCompletionBlock)completedBlock
{
    __block BOOL isCache = NO;
    void (^newCompletedBlock)(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) = ^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (!isCache && image && options != SDWebImageCacheMemoryOnly && ![[url absoluteString] isEqualToString:path] && path && ![path isEqualToString:@""]) {
            [[SDImageCache sharedImageCache] storeImage:image forKey:path];
        }
        if(completedBlock) completedBlock(image,error,cacheType,imageURL);
    };
    if (path && ![path isEqualToString:@""]){
        if ([[SDImageCache sharedImageCache]diskImageExistsWithKey:path]) {
            isCache = YES;
            [self sd_setImageWithURL:[NSURL URLWithString:path] placeholderImage:placeholder options:SDWebImageRetryFailed progress:progressBlock completed:newCompletedBlock];
        }else [self sd_setImageWithURL:url placeholderImage:placeholder options:SDWebImageCacheMemoryOnly progress:progressBlock completed:newCompletedBlock];
    }else [self sd_setImageWithURL:url placeholderImage:placeholder options:options progress:progressBlock completed:completedBlock];
}


@end
