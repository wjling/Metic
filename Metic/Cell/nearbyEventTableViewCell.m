//
//  nearbyEventTableViewCell.m
//  Metic
//
//  Created by ligang_mac4 on 14-8-11.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "nearbyEventTableViewCell.h"

@implementation nearbyEventTableViewCell
@synthesize avatar;
@synthesize eventName;
@synthesize themePhoto;
//@synthesize eventDetail;
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

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setFrame:(CGRect)frame
{
    //frame.origin.x += widthspace;
    frame.origin.y += deepspace;
    //frame.size.width -= 2 * widthspace;
    frame.size.height -= 2 * deepspace;
    [super setFrame:frame];
    
}
@end
