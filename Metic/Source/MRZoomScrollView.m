//
//  MRZoomScrollView.m
//  ScrollViewWithZoom
//
//  Created by xuym on 13-3-27.
//  Copyright (c) 2013年 xuym. All rights reserved.
//

#import "MRZoomScrollView.h"

#define MRScreenWidth      CGRectGetWidth([UIScreen mainScreen].applicationFrame)
#define MRScreenHeight     CGRectGetHeight([UIScreen mainScreen].applicationFrame)

@interface MRZoomScrollView (Utility)

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center;

@end

@implementation MRZoomScrollView

@synthesize imageView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.delegate = self;
        self.frame = CGRectMake(0, 0, MRScreenWidth, MRScreenHeight);
        [self setShowsHorizontalScrollIndicator:NO];
        [self setShowsVerticalScrollIndicator:NO];
        [self initImageView];
    }
    return self;
}

- (void)initImageView
{
    imageView = [[UIImageView alloc]init];
    
    // The imageView can be zoomed largest size
    imageView.frame = CGRectMake(0, 0, MRScreenWidth * 4, MRScreenHeight * 4);
    imageView.userInteractionEnabled = YES;
    [self addSubview:imageView];
    
    // Add gesture,double tap zoom imageView.
    UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(handleDoubleTap:)];
    [doubleTapGesture setNumberOfTapsRequired:2];
    [imageView addGestureRecognizer:doubleTapGesture];
    
    float minimumScale = self.frame.size.width / imageView.frame.size.width;
    [self setMinimumZoomScale:minimumScale];
    [self setZoomScale:minimumScale];
}

-(void)fitImageView
{
    float containerWidth = 316;
    float containerHeight = self.frame.size.height;
    [self setContentSize:CGSizeMake(containerWidth, containerHeight)];
    if (containerWidth/containerHeight < self.imageView.image.size.width / self.imageView.image.size.height) {
        float photoHeight = self.imageView.image.size.height*containerWidth/imageView.image.size.width;
        [self.imageView setFrame:CGRectMake(0, (containerHeight - photoHeight)/2, containerWidth, photoHeight)];
    }else{
        float photoWidth = self.imageView.image.size.width*containerHeight/imageView.image.size.height;
        [self.imageView setFrame:CGRectMake((containerWidth - photoWidth)/2, 0, photoWidth, containerHeight)];
    }
}
#pragma mark - Zoom methods

- (void)handleDoubleTap:(UIGestureRecognizer *)gesture
{
    float newScale = self.zoomScale * 2.0;
    if (self.zoomScale == 1.0) {
        newScale = 0.25;
    }
    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gesture locationInView:gesture.view]];
    [self zoomToRect:zoomRect animated:YES];
}

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center
{
    CGRect zoomRect;
    zoomRect.size.height = self.frame.size.height / scale;
    zoomRect.size.width  = self.frame.size.width  / scale;
    zoomRect.origin.x = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0);
    return zoomRect;
}

- (void)zoomToNormal
{
    float newScale = 0.25;
    if (self.zoomScale != newScale) {
        CGRect zoomRect = [self zoomRectForScale:newScale withCenter:CGPointMake(self.contentOffset.x, self.contentOffset.y)];
        [self zoomToRect:zoomRect animated:YES];
    }
    
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return imageView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
{
    [scrollView setZoomScale:scale animated:NO];
    [self setContentSize:CGSizeMake(self.contentSize.width, self.imageView.frame.origin.y*2 +self.imageView.frame.size.height)];
}

@end
