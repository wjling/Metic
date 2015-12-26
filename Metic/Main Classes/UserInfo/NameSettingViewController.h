//
//  NameSettingViewController.h
//  Metic
//
//  Created by mac on 14-7-17.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonUtils.h"
#import "HttpSender.h"
#import "MTUser.h"
#import "AppConstants.h"
#import "AppDelegate.h"
//

@interface NameSettingViewController : UIViewController<HttpSenderDelegate>
@property (strong, nonatomic) IBOutlet UITextField *name_textField;
@property (strong, nonatomic) IBOutlet UIButton *confirm_barButton;

- (IBAction)confirmClicked:(id)sender;

@end
