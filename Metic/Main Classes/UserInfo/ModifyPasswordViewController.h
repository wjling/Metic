//
//  ModifyPasswordViewController.h
//  WeShare
//
//  Created by mac on 14-9-2.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonUtils.h"
#import "MTUser.h"
#import "HttpSender.h"

@interface ModifyPasswordViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIView *currentPS_view;
@property (strong, nonatomic) IBOutlet UIView *modifyPS_view;
@property (strong, nonatomic) IBOutlet UIView *conformPS_view;
@property (strong, nonatomic) IBOutlet UITextField *currentPS_textfield;
@property (strong, nonatomic) IBOutlet UITextField *modifyPS_textfield;
@property (strong, nonatomic) IBOutlet UITextField *conformPS_textfield;

- (IBAction)okBtnClicked:(id)sender;
@end
