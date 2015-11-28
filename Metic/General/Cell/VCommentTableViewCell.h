//
//  VCommentTableViewCell.h
//  WeShare
//
//  Created by ligang6 on 14-9-2.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MLEmojiLabel.h"
#import "VideoDetailViewController.h"

@interface VCommentTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *avatar;
@property (strong, nonatomic) IBOutlet UILabel *author;
@property (strong, nonatomic) MLEmojiLabel *comment;
@property (strong, nonatomic) NSString *origincomment;
@property (strong, nonatomic) IBOutlet UILabel *date;
@property (strong, nonatomic) NSString *authorName;
@property (strong, nonatomic) NSNumber *authorId;
@property (strong, nonatomic) NSNumber *vcomment_id;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *waitView;
@property (strong, nonatomic) IBOutlet UIButton *resend_Button;
@property (strong, nonatomic) UIView* background;
@property (weak, nonatomic) VideoDetailViewController* controller;
@property (nonatomic,strong) NSDictionary* VcommentDict;
- (IBAction)resend:(id)sender;


@end