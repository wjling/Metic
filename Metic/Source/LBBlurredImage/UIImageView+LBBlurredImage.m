//
//  UIImageView+LBBlurredImage.m
//  LBBlurredImage
//
//  Created by Luca Bernardi on 11/11/12.
//  Copyright (c) 2012 Luca Bernardi. All rights reserved.
//

#import "UIImageView+LBBlurredImage.h"
#import <CoreImage/CoreImage.h>


NSString *const kLBBlurredImageErrorDomain          = @"com.lucabernardi.blurred_image_additions";
CGFloat const   kLBBlurredImageDefaultBlurRadius    = 20.0;


@implementation UIImageView (LBBlurredImage)

#pragma mark - LBBlurredImage Additions

- (void)setImageToBlur: (UIImage *)image
            blurRadius: (CGFloat)blurRadius
       completionBlock: (LBBlurredImageCompletionBlock) completion

{
    CIContext *context   = [CIContext contextWithOptions:nil];
    CIImage *sourceImage = [CIImage imageWithCGImage:image.CGImage];
    
    // Apply clamp filter:
    // this is needed because the CIGaussianBlur when applied makes
    // a trasparent border around the image
    
    NSString *clampFilterName = @"CIAffineClamp";
    CIFilter *clamp = [CIFilter filterWithName:clampFilterName];
    
    if (!clamp) {
        
        NSError *error = [self errorForNotExistingFilterWithName:clampFilterName];
        if (completion) {
            completion(error);
        }
        return;
    }
    
    [clamp setValue:sourceImage
             forKey:kCIInputImageKey];
    
    CIImage *clampResult = [clamp valueForKey:kCIOutputImageKey];
    
    // Apply Gaussian Blur filter
    
    NSString *gaussianBlurFilterName = @"CIGaussianBlur";
    CIFilter *gaussianBlur           = [CIFilter filterWithName:gaussianBlurFilterName];
    
    if (!gaussianBlur) {
        
        NSError *error = [self errorForNotExistingFilterWithName:gaussianBlurFilterName];
        if (completion) {
            completion(error);
        }
        return;
    }
    
    [gaussianBlur setValue:clampResult
                    forKey:kCIInputImageKey];
    [gaussianBlur setValue:[NSNumber numberWithFloat:blurRadius]
                    forKey:@"inputRadius"];
    
    CIImage *gaussianBlurResult = [gaussianBlur valueForKey:kCIOutputImageKey];
    
    __weak UIImageView *selfWeak = self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        CGImageRef cgImage = [context createCGImage:gaussianBlurResult
                                           fromRect:[sourceImage extent]];
        
        UIImage *blurredImage = [UIImage imageWithCGImage:cgImage];
        CGImageRelease(cgImage);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            selfWeak.image = blurredImage;
            if (completion){
                completion(nil);
            }
        });
    });
}

- (void)setImageToBlur: (UIImage *)image
            blurRadius: (CGFloat)blurRadius
            brightness: (CGFloat)brightness
       completionBlock: (LBBlurredImageCompletionBlock) completion
{
    CIContext *context   = [CIContext contextWithOptions:nil];
    CIImage *sourceImage = [CIImage imageWithCGImage:image.CGImage];
    
    // Apply clamp filter:
    // this is needed because the CIGaussianBlur when applied makes
    // a trasparent border around the image
    
    NSString *clampFilterName = @"CIAffineClamp";
    CIFilter *clamp = [CIFilter filterWithName:clampFilterName];
    
    if (!clamp) {
        
        NSError *error = [self errorForNotExistingFilterWithName:clampFilterName];
        if (completion) {
            completion(error);
        }
        return;
    }
    
    [clamp setValue:sourceImage
             forKey:kCIInputImageKey];
    
    CIImage *clampResult = [clamp valueForKey:kCIOutputImageKey];
    
    
    NSString* lightenFilterName = @"CIColorControls";
    CIFilter *lighten = [CIFilter filterWithName:lightenFilterName];
    if (!lighten) {
        
        NSError *error = [self errorForNotExistingFilterWithName:lightenFilterName];
        if (completion) {
            completion(error);
        }
        return;
    }
    
    [lighten setValue:clampResult forKey:kCIInputImageKey];
    [lighten setValue:[NSNumber numberWithFloat:brightness] forKey:@"inputBrightness"];
    CIImage* brightResult = [lighten valueForKey:kCIOutputImageKey];

    
    // Apply Gaussian Blur filter
    
    NSString *gaussianBlurFilterName = @"CIGaussianBlur";
    CIFilter *gaussianBlur           = [CIFilter filterWithName:gaussianBlurFilterName];
    
    if (!gaussianBlur) {
        
        NSError *error = [self errorForNotExistingFilterWithName:gaussianBlurFilterName];
        if (completion) {
            completion(error);
        }
        return;
    }
    
    [gaussianBlur setValue:brightResult
                    forKey:kCIInputImageKey];
    [gaussianBlur setValue:[NSNumber numberWithFloat:blurRadius]
                    forKey:@"inputRadius"];
    
    CIImage *gaussianBlurResult = [gaussianBlur valueForKey:kCIOutputImageKey];
    
    
//    NSString* lightenFilterName = @"CIColorControls";
//    CIFilter *lighten = [CIFilter filterWithName:lightenFilterName];
//    if (!lighten) {
//        
//        NSError *error = [self errorForNotExistingFilterWithName:lightenFilterName];
//        if (completion) {
//            completion(error);
//        }
//        return;
//    }
//
//    [lighten setValue:gaussianBlurResult forKey:kCIInputImageKey];
//    [lighten setValue:[NSNumber numberWithFloat:brightness] forKey:@"inputBrightness"];
//    CIImage* brightResult = [lighten valueForKey:kCIOutputImageKey];
    
    __weak UIImageView *selfWeak = self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        CGImageRef cgImage = [context createCGImage:gaussianBlurResult
                                           fromRect:[sourceImage extent]];
        
        UIImage *blurredImage = [UIImage imageWithCGImage:cgImage];
        CGImageRelease(cgImage);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            selfWeak.image = blurredImage;
            if (completion){
                completion(nil);
            }
        });
    });

}

/**
 Internal method for generate an NSError if the provided CIFilter name doesn't exists
 */
- (NSError *)errorForNotExistingFilterWithName:(NSString *)filterName
{
    NSString *errorDescription = [NSString stringWithFormat:@"The CIFilter named %@ doesn't exist",filterName];
    NSError *error             = [NSError errorWithDomain:kLBBlurredImageErrorDomain
                                                     code:LBBlurredImageErrorFilterNotAvailable
                                                 userInfo:@{NSLocalizedDescriptionKey : errorDescription}];
    return error;
}

@end
