//
//  CustomCellTableViewCell.h
//  Metic
//
//  Created by ligang_mac4 on 14-5-28.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomCellTableViewCell : UITableViewCell

{
    
    IBOutlet UILabel *eventName;
    IBOutlet UILabel *beginTime;
    IBOutlet UILabel *endTime;
    IBOutlet UILabel *eventDetail;
    IBOutlet UILabel *timeInfo;
    IBOutlet UIButton *imgWall;
    IBOutlet UIButton *videoWall;
    IBOutlet UILabel *location;
    IBOutlet UILabel *launcherinfo;
    IBOutlet UILabel *member_count;
    
}

- (IBAction)jumpToPictureWall:(id)sender;
- (IBAction)jumpToVideoWall:(id)sender;






@property(nonatomic,strong) UILabel *eventName;
@property(nonatomic,strong) UILabel *beginTime;
@property(nonatomic,strong) UILabel *endTime;
@property(nonatomic,strong) UILabel *timeInfo;
@property(nonatomic,strong) UILabel *location;
@property(nonatomic,strong) UILabel *launcherinfo;
@property(nonatomic,strong) UILabel *eventDetail;
@property(nonatomic,strong) UIButton *videoWall;
@property(nonatomic,strong) UIButton *imgWall;
@property(nonatomic,strong) UILabel *member_count;
@property(nonatomic,strong) NSNumber *eventId;



@end