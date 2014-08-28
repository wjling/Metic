//
//  PhotoDetailViewController.h
//  Metic
//
//  Created by ligang6 on 14-7-4.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoGetter.h"
#import "../MJRefresh/MJRefreshFooterView.h"
#import "../Source/UMSocial_Sdk_4.0/Header/UMSocial.h"
#import "../UIView/MTMessageTextView.h"
#import "PictureWallViewController.h"

@interface PhotoDetailViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UMSocialUIDelegate,UIScrollViewDelegate,MJRefreshBaseViewDelegate,UITextViewDelegate,UIAlertViewDelegate>
@property (nonatomic,strong) UIImage* photo;
@property (nonatomic,strong) NSNumber* photoId;
@property (nonatomic,strong) NSNumber* eventId;
@property (nonatomic,strong) NSString* eventName;
@property (nonatomic,strong) NSDictionary * photoInfo;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UIViewController* photoDisplayController;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttons;
@property (strong, nonatomic) MJRefreshFooterView* footer;
@property (nonatomic,strong) UIView* optionShadowView;
@property (nonatomic,strong) UIView* commentOptionView;
@property (strong, nonatomic) IBOutlet UIView *commentView;
@property (strong, nonatomic) IBOutlet MTMessageTextView *inputTextView;
@property (strong, nonatomic) PictureWallViewController* controller;
@property int type;
@property BOOL isEmotionOpen;
- (IBAction)good:(id)sender;
- (IBAction)comment:(id)sender;
- (IBAction)share:(id)sender;
- (IBAction)download:(id)sender;
- (IBAction)publishComment:(id)sender;
- (IBAction)button_Emotionpress:(id)sender;
@end
