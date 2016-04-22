//
//  CustomCellTableViewCell.m
//  Metic
//
//  Created by ligang_mac4 on 14-5-28.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "EventCellTableViewCell.h"
#import "BannerViewController.h"
#import "NotificationController.h"
#import "PictureWall2.h"
#import "VideoWallViewController.h"
#import "showParticipatorsViewController.h"
#import "SVProgressHUD.h"
#import "MTShowTextViewController.h"
#import "MegUtils.h"
#import "MTOperation.h"


#define MainFontSize 14

@interface EventCellTableViewCell ()

@property(nonatomic,strong) BannerViewController *bannerView;

@end

@implementation EventCellTableViewCell

@synthesize launcherImg;
@synthesize themePhoto;
@synthesize eventName;
@synthesize eventDetail;
@synthesize videoWall;
@synthesize imgWall;
@synthesize timeInfo;
@synthesize location;
@synthesize launcherinfo;
@synthesize member_count;
@synthesize comment;
@synthesize commentInputView;
@synthesize addPaticipator;
@synthesize imgWall_icon;
@synthesize videoWall_icon;
@synthesize controller;
@synthesize bannerView;


#define widthspace 10
#define deepspace 4

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        
        // Initialization code
    }
    return self;
    
}

- (void)awakeFromNib
{
    // Initialization code
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshPVRPStatus) name: @"refreshPVRPStatus" object:nil];
    
    //点击显示MTShowTextViewController
    UITapGestureRecognizer * tapRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showDetail:)];
    [eventDetail addGestureRecognizer:tapRecognizer];
}

- (void)applyData:(NSDictionary*)data
{
    self.eventInfo = data;
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
    
    NSString* launcher = [MTOperation getAliasWithUserId:data[@"launcher_id"] userName:data[@"launcher"]];
    
    self.launcherinfo.text = [[NSString alloc]initWithFormat:@"发起人: %@",launcher];
    NSInteger visibilityNum = [data[@"visibility"] integerValue];
    switch (visibilityNum) {
        case 0:
            self.eventType.text = @"活动类型: 私人活动";
            break;
        case 1:
            self.eventType.text = @"活动类型: 公开(内容不可见)";
            break;
        case 2:
            self.eventType.text = @"活动类型: 公开(内容可见)";
            break;
        default:
            break;
    }
    BOOL isMine = [[data valueForKey:@"launcher_id"] intValue] == [[MTUser sharedInstance].userid intValue];
    BOOL visibility = [[data valueForKey:@"isIn"] boolValue] && ([[data valueForKey:@"visibility"] boolValue] || isMine);
    if (visibility) {
        [self.addPaticipator setBackgroundImage:[UIImage imageNamed:@"活动邀请好友"] forState:UIControlStateNormal];
    }else [self.addPaticipator setBackgroundImage:[UIImage imageNamed:@"不能邀请好友"] forState:UIControlStateNormal];
    NSString* text = [data valueForKey:@"remark"];
    if (text && [text isEqualToString:@""]) {
        text = @"暂无活动描述";
    }
    self.eventDetail.text = text;
    
    NSNumber* launcherId = [data valueForKey:@"launcher_id"];
    PhotoGetter* authorImgGetter = [[PhotoGetter alloc]initWithData:self.launcherImg authorId:launcherId];

    launcherImg.layer.masksToBounds = YES;
    launcherImg.layer.cornerRadius = 4;
    [authorImgGetter getAvatar];
    self.eventId = [data valueForKey:@"event_id"];
    
    [self drawOfficialFlag:[[data valueForKey:@"verify"] boolValue]];
    
    PhotoGetter* bannerGetter = [[PhotoGetter alloc]initWithData:self.themePhoto authorId:self.eventId];
    NSString* bannerURL = [data valueForKey:@"banner"];
    NSString* bannerPath = [MegUtils bannerImagePathWithEventId:self.eventId];
    [bannerGetter getBanner:[data valueForKey:@"code"] url:bannerURL path:bannerPath retainOldone:YES];
    
    NSArray *memberids = [data valueForKey:@"member"];
    for (int i =0; i<4; i++) {
        UIImageView *tmp = self.avatarArray[i];
        if (i < participator_count) {
            PhotoGetter* miniGetter = [[PhotoGetter alloc]initWithData:tmp authorId:memberids[i]];
            [miniGetter getAvatar];
        }else tmp.image = nil;
        
    }
    [self setImgWallpoint];
    [self setVideoWallpoint];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)showDetail:(id)sender {
    if (eventDetail) {
        MTShowTextViewController* showTextVC = [[MTShowTextViewController alloc]init];
        showTextVC.content = eventDetail.text;
        [showTextVC show];
    }
}

- (IBAction)jumpToPictureWall:(id)sender {
    if (!_eventInfo) {
        return;
    }
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle: nil];
    PictureWall2 *pictureWall = [mainStoryboard instantiateViewControllerWithIdentifier: @"PictureWall2"];
    pictureWall.eventId = self.eventId;
    pictureWall.eventLauncherId = [_eventInfo valueForKey:@"launcher_id"];
    pictureWall.eventName = [_eventInfo valueForKey:@"subject"];
    pictureWall.eventInfo = self.eventInfo;
    [self.controller.navigationController pushViewController:pictureWall animated:YES];
    return;
    [self.controller performSegueWithIdentifier:@"toPictureWall" sender:self.controller];
}

- (IBAction)jumpToVideoWall:(id)sender {
    if (!_eventInfo) {
        return;
    }
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle: nil];
    VideoWallViewController *videowall = [mainStoryboard instantiateViewControllerWithIdentifier: @"VideoWallViewController"];
    videowall.eventId = self.eventId;
    videowall.eventLauncherId = [_eventInfo valueForKey:@"launcher_id"];;
    videowall.eventName = [_eventInfo valueForKey:@"subject"];
    videowall.eventInfo = self.eventInfo;
    [self.controller.navigationController pushViewController:videowall animated:YES];
    return;
    [self.controller performSegueWithIdentifier:@"toVideoWall" sender:self.controller];
    
}

- (IBAction)addComment:(id)sender {
}

- (IBAction)showParticipators:(id)sender {
    if ([controller isKindOfClass:[EventDetailViewController class]]) {
        if (self.controller.isKeyBoard) {
            [self.controller.inputTextView resignFirstResponder];
        }else if (self.controller.isEmotionOpen){
            [self.controller button_Emotionpress:nil];
        } else [self.controller performSegueWithIdentifier:@"showParticipators" sender:self.controller];
    }else{
        if (self.controller.isKeyBoard) {
            [self.controller.inputTextView resignFirstResponder];
            return;
        }
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone"
                                                                 bundle: nil];
        showParticipatorsViewController *viewcontroller = [mainStoryboard instantiateViewControllerWithIdentifier: @"showParticipatorsViewController"];

        viewcontroller.eventId = self.eventId;
        viewcontroller.canManage = NO;
        [self.controller.navigationController pushViewController:viewcontroller animated:YES];
    }
    
}

- (IBAction)showBanner:(id)sender {
    if ([self.controller isKindOfClass:[EventDetailViewController class]]) {
        if (self.controller.isKeyBoard) {
            [self.controller.inputTextView resignFirstResponder];
        }else if (self.controller.isEmotionOpen){
            [self.controller button_Emotionpress:nil];
        }else{
            bannerView = [[BannerViewController alloc] init];
            bannerView.banner = themePhoto.image;
            
            BOOL isMine = [[self.eventInfo valueForKey:@"launcher_id"] intValue] == [[MTUser sharedInstance].userid intValue];
            if (isMine) {
                UIButton *changeBannerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                
                [changeBannerBtn setImage:[UIImage imageNamed:@"icon_change_banner"] forState:UIControlStateNormal];
                [changeBannerBtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
                [changeBannerBtn addTarget:self action:@selector(changeBanner) forControlEvents:UIControlEventTouchUpInside];
                [changeBannerBtn setBounds:CGRectMake(0, 0, 120, 40)];
                
                [bannerView setCustomView:changeBannerBtn];
            }
            [self.controller presentViewController:bannerView animated:YES completion:^{}];
        }
    }else{
        if (self.controller.isKeyBoard) {
            [self.controller.inputTextView resignFirstResponder];
            return;
        }
        bannerView = [[BannerViewController alloc] init];
        bannerView.banner = themePhoto.image;
        [self.controller presentViewController:bannerView animated:YES completion:^{}];
    }
    
}

- (void)changeBanner {
    [self.controller changeBanner];
    [bannerView dismissViewControllerAnimated:YES completion:NULL];
}

-(void)drawOfficialFlag:(BOOL)isOfficial
{
    if (isOfficial) {
        if (self.officialFlag) {
            [self addSubview:self.officialFlag];
        }else{
            float width = kMainScreenWidth;
            self.officialFlag = [[UIImageView alloc]initWithFrame:CGRectMake(width - 48, 0, 25.6, 28.4)];
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

-(void)refreshPVRPStatus
{
    if (self && _eventId) {
        if (imgWall) [self setImgWallpoint];
        if (videoWall) [self setVideoWallpoint];
    }
}

-(void)setImgWallpoint
{
    if ([NotificationController visitPhotoWall:_eventId needClear:NO]) {
        UIImageView* image = (UIImageView*)[imgWall viewWithTag:NEW_PHOTO_NOTIFICATION];
        if (!image) {
            image = [[UIImageView alloc]initWithFrame:CGRectMake(135, 0, 10, 10)];
            image.image = [UIImage imageNamed:@"slidebar_icon_redpoint"];
            [imgWall addSubview:image];
            [image setTag:NEW_PHOTO_NOTIFICATION];
        }
    }else{
        UIImageView* image = (UIImageView*)[imgWall viewWithTag:NEW_PHOTO_NOTIFICATION];
        if (image) {
            [image removeFromSuperview];
        }
    }
}

-(void)setVideoWallpoint
{
    if ([NotificationController visitVideoWall:_eventId needClear:NO]) {
        UIImageView* image = (UIImageView*)[videoWall viewWithTag:NEW_VIDEO_NOTIFICATION];
        if (!image) {
            image = [[UIImageView alloc]initWithFrame:CGRectMake(135, 0, 10, 10)];
            image.image = [UIImage imageNamed:@"slidebar_icon_redpoint"];
            [videoWall addSubview:image];
            [image setTag:NEW_VIDEO_NOTIFICATION];
        }
    }else{
        UIImageView* image = (UIImageView*)[videoWall viewWithTag:NEW_VIDEO_NOTIFICATION];
        if (image) {
            [image removeFromSuperview];
        }
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"refreshPVRPStatus" object:nil];
    
}


@end