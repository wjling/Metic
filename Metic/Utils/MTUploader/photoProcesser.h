//
//  photoProcesser.h
//  WeShare
//
//  Created by ligang6 on 15-3-7.
//  Copyright (c) 2015年 WeShare. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface photoProcesser : NSObject

#pragma 压缩图片 返回图片名
+ (NSData*)compressPhoto:(UIImage*)image maxSize:(NSInteger)maxSize;

#pragma 生成图片文件名
+ (NSString*)generateImageName;

#pragma 保存图片至临时文件夹
+ (void)saveImage:(NSData*)imageData fileName:(NSString*)fileName;
@end
