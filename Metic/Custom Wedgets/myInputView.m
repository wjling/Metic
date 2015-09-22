//
//  myInputView.m
//  WeShare
//
//  Created by ligang_mac4 on 14-10-24.
//  Copyright (c) 2014年 WeShare. All rights reserved.
//

#import "myInputView.h"

@implementation myInputView
@synthesize textField;
@synthesize prefix_label;
@synthesize bgImgView;

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(id)init
{
    self = [super init];
    if (self) {
        // Initialization code
        MTLOG(@"myInputView init");
        [self initViews];
    }
    return self;

}

-(id)initWithFrame:(CGRect)frame
{
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        MTLOG(@"myInputView initwithframe,frame: x: %f, y: %f, width: %f, height: %f",frame.origin.x,frame.origin.y, frame.size.width, frame.size.height);
        [self initViews:frame];
    }
    return self;
}

-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [bgImgView setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    [prefix_label setFrame:CGRectMake(6, 0, frame.size.width / 5.0, frame.size.height)];
    CGFloat len = prefix_label.frame.origin.x + prefix_label.frame.size.width;
    [textField setFrame:CGRectMake(len + 3, 0, frame.size.width - len, frame.size.height)];
}

-(void)initViews
{
    bgImgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"输入框-1"]];
    prefix_label = [[UILabel alloc]init];
    textField = [[UITextField alloc]init];
    
    [self addSubview:bgImgView];
    [self addSubview:prefix_label];
    [self addSubview:textField];
}

-(void)initViews:(CGRect)frame
{
//    UIColor *bgColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"输入框-1"]];
//    [self setBackgroundColor:bgColor];
    bgImgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"输入框-1"]];
    [bgImgView setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    prefix_label = [[UILabel alloc]initWithFrame:CGRectMake(6, 0, frame.size.width / 5.0, frame.size.height)];
    prefix_label.adjustsFontSizeToFitWidth = YES;
    
    CGFloat len = prefix_label.frame.origin.x + prefix_label.frame.size.width;
    textField = [[UITextField alloc]initWithFrame:CGRectMake(len + 3, 0, frame.size.width - len, frame.size.height)];
    
    [self addSubview:bgImgView];
    [self addSubview:prefix_label];
    [self addSubview:textField];
}

@end
