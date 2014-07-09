//
//  LaunchEventViewController.h
//  Metic
//
//  Created by ligang6 on 14-6-3.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HttpSender.h"
#import <CoreLocation/CoreLocation.h>
#import <CoreLocation/CLLocationManagerDelegate.h>
//#import <MapKit/MapKit.h>


@interface LaunchEventViewController : UIViewController<UIScrollViewDelegate,UITextFieldDelegate,HttpSenderDelegate,UITextViewDelegate,CLLocationManagerDelegate>
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UITextField *event_text;
@property (strong, nonatomic) IBOutlet UITextField *begin_time_text;
@property (strong, nonatomic) IBOutlet UITextField *end_time_text;
- (IBAction)launch:(id)sender;
- (IBAction)getLoc:(id)sender;
@property (strong, nonatomic) IBOutlet UITextField *subject_text;
@property (strong, nonatomic) IBOutlet UITextField *location_text;
@property (strong, nonatomic) IBOutlet UITextView *detail_text;
@property (strong, nonatomic) IBOutlet UISwitch *canin;
@property (strong, nonatomic) IBOutlet UIButton *launch_button;
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *roundCornerView;



@end
