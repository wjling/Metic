//
//  nearbyEventTableViewCell.h
//  Metic
//
//  Created by ligang_mac4 on 14-8-11.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTTAttributedLabel.h"
@interface nearbyEventTableViewCell : UITableViewCell<UIAlertViewDelegate>
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
    IBOutlet UILabel *location;
    IBOutlet UILabel *launcherinfo;
    IBOutlet TTTAttributedLabel *member_count;
    IBOutlet UILabel *statusLabel;
    IBOutlet UIButton *wantInBtn;
}
- (IBAction)showParticipant:(id)sender;
-(void)drawOfficialFlag:(BOOL)isOfficial;

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
@property(nonatomic,strong) TTTAttributedLabel *member_count;
@property(nonatomic,strong) NSNumber *eventId;
@property(nonatomic,strong) UIViewController* nearbyEventViewController;
@property(nonatomic,strong) UILabel* statusLabel;
@property(nonatomic,strong) UIButton* wantInBtn;
@property(nonatomic,strong) UIImageView* officialFlag;
@property(nonatomic,strong) NSDictionary* dict;


@end
