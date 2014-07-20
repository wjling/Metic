//
//  RegisterViewController.h
//  Metic
//
//  Created by ligang_mac4 on 14-5-27.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HttpSender.h"
#import "CommonUtils.h"
#import "AppConstants.h"
#import "InputHandleView.h"

@interface RegisterViewController : UIViewController <InputHandleViewDelegate, HttpSenderDelegate,UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *textField_email;
@property (weak, nonatomic) IBOutlet UITextField *textField_userName;
@property (weak, nonatomic) IBOutlet UITextField *textField_password;
@property (weak, nonatomic) IBOutlet UITextField *textField_confromPassword;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl_gender;
@property (weak, nonatomic) IBOutlet UIButton *button_signUp;
@property (weak, nonatomic) IBOutlet UIButton *button_backToLogin;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIButton *nextStep;
@property (strong, nonatomic) IBOutlet InputHandleView *rootView;


-(IBAction)signUpButtonClicked:(id)sender;
-(IBAction)backToLoginButtonClicked:(id)sender;
//-(void)genderSegmentedControlChanged:(int*)gender;
//-(IBAction)backgroundBtn:(id)sender;
//- (IBAction)text_Clear:(id)sender;
- (IBAction)step_next:(id)sender;


- (void)jumpToLogin;
- (void)jumpToMain;
@end
