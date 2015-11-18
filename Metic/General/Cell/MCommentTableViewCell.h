//
//  MCommentTableViewCell.h
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

@interface MCommentTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *avatar;
@property (strong, nonatomic) IBOutlet UILabel *publishTime;
@property (strong, nonatomic) IBOutlet UILabel *publisher;
- (IBAction)delete_Comment:(id)sender;
@property(strong,nonatomic) NSNumber* commentid;
@property(strong,nonatomic) NSNumber* eventId;
@property(strong,nonatomic) NSString* author;
@property(strong,nonatomic) NSNumber* authorId;
@property (strong, nonatomic) NSString *origincomment;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *waitView;
@property(nonatomic,weak) EventDetailViewController *controller;
@property BOOL isZan;
@property (strong, nonatomic) IBOutlet UIButton *good_button;
- (IBAction)appreciate:(id)sender;
@property (strong, nonatomic) IBOutlet UILabel *good_num;
@property (strong, nonatomic) IBOutlet UIImageView *subCommentBG;
@property (strong, nonatomic) IBOutlet UIView *zanView;
@property (strong, nonatomic) IBOutlet UIButton *resend_Button;
@property (strong, nonatomic) IBOutlet MLEmojiLabel *comment;



@end
