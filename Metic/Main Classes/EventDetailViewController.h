//
//  EventDetailViewController.h
//  Metic
//
//  Created by ligang_mac4 on 14-5-29.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MySqlite.h"
#import "HttpSender.h"
#import "CommonUtils.h"
#import "MJRefreshHeaderView.h"
#import "MJRefreshFooterView.h"
#import "../Utils/PhotoGetter.h"
#import "../Source/MLEmoji/MLEmojiLabel.h"

@interface EventDetailViewController : UIViewController<UIScrollViewDelegate,UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource,MJRefreshBaseViewDelegate,MLEmojiLabelDelegate>

@property(nonatomic,strong)NSNumber *eventId;
@property(nonatomic,strong)MySqlite *sql;
@property (strong,nonatomic) MJRefreshHeaderView *header;
@property (strong,nonatomic) MJRefreshFooterView *footer;
@property (strong, nonatomic)  UIButton *comment_button;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *commentView;
@property (strong, nonatomic) IBOutlet UITextField *inputField;
@property (strong, nonatomic) IBOutlet UIButton *button_Emotion;
@property (nonatomic,strong) NSNumber *master_sequence;
@property BOOL isPublish;
@property BOOL isKeyBoard;
@property BOOL isEmotionOpen;
- (IBAction)button_Emotionpress:(id)sender;
- (void)pullMainCommentFromAir;
- (IBAction)publishComment:(id)sender;
- (IBAction)show2Dcode:(id)sender;
- (void)delete_Comment:(id)sender;
- (void)appreciate:(id)sender;
- (void)readyforMainC;






@end
