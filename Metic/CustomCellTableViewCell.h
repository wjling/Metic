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
@property (strong, nonatomic) IBOutlet UIButton *jumpToPictureWall;
@property (strong, nonatomic) IBOutlet UIButton *jumpToVideoWall;

@property(nonatomic,retain) UILabel *eventName;
@property(nonatomic,retain) UILabel *beginTime;
@property(nonatomic,retain) UILabel *endTime;
@property(nonatomic,retain) UILabel *timeInfo;
@property(nonatomic,retain) UILabel *location;
@property(nonatomic,retain) UILabel *launcherinfo;
@property(nonatomic,retain) UILabel *eventDetail;
@property(nonatomic,retain) UIButton *videoWall;
@property(nonatomic,retain) UIButton *imgWall;
@property(nonatomic,retain) UILabel *member_count;




@end