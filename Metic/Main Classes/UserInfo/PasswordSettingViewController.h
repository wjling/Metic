//
//  PasswordSettingViewController.h
//  WeShare
//
//  Created by 俊健 on 15/12/23.
//  Copyright (c) 2015年 WeShare. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PasswordSettingViewController : UIViewController
@property (strong, nonatomic) IBOutlet UITextField *passwordTextfield;
@property (strong, nonatomic) NSString *verificatedPhone;
@property (strong, nonatomic) NSString *salt;

- (IBAction)confirm:(id)sender;

@end
