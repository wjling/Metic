//
//  MTTextInputView.m
//  WeShare
//
//  Created by dishcool on 16/5/23.
//  Copyright © 2016年 WeShare. All rights reserved.
//

#import "MTTextInputView.h"
#import "MTMessageTextView.h"
#import "emotion_Keyboard.h"

@interface MTTextInputView()<UITextViewDelegate>
@property (strong, nonatomic) UIButton *emotionBtn;
@property (strong, nonatomic) UIButton *sendBtn;
@property (strong, nonatomic) MTMessageTextView *inputTextView;
@property (strong, nonatomic) emotion_Keyboard *emotionKeyboard;

@property (nonatomic) CGFloat textViewHeight;

@property (nonatomic) BOOL isEmotionOpen;
@property (nonatomic) BOOL isKeyBoardOpen;

@end

@implementation MTTextInputView
@synthesize isEmotionOpen;
@synthesize isKeyBoardOpen;
@synthesize textViewHeight;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupData];
        [self setupView];
        [self addKeyboardObserver];
    }
    
    return self;
}

- (void)dealloc {
    [self removeKeyboardObserver];
}

#pragma mark - init

- (void)setupData {
    isEmotionOpen = NO;
    textViewHeight = 45;
}

- (void)setupView {
    
    [self setBackgroundColor:[UIColor whiteColor]];
    self.autoresizesSubviews = YES;
    [self setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
    
    UIButton *emotionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [emotionBtn setFrame:CGRectMake(0, 0, 35, textViewHeight)];
    [emotionBtn setImage:[UIImage imageNamed:@"button_emotion"] forState:UIControlStateNormal];
    [emotionBtn addTarget:self action:@selector(button_Emotionpress:) forControlEvents:UIControlEventTouchUpInside];
    self.emotionBtn = emotionBtn;
    
    UIButton *sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [sendBtn setFrame:CGRectMake(kMainScreenWidth - 38, 5, 35, 35)];
    [sendBtn setImage:[UIImage imageNamed:@"输入框"] forState:UIControlStateNormal];
    [sendBtn addTarget:self action:@selector(sendMessage:) forControlEvents:UIControlEventTouchUpInside];
    self.sendBtn = sendBtn;
    
    // 初始化输入框
    MTMessageTextView *textView = [[MTMessageTextView  alloc] initWithFrame:CGRectZero];
    
    // 这个是仿微信的一个细节体验
    textView.returnKeyType = UIReturnKeySend;
    textView.enablesReturnKeyAutomatically = YES; // UITextView内部判断send按钮是否可以用
    textView.placeHolder = @"发送新消息";
    textView.delegate = self;
    
    textView.frame = CGRectMake(38, 5, kMainScreenWidth - 80, 35);
    textView.backgroundColor = [UIColor clearColor];
    textView.layer.borderColor = [UIColor colorWithWhite:0.8f alpha:1.0f].CGColor;
    textView.layer.borderWidth = 0.65f;
    textView.layer.cornerRadius = 6.0f;
    self.inputTextView = textView;

    
    //初始化表情面板
    emotion_Keyboard * emotionKeyboard = [[emotion_Keyboard alloc]initWithFrame:CGRectMake(0, 45, kMainScreenWidth,200)];
//    [emotionKeyboard setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
    emotionKeyboard.textView = self.inputTextView;
    self.emotionKeyboard = emotionKeyboard;
}

- (void)addKeyboardObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChangedExt:) name:UITextViewTextDidChangeNotification object:nil];
}

- (void)removeKeyboardObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:nil];
}


#pragma mark - get & set

- (void)setEmotionBtn:(UIButton *)emotionBtn {
    [self.emotionBtn removeFromSuperview];
    _emotionBtn = emotionBtn;
    [self addSubview:emotionBtn];
}

- (void)setSendBtn:(UIButton *)sendBtn {
    [self.sendBtn removeFromSuperview];
    _sendBtn = sendBtn;
    [self addSubview:sendBtn];
}

- (void)setInputTextView:(MTMessageTextView *)inputTextView {
    [self.inputTextView removeFromSuperview];
    _inputTextView = inputTextView;
    [self addSubview:inputTextView];
}

- (void)setEmotionKeyboard:(emotion_Keyboard *)emotionKeyboard {
    [self.emotionKeyboard removeFromSuperview];
    _emotionKeyboard = emotionKeyboard;
    [self addSubview:emotionKeyboard];
}

- (void)setPlaceHolder:(NSString *)placeHolder {
    self.inputTextView.placeHolder = placeHolder;
}

- (NSString *)text {
    return self.inputTextView.text;
}

#pragma mark - Intefare Method
- (void)openKeyboard {
    [self.inputTextView becomeFirstResponder];
}

- (BOOL)dismissKeyboard {
    BOOL done = NO;
    if (isKeyBoardOpen) {
        [self.inputTextView resignFirstResponder];
        done = YES;
    }
    if (isEmotionOpen) {
        [self button_Emotionpress:nil];
        done = YES;
    }
    return done;
}

- (void)clear {
    self.inputTextView.text = @"";
    
    [self dismissKeyboard];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self textChangedExt:nil];
        self.inputTextView.text = @"";
    });
}

#pragma mark - Button Method
- (void)button_Emotionpress:(id)sender {
    if (!isEmotionOpen) {
        isEmotionOpen = YES;
        if (isKeyBoardOpen) {
            [_inputTextView resignFirstResponder];
        }

        CGRect keyboardFrame = self.emotionKeyboard.frame;
        // get a rect for the textView frame
        CGRect containerFrame = self.frame;
        containerFrame.origin.y -= CGRectGetHeight(keyboardFrame);
        containerFrame.size.height = textViewHeight + CGRectGetHeight(keyboardFrame);
        
        // animations settings
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:0.25];
        [UIView setAnimationCurve:7];
        
        // set views with new info
        self.frame = containerFrame;
        
        // commit animations
        [UIView commitAnimations];
    }else {
        isEmotionOpen = NO;
        CGRect keyboardFrame = self.emotionKeyboard.frame;
        CGRect containerFrame = self.frame;
        containerFrame.origin.y += CGRectGetHeight(keyboardFrame);
        containerFrame.size.height = textViewHeight;
        // animations settings
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:0.25];
        [UIView setAnimationCurve:7];
        self.frame = containerFrame;
        
        [UIView commitAnimations];
    }
}

- (void)sendMessage:(id)sender {
    [self.delegate textInputView:self sendMessage:self.inputTextView.text];
}

#pragma mark - TextView view delegate
-(void)textChangedExt:(NSNotification *)notification
{
    CGRect frame = self.inputTextView.frame;
    float change = self.inputTextView.contentSize.height - frame.size.height;
    if (change != 0 && self.inputTextView.contentSize.height < 120) {
        frame.size.height = self.inputTextView.contentSize.height;
        [self.inputTextView setFrame:frame];
        
        textViewHeight += change;
        
        frame = self.frame;
        frame.origin.y -= change;
        frame.size.height += change;
        [self setFrame:frame];
        
        CGRect keyboardFrame = self.emotionKeyboard.frame;
        keyboardFrame.origin.y += change;
        [self.emotionKeyboard setFrame:keyboardFrame];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [self sendMessage:nil];
        return NO;
    }
    return YES;
}

-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if (isEmotionOpen) {
        [self button_Emotionpress:nil];
    }
    
    if ([self.delegate respondsToSelector:@selector(textViewShouldBeginEditing:)]) {
        [(id <UITextViewDelegate>)self.delegate textViewShouldBeginEditing:textView];
    }
    return YES;
}

#pragma mark - keyboard observer method
//Code from Brett Schumann
-(void) keyboardWillShow:(NSNotification *)note{
    isKeyBoardOpen = YES;
    if (self.isEmotionOpen) {
        [self button_Emotionpress:nil];
    }
    // get keyboard size and loctaion
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    // Need to translate the bounds to account for rotation.
//    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
    // get a rect for the textView frame
    CGRect containerFrame = self.frame;
    containerFrame.origin.y = CGRectGetHeight(self.superview.bounds) - CGRectGetHeight(keyboardBounds) - textViewHeight;
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    // set views with new info
    self.frame = containerFrame;
    
    // commit animations
    [UIView commitAnimations];
}

-(void) keyboardWillHide:(NSNotification *)note{

    isKeyBoardOpen = NO;
    
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // get a rect for the textView frame
    CGRect containerFrame = self.frame;
    containerFrame.origin.y = CGRectGetHeight(self.superview.bounds) - textViewHeight;
    
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    // set views with new info
    self.frame = containerFrame;
    
    // commit animations
    [UIView commitAnimations];
}
@end
