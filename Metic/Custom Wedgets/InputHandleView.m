//
//  InputHandleView.m
//  Metic
//
//  Created by mac on 14-7-19.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "InputHandleView.h"

@implementation InputHandleView
@synthesize tapRecognizer;
@synthesize myDelegate;

- (id)initWithFrame:(CGRect)frame
{
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    tapRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(backgroundBtn:)];
    [self addGestureRecognizer:tapRecognizer];
    return [super initWithCoder:aDecoder];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(void)backgroundBtn:(id)sender
{
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
}


#pragma mark - UITextFieldDelegate
//开始编辑输入框的时候，软键盘出现，执行此事件 
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    selfOriginFrame = self.frame;
    CGRect frame;
    if ([textField superview] == self) {
        frame = textField.frame;
    }
    else
    {
        frame = [textField convertRect:textField.frame toView:self];
    }
    NSLog(@"textField frame: x: %f, y: %f, width: %f, height: %f",frame.origin.x,frame.origin.y,frame.size.width,frame.size.height);
    textFieldOffset = frame.origin.y + textField.frame.size.height - (self.frame.size.height - 216.0 - 40);//键盘高度216
    NSLog(@"textField offset: %f",textFieldOffset);
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    
    //将视图的Y坐标向上移动offset个单位，以使下面腾出地方用于软键盘的显示
    if(textFieldOffset > 0)
        self.frame = CGRectMake(0.0f, self.frame.origin.y-textFieldOffset, self.frame.size.width, self.frame.size.height);
    
    [UIView commitAnimations];
    if ([myDelegate respondsToSelector:@selector(textFieldDidBeginEditing:)]) {
        [myDelegate textFieldDidBeginEditing:textField];
    }
}

//当用户按下return键或者按回车键，keyboard消失
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if ([myDelegate respondsToSelector:@selector(textFieldShouldReturn:)]) {
        [myDelegate textFieldShouldReturn:textField];
    }
    return YES;
}

//输入框编辑完成以后，将视图恢复到原始状态
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    self.frame = selfOriginFrame; //CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    [UIView commitAnimations];
    
    if ([myDelegate respondsToSelector:@selector(textFieldDidEndEditing:)]) {
        [myDelegate textFieldDidEndEditing:textField];
    }
}

#pragma mark - UITextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    selfOriginFrame = self.frame;
    if ([textView superview] == self) {
        textViewFrame = textView.frame;
    }
    else
    {
        textViewFrame = [textView convertRect:textView.frame toView:self];
    }
    
//    textViewFrame = [self frame];
//    UIFont *font = [UIFont systemFontOfSize:14.0];
    UIFont *font = textView.font;
    CGSize size = [textView.text sizeWithFont:font constrainedToSize:CGSizeMake(textViewFrame.size.width-15, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    textHeight = size.height * 0.7;
    
//    CGRect frame = CGRectMake(textView.frame.origin.x, textView.frame.origin.y, textViewFrame.size.width, textViewFrame.size.height);
    CGRect frame = self.frame;
    int offset = self.frame.origin.y + textViewFrame.origin.y + textHeight- (self.frame.size.height - 216.0 - 30);//键盘高度216
    NSLog(@"offset: %d", offset);
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    //将视图的Y坐标向上移动offset个单位，以使下面腾出地方用于软键盘的显示
    if(offset > 0)
    {
        //        self.frame = CGRectMake(0.0f, -offset, self.frame.size.width, self.frame.size.height);
        frame.origin.y -= offset;
        [self setFrame:frame];
    }
    [UIView commitAnimations];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
//    UIFont *font = [UIFont systemFontOfSize:14.0];
    UIFont *font = textView.font;
    CGSize size = [textView.text sizeWithFont:font constrainedToSize:CGSizeMake(textView.contentSize.width - 15, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    CGFloat windowHeight = textViewFrame.size.height * 0.7;
    textHeight = size.height * 0.7; //经过多次测试，在当前字体下文本的高度要0.7倍调整
    if (textHeight < windowHeight) {

        
        NSLog(@"Feedback, text Height: %f, text view height: %f, text view y: %f",textHeight, textViewFrame.size.height, textViewFrame.origin.y);
//        CGRect frame = CGRectMake(textView.frame.origin.x, textView.frame.origin.y, textViewFrame.size.width, textViewFrame.size.height);
        CGRect frame = self.frame;
        CGFloat offset = self.frame.origin.y + textViewFrame.origin.y + textHeight - (self.frame.size.height - 216.0 - 30);//键盘高度216
        NSLog(@"offset: %f, self.frame.origin.y: %f", offset,self.frame.origin.y);
        if (offset > 0) {
            NSTimeInterval animationDuration = 0.30f;
            [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
            [UIView setAnimationDuration:animationDuration];
            //将视图的Y坐标向上移动offset个单位，以使下面腾出地方用于软键盘的显示
            //        self.frame = CGRectMake(0.0f, -offset, self.frame.size.width, self.frame.size.height);
            frame.origin.y -= offset;
            [self setFrame:frame];
            [UIView commitAnimations];
        }
        else
        {
            if (self.frame.origin.y < selfOriginFrame.origin.y) {
//                CGFloat offset2 = (self.frame.size.height - 216) - (self.frame.origin.y + textViewFrame.origin.y + textHeight);
                frame.origin.y += offset;
                if (frame.origin.y > selfOriginFrame.origin.y) {
                    frame.origin.y = selfOriginFrame.origin.y;
                   
                }
                NSTimeInterval animationDuration = 0.30f;
                [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
                [UIView setAnimationDuration:animationDuration];
                //将视图的Y坐标向上移动offset个单位，以使下面腾出地方用于软键盘的显示
                [self setFrame:frame];
                [UIView commitAnimations];
            }
        }
        
    }
    else
    {
        
        CGRect frame = self.frame;
        int offset = textViewFrame.origin.y + textViewFrame.size.height- (self.frame.size.height - 216.0 - 30);//键盘高度216
        
        if (offset > 0) {
            NSTimeInterval animationDuration = 0.30f;
            [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
            [UIView setAnimationDuration:animationDuration];
            
            //将视图的Y坐标向上移动offset个单位，以使下面腾出地方用于软键盘的显示
        
            frame.origin.y -= offset;
            [textView setFrame:frame];
            
            
            [UIView commitAnimations];
        }
//        CGRect frame = self.frame;
//        CGFloat offset = self.frame.origin.y + textViewFrame.origin.y + textHeight - (self.frame.size.height - 216.0);//键盘高度216
//        NSLog(@"offset: %f, self.frame.origin.y: %f", offset,self.frame.origin.y);
//
//        if (offset < 0) {
//            if (self.frame.origin.y < selfOriginFrame.origin.y) {
//                CGFloat offset2 = (self.frame.size.height - 216) - (self.frame.origin.y + textViewFrame.origin.y + textHeight);
//                frame.origin.y += offset2;
//                if (frame.origin.y > selfOriginFrame.origin.y) {
//                    frame.origin.y = selfOriginFrame.origin.y;
//                    
//                }
//                NSTimeInterval animationDuration = 0.30f;
//                [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
//                [UIView setAnimationDuration:animationDuration];
//                //将视图的Y坐标向上移动offset个单位，以使下面腾出地方用于软键盘的显示
//                [self setFrame:frame];
//                [UIView commitAnimations];
//            }
//        }

        
    }

    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
//    NSLog(@"textView did end editing");
//    [textView setFrame:textViewFrame];
    [self setFrame:selfOriginFrame];
    [textView setContentOffset:CGPointMake(0, 0) animated:YES];
    [textView setContentOffset:CGPointMake(0, 0) animated:YES];
}

@end
