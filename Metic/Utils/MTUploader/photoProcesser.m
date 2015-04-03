//
//  photoProcesser.m
//  WeShare
//
//  Created by ligang6 on 15-3-7.
//  Copyright (c) 2015年 WeShare. All rights reserved.
//

#import "photoProcesser.h"
#import "UIImage+UIImageExtras.h"
#import "MTUser.h"

@implementation photoProcesser
+ (NSDictionary*)compressPhoto:(UIImage*)image maxSize:(NSInteger)maxSize
{
    UIImage* compressedImage = image;
    NSData* imageData = UIImageJPEGRepresentation(compressedImage, 1.0);
    BOOL flag = YES;
    float adjustWidth = 640.0;
    while (flag) {
        if (compressedImage.size.width> adjustWidth) {
            CGSize imagesize=CGSizeMake((NSInteger)adjustWidth, (NSInteger)(compressedImage.size.height * adjustWidth/compressedImage.size.width));
            compressedImage = [compressedImage imageByScalingToSize:imagesize];
            imageData = UIImageJPEGRepresentation(compressedImage, 1.0);
        }
        float para = 1.0;
        int restOp = 5;
        while (imageData.length > maxSize*1000) {
            imageData = UIImageJPEGRepresentation(compressedImage, para*0.5);
            compressedImage = [UIImage imageWithData:imageData];
            if (!restOp--) {
                adjustWidth *= 7/8.0;
                break;
            }
        }
        if (imageData.length < maxSize*1000) {
            flag = NO;
        }
    }
    NSMutableDictionary* ImgData = [[NSMutableDictionary alloc]init];
    [ImgData setValue:imageData forKey:@"imageData"];
    [ImgData setValue:[NSNumber numberWithFloat:compressedImage.size.width] forKey:@"width"];
    [ImgData setValue:[NSNumber numberWithFloat:compressedImage.size.height] forKey:@"height"];
    return ImgData;
}

+ (NSString*)generateImageName
{
    NSDateFormatter * formatter = [[NSDateFormatter alloc ] init];
    [formatter setDateFormat:[NSString stringWithFormat:@"%@YYYYMMddHHmmssSSSSS",[MTUser sharedInstance].userid]];
    NSString *date =  [formatter stringFromDate:[NSDate date]];
    NSString *fileName = [[NSString alloc] initWithFormat:@"%@", date];
    return fileName;
}

+ (void)saveImage:(NSData*)imageData fileName:(NSString*)fileName
{
    
    NSString* path = [NSString stringWithFormat:@"uploadImages/%@.png",fileName];
    NSString* docFolder = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString* filePath = [docFolder stringByAppendingPathComponent:path];
    [imageData writeToFile:filePath atomically:YES];
}
@end
