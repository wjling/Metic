//
//  CustomCellTableViewCell.h
//  Metic
//
//  Created by ligang_mac4 on 14-5-28.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EventDetailViewController.h"
#import "MTTableViewCellBase.h"

@interface EventCellTableViewCell : MTTableViewCellBase

{
    
    IBOutlet UIImageView *launcherImg;
    IBOutlet UIImageView *themePhoto;
    IBOutlet UILabel *eventName;
    IBOutlet UILabel *eventDetail;
    IBOutlet UILabel *timeInfo;
    IBOutlet UIButton *imgWall;
    IBOutlet UIButton *videoWall;
    IBOutlet UIImageView *imgWall_icon;
    IBOutlet UIImageView *videoWall_icon;
    IBOutlet UIButton *comment;
    IBOutlet UILabel *location;
    IBOutlet UILabel *launcherinfo;
    IBOutlet TTTAttributedLabel *member_count;
    IBOutlet UIView *commentInputView;
    IBOutlet UIButton *addPaticipator;
    IBOutlet UILabel *eventType;
    
}

- (void)showDetail:(id)sender;
- (IBAction)jumpToPictureWall:(id)sender;
- (IBAction)jumpToVideoWall:(id)sender;
- (IBAction)addComment:(id)sender;
- (IBAction)showParticipators:(id)sender;
- (IBAction)showBanner:(id)sender;
-(void)drawOfficialFlag:(BOOL)isOfficial;
-(void)setImgWallpoint;
-(void)setVideoWallpoint;
@property (strong, nonatomic) IBOutlet UIView *mediaEntrance;
@property(nonatomic,strong) NSDictionary* eventInfo;
@property (weak, nonatomic) IBOutlet UIImageView *imgPoint;
@property (weak, nonatomic) IBOutlet UIImageView *videoPoint;

@property(nonatomic,strong) UIImageView* officialFlag;
@property(nonatomic,strong) UIImageView* launcherImg;
@property(nonatomic,strong) UIImageView *themePhoto;
@property(nonatomic,strong) UILabel *eventName;
@property(nonatomic,strong) UILabel *eventType;
@property (strong, nonatomic) IBOutlet TTTAttributedLabel *eventTime;
@property(nonatomic,strong) UILabel *timeInfo;
@property(nonatomic,strong) UILabel *location;
@property(nonatomic,strong) UILabel *launcherinfo;
@property(nonatomic,strong) UILabel *eventDetail;
@property(nonatomic,strong) UIButton *videoWall;
@property(nonatomic,strong) UIButton *imgWall;
@property(nonatomic,strong) UIImageView* imgWall_icon;
@property(nonatomic,strong) UIImageView* videoWall_icon;
@property(nonatomic,strong) UIButton *comment;
@property(nonatomic,strong) TTTAttributedLabel *member_count;
@property(nonatomic,strong) NSNumber *eventId;
@property(nonatomic,strong) UIView *commentInputView;
@property(nonatomic,weak) EventDetailViewController * controller;
@property(nonatomic,strong) UIButton *addPaticipator;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *avatarArray;

@end