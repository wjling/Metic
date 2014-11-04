//
//  PcommentTableViewCell.h
//  Metic
//
//  Created by ligang6 on 14-7-6.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "../Source/MLEmoji/MLEmojiLabel.h"
#import "PhotoDetailViewController.h"

@interface PcommentTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *avatar;
@property (strong, nonatomic) IBOutlet UILabel *author;
@property (strong, nonatomic) MLEmojiLabel *comment;
@property (strong, nonatomic) NSString *origincomment;
@property (strong, nonatomic) IBOutlet UILabel *date;
@property (strong, nonatomic) NSString *authorName;
@property (strong, nonatomic) NSNumber *authorId;
@property (strong, nonatomic) NSNumber *pcomment_id;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *waitView;
@property (strong, nonatomic) IBOutlet UIButton *resend_Button;
@property (strong, nonatomic) UIView* background;
@property (weak, nonatomic) PhotoDetailViewController* controller;
- (IBAction)resend:(id)sender;


@end
