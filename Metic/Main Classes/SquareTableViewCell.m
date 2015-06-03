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
    
    self.subject.text = [data valueForKey:@"subject"];
    NSNumber* pv = [data valueForKey:@"pv"];
    if (pv) {
        self.viewcount.text = [NSString stringWithFormat:@"%@次浏览",pv];
    }else{
        self.viewcount.text = @"";
    }
    
    
    PhotoGetter* avatarGetter = [[PhotoGetter alloc]initWithData:self.avatar authorId:[data valueForKey:@"launcher_id"]];
    [avatarGetter getAvatar];
    
    PhotoGetter* bannerGetter = [[PhotoGetter alloc]initWithData:self.themePhoto authorId:[data valueForKey:@"event_id"]];
    NSString* bannerURL = [data valueForKey:@"banner"];
    [bannerGetter getBanner:[data valueForKey:@"code"] url:bannerURL];

    BOOL official = [[data valueForKey:@"verify"] boolValue];
    [self drawOfficialFlag:official];
    CGRect frame = _subject.frame;
//    if (official) {
//        frame.size.width = 200;
//    }else{
//        frame.size.width = 250;
//    }
    [_subject setFrame:frame];

}

-(void)drawOfficialFlag:(BOOL)isOfficial
{
    if (isOfficial) {
        if (_officialFlag) {
            [_themePhoto addSubview:_officialFlag];
        }else{
            float height = CGRectGetHeight(_themePhoto.frame)*0.6;
            _officialFlag = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetWidth(_themePhoto.frame)-height, 0, height, height)];
            _officialFlag.image = [UIImage imageNamed:@"最新活动推荐icon"];
            [_themePhoto addSubview:_officialFlag];
        }
    }else{
        if (_officialFlag) {
            [_officialFlag removeFromSuperview];
        }
    }
}

@end
