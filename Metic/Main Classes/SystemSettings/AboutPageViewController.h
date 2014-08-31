//
//  AboutPageViewController.h
//  WeShare
//
//  Created by mac on 14-8-31.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonUtils.h"

@interface AboutPageViewController : UIViewController
@property (strong, nonatomic) IBOutlet UILabel *version_label;
@property (strong, nonatomic) IBOutlet UIButton *URL_button;

- (IBAction)URLBtnClicked:(id)sender;
@end
