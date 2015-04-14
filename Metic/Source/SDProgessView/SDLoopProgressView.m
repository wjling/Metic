//
//  SDLoopProgressView.m
//  SDProgressView
//
//  Created by aier on 15-2-19.
//  Copyright (c) 2015年 GSD. All rights reserved.
//

#import "SDLoopProgressView.h"

@implementation SDLoopProgressView

- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx0 = UIGraphicsGetCurrentContext();
    
    CGFloat xCenter0 = rect.size.width * 0.5;
    CGFloat yCenter0 = rect.size.height * 0.5;
    [[UIColor colorWithWhite:0 alpha:0.5f] set];
    
    CGContextSetLineWidth(ctx0, 10 * SDProgressViewFontScale);
    CGContextSetLineCap(ctx0, kCGLineCapRound);
    CGFloat to0 = - M_PI * 0.5 + 1.0 * M_PI * 2 + 0.05; // 初始值0.05
    CGFloat radius0 = MIN(rect.size.width, rect.size.height) * 0.5 - SDProgressViewItemMargin;
    CGContextAddArc(ctx0, xCenter0, yCenter0, radius0, - M_PI * 0.5, to0, 0);
    CGContextStrokePath(ctx0);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGFloat xCenter = rect.size.width * 0.5;
    CGFloat yCenter = rect.size.height * 0.5;
    [[UIColor whiteColor] set];
    
    CGContextSetLineWidth(ctx, 10 * SDProgressViewFontScale);
    CGContextSetLineCap(ctx, kCGLineCapRound);
    CGFloat to = - M_PI * 0.5 + self.progress * M_PI * 2 + 0.05; // 初始值0.05
    CGFloat radius = MIN(rect.size.width, rect.size.height) * 0.5 - SDProgressViewItemMargin;
    CGContextAddArc(ctx, xCenter, yCenter, radius, - M_PI * 0.5, to, 0);
    CGContextStrokePath(ctx);
    
    
    
    // 进度数字
    NSString *progressStr = [NSString stringWithFormat:@"%.0f", self.progress * 100];
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    attributes[NSFontAttributeName] = [UIFont boldSystemFontOfSize:20 * SDProgressViewFontScale];
    attributes[NSForegroundColorAttributeName] = [UIColor whiteColor];
    [self setCenterProgressText:progressStr withAttributes:attributes];
}

@end
