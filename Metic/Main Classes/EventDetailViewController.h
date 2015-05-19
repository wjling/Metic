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
#import "../Utils/PhotoGetter.h"
#import "../Source/MLEmoji/MLEmojiLabel.h"
#import "../UIView/MTMessageTextView.h"
#import "../Utils/PhotoGetter.h"

@interface EventDetailViewController : UIViewController<UIScrollViewDelegate,UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource,MJRefreshBaseViewDelegate,MLEmojiLabelDelegate,UIAlertViewDelegate,PhotoGetterDelegate>

@property(nonatomic,strong)NSNumber *eventId;
@property(nonatomic,strong)NSNumber* eventLauncherId;
@property (strong,nonatomic) MJRefreshHeaderView *header;
@property (strong,nonatomic) MJRefreshFooterView *footer;
@property (strong, nonatomic) UIButton *comment_button;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UIView *commentView;
@property (strong, nonatomic) UIView *inputView;
@property (strong, nonatomic) MTMessageTextView *inputTextView;
@property (strong, nonatomic) UIButton *button_Emotion;
@property (nonatomic,strong) NSNumber *master_sequence;
@property (nonatomic,strong) UIView* optionShadowView;
@property (nonatomic,strong) UIView* commentOptionView;
@property (nonatomic,strong) NSMutableDictionary *event;
@property (nonatomic,strong) UIImage* uploadImage;
@property int Bannercode;

@property BOOL isFromQRCode;
@property BOOL isPublish;
@property BOOL isKeyBoard;
@property BOOL isEmotionOpen;
- (IBAction)button_Emotionpress:(id)sender;
- (void)pullMainCommentFromAir;
- (IBAction)publishComment:(id)sender;
- (IBAction)show2Dcode:(id)sender;
- (IBAction)report:(id)sender;
- (void)delete_Comment:(id)sender;
- (void)appreciate:(id)sender;
- (void)readyforMainC;
- (IBAction)more:(id)sender;






@end
