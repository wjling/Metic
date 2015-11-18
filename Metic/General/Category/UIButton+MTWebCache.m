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
    [self sd_setImageWithURL:url forState:state  placeholderImage:nil options:SDWebImageRetryFailed completed:completedBlock];

}

@end
