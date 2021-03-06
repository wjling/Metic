//
//  PhotoDetailViewController.h
//  Metic
//
//  Created by ligang6 on 14-7-4.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoGetter.h"
#import "MJRefreshFooterView.h"
#import "UMSocial.h"
#import "PictureWall2.h"
#import "MTTextInputView.h"

@interface PhotoDetailViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UMSocialUIDelegate,UIScrollViewDelegate,MJRefreshBaseViewDelegate,UITextViewDelegate,UIAlertViewDelegate, MTTextInputViewDelegate>
@property (nonatomic,strong) NSNumber* photoId;
@property (nonatomic,strong) NSNumber* eventId;
@property (nonatomic,strong) NSNumber* eventLauncherId;
@property (nonatomic,strong) NSString* eventName;
@property (nonatomic,strong) NSMutableDictionary * photoInfo;
@property (nonatomic,strong) NSMutableArray * pcomment_list;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UIViewController* photoDisplayController;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttons;
//@property (strong, nonatomic) MJRefreshFooterView* footer;
@property (nonatomic, strong) MTTextInputView *textInputView;
@property (nonatomic,strong) UIView* optionShadowView;

@property BOOL canManage;
- (IBAction)good:(id)sender;
- (IBAction)comment:(id)sender;
- (IBAction)share:(id)sender;
- (IBAction)download:(id)sender;
- (IBAction)publishComment:(id)sender;
- (IBAction)button_Emotionpress:(id)sender;
- (void)removeOptionBtn;
- (void)tabbarButtonOption;
- (void)commentNumMinus;
- (void)commentNumPlus;
@end
