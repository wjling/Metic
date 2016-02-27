//
//  emotion_Keyboard.h
//  WeShare
//
//  Created by ligang_mac4 on 14-8-18.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface emotion_Keyboard : UIView
-(id)initWithPoint:(CGPoint)point;

@property(nonatomic,strong) UITextField* textField;
@property(nonatomic,strong) UITextView* textView;

@end
