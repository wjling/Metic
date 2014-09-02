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
//    textViewFrame = [textView convertRect:textView.frame toView:self];
    textViewFrame = [textView frame];
    UIFont *font = [UIFont systemFontOfSize:14.0];
    CGSize size = [textView.text sizeWithFont:font constrainedToSize:CGSizeMake(textViewFrame.size.width-16, 9999) lineBreakMode:NSLineBreakByWordWrapping];
    textHeight = size.height+16;
    
    CGRect frame = CGRectMake(textView.frame.origin.x, textView.frame.origin.y, textViewFrame.size.width, textViewFrame.size.height);
    int offset = textView.frame.origin.y + textHeight- (self.frame.size.height - 216.0);//键盘高度216
    NSLog(@"offset: %d", offset);
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    //将视图的Y坐标向上移动offset个单位，以使下面腾出地方用于软键盘的显示
    if(offset > 0)
    {
        //        self.frame = CGRectMake(0.0f, -offset, self.frame.size.width, self.frame.size.height);
        frame.origin.y -= offset;
        [textView setFrame:frame];
    }
    [UIView commitAnimations];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    UIFont *font = [UIFont systemFontOfSize:14.0];
    CGSize size = [textView.text sizeWithFont:font constrainedToSize:CGSizeMake(textViewFrame.size.width-16, 9999) lineBreakMode:NSLineBreakByWordWrapping];
    if (textHeight < textViewFrame.size.height) {

        textHeight = size.height+16;
        
        CGRect frame = CGRectMake(textView.frame.origin.x, textView.frame.origin.y, textViewFrame.size.width, textViewFrame.size.height);
        int offset = textView.frame.origin.y + textHeight- (self.frame.size.height - 216.0);//键盘高度216
//        NSLog(@"offset: %d", offset);
        NSTimeInterval animationDuration = 0.30f;
        [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
        [UIView setAnimationDuration:animationDuration];
        //将视图的Y坐标向上移动offset个单位，以使下面腾出地方用于软键盘的显示
        if(offset > 0)
        {
            //        self.frame = CGRectMake(0.0f, -offset, self.frame.size.width, self.frame.size.height);
            frame.origin.y -= offset;
            [textView setFrame:frame];
        }
        [UIView commitAnimations];
    }
    else
    {
        
        CGRect frame = CGRectMake(textViewFrame.origin.x, textViewFrame.origin.y, textViewFrame.size.width, textViewFrame.size.height);
        int offset = textView.frame.origin.y + textView.frame.size.height- (self.frame.size.height - 216.0);//键盘高度216
        
        NSTimeInterval animationDuration = 0.30f;
        [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
        [UIView setAnimationDuration:animationDuration];
        
        //将视图的Y坐标向上移动offset个单位，以使下面腾出地方用于软键盘的显示
        if(offset > 0)
        {
            //        self.frame = CGRectMake(0.0f, -offset, self.frame.size.width, self.frame.size.height);
            frame.origin.y -= offset;
            [textView setFrame:frame];
        }
        
        [UIView commitAnimations];
    }

    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
//    NSLog(@"textView did end editing");
    [textView setFrame:textViewFrame];
    [textView setContentOffset:CGPointMake(0, 0) animated:YES];
    [textView setContentOffset:CGPointMake(0, 0) animated:YES];
}

@end
