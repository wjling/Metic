//
//  MCommentTableViewCell.h
//  Metic
//
//  Created by ligang6 on 14-6-15.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "../Main Classes/MTUser.h"
#import "../Utils/CommonUtils.h"
#import "../Utils/HttpSender.h"
#import "../Main Classes/EventDetailViewController.h"

@interface MCommentTableViewCell : UITableViewCell
- (IBAction)delete_Comment:(id)sender;
@property(strong,nonatomic) NSNumber* commentid;
@property(strong,nonatomic) NSNumber* eventId;
@property(strong,nonatomic) NSString* author;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *waitView;
@property(nonatomic,strong) EventDetailViewController *controller;
@property BOOL isZan;
@property (strong, nonatomic) IBOutlet UIButton *good_button;
- (IBAction)appreciate:(id)sender;
@property (strong, nonatomic) IBOutlet UILabel *good_num;
@property (strong, nonatomic) IBOutlet UIImageView *subCommentBG;
@property (strong, nonatomic) IBOutlet UIView *zanView;


@end
