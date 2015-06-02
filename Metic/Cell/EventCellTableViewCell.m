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
#import "../Source/SVProgressHUD/SVProgressHUD.h"

@implementation EventCellTableViewCell

@synthesize launcherImg;
@synthesize themePhoto;
@synthesize eventName;
@synthesize eventDetail;
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
@synthesize comment;
@synthesize commentInputView;
@synthesize addPaticipator;
@synthesize imgWall_icon;
@synthesize videoWall_icon;


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
}

//- (void)setFrame:(CGRect)frame
//{
//    frame.origin.x += widthspace;
//    frame.origin.y += deepspace;
//    frame.size.width -= 2 * widthspace;
//    frame.size.height -= 2 * deepspace;
//    [super setFrame:frame];
//    
//}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    
    
    [super setSelected:selected animated:animated];
    
    
    
    // Configure the view for the selected state
    
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
    [self.eventController.navigationController pushViewController:pictureWall animated:YES];
    return;
    [self.eventController performSegueWithIdentifier:@"toPictureWall" sender:self.eventController];
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
    [self.eventController.navigationController pushViewController:videowall animated:YES];
    return;
    [self.eventController performSegueWithIdentifier:@"toVideoWall" sender:self.eventController];
    
}

- (IBAction)addComment:(id)sender {
}

- (IBAction)showParticipators:(id)sender {
    if ([_eventController isKindOfClass:[EventDetailViewController class]]) {
        if (_eventController.isKeyBoard) {
            [_eventController.inputTextView resignFirstResponder];
        }else if (_eventController.isEmotionOpen){
            [_eventController button_Emotionpress:nil];
        } else [self.eventController performSegueWithIdentifier:@"showParticipators" sender:self.eventController];
    }else{
        if (_eventController.isKeyBoard) {
            [_eventController.inputTextView resignFirstResponder];
            return;
        }
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone"
                                                                 bundle: nil];
        showParticipatorsViewController *viewcontroller = [mainStoryboard instantiateViewControllerWithIdentifier: @"showParticipatorsViewController"];

        viewcontroller.eventId = self.eventId;
        viewcontroller.canManage = NO;
        [self.eventController.navigationController pushViewController:viewcontroller animated:YES];
    }
    
}

- (IBAction)showBanner:(id)sender {
    if ([_eventController isKindOfClass:[EventDetailViewController class]]) {
        if (_eventController.isKeyBoard) {
            [_eventController.inputTextView resignFirstResponder];
        }else if (_eventController.isEmotionOpen){
            [_eventController button_Emotionpress:nil];
        }else{
            BannerViewController* bannerView = [[BannerViewController alloc] init];
            bannerView.banner = themePhoto.image;
            [self.eventController presentViewController:bannerView animated:YES completion:^{}];
        }
    }else{
        if (_eventController.isKeyBoard) {
            [_eventController.inputTextView resignFirstResponder];
            return;
        }
        BannerViewController* bannerView = [[BannerViewController alloc] init];
        bannerView.banner = themePhoto.image;
        [self.eventController presentViewController:bannerView animated:YES completion:^{}];
    }
    
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

-(void)refreshPVRPStatus
{
    if (self && _eventId) {
        if (imgWall) [self setImgWallpoint];
        if (videoWall) [self setVideoWallpoint];
    }
}

-(void)setImgWallpoint
{
    NSLog(@"init button");
    if ([NotificationController visitPhotoWall:_eventId needClear:NO]) {
        UIImageView* image = (UIImageView*)[imgWall viewWithTag:992];
        if (!image) {
            image = [[UIImageView alloc]initWithFrame:CGRectMake(135, 0, 10, 10)];
            image.image = [UIImage imageNamed:@"选择点图标"];
            [imgWall addSubview:image];
            [image setTag:992];
        }
    }else{
        UIImageView* image = (UIImageView*)[imgWall viewWithTag:992];
        if (image) {
            [image removeFromSuperview];
        }
    }
}

-(void)setVideoWallpoint
{
    NSLog(@"init button");
    if ([NotificationController visitVideoWall:_eventId needClear:NO]) {
        UIImageView* image = (UIImageView*)[videoWall viewWithTag:991];
        if (!image) {
            image = [[UIImageView alloc]initWithFrame:CGRectMake(135, 0, 10, 10)];
            image.image = [UIImage imageNamed:@"选择点图标"];
            [videoWall addSubview:image];
            [image setTag:991];
        }
    }else{
        UIImageView* image = (UIImageView*)[videoWall viewWithTag:991];
        if (image) {
            [image removeFromSuperview];
        }
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"refreshPVRPStatus" object:nil];
    
}


@end