//
//  BindingPhoneViewController.h
//  WeShare
//
//  Created by mac on 14-9-3.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonUtils.h"
#import "HttpSender.h"
#import "MTUser.h"

@interface BindingPhoneViewController : UIViewController<UIAlertViewDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *gou_imageview;
@property (strong, nonatomic) IBOutlet UILabel *hint1_label;
@property (strong, nonatomic) IBOutlet UILabel *bindingNumber_label;
@property (strong, nonatomic) IBOutlet UILabel *hint2_label;
@property (strong, nonatomic) IBOutlet UIButton *checkContact_button;
@property (strong, nonatomic) IBOutlet UIButton *changeNumber_button;

- (IBAction)checkContactClicked:(id)sender;
- (IBAction)changeNumberClicked:(id)sender;
@end
