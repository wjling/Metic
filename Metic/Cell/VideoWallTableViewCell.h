//
//  VideoWallTableViewCell.h
//  WeShare
//
//  Created by ligang6 on 14-8-31.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "../Main Classes/Video/VideoWallViewController.h"
#import "../Source/ASIHTTPRequest2/ASIHTTPRequest.h"

@interface VideoWallTableViewCell : UITableViewCell<ASIHTTPRequestDelegate>{
    ASIHTTPRequest *videoRequest;
    unsigned long long Recordull;
    BOOL isReady;
}
@property (strong, nonatomic) IBOutlet UIImageView *avatar;
@property (strong, nonatomic) IBOutlet UILabel *author;
@property (strong, nonatomic) IBOutlet UILabel *time;
@property (strong, nonatomic) IBOutlet UIView *videoContainer;

@property (strong, nonatomic) IBOutlet UIButton *video_button;
@property (strong, nonatomic) UIImage* videoThumb;
@property (strong, nonatomic) IBOutlet UILabel *title;
@property (strong, nonatomic) IBOutlet UIButton *comment_button;
@property (strong, nonatomic) IBOutlet UIButton *good_button;
@property (strong, nonatomic) IBOutlet UIView *textViewContainer;
@property (strong, nonatomic) IBOutlet UIView *controlContainer;

@property (strong, nonatomic) NSNumber *authorId;
@property (strong, nonatomic) NSNumber *eventId;
@property (strong, nonatomic) NSNumber *videoId;
@property (strong, nonatomic) NSNumber *videoName;
@property (strong, nonatomic) NSMutableDictionary *videoInfo;
@property (strong, nonatomic) VideoWallViewController* controller;

@property (nonatomic) BOOL isZan;
@property (nonatomic) float height;
- (IBAction)play:(id)sender;
-(void)setISZan:(BOOL)isZan;
-(void)setGood_buttonNum:(NSNumber *)num;
-(void)setComment_buttonNum:(NSNumber *)num;
-(void)refresh;
-(void)animationBegin;
@end
