//
//  EventDetailViewController.h
//  Metic
//
//  Created by ligang_mac4 on 14-5-29.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HttpSender.h"
#import "CommonUtils.h"
#import "MJRefreshHeaderView.h"
#import "MJRefreshFooterView.h"
#import "PhotoGetter.h"
#import "MLEmojiLabel.h"
#import "PhotoGetter.h"
#import "MTTextInputView.h"

@interface EventDetailViewController : UIViewController<UIScrollViewDelegate,UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource,MJRefreshBaseViewDelegate,MLEmojiLabelDelegate,UIAlertViewDelegate,PhotoGetterDelegate>

@property(nonatomic,strong) NSNumber *eventId;
@property(nonatomic,strong) NSNumber *shareId;
@property(nonatomic,strong) NSNumber* eventLauncherId;
@property (strong,nonatomic) MJRefreshHeaderView *header;
@property (strong,nonatomic) MJRefreshFooterView *footer;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
//@property (strong, nonatomic) UIView *commentView;
@property (nonatomic,strong) NSNumber *master_sequence;
@property (nonatomic, strong) MTTextInputView *textInputView;
@property (nonatomic,strong) NSMutableDictionary *event;
@property (nonatomic,strong) UIImage* uploadImage;
@property NSInteger Bannercode;

@property BOOL isFromQRCode;
@property BOOL isPublish;

- (void)pullMainCommentFromAir;
- (void)publishComment:(id)sender;
- (void)show2Dcode:(id)sender;
- (void)report:(id)sender;
- (void)delete_Comment:(id)sender;
- (void)appreciate:(id)sender;
- (void)changeBanner;
- (IBAction)more:(id)sender;


@end
