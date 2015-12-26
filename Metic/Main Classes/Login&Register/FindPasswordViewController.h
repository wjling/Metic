//
//  FindPasswordViewController.h
//  WeShare
//
//  Created by 俊健 on 15/12/15.
//  Copyright (c) 2015年 WeShare. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FindPasswordViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIButton *verificateWithTelButton;
@property (strong, nonatomic) IBOutlet UIButton *verificateWithEmailButton;

- (IBAction)verificateWithTel:(id)sender;
- (IBAction)verificateWithEmailButton:(id)sender;
@end
