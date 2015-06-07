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
+ (NSDictionary*)compressPhoto:(UIImage*)image maxWidth:(NSInteger)maxWidth maxSize:(NSInteger)maxSize
{
    
    NSData* imageData = UIImageJPEGRepresentation(image, 1.0);
    BOOL flag = YES;
    NSInteger adjustWidth = maxWidth;
    if (adjustWidth < 640) adjustWidth = 640;
    if (adjustWidth > 1440) adjustWidth = 1440;
    NSInteger curWidth = image.size.width;
    float ratio = (float)(image.size.height /image.size.width);
    
    while (flag) {
        UIImage* compressedImage;
        if (curWidth> adjustWidth) {
            curWidth = adjustWidth;
            CGSize imagesize=CGSizeMake(adjustWidth, (NSInteger)(adjustWidth*ratio));
            @autoreleasepool {
                compressedImage = [image imageByScalingToSize:imagesize];
                imageData = UIImageJPEGRepresentation(compressedImage, 1.0);
            }
        }
        
        float para = 1.0;
        int restOp = 5;
        while (imageData.length > maxSize*1000) {
            @autoreleasepool {
                para *= 0.8;
                imageData = UIImageJPEGRepresentation(compressedImage, para);
                if (!restOp--) {
                    adjustWidth *= 7/8.0;
                    imageData = nil;
                    break;
                }
            }
        }
        if (imageData || imageData.length < maxSize*1000) {
            flag = NO;
        }
    }
    NSMutableDictionary* ImgData = [[NSMutableDictionary alloc]init];
    [ImgData setValue:imageData forKey:@"imageData"];
    [ImgData setValue:[NSNumber numberWithInteger:adjustWidth] forKey:@"width"];
    [ImgData setValue:[NSNumber numberWithInteger:(NSInteger)(adjustWidth*ratio)] forKey:@"height"];
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
