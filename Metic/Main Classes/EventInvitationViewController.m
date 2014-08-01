//
//  EventInvitationViewController.m
//  Metic
//
//  Created by ligang_mac4 on 14-7-28.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "EventInvitationViewController.h"
#import "../Cell/EventInvitationTableViewCell.h"
#import "PhotoGetter.h"
#import "MTUser.h"

@interface EventInvitationViewController ()
@property (nonatomic,strong) NSMutableArray* eventRequestMsg;
@end

@implementation EventInvitationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _eventRequestMsg = [MTUser sharedInstance].eventRequestMsg;
    _tableView.dataSource = self;
    _tableView.delegate = self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [_tableView reloadData];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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


#pragma mark UITableViewDataSource
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 289;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _eventRequestMsg.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"eventInvitationCell";
    BOOL nibsRegistered = NO;
    if (!nibsRegistered) {
        UINib *nib = [UINib nibWithNibName:NSStringFromClass([EventInvitationTableViewCell class]) bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:CellIdentifier];
        nibsRegistered = YES;
    }
    EventInvitationTableViewCell *cell = (EventInvitationTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    
    NSDictionary *a = _eventRequestMsg[indexPath.row];
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
    cell.inviteInfo.text = [[NSString alloc]initWithFormat:@"%@ 邀请你加入活动",[a valueForKey:@"launcher"] ];
    cell.eventId = [a valueForKey:@"event_id"];
    //cell.avatar.layer.masksToBounds = YES;
    [cell.avatar.layer setCornerRadius:15];
    
    PhotoGetter* avatarGetter = [[PhotoGetter alloc]initWithData:cell.avatar authorId:[a valueForKey:@"launcher_id"]];
    [avatarGetter getPhoto];
    
    PhotoGetter* bannerGetter = [[PhotoGetter alloc]initWithData:cell.themePhoto authorId:[a valueForKey:@"event_id"]];
    [bannerGetter getBanner:[a valueForKey:@"code"]];

    
    NSArray *memberids = [a valueForKey:@"member"];
    
    for (int i =3; i>=0; i--) {
        UIImageView *tmp = ((UIImageView*)[((UIView*)[cell viewWithTag:103]) viewWithTag:i+1]);
        //tmp.layer.masksToBounds = YES;
        [tmp.layer setCornerRadius:5];
        if (i < participator_count) {
            PhotoGetter* miniGetter = [[PhotoGetter alloc]initWithData:tmp authorId:memberids[i]];
            [miniGetter getPhoto];
        }else tmp.image = nil;
        
    }
    
    
    
    return cell;
}

#pragma mark UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - SlideNavigationController Methods -

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
	return YES;
}

- (BOOL)slideNavigationControllerShouldDisplayRightMenu
{
	return NO;
}
-(void)sendDistance:(float)distance
{
    if (distance > 0) {
        self.shadowView.hidden = NO;
        [self.view bringSubviewToFront:self.shadowView];
        [self.shadowView setAlpha:distance/400.0];
    }else{
        //self.shadowView.hidden = YES;
        //[self.view sendSubviewToBack:self.shadowView];
    }
}
@end
