//
//  myScrollView.m
//  WeShare
//
//  Created by mac on 14-8-14.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "myScrollView.h"

@implementation myScrollView
@synthesize originContentSize;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(void)setContentSize:(CGSize)contentSize
{
    [super setContentSize:contentSize];
    if (self.originContentSize.width == 0) {
        self.originContentSize = contentSize;
    }
    
//    MTLOG(@"self content size: width: %f, height: %f",self.originContentSize.width,self.originContentSize.height);
}

//-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    UITouch* touch = [touches anyObject];
//    CGFloat lastX = [touch locationInView:self].x;
//    if (lastX <= 10) {
//        [self.superview touchesBegan:touches withEvent:event];
////        self.scrollEnabled = NO;
//        [super touchesBegan:touches withEvent:event];
//        MTLOG(@"superview do the touch, superview: %@",self.superview);
//        MTLOG(@"content size: width: %f, height: %f",self.contentSize.width,self.contentSize.height);
//    }
//    else
//    {
//        [self setNeedsDisplay];
////        self.scrollEnabled = YES;
//        [super touchesBegan:touches withEvent:event];
//        MTLOG(@"self do the touch");
//        MTLOG(@"content size: width: %f, height: %f",self.contentSize.width,self.contentSize.height);
//    }
//}


-(UIView*)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    MTLOG(@"point : x: %f, y: %f",point.x,point.y);
    if (point.x <= 10) {
//        MTLOG(@"superview do the touch, view: %@",self.superview);
//        MTLOG(@"content size: width: %f, height: %f",self.contentSize.width,self.contentSize.height);
        return self.superview;
    }
    else
    {
//        UIView* view = [super hitTest:point withEvent:event];
//        MTLOG(@"self do the touch, view: %@",self);
        self.contentSize = self.originContentSize;
//        MTLOG(@"content size: width: %f, height: %f",self.contentSize.width,self.contentSize.height);
        return [super hitTest:point withEvent:event];
    }
}

@end
