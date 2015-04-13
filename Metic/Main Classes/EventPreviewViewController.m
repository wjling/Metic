//
//  EventPreviewViewController.m
//  WeShare
//
//  Created by 俊健 on 15/4/13.
//  Copyright (c) 2015年 WeShare. All rights reserved.
//

#import "EventPreviewViewController.h"
#import "EventCellTableViewCell.h"
#import "EventPhotosTableViewCell.h"
#import "Reachability.h"

#define MainFontSize 14


@interface EventPreviewViewController ()<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,strong) UITableView* tableView;
@property(nonatomic,strong) NSNumber* eventId;
@property BOOL shouldShowPhoto;

@end

@implementation EventPreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self initUI];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)initUI
{
    [CommonUtils addLeftButton:self isFirstPage:NO];
    if (!_tableView) {
        CGRect frame = self.view.frame;
        frame.size.height -= 64 - frame.origin.y;
        frame.origin.y = 0;
        _tableView = [[UITableView alloc]initWithFrame:frame];
        [_tableView setBackgroundColor:[UIColor colorWithWhite:242.0/255.0 alpha:1.0]];
        [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [_tableView setRowHeight:289];
        [_tableView setShowsVerticalScrollIndicator:NO];
        [self.view addSubview:_tableView];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        [_tableView reloadData];
    }
}

- (void)initData
{
    _eventId = [_eventInfo valueForKey:@"event_id"];
    if([[Reachability reachabilityForInternetConnection] currentReachabilityStatus]!= 0) {
        _shouldShowPhoto = YES;
    }else _shouldShowPhoto = NO;

}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        static NSString *eventCellIdentifier = @"eventcell";
        BOOL nibsRegistered = NO;
        if (!nibsRegistered) {
            UINib *nib = [UINib nibWithNibName:NSStringFromClass([EventCellTableViewCell class]) bundle:nil];
            [tableView registerNib:nib forCellReuseIdentifier:eventCellIdentifier];
            nibsRegistered = YES;
        }
        EventCellTableViewCell *cell = (EventCellTableViewCell *)[tableView dequeueReusableCellWithIdentifier:eventCellIdentifier];
        //        NSLog(@"%@",_event);
        cell.eventName.text = [_eventInfo valueForKey:@"subject"];
        NSString* beginT = [_eventInfo valueForKey:@"time"];
        NSString* endT = [_eventInfo valueForKey:@"endTime"];
        cell.beginDate.text = [[[beginT substringWithRange:NSMakeRange(5, 5)] stringByAppendingString:@"日"] stringByReplacingOccurrencesOfString:@"-" withString:@"月"];
        cell.beginTime.text = [beginT substringWithRange:NSMakeRange(11, 5)];
        if (endT.length > 9)cell.endDate.text = [[[endT substringWithRange:NSMakeRange(5, 5)] stringByAppendingString:@"日"]  stringByReplacingOccurrencesOfString:@"-" withString:@"月"];
        if (endT.length > 15)cell.endTime.text = [endT substringWithRange:NSMakeRange(11, 5)];
        cell.timeInfo.text = [CommonUtils calculateTimeInfo:beginT endTime:endT launchTime:[_eventInfo valueForKey:@"launch_time"]];
        cell.location.text = [[NSString alloc]initWithFormat:@"活动地点: %@",[_eventInfo valueForKey:@"location"] ];
        NSInteger participator_count = [[_eventInfo valueForKey:@"member_count"] integerValue];
        NSString* partiCount_Str = [NSString stringWithFormat:@"%ld",(long)participator_count];
        NSString* participator_Str = [NSString stringWithFormat:@"已有 %@ 人参加",partiCount_Str];
        
        cell.member_count.font = [UIFont systemFontOfSize:15];
        cell.member_count.numberOfLines = 0;
        cell.member_count.lineBreakMode = NSLineBreakByCharWrapping;
        cell.member_count.tintColor = [UIColor lightGrayColor];
        [cell.member_count setText:participator_Str afterInheritingLabelAttributesAndConfiguringWithBlock:^(NSMutableAttributedString *mutableAttributedString) {
            NSRange redRange = [participator_Str rangeOfString:partiCount_Str];
            UIFont *systemFont = [UIFont systemFontOfSize:18];
            
            if (redRange.location != NSNotFound) {
                // Core Text APIs use C functions without a direct bridge to UIFont. See Apple's "Core Text Programming Guide" to learn how to configure string attributes.
                [mutableAttributedString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(id)[CommonUtils colorWithValue:0xef7337].CGColor range:redRange];
                
                CTFontRef italicFont = CTFontCreateWithName((__bridge CFStringRef)systemFont.fontName, systemFont.pointSize, NULL);
                [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)italicFont range:redRange];
                CFRelease(italicFont);
            }
            return mutableAttributedString;
        }];
        
        NSString* launcher = [[MTUser sharedInstance].alias_dic objectForKey:[NSString stringWithFormat:@"%@",[_eventInfo valueForKey:@"launcher_id"]]];
        if (launcher == nil || [launcher isEqual:[NSNull null]]) {
            launcher = [_eventInfo valueForKey:@"launcher"];
        }
        cell.launcherinfo.text = [[NSString alloc]initWithFormat:@"发起人: %@",launcher];
        [cell.addPaticipator setBackgroundImage:[UIImage imageNamed:@"不能邀请好友"] forState:UIControlStateNormal];
        
        NSString* text = [_eventInfo valueForKey:@"remark"];
        float commentHeight = [CommonUtils calculateTextHeight:text width:300.0 fontSize:MainFontSize isEmotion:YES];
        if (commentHeight < 25) commentHeight = 25;
        if (text && [text isEqualToString:@""]) {
            commentHeight = 10;
        }else if(text) commentHeight += 5;
        cell.eventDetail.text = text;
        CGRect frame = cell.eventDetail.frame;
        frame.size.height = commentHeight;
        [cell.eventDetail setFrame:frame];
        frame = cell.frame;
        frame.size.height = 303 + commentHeight;
        cell.frame = frame;
        
        NSNumber* launcherId = [_eventInfo valueForKey:@"launcher_id"];
        PhotoGetter* authorImgGetter = [[PhotoGetter alloc]initWithData:cell.launcherImg authorId:launcherId];
        UIImageView* launcherImg = cell.launcherImg;
        launcherImg.layer.masksToBounds = YES;
        launcherImg.layer.cornerRadius = 4;
        [authorImgGetter getAvatar];
        cell.eventId = [_eventInfo valueForKey:@"event_id"];
        cell.eventController = self;
        [cell drawOfficialFlag:[[_eventInfo valueForKey:@"verify"] boolValue]];
        
        PhotoGetter* bannerGetter = [[PhotoGetter alloc]initWithData:cell.themePhoto authorId:self.eventId];
        NSString* bannerURL = [_eventInfo valueForKey:@"banner"];
        [bannerGetter getBanner:[_eventInfo valueForKey:@"code"] url:bannerURL];
        
        NSArray *memberids = [_eventInfo valueForKey:@"member"];
        for (int i =0; i<4; i++) {
            UIImageView *tmp = ((UIImageView*)[((UIView*)[cell viewWithTag:103]) viewWithTag:i+1]);
            if (i < participator_count) {
                PhotoGetter* miniGetter = [[PhotoGetter alloc]initWithData:tmp authorId:memberids[i]];
                [miniGetter getAvatar];
            }else tmp.image = nil;
            
        }
        [cell.videoWall setHidden:YES];
        [cell.imgWall setHidden:YES];
        [cell.videoWall_icon setHidden:YES];
        [cell.imgWall_icon setHidden:YES];
        return cell;
    }else{
        BOOL nibsRegistered = NO;
        if (!nibsRegistered) {
            UINib *nib = [UINib nibWithNibName:NSStringFromClass([EventPhotosTableViewCell class]) bundle:nil];
            [tableView registerNib:nib forCellReuseIdentifier:@"EventPhotosTableViewCell"];
            nibsRegistered = YES;
        }
        EventPhotosTableViewCell *cell = (EventPhotosTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"EventPhotosTableViewCell"];
        

        
        return cell;
    }
    
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        NSString* text = [_eventInfo valueForKey:@"remark"];
        float commentHeight = [CommonUtils calculateTextHeight:text width:300.0 fontSize:MainFontSize isEmotion:NO];
        if (commentHeight < 25) commentHeight = 25;
        if (text && [text isEqualToString:@""]) {
            commentHeight = 10;
        }else if(text) commentHeight += 5;
        return 262 + commentHeight;
    }
    else {
        if (_shouldShowPhoto) return 131;
        else return 51;
    }

}



@end
