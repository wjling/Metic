//
//  CustomCellTableViewCell.h
//  Metic
//
//  Created by ligang_mac4 on 14-5-28.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "../Main Classes/HomeViewController.h"
#import "TTTAttributedLabel.h"
#import "MTTableViewCellBase.h"

@interface CustomCellTableViewCell : MTTableViewCellBase

{
    
    IBOutlet UIImageView *avatar;
    IBOutlet UILabel *eventName;
    IBOutlet UIImageView *themePhoto;
    IBOutlet UILabel *beginDate;
    IBOutlet UILabel *beginTime;
    IBOutlet UILabel *endDate;
    IBOutlet UILabel *endTime;
//    IBOutlet UILabel *eventDetail;
    IBOutlet UILabel *timeInfo;
    IBOutlet UIButton *imgWall;
    IBOutlet UIButton *videoWall;
    IBOutlet UILabel *location;
    IBOutlet UILabel *launcherinfo;
    IBOutlet TTTAttributedLabel *member_count;
    
}

- (IBAction)jumpToPictureWall:(id)sender;
- (IBAction)jumpToVideoWall:(id)sender;
- (void)drawOfficialFlag:(BOOL)isOfficial;
- (void)applyData:(NSDictionary*)data;

@property(nonatomic,strong)NSDictionary* eventInfo;

@property(nonatomic,weak) HomeViewController* homeController;
@property(atomic,strong) UIImageView *avatar;
@property(nonatomic,strong) UILabel *eventName;
@property(nonatomic,strong) UIImageView *themePhoto;
@property(nonatomic,strong) UILabel *beginDate;
@property(nonatomic,strong) UILabel *endDate;
@property(nonatomic,strong) UILabel *beginTime;
@property(nonatomic,strong) UILabel *endTime;
@property(nonatomic,strong) UILabel *timeInfo;
@property(nonatomic,strong) UILabel *location;
@property(nonatomic,strong) UILabel *launcherinfo;
//@property(nonatomic,strong) UILabel *eventDetail;
@property(nonatomic,strong) UIButton *videoWall;
@property(nonatomic,strong) UIButton *imgWall;
@property(nonatomic,strong) TTTAttributedLabel *member_count;
@property(nonatomic,strong) NSNumber *eventId;
@property(nonatomic,strong) NSNumber *launcherId;
@property(nonatomic,strong) NSString *event;
@property(nonatomic,strong) UIImageView *officialFlag;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *avatarArray;



@end