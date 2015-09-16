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
static char kMTDownloadNKey;
@implementation UIImageView (MTTag)
@dynamic downloadId;
@dynamic downloadName;

- (void)setDownloadId:(NSNumber *)downloadId

{
    objc_setAssociatedObject(self, &kMTDownloadKey, downloadId, OBJC_ASSOCIATION_COPY);
}

- (NSString*)downloadId
{
    return objc_getAssociatedObject(self, &kMTDownloadKey);
}


- (void)setDownloadName:(NSString *)downloadName

{
    objc_setAssociatedObject(self, &kMTDownloadNKey, downloadName, OBJC_ASSOCIATION_COPY);
}

- (NSString*)downloadName
{
    return objc_getAssociatedObject(self, &kMTDownloadNKey);
}

@end
