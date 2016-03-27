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
#import "AppConstants.h"

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
    //frame.origin.x += widthspace;
    frame.origin.y += deepspace;
    //frame.size.width -= 2 * widthspace;
    frame.size.height -= 2 * deepspace;
    [super setFrame:frame];
    
}

- (IBAction)wantIn:(id)sender {
    UIAlertView* confirmAlert = [[UIAlertView alloc]initWithTitle:@"系统消息" message:@"请输入申请加入信息：" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    confirmAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    if ([MTUser sharedInstance].name && ![[MTUser sharedInstance].name isEqual:[NSNull null]]) {
        [confirmAlert textFieldAtIndex:0].text = [NSString stringWithFormat:@"我是%@",[MTUser sharedInstance].name];
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

-(void)dismissAlertView:(UIAlertView*) alertView
{
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
    
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
