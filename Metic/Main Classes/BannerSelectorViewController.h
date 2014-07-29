//
//  BannerSelectorViewController.h
//  Metic
//
//  Created by ligang_mac4 on 14-7-29.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PECropViewController.h"
#import "LaunchEventViewController.h"

@interface BannerSelectorViewController : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate,PECropViewControllerDelegate>
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *defaultBanners;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *selectorIndictors;
@property (strong, nonatomic) UIImage* uploadImage;
@property (strong, nonatomic) LaunchEventViewController* controller;
- (IBAction)selectBanner:(id)sender;
- (IBAction)getMyBanner:(id)sender;
- (IBAction)confirmBanner:(id)sender;

@end
