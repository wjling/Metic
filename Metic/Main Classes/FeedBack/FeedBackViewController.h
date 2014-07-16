//
//  FeedBackViewController.h
//  Metic
//
//  Created by mac on 14-7-15.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlideNavigationController.h"

@interface FeedBackViewController : UIViewController<SlideNavigationControllerDelegate>
@property (strong, nonatomic) IBOutlet UITextField *title_textField;
@property (strong, nonatomic) IBOutlet UITextView *content_textView;
@property (strong, nonatomic) IBOutlet UITextField *contact1_textField;
@property (strong, nonatomic) IBOutlet UITextField *contact2_textField;

- (IBAction)confrim_button:(id)sender;

@end
