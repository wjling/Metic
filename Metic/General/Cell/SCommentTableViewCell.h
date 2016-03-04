//
//  SCommentTableViewCell.h
//  Metic
//
//  Created by ligang6 on 14-6-15.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MTUser.h"
#import "CommonUtils.h"
#import "HttpSender.h"
#import "EventDetailViewController.h"
#import "MLEmojiLabel.h"

@interface SCommentTableViewCell : UITableViewCell<MLEmojiLabelDelegate>
- (IBAction)delete_Comment:(id)sender;
@property(strong,nonatomic) NSString* author;
@property(strong,nonatomic) NSNumber* authorid;
@property(strong,nonatomic) NSNumber* commentid;
@property(strong,nonatomic) NSNumber* mainCommentId;
@property(strong,nonatomic) NSString* originComment;
@property (strong, nonatomic) IBOutlet UILabel *publishTimeLabel;
@property (strong, nonatomic) IBOutlet MLEmojiLabel *comment;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *waitView;
@property(nonatomic,weak) EventDetailViewController *controller;
@property(nonatomic,strong) NSMutableArray* McommentArr;
@property(nonatomic,strong) NSDictionary* ScommentDict;
@property (strong, nonatomic) IBOutlet UIButton *resend_Button;
@end
