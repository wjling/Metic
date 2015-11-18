//
//  UIImage+squareThumbail.m
//  WeShare
//
//  Created by 俊健 on 15/4/3.
//  Copyright (c) 2015年 WeShare. All rights reserved.
//

#import "UIImage+squareThumbail.h"

@implementation UIImage (squareThumbail)
-(UIImage *)squareAndSmall // as a category (so, 'self' is the input image)
{
    // fromCleverError's original
    // http://stackoverflow.com/questions/17884555
    CGSize finalsize = CGSizeMake(128,128);
    
    CGFloat scale = MAX(
                        finalsize.width/self.size.width,
                        finalsize.height/self.size.height);
    CGFloat width = self.size.width * scale;
    CGFloat height = self.size.height * scale;
    
    CGRect rr = CGRectMake( 0, 0, width, height);
    
    UIGraphicsBeginImageContextWithOptions(finalsize, NO, 0);
    [self drawInRect:rr];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
@end
