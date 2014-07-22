//
//  ScaningViewController.h
//  Metic
//
//  Created by ligang6 on 14-7-19.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZBarSDK.h"
#import "SlideNavigationController.h"

@interface ScaningViewController : UIViewController<SlideNavigationControllerDelegate,ZBarReaderDelegate>
@property (strong, nonatomic) IBOutlet UIView *shadowView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
- (IBAction)scan:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *label;
@end
