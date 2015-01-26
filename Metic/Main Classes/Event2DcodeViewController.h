//
//  Event2DcodeViewController.h
//  Metic
//
//  Created by ligang6 on 14-7-19.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UMSocial.h"

@interface Event2DcodeViewController : UIViewController<UMSocialUIDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *avatar;
@property (strong, nonatomic) IBOutlet UILabel *activity;
@property (strong, nonatomic) IBOutlet UILabel *launcher;
@property (strong, nonatomic) IBOutlet UIImageView *TwodCode;
@property (strong, nonatomic) IBOutlet UIView *mainView;
@property (strong, nonatomic) NSNumber* eventId;
@property (strong, nonatomic) NSDictionary* eventInfo;
- (IBAction)shareQRcode:(id)sender;
- (IBAction)saveQRcode:(id)sender;
@end
