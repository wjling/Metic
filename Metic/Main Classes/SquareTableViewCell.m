//
//  SquareTableViewCell.m
//  WeShare
//
//  Created by 俊健 on 15/5/4.
//  Copyright (c) 2015年 WeShare. All rights reserved.
//

#import "SquareTableViewCell.h"
#import "CommonUtils.h"
#import "MTUser.h"
#import "PhotoGetter.h"

@interface SquareTableViewCell ()
@property(nonatomic,strong) UIImageView* officialFlag;
@end

@implementation SquareTableViewCell

- (void)awakeFromNib {
    // Initialization code
    _avatar.layer.cornerRadius = 3;
    _avatar.layer.masksToBounds = YES;
    
    _themePhoto.layer.cornerRadius = 2;
    _themePhoto.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)applyData:(NSDictionary*)data
{
    self.eventInfo = data;
//    NSString* beginT = [data valueForKey:@"time"];
//    NSString* endT = [data valueForKey:@"endTime"];
//
//    self.timeInfo.text = [CommonUtils calculateTimeInfo:beginT endTime:endT launchTime:[data valueForKey:@"launch_time"]];
//    self.location.text = [[NSString alloc]initWithFormat:@"活动地点: %@",[data valueForKey:@"location"]];
    
//    NSString* launcher = [[MTUser sharedInstance].alias_dic objectForKey:[NSString stringWithFormat:@"%@",[data valueForKey:@"launcher_id"]]];
//    if (launcher == nil || [launcher isEqual:[NSNull null]]) {
//        launcher = [data valueForKey:@"launcher"];
//    }
//
//    self.launcherinfo.text = [[NSString alloc]initWithFormat:@"发起人: %@",launcher];
//
//    NSString* remark = [data valueForKey:@"remark"];
//    if (remark && ![remark isEqualToString:@""]) {
//        self.remark.text = remark;
//    }else{
//        self.remark.text = @"";
//    }
    
    self.subject.text = [data valueForKey:@"subject"];
    
    PhotoGetter* avatarGetter = [[PhotoGetter alloc]initWithData:self.avatar authorId:[data valueForKey:@"launcher_id"]];
    [avatarGetter getAvatar];
    
    PhotoGetter* bannerGetter = [[PhotoGetter alloc]initWithData:self.themePhoto authorId:[data valueForKey:@"event_id"]];
    NSString* bannerURL = [data valueForKey:@"banner"];
    [bannerGetter getBanner:[data valueForKey:@"code"] url:bannerURL];

    BOOL official = [[data valueForKey:@"verify"] boolValue];
    [self drawOfficialFlag:official];
    CGRect frame = _subject.frame;
    if (official) {
        frame.size.width = 200;
    }else{
        frame.size.width = 250;
    }
    [_subject setFrame:frame];

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

@end
