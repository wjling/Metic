//
//  ScanViewController.h
//  Metic
//
//  Created by ligang_mac4 on 14-7-23.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "ZBarSDK.h"
#import "AppConstants.h"
#import "HttpSender.h"
#import "MenuViewController.h"

@interface ScanViewController : UIViewController<HttpSenderDelegate,UIAlertViewDelegate,UIImagePickerControllerDelegate>

@property (strong, nonatomic) IBOutlet UIView *shadowView;
@property (strong, nonatomic) IBOutlet UIView *showView;
@property (strong, nonatomic) IBOutlet UIView *resultView;
@property (strong, nonatomic) IBOutlet UIView *GUI;
@property (strong, nonatomic) IBOutlet UIButton *inButton;
@property (strong, nonatomic) IBOutlet UIButton *backButton;
@property (strong, nonatomic) IBOutlet UIView *controlView;
@property (weak, nonatomic) MenuViewController *menu;
@property BOOL needPopBack;
- (IBAction)back:(id)sender;
- (IBAction)wantIn:(id)sender;
- (IBAction)scanLocalPhoto:(id)sender;

@end
