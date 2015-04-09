//
//  FeedBackViewController.h
//  Metic
//
//  Created by mac on 14-7-15.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlideNavigationController.h"
#import "InputHandleView.h"
#import "MTUser.h"
#import "HttpSender.h"
#import "CommonUtils.h"

@interface FeedBackViewController : UIViewController<SlideNavigationControllerDelegate,UITextViewDelegate,HttpSenderDelegate,InputHandleViewDelegate>

@property (strong, nonatomic) IBOutlet UITextView *content_textView;
@property (strong, nonatomic) IBOutlet UITextField *contact1_textField;
@property (strong, nonatomic) IBOutlet InputHandleView *rootView;
@property (strong, nonatomic) IBOutlet UIView *shadowView;

- (IBAction)confrim_button:(id)sender;

@end
