//
//  ScanViewController.h
//  Metic
//
//  Created by ligang_mac4 on 14-7-23.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZBarSDK.h"
#import "AppConstants.h"
#import "HttpSender.h"

@interface ScanViewController : UIViewController<ZBarReaderViewDelegate,HttpSenderDelegate,UIAlertViewDelegate>
{
    IBOutlet ZBarReaderView *readerView;
}

@property (strong, nonatomic) IBOutlet UIView *shadowView;
@property (strong, nonatomic) IBOutlet UIView *showView;
@property (strong, nonatomic) IBOutlet UIView *resultView;
@property (nonatomic, retain) ZBarReaderView *readerView;
@property (strong, nonatomic) IBOutlet UIButton *inButton;
- (IBAction)back:(id)sender;
- (IBAction)wantIn:(id)sender;

@end
