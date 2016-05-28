//
//  FillinInfoViewController.h
//  WeShare
//
//  Created by mac on 14-8-28.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonUtils.h"
#import "HttpSender.h"
#import "PECropViewController.h"
#import "PhotoGetter.h"
#import "NameSettingViewController.h"
#import "LocationSettingViewController.h"
#import "SignSetttingViewController.h"
#import "SingleSelectionAlertView.h"
#import "MTThridAccount.h"

@interface FillinInfoViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,PECropViewControllerDelegate,SingleSelectionAlertViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *info_tableview;
@property (strong, nonatomic) IBOutlet UIButton *ok_button;
@property (strong, nonatomic) UIImage* avatar;
@property (strong, nonatomic) NSString* email;
@property (strong ,nonatomic) NSString* name;
@property (strong, nonatomic) NSNumber *gender;
@property (strong, nonatomic) NSString* location;
@property (strong, nonatomic) NSString* sign;
@property (strong, nonatomic) MTThridAccount *thirdAccount;

- (IBAction)okBtnClicked:(id)sender;
@end
