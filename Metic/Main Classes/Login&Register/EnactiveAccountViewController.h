//
//  EnactiveAccountViewController.h
//  WeShare
//
//  Created by 俊健 on 15/12/5.
//  Copyright (c) 2015年 WeShare. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EnactiveAccountViewController : UIViewController
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *passwd;

- (IBAction)checkActivation:(id)sender;
- (IBAction)resendEmail:(id)sender;
-(void)setEmail:(NSString *)email AndPasswd:(NSString *)passwd;
@end
