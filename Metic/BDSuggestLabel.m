//
//  BDSuggestLabel.m
//  BingDic
//
//  Created by 854072335 yxlong on 13-1-3.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import "BDSuggestLabel.h"
#import "NSAttributedString+Attributes.h"

@implementation BDSuggestLabel
@synthesize keyWord = _keyword;
@synthesize keyWordColor = _keywordColor;
@synthesize keyWordFont = _keyWordFont;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _keywordColor = [UIColor blackColor];
        _keyWordFont = [UIFont systemFontOfSize:19.0f];
        
    }
    return self;
}

- (void) setText:(NSString *) _text
{
    [super setText:_text];
//    [self setNeedsDisplay];
}
- (NSString *) keyWord
{
    return _keyword;
}
- (void) setKeyWord:(NSString *) keyWord_
{
    _keyword = [keyWord_ copy];
//    [self setNeedsDisplay];
}

- (UIColor *) keyWordColor
{
    return _keywordColor;
}
- (void) setKeyWordColor:(UIColor *)keyWordColor_
{
    _keywordColor = [keyWordColor_ copy];
    [self setNeedsDisplay];
}
- (void) setKeyWordFont:(UIFont *)keyWordFont_
{
    _keyWordFont = [keyWordFont_ copy];
    
    [self setNeedsDisplay];
}


- (void)drawTextInRect:(CGRect) aRect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:self.text] ;
    [attrString setFont:self.font range:NSMakeRange(0, [self.text length])];
    [attrString setTextColor:self.textColor range:NSMakeRange(0, [self.text length])];
    [attrString setTextAlignment:kCTLeftTextAlignment lineBreakMode:kCTLineBreakByCharWrapping range:NSMakeRange(0, [self.text length])];
    // set keyword' attribute
    if(_keyword&&self.text)
    {
        NSRange keyWordRange = [self.text rangeOfString:_keyword];
        if(keyWordRange.location != NSNotFound)
        {
            [attrString setFont:_keyWordFont range:keyWordRange];//执行完set后，font即被释放掉，所以在dealloc里面不在releaseß
            [attrString setTextColor:_keywordColor range:keyWordRange];
        }
    }
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, aRect);
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attrString);
    
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, [attrString length]), path, NULL);
    CFRelease(framesetter);
    //CFRelease(attrString);
    
    if (frame) 
    {
        CGContextSaveGState(context);
        // Core Text wants to draw our text upside-down!  This flips it the 
        // right way.
        CGContextTranslateCTM(context, 0, aRect.origin.y);
        CGContextScaleCTM(context, 1, -1);
        CGContextTranslateCTM(context, 0, -(aRect.origin.y + aRect.size.height));
//        CGContextConcatCTM(context, CGAffineTransformScale(CGAffineTransformMakeTranslation(0, self.bounds.size.height), 1.f, -1.f));
        CTFrameDraw(frame, context);
        
        CGContextRestoreGState(context);
        
        CFRelease(frame);
    }
}


@end
