//
//  CustomCellTableViewCell.m
//  Metic
//
//  Created by ligang_mac4 on 14-5-28.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "EventCellTableViewCell.h"
#import "BannerViewController.h"

@implementation EventCellTableViewCell

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


#define widthspace 10
#define deepspace 4

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        
        // Initialization code
        

        
    }
    return self;
    
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
    [self.eventController performSegueWithIdentifier:@"toPictureWall" sender:self.eventController];
}

- (IBAction)jumpToVideoWall:(id)sender {
    [CommonUtils showSimpleAlertViewWithTitle:@"系统消息" WithMessage:@"敬请期待" WithDelegate:nil WithCancelTitle:@"确定"];
}

- (IBAction)addComment:(id)sender {
}

- (IBAction)showParticipators:(id)sender {
    if (_eventController.isKeyBoard) {
        [_eventController.inputField resignFirstResponder];
    }else if (_eventController.isEmotionOpen){
        [_eventController button_Emotionpress:nil];
    } else [self.eventController performSegueWithIdentifier:@"showParticipators" sender:self.eventController];
}

- (IBAction)showBanner:(id)sender {
    if (_eventController.isKeyBoard) {
        [_eventController.inputField resignFirstResponder];
    }else if (_eventController.isEmotionOpen){
        [_eventController button_Emotionpress:nil];
    }else{
        BannerViewController* bannerView = [[BannerViewController alloc] init];
        bannerView.banner = themePhoto.image;
        [self.eventController presentViewController:bannerView animated:YES completion:^{}];
    }
}



- (void)dealloc {
    
    
}


@end