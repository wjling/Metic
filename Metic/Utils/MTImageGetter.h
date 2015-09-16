//
//  MTImageGetter.h
//  WeShare
//
//  Created by 俊健 on 15/9/16.
//  Copyright (c) 2015年 WeShare. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIImageView+MTWebCache.h"

typedef void(^MTImageGetterCompletionBlock)(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL);

typedef enum : NSUInteger {
    MTImageGetterTypeAvatar,
    MTImageGetterTypePhoto,
    MTImageGetterTypeVideoThumb,
} MTImageGetterType;

@interface MTImageGetter : NSObject

-(instancetype)initWithImageView:(UIImageView*)imageView imageId:(NSNumber *)imageId imageName:(NSString *)imageName type:(MTImageGetterType)type;
-(void)getImage;
-(void)getImageComplete:(MTImageGetterCompletionBlock)completedBlock;
@end
