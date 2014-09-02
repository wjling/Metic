//
//  VideoDetailViewController.h
//  WeShare
//
//  Created by ligang6 on 14-9-2.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "PhotoGetter.h"
#import "../../MJRefresh/MJRefreshFooterView.h"
#import "../../UIView/MTMessageTextView.h"

@interface VideoDetailViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate,MJRefreshBaseViewDelegate,UITextViewDelegate,UIAlertViewDelegate>
@property (nonatomic,strong) UIImage* video_thumb;
@property (nonatomic,strong) NSNumber* videoId;
@property (nonatomic,strong) NSNumber* eventId;
@property (nonatomic,strong) NSString* eventName;
@property (nonatomic,strong) NSDictionary * videoInfo;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) MJRefreshFooterView* footer;
@property (nonatomic,strong) UIView* optionShadowView;
@property (nonatomic,strong) UIView* commentOptionView;
@property (strong, nonatomic) IBOutlet UIView *commentView;
@property (strong, nonatomic) IBOutlet MTMessageTextView *inputTextView;

@property BOOL isEmotionOpen;
- (IBAction)publishComment:(id)sender;
- (IBAction)button_Emotionpress:(id)sender;
@end
