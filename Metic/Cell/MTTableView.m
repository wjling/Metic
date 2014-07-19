//
//  MTTableView.m
//  Metic
//
//  Created by ligang_mac4 on 14-6-26.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "MTTableView.h"
#import "../Cell/CustomCellTableViewCell.h"
#import "../Source/SDWebImage/UIImageView+WebCache.h"





@implementation MTTableView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


#pragma mark 代理方法-UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.eventsSource) {
        return self.eventsSource.count;
    }else
        return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"customcell";
    BOOL nibsRegistered = NO;
    if (!nibsRegistered) {
        UINib *nib = [UINib nibWithNibName:NSStringFromClass([CustomCellTableViewCell class]) bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:CellIdentifier];
        nibsRegistered = YES;
    }
    CustomCellTableViewCell *cell = (CustomCellTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    
    if (self.eventsSource) {
        NSDictionary *a = self.eventsSource[indexPath.row];
        cell.eventName.text = [a valueForKey:@"subject"];
        NSString* beginT = [a valueForKey:@"time"];
        NSString* endT = [a valueForKey:@"endTime"];
        cell.beginDate.text = [[[beginT substringWithRange:NSMakeRange(5, 5)] stringByAppendingString:@"日"] stringByReplacingOccurrencesOfString:@"-" withString:@"月"];
        cell.beginTime.text = [beginT substringWithRange:NSMakeRange(11, 5)];
        cell.endDate.text = [[[endT substringWithRange:NSMakeRange(5, 5)] stringByAppendingString:@"日"]  stringByReplacingOccurrencesOfString:@"-" withString:@"月"];
        cell.endTime.text = [endT substringWithRange:NSMakeRange(11, 5)];
        cell.timeInfo.text = [self calculateTimeInfo:beginT endTime:endT launchTime:[a valueForKey:@"launch_time"]];
        cell.location.text = [[NSString alloc]initWithFormat:@"活动地点: %@",[a valueForKey:@"location"] ];
        int participator_count = [[a valueForKey:@"member_count"] intValue];
        cell.member_count.text = [[NSString alloc] initWithFormat:@"已有 %d 人参加",participator_count];
        cell.launcherinfo.text = [[NSString alloc]initWithFormat:@"发起人: %@",[a valueForKey:@"launcher"] ];
        cell.eventId = [a valueForKey:@"event_id"];
        cell.avatar.layer.masksToBounds = YES;
        [cell.avatar.layer setCornerRadius:15];
        
        PhotoGetter* avatarGetter = [[PhotoGetter alloc]initWithData:cell.avatar authorId:[a valueForKey:@"launcher_id"]];
        [avatarGetter getPhoto];
        
        PhotoGetter* bannerGetter = [[PhotoGetter alloc]initWithData:cell.themePhoto authorId:[a valueForKey:@"event_id"]];
        [bannerGetter getBanner];

        cell.homeController = self.homeController;
        
        NSArray *memberids = [a valueForKey:@"member"];

        for (int i =3; i>=0; i--) {
            UIImageView *tmp = ((UIImageView*)[((UIView*)[cell viewWithTag:103]) viewWithTag:i+1]);
            tmp.layer.masksToBounds = YES;
            [tmp.layer setCornerRadius:5];
            if (i < participator_count) {
                PhotoGetter* miniGetter = [[PhotoGetter alloc]initWithData:tmp authorId:memberids[i]];
                [miniGetter getPhoto];
            }else tmp.image = nil;
            
        }
    }
    
	return cell;
}

-(NSString*)calculateTimeInfo:(NSString*)beginTime endTime:(NSString*)endTime launchTime:(NSString*)launchTime
{
    NSString* timeInfo = @"";
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    NSDate* begin = [dateFormatter dateFromString:beginTime];
    NSDate* end = [dateFormatter dateFromString:endTime];
    NSTimeInterval begins = [begin timeIntervalSince1970];
    NSTimeInterval ends = [end timeIntervalSince1970];
    NSString* launchInfo = [NSString stringWithFormat:@"创建于 %@日",[[launchTime substringWithRange:NSMakeRange(5, 5)] stringByReplacingOccurrencesOfString:@"-" withString:@"月"]];
    int dis = ends-begins;
    if (dis > 0) {
        NSString* duration = @"";
        if (dis >= 31536000) {
            duration = [NSString stringWithFormat:@"%d年",dis/31536000];
        }else if (dis >= 2592000) {
            duration = [NSString stringWithFormat:@"%d月",dis/2592000];
        }else if (dis >= 86400) {
            duration = [NSString stringWithFormat:@"%d日",dis/86400];
        }else if (dis >= 3600) {
            duration = [NSString stringWithFormat:@"%d小时",dis/3600];
        }else if (dis >= 60) {
            duration = [NSString stringWithFormat:@"%d分钟",dis/60];
        }else{
            duration = [NSString stringWithFormat:@"%d秒",dis];
        }
        
        timeInfo = [NSString stringWithFormat:@"活动持续时间：%@",duration];
        while (timeInfo.length < 15) {
            timeInfo = [timeInfo stringByAppendingString:@" "];
        }
        timeInfo = [timeInfo stringByAppendingString:launchInfo];
    }else timeInfo = launchInfo;
    return timeInfo;
}



@end
