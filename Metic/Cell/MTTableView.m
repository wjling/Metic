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
    if (self.eventsSource && self.eventsSource.count != 0) {
        return self.eventsSource.count;
    }else
        return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.eventsSource || self.eventsSource.count == 0) {
        UITableViewCell* cell = [[UITableViewCell alloc]init];
        UILabel* label = [[UILabel alloc]initWithFrame:CGRectMake(0,0,300,70)];
        cell.userInteractionEnabled = NO;
        cell.backgroundColor = [UIColor clearColor];
        
        
        label.text = @"还没有活动哦，快去发起吧";
        label.numberOfLines = 1;
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont fontWithName:@"Helvetica-Bold" size:15];
        label.textColor = [UIColor colorWithWhite:147.0/255.0 alpha:1.0f];
        label.textAlignment = NSTextAlignmentCenter;
        [cell addSubview:label];
        
        
        return cell;
    }

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
        cell.event = [a valueForKey:@"subject"];
        NSString* beginT = [a valueForKey:@"time"];
        NSString* endT = [a valueForKey:@"endTime"];
        cell.beginDate.text = [[[beginT substringWithRange:NSMakeRange(5, 5)] stringByAppendingString:@"日"] stringByReplacingOccurrencesOfString:@"-" withString:@"月"];
        cell.beginTime.text = [beginT substringWithRange:NSMakeRange(11, 5)];
        if (endT.length > 9) cell.endDate.text = [[[endT substringWithRange:NSMakeRange(5, 5)] stringByAppendingString:@"日"]  stringByReplacingOccurrencesOfString:@"-" withString:@"月"];
        if (endT.length > 15)cell.endTime.text = [endT substringWithRange:NSMakeRange(11, 5)];
        cell.timeInfo.text = [CommonUtils calculateTimeInfo:beginT endTime:endT launchTime:[a valueForKey:@"launch_time"]];
        cell.location.text = [[NSString alloc]initWithFormat:@"活动地点: %@",[a valueForKey:@"location"] ];
        
        NSInteger participator_count = [[a valueForKey:@"member_count"] integerValue];
        NSString* partiCount_Str = [NSString stringWithFormat:@"%ld",(long)participator_count];
        NSString* participator_Str = [NSString stringWithFormat:@"已有 %@ 人参加",partiCount_Str];

        cell.member_count.font = [UIFont systemFontOfSize:15];
        cell.member_count.numberOfLines = 0;
        cell.member_count.lineBreakMode = NSLineBreakByCharWrapping;
        cell.member_count.tintColor = [UIColor lightGrayColor];
        [cell.member_count setText:participator_Str afterInheritingLabelAttributesAndConfiguringWithBlock:^(NSMutableAttributedString *mutableAttributedString) {
            NSRange redRange = [participator_Str rangeOfString:partiCount_Str];
            UIFont *italicSystemFont = [UIFont italicSystemFontOfSize:18];
            
            if (redRange.location != NSNotFound) {
                // Core Text APIs use C functions without a direct bridge to UIFont. See Apple's "Core Text Programming Guide" to learn how to configure string attributes.
                [mutableAttributedString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(id)[UIColor redColor].CGColor range:redRange];
                
                CTFontRef italicFont = CTFontCreateWithName((__bridge CFStringRef)italicSystemFont.fontName, italicSystemFont.pointSize, NULL);
                [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)italicFont range:redRange];
                CFRelease(italicFont);
            }
            return mutableAttributedString;
        }];

        
        NSString* launcher = [[MTUser sharedInstance].alias_dic objectForKey:[NSString stringWithFormat:@"%@",[a valueForKey:@"launcher_id"]]];
        if (launcher == nil || [launcher isEqual:[NSNull null]]) {
            launcher = [a valueForKey:@"launcher"];
        }
        
        
        cell.launcherinfo.text = [[NSString alloc]initWithFormat:@"发起人: %@",launcher];
        cell.eventId = [a valueForKey:@"event_id"];
        cell.launcherId = [a valueForKey:@"launcher_id"];
        //cell.avatar.layer.masksToBounds = YES;
        [cell.avatar.layer setCornerRadius:15];
        
        [cell drawOfficialFlag:[[a valueForKey:@"verify"] boolValue]];
        
        
        PhotoGetter* avatarGetter = [[PhotoGetter alloc]initWithData:cell.avatar authorId:[a valueForKey:@"launcher_id"]];
        [avatarGetter getAvatar];
        
        PhotoGetter* bannerGetter = [[PhotoGetter alloc]initWithData:cell.themePhoto authorId:[a valueForKey:@"event_id"]];
        NSString* bannerURL = [a valueForKey:@"banner"];
        [bannerGetter getBanner:[a valueForKey:@"code"] url:bannerURL];

        cell.homeController = self.homeController;
        
        NSArray *memberids = [a valueForKey:@"member"];

        for (int i =3; i>=0; i--) {
            UIImageView *tmp = ((UIImageView*)[((UIView*)[cell viewWithTag:103]) viewWithTag:i+1]);
            //tmp.layer.masksToBounds = YES;
            //[tmp.layer setCornerRadius:5];
            if (i < participator_count) {
                PhotoGetter* miniGetter = [[PhotoGetter alloc]initWithData:tmp authorId:memberids[i]];
                [miniGetter getAvatar];
            }else{
                [tmp sd_cancelCurrentImageLoad];
                tmp.image = nil;
            }
            
        }
    }
    
	return cell;
}




@end
