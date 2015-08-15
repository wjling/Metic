//
//  UIButton+MTWebCache.m
//  WeShare
//
//  Created by 俊健 on 15/8/15.
//  Copyright (c) 2015年 WeShare. All rights reserved.
//

#import "UIButton+MTWebCache.h"

@implementation UIButton (MTWebCache)

- (void)sd_setImageWithURL:(NSURL *)url forState:(UIControlState)state cloudPath:(NSString *)path completed:(SDWebImageCompletionBlock)completedBlock {
    
    __block BOOL isCache = NO;
    void (^newCompletedBlock)(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) = ^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (!isCache && image && ![[url absoluteString] isEqualToString:path] && path && ![path isEqualToString:@""]) {
            [[SDImageCache sharedImageCache] storeImage:image forKey:path];
        }
        if(completedBlock) completedBlock(image,error,cacheType,imageURL);
    };
    if (path && ![path isEqualToString:@""]){
        if ([[SDImageCache sharedImageCache]diskImageExistsWithKey:path]) {
            isCache = YES;
            [self sd_setImageWithURL:[NSURL URLWithString:path] forState:state placeholderImage:nil options:SDWebImageRetryFailed completed:newCompletedBlock];
        }else [self sd_setImageWithURL:url forState:state  placeholderImage:nil options:SDWebImageCacheMemoryOnly completed:newCompletedBlock];
    }else [self sd_setImageWithURL:url forState:state  placeholderImage:nil options:SDWebImageRetryFailed completed:completedBlock];

}

@end
