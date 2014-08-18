//
//  SignSetttingViewController.h
//  Metic
//
//  Created by mac on 14-7-20.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InputHandleView.h"
#import "CommonUtils.h"
#import "MTUser.h"
#import "HttpSender.h"

@interface SignSetttingViewController : UIViewController<HttpSenderDelegate>
@property (strong, nonatomic) IBOutlet UITextView *content_textView;
@property (strong, nonatomic) IBOutlet InputHandleView *rootView;
@property (strong, nonatomic) IBOutlet UIButton *right_barButton;

-(void)rightBarBtnClicked:(id)sender;
@end
