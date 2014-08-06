//
//  UserInfoViewController.h
//  Metic
//
//  Created by mac on 14-7-16.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserInfoTableViewCell.h"
#import "PhotoGetter.h"
#import "SingleSelectionAlertView.h"
#import "NameSettingViewController.h"
#import "LocationSettingViewController.h"
#import "SignSetttingViewController.h"
#import "HttpSender.h"
#import "HomeViewController.h"
#import "SlideNavigationController.h"
#import "PECropViewController.h"

@interface UserInfoViewController : UIViewController<SlideNavigationControllerDelegate,UITableViewDataSource,UITableViewDelegate,SingleSelectionAlertViewDelegate,HttpSenderDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,PECropViewControllerDelegate>
@property (strong, nonatomic) IBOutlet UIView *banner_UIview;
@property (strong, nonatomic) IBOutlet UIImageView *banner_imageView;
@property (strong, nonatomic) IBOutlet UIImageView *avatar_imageView;
@property (strong, nonatomic) IBOutlet UILabel *name_label;
@property (strong, nonatomic) UIImageView *gender_imageView;
@property (strong, nonatomic) IBOutlet UILabel *email_label;
@property (strong, nonatomic) IBOutlet UITableView *info_tableView;
@property (strong, nonatomic) NameSettingViewController* name_vc;
@property (strong, nonatomic) IBOutlet UIView *shadowView;

-(void)refresh;

@end
