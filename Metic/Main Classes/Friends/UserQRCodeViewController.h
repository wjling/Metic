//
//  UserQRCodeViewController.h
//  WeShare
//
//  Created by mac on 14-9-1.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonUtils.h"
#import "MobClick.h"
#import "PhotoGetter.h"
#import <QREncoder/QREncoder.h>
#import "UMSocial.h"

@interface UserQRCodeViewController : UIViewController<UMSocialUIDelegate>
@property (strong, nonatomic) IBOutlet UIView *mainView;
@property (strong, nonatomic) IBOutlet UIImageView *avatar;
@property (strong, nonatomic) IBOutlet UIImageView *QRcode_imageview;
@property (strong, nonatomic) IBOutlet UILabel *fname_label;
@property (strong, nonatomic) IBOutlet UILabel *femail_label;
@property (strong, nonatomic) NSMutableDictionary* friendInfo_dic;
@property (strong, nonatomic) NSNumber* fid;

- (IBAction)shareQRcode:(id)sender;
- (IBAction)saveQRcode:(id)sender;
@end
