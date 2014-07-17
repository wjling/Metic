//
//  LaunchEventViewController.h
//  Metic
//
//  Created by ligang6 on 14-6-3.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HttpSender.h"
#import "BMapKit.h"
#import "PECropViewController.h"
#import "../Utils/PhotoGetter.h"


@interface LaunchEventViewController : UIViewController<UIScrollViewDelegate,UITextFieldDelegate,HttpSenderDelegate,UITextViewDelegate,BMKGeoCodeSearchDelegate,BMKLocationServiceDelegate,PECropViewControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate,PhotoGetterDelegate>
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UITextField *event_text;
@property (strong, nonatomic) IBOutlet UITextField *begin_time_text;
@property (strong, nonatomic) IBOutlet UITextField *end_time_text;
- (IBAction)launch:(id)sender;
- (IBAction)getLoc:(id)sender;
- (IBAction)getBanner:(id)sender;
@property (strong, nonatomic) IBOutlet UITextField *subject_text;
@property (strong, nonatomic) IBOutlet UITextField *location_text;
@property (strong, nonatomic) IBOutlet UITextView *detail_text;
@property (strong, nonatomic) IBOutlet UISwitch *canin;
@property (strong, nonatomic) IBOutlet UIButton *banner_button;
@property (strong, nonatomic) IBOutlet UIButton *launch_button;
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *roundCornerView;
@property (nonatomic) CLLocationCoordinate2D pt;
@property (nonatomic,strong) NSString *positionInfo;
@property (strong, nonatomic) UIViewController* controller;



@end
