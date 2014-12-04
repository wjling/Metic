//
//  CustomCellTableViewCell.m
//  Metic
//
//  Created by ligang_mac4 on 14-5-28.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "CustomCellTableViewCell.h"
#import "../Main Classes/PictureWall2.h"

@implementation CustomCellTableViewCell

@synthesize avatar;
@synthesize eventName;
@synthesize themePhoto;
//@synthesize eventDetail;
@synthesize videoWall;
@synthesize imgWall;
@synthesize beginTime;
@synthesize beginDate;
@synthesize endTime;
@synthesize endDate;
@synthesize timeInfo;
@synthesize location;
@synthesize launcherinfo;
@synthesize member_count;


#define widthspace 10
#define deepspace 4

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        
        // Initialization code
        

        
    }
    return self;
    
}

- (void)setFrame:(CGRect)frame
{
    //frame.origin.x += widthspace;
    frame.origin.y += deepspace;
    //frame.size.width -= 2 * widthspace;
    frame.size.height -= 2 * deepspace;
    [super setFrame:frame];
    
}

-(void)drawOfficialFlag:(BOOL)isOfficial
{
    if (isOfficial) {
        if (_officialFlag) {
            [self addSubview:_officialFlag];
        }else{
            float width = self.bounds.size.width;
            _officialFlag = [[UIImageView alloc]initWithFrame:CGRectMake(width*0.85, 0, width*0.08, width*0.8/9)];
            _officialFlag.image = [UIImage imageNamed:@"flag.jpg"];
            UILabel* label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, width*0.08, width*0.08)];
            label.textAlignment = NSTextAlignmentCenter;
            label.text = @"官";
            label.font = [UIFont systemFontOfSize:15];
            label.textColor = [UIColor whiteColor];
            [_officialFlag addSubview:label];
            [self addSubview:_officialFlag];
        }
    }else{
        if (_officialFlag) {
            [_officialFlag removeFromSuperview];
        }
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    
    
    [super setSelected:selected animated:animated];
    
    
    
    // Configure the view for the selected state
    
}

- (IBAction)jumpToPictureWall:(id)sender {
    self.homeController.selete_Eventid = self.eventId;
    self.homeController.selete_EventName = _event;
    [self.homeController performSegueWithIdentifier:@"HomeToPictureWall" sender:self.homeController];
}

- (IBAction)jumpToVideoWall:(id)sender {
    //[CommonUtils showSimpleAlertViewWithTitle:@"系统消息" WithMessage:@"敬请期待" WithDelegate:nil WithCancelTitle:@"确定"];
    self.homeController.selete_Eventid = self.eventId;
    self.homeController.selete_EventName = _event;
    [self.homeController performSegueWithIdentifier:@"HomeToVideoWall" sender:self.homeController];
}



- (void)dealloc {
    
    
}


@end