//
//  nearbyEventTableViewCell.m
//  Metic
//
//  Created by ligang_mac4 on 14-8-11.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "nearbyEventTableViewCell.h"
#import "NearbyEventViewController.h"
#import "EventSearchViewController.h"
#import "HttpSender.h"
#import "CommonUtils.h"
#import "MTUser.h"
#import "MTOperation.h"
#import "AppConstants.h"
#import "PhotoGetter.h"
#import "MegUtils.h"
#import "UIImageView+WebCache.h"


@implementation nearbyEventTableViewCell
@synthesize avatar;
@synthesize eventName;
@synthesize themePhoto;
//@synthesize eventDetail;
@synthesize timeInfo;
@synthesize location;
@synthesize launcherinfo;
@synthesize member_count;
@synthesize wantInBtn;
@synthesize statusLabel;

#define widthspace 10
#define deepspace 4

- (void)awakeFromNib
{
    // Initialization code
    self.wantInBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
}

- (IBAction)wantIn:(id)sender {
    UIAlertView* confirmAlert = [[UIAlertView alloc]initWithTitle:@"系统消息" message:@"请输入申请加入信息：" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    confirmAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    if ([MTUser sharedInstance].name && ![[MTUser sharedInstance].name isEqual:[NSNull null]]) {
        [confirmAlert textFieldAtIndex:0].text = [NSString stringWithFormat:@"我是%@,我想申请加入您的活动。",[MTUser sharedInstance].name];
    }
    [confirmAlert show];
    
}

- (IBAction)showParticipant:(id)sender {
    
    NSString* segueName;
    if ([self.nearbyEventViewController isKindOfClass:[NearbyEventViewController class]]) {
        ((NearbyEventViewController*)_nearbyEventViewController).selectedEventId = _eventId;//searchToshowparticipant
        segueName = @"nearbyToshowparticipant";
    }else if ([self.nearbyEventViewController isKindOfClass:[EventSearchViewController class]]){
        ((NearbyEventViewController*)_nearbyEventViewController).selectedEventId = _eventId;//searchToshowparticipant
        segueName = @"searchToshowparticipant";
    }
    if (segueName) [self.nearbyEventViewController performSegueWithIdentifier:segueName sender:self.nearbyEventViewController];
}

-(void)drawOfficialFlag:(BOOL)isOfficial
{
    if (isOfficial) {
        if (self.officialFlag) {
            [self addSubview:self.officialFlag];
        }else{
            float width = kMainScreenWidth;
            self.officialFlag = [[UIImageView alloc]initWithFrame:CGRectMake(width - 48 - 20, 4, 25.6, 28.4)];
            self.officialFlag.image = [UIImage imageNamed:@"flag.jpg"];
            UILabel* label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 25.6, 28.4)];
            label.textAlignment = NSTextAlignmentCenter;
            label.text = @"官";
            label.font = [UIFont systemFontOfSize:15];
            label.textColor = [UIColor whiteColor];
            [self.officialFlag addSubview:label];
            [self addSubview:self.officialFlag];
        }
    }else{
        if (self.officialFlag) {
            [self.officialFlag removeFromSuperview];
        }
    }
}

-(void)dismissAlertView:(UIAlertView*) alertView
{
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
}

- (void)applyData:(NSDictionary*)data {
    
    self.dict = data;
    self.eventName.text = [data valueForKey:@"subject"];
    NSString* beginT = [data valueForKey:@"time"];
    NSString* endT = [data valueForKey:@"endTime"];
    [CommonUtils generateEventContinuedInfoLabel:self.eventTime beginTime:beginT endTime:endT];
    
    self.timeInfo.text = [CommonUtils calculateTimeInfo:beginT endTime:endT launchTime:[data valueForKey:@"launch_time"]];
    self.location.text = [[NSString alloc]initWithFormat:@"活动地点: %@",[data valueForKey:@"location"] ];
    
    NSInteger participator_count = [[data valueForKey:@"member_count"] integerValue];
    NSString* partiCount_Str = [NSString stringWithFormat:@"%ld",(long)participator_count];
    NSString* participator_Str = [NSString stringWithFormat:@"已有 %@ 人参加",partiCount_Str];
    
    self.member_count.font = [UIFont systemFontOfSize:15];
    self.member_count.numberOfLines = 0;
    self.member_count.lineBreakMode = NSLineBreakByCharWrapping;
    self.member_count.tintColor = [UIColor lightGrayColor];
    [self.member_count setText:participator_Str afterInheritingLabelAttributesAndConfiguringWithBlock:^(NSMutableAttributedString *mutableAttributedString) {
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
    
    
    
    //显示备注名
    NSString* alias = [MTOperation getAliasWithUserId:data[@"launcher_id"] userName:data[@"launcher"]];
    self.launcherinfo.text = [[NSString alloc]initWithFormat:@"发起人: %@",alias];
    NSInteger visibility = [data[@"visibility"] integerValue];
    switch (visibility) {
        case 0:
            eventType.text = @"活动类型: 私人活动";
            break;
        case 1:
            eventType.text = @"活动类型: 公开 (内容不可见)";
            break;
        case 2:
            eventType.text = @"活动类型: 公开 (内容可见)";
            break;
        default:
            break;
    }

    self.eventId = [data valueForKey:@"event_id"];
    PhotoGetter* avatarGetter = [[PhotoGetter alloc]initWithData:self.avatar authorId:[data valueForKey:@"launcher_id"]];
    [avatarGetter getAvatar];
    [self drawOfficialFlag:[[data valueForKey:@"verify"] boolValue]];
    PhotoGetter* bannerGetter = [[PhotoGetter alloc]initWithData:self.themePhoto authorId:[data valueForKey:@"event_id"]];
    NSString* bannerURL = [data valueForKey:@"banner"];
    NSString* bannerPath = [MegUtils bannerImagePathWithEventId:[data valueForKey:@"event_id"]];
    [bannerGetter getBanner:[data valueForKey:@"code"] url:bannerURL path:bannerPath];
    if ([[data valueForKey:@"isIn"] boolValue]) {
        [self.statusLabel setHidden:NO];
        self.statusLabel.text = @"已加入活动";
        [self.wantInBtn setHidden:YES];
    }else if ([[data valueForKey:@"visibility"] boolValue]) {
        [self.statusLabel setHidden:YES];
        [self.wantInBtn setHidden:NO];
    }else{
        [self.statusLabel setHidden:NO];
        self.statusLabel.text = @"非公开活动";
        [self.wantInBtn setHidden:YES];
    }
    
    NSArray *memberids = [data valueForKey:@"member"];
    
    for (int i =3; i>=0; i--) {
        UIImageView *tmp = self.avatarArray[i];
        if (i < participator_count) {
            PhotoGetter* miniGetter = [[PhotoGetter alloc]initWithData:tmp authorId:memberids[i]];
            [miniGetter getAvatar];
        }else{
            [tmp sd_cancelCurrentImageLoad];
            tmp.image = nil;
        }
    }
    [self setBackgroundColor:[UIColor whiteColor]];
}

#pragma mark - UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case 0:{
            NSInteger cancelBtnIndex = alertView.cancelButtonIndex;
            NSInteger okBtnIndex = alertView.firstOtherButtonIndex;
            if (buttonIndex == cancelBtnIndex) {
                ;
            }
            else if (buttonIndex == okBtnIndex)
            {
                NSString* cm = [alertView textFieldAtIndex:0].text;
                
                NSDictionary* dictionary = [CommonUtils packParamsInDictionary:[NSNumber numberWithInt:REQUEST_EVENT],@"cmd",[MTUser sharedInstance].userid,@"id",cm,@"confirm_msg", _eventId,@"event_id",nil];
                MTLOG(@"%@",dictionary);
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
                HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
                [httpSender sendMessage:jsonData withOperationCode:PARTICIPATE_EVENT];
                
            }
        }
            break;
            
        default:
            break;
    }
}


#pragma mark - HttpSender Delegate
-(void)finishWithReceivedData:(NSData *)rData
{
    NSString* temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
    MTLOG(@"received Data: %@",temp);
    NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
    NSNumber *cmd = [response1 valueForKey:@"cmd"];
    
    switch ([cmd intValue]) {
        case NORMAL_REPLY:
        {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"系统消息" message:@"请等待发起人验证" delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
            [alert show];
            [self performSelector:@selector(dismissAlertView:) withObject:alert afterDelay:1.5];
            
        }
            break;
    }
}

@end
