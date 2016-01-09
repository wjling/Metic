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
#import "PhotoGetter.h"
#import "FlatDatePicker.h"

@interface LaunchEventViewController : UIViewController<UICollectionViewDataSource,UIScrollViewDelegate,UICollectionViewDelegate,UITextFieldDelegate,UITextViewDelegate,BMKGeoCodeSearchDelegate,BMKLocationServiceDelegate,PhotoGetterDelegate,FlatDatePickerDelegate,UIGestureRecognizerDelegate>
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UITextField *event_text;
@property (strong, nonatomic) IBOutlet UITextField *begin_time_text;
@property (strong, nonatomic) IBOutlet UITextField *end_time_text;
- (IBAction)launch:(id)sender;
- (IBAction)getLoc:(id)sender;
- (IBAction)getBanner:(id)sender;
- (BOOL)shouldDraft;
- (void)alertMakingDraft;
- (void)makeDraft;
@property (strong, nonatomic) IBOutlet UITextField *subject_text;
@property (strong, nonatomic) IBOutlet UITextField *location_text;
@property (strong, nonatomic) IBOutlet UITextView *detail_text;
@property (strong, nonatomic) IBOutlet UIButton *banner_button;
@property (strong, nonatomic) IBOutlet UIButton *launch_button;
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *roundCornerView;
@property (strong, nonatomic) IBOutlet UIButton *eventTypeMenuView;

@property (nonatomic) CLLocationCoordinate2D pt;
@property (nonatomic,strong) NSString *positionInfo;
@property (strong, nonatomic) UIViewController* controller;
@property (strong, nonatomic) UIImage* uploadImage;
@property BOOL canLeave;
@property NSInteger code;

- (IBAction)changeEventType:(id)sender;

@end
