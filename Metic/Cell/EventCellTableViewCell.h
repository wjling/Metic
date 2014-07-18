//
//  CustomCellTableViewCell.h
//  Metic
//
//  Created by ligang_mac4 on 14-5-28.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "../Main Classes/EventDetailViewController.h"

@interface EventCellTableViewCell : UITableViewCell

{
    
    IBOutlet UIImageView *themePhoto;
    IBOutlet UILabel *eventName;
    IBOutlet UILabel *beginDate;
    IBOutlet UILabel *beginTime;
    IBOutlet UILabel *endDate;
    IBOutlet UILabel *endTime;
    IBOutlet UILabel *eventDetail;
    IBOutlet UILabel *timeInfo;
    IBOutlet UIButton *imgWall;
    IBOutlet UIButton *videoWall;
    IBOutlet UIButton *comment;
    IBOutlet UILabel *location;
    IBOutlet UILabel *launcherinfo;
    IBOutlet UILabel *member_count;
    IBOutlet UIView *commentInputView;
    
    
}

- (IBAction)jumpToPictureWall:(id)sender;
- (IBAction)jumpToVideoWall:(id)sender;
- (IBAction)addComment:(id)sender;
- (IBAction)showParticipators:(id)sender;






@property(nonatomic,strong) UIImageView *themePhoto;
@property(nonatomic,strong) UILabel *eventName;
@property(nonatomic,strong) UILabel *beginDate;
@property(nonatomic,strong) UILabel *endDate;
@property(nonatomic,strong) UILabel *beginTime;
@property(nonatomic,strong) UILabel *endTime;
@property(nonatomic,strong) UILabel *timeInfo;
@property(nonatomic,strong) UILabel *location;
@property(nonatomic,strong) UILabel *launcherinfo;
@property(nonatomic,strong) UILabel *eventDetail;
@property(nonatomic,strong) UIButton *videoWall;
@property(nonatomic,strong) UIButton *imgWall;
@property(nonatomic,strong) UIButton *comment;
@property(nonatomic,strong) UILabel *member_count;
@property(nonatomic,strong) NSNumber *eventId;
@property(nonatomic,strong) UIView *commentInputView;
@property(nonatomic,strong) EventDetailViewController * eventController;


@end