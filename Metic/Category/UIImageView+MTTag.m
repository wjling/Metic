//
//  UIImageView+MTTag.m
//  WeShare
//
//  Created by 俊健 on 15/9/12.
//  Copyright (c) 2015年 WeShare. All rights reserved.
//

#import "UIImageView+MTTag.h"
#import <objc/runtime.h>

static char kMTDownloadKey;
@implementation UIImageView (MTTag)
@dynamic downloadId;

- (void)setDownloadId:(NSNumber *)downloadId

{
    objc_setAssociatedObject(self, &kMTDownloadKey, downloadId, OBJC_ASSOCIATION_COPY);
}

- (NSString*)downloadId
{
    return objc_getAssociatedObject(self, &kMTDownloadKey);
}

@end
