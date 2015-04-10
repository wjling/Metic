//
//  MTprogressView.m
//  WeShare
//
//  Created by 俊健 on 15/4/10.
//  Copyright (c) 2015年 WeShare. All rights reserved.
//

#import "MTprogressView.h"

typedef enum {
    MTprogressViewStateWaiting = 0,
    MTprogressViewStateOperationInProgress = 1,
    MTprogressViewStateOperationFinished = 2
} MTprogressViewState;

@interface MTprogressView ()

@property (assign, nonatomic) MTprogressViewState state;
@property (assign, nonatomic) CGFloat animationProggress;
@property (strong, nonatomic) NSTimer *timer;

@end


CGFloat const DAUpdateUIFrequency = 1. / 25.;


@implementation MTprogressView

#pragma mark - Initialization

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setUp];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUp];
    }
    return self;
}

- (void)setUp
{
    self.backgroundColor = [UIColor clearColor];
    self.progress = 0.;
    self.outerRadiusRatio = 5;
    self.innerRadiusRatio = 0.4;
    self.overlayColor = [UIColor colorWithWhite:250.0/255.0 alpha:0.7];
    self.animationProggress = 0.;
    self.stateChangeAnimationDuration = 0.25;
    self.triggersDownloadDidFinishAnimationAutomatically = YES;
}

#pragma mark - Public

- (void)displayOperationDidFinishAnimation
{
    self.state = MTprogressViewStateOperationFinished;
    self.animationProggress = 0.;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:DAUpdateUIFrequency target:self selector:@selector(update) userInfo:nil repeats:YES];
}

- (void)displayOperationWillTriggerAnimation
{
    self.state = MTprogressViewStateWaiting;
    self.animationProggress = 0.;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:DAUpdateUIFrequency target:self selector:@selector(update) userInfo:nil repeats:YES];
}

#pragma mark * Overwritten methods

- (void)drawRect:(CGRect)rect
{
    CGFloat width = CGRectGetWidth(rect);
    CGFloat height = CGRectGetHeight(rect);
    
    CGFloat outerRadius = [self outerRadius];
    CGFloat innerRadius = [self innerRadius];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, width / 2., height / 2.);
    CGContextScaleCTM(context, 1., -1.);
    CGContextSetRGBFillColor(context, 0., 0., 0., 0.5);
    CGContextSetFillColorWithColor(context, self.overlayColor.CGColor);
    
    if (_progress <= 1.) {
        CGFloat angle = (360. * _progress);
        CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI_2);
        CGMutablePathRef path2 = CGPathCreateMutable();
        CGPathMoveToPoint(path2, &transform, innerRadius, 0.);
        CGPathAddArc(path2, &transform, 0., 0., innerRadius*0.9, 0.,-1* angle / 180. * M_PI, YES);
        CGPathAddLineToPoint(path2, &transform, 0., 0.);
        CGPathAddLineToPoint(path2, &transform, innerRadius, 0.);
        CGContextAddPath(context, path2);
        CGContextFillPath(context);
        CGPathRelease(path2);
        
        CGAffineTransform transform3 = CGAffineTransformMakeRotation(M_PI_2);
        CGMutablePathRef path3 = CGPathCreateMutable();
        CGPathMoveToPoint(path3, &transform3, innerRadius, 0.);
        CGPathAddArc(path3, &transform3, 0., 0., innerRadius*1.1, 0.,-2 * M_PI, YES);
        CGPathAddArc(path3, &transform3, 0., 0., innerRadius*1, 0.,-2 * M_PI, NO);
        CGContextAddPath(context, path3);
        CGContextFillPath(context);
        CGPathRelease(path3);
    }
}

- (void)setInnerRadiusRatio:(CGFloat)innerRadiusRatio
{
    _innerRadiusRatio = (innerRadiusRatio < 0.) ? 0. : (innerRadiusRatio > 1.) ? 1. : innerRadiusRatio;
}

- (void)setOuterRadiusRatio:(CGFloat)outerRadiusRatio
{
    _outerRadiusRatio = (outerRadiusRatio < 0.) ? 0. : (outerRadiusRatio > 5.) ? 5. : outerRadiusRatio;
}

- (void)setProgress:(CGFloat)progress
{
    if (_progress != progress) {
        _progress = (progress < 0.) ? 0. : (progress > 1.) ? 1. : progress;
        if (progress > 0. && progress < 1.) {
            self.state = MTprogressViewStateOperationInProgress;
            [self setNeedsDisplay];
        } else if (progress == 1.){
            if (self.triggersDownloadDidFinishAnimationAutomatically) {
                [self displayOperationDidFinishAnimation];
            }else{
                [self setNeedsDisplay];
            }
        }
    }
}

#pragma mark - Private

- (CGFloat)innerRadius
{
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    CGFloat radius = MIN(width, height) / 2. * self.innerRadiusRatio;
    switch (self.state) {
        case MTprogressViewStateWaiting: return radius * self.animationProggress;
        case MTprogressViewStateOperationFinished: return radius + (MAX(width, height) / sqrtf(2.) - radius) * self.animationProggress;
        default: return radius;
    }
}

- (CGFloat)outerRadius
{
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    CGFloat radius = MIN(width, height) / 2. * self.outerRadiusRatio;
    return radius;
    switch (self.state) {
        case MTprogressViewStateWaiting: return radius * self.animationProggress;
        case MTprogressViewStateOperationFinished: return radius + (MAX(width, height) / sqrtf(2.) - radius) * self.animationProggress;
        default: return radius;
    }
}

- (void)update
{
    CGFloat animationProggress = self.animationProggress + DAUpdateUIFrequency / self.stateChangeAnimationDuration;
    if (animationProggress >= 1.) {
        self.animationProggress = 1.;
        [self.timer invalidate];
    } else {
        self.animationProggress = animationProggress;
    }
    [self setNeedsDisplay];
}

@end
