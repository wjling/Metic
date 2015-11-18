//
//  UIButton+MTWebCache.h
//  WeShare
//
//  Created by 俊健 on 15/8/15.
//  Copyright (c) 2015年 WeShare. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIButton+WebCache.h"

@interface UIButton (MTWebCache)

- (void)sd_setImageWithURL:(NSURL *)url forState:(UIControlState)state cloudPath:(NSString *)path completed:(SDWebImageCompletionBlock)completedBlock;

@end
