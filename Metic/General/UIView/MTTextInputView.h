//
//  MTTextInputView.h
//  WeShare
//
//  Created by dishcool on 16/5/23.
//  Copyright © 2016年 WeShare. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MTTextInputView;

@protocol MTTextInputViewDelegate <NSObject>

@required
- (void)textInputView:(MTTextInputView *)textInputView sendMessage:(NSString *)message;

@end

@interface MTTextInputView : UIView

@property (nonatomic, weak) id<MTTextInputViewDelegate> delegate;

@property (nonatomic, strong) NSString *placeHolder;

@property (nonatomic, strong) NSString *text;

- (void)openKeyboard;

- (BOOL)dismissKeyboard;

- (void)clear;

- (void)addKeyboardObserver;

- (void)removeKeyboardObserver;

@end
