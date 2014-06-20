//
//  MCommentTableViewCell.h
//  Metic
//
//  Created by ligang6 on 14-6-15.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "../Main Classes/MTUser.h"
#import "../CommonUtils.h"
#import "../HttpSender.h"
#import "../Main Classes/EventDetailViewController.h"

@interface MCommentTableViewCell : UITableViewCell
- (IBAction)delete_Comment:(id)sender;
@property(strong,nonatomic) NSNumber* commentid;
@property(nonatomic,strong) EventDetailViewController *controller;
@property int m,s;

@end
