//
//  InputHandleView.h
//  Metic
//
//  Created by mac on 14-7-19.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import <UIKit/UIKit.h>

//该协议暂时只有textfield相关的方法，作用与UITextFieldDelegate里面同名方法的作用基本一致。
@protocol InputHandleViewDelegate <NSObject>

@optional
- (void)textFieldDidBeginEditing:(UITextField *)textField;
-(BOOL)textFieldShouldReturn:(UITextField *)textField;
-(void)textFieldDidEndEditing:(UITextField *)textField;

@end

//InputHandleView通常用法是作为一个root view，在上面加上textfield和textview
//注意：要把textfield或者textview的delegate设成该InputHandleView即可
@interface InputHandleView : UIView <UITextFieldDelegate,UITextViewDelegate>
{
    CGFloat textFieldOffset;
    CGRect selfOriginFrame;
    CGRect textViewFrame;
    CGFloat textHeight;
}
@property (strong, nonatomic) UITapGestureRecognizer* tapRecognizer;
@property (strong, nonatomic) id<InputHandleViewDelegate> myDelegate;

@end
