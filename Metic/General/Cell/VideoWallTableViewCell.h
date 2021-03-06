//
//  VideoWallTableViewCell.h
//  WeShare
//
//  Created by ligang6 on 14-8-31.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoWallViewController.h"
#import "ASIHTTPRequest.h"

@interface VideoWallTableViewCell : UITableViewCell<ASIHTTPRequestDelegate>{
    ASIHTTPRequest *videoRequest;
    unsigned long long Recordull;
    BOOL isReady;
}

@property (strong, nonatomic) IBOutlet UIImageView *avatar;
@property (strong, nonatomic) IBOutlet UILabel *author;
@property (strong, nonatomic) IBOutlet UILabel *time;
@property (strong, nonatomic) IBOutlet UIView *videoContainer;

@property (strong, nonatomic) IBOutlet UIImageView *thumbImg;
@property (strong, nonatomic) IBOutlet UIButton *video_button;
@property (strong, nonatomic) IBOutlet UIView *videoView;
@property (strong, nonatomic) UIImage* videoThumb;
@property (strong, nonatomic) IBOutlet UIImageView *videoPlayImg;
@property (strong, nonatomic) IBOutlet UILabel *title;
@property (strong, nonatomic) IBOutlet UIView *textViewContainer;

@property (strong, nonatomic) NSNumber *authorId;
@property (strong, nonatomic) NSNumber *eventId;
@property (strong, nonatomic) NSNumber *videoId;
@property (strong, nonatomic) NSString *videoName;
@property (strong, nonatomic) NSMutableDictionary *videoInfo;
@property (weak, nonatomic) VideoWallViewController* controller;

@property (nonatomic) BOOL isZan;
@property BOOL isVideoReady;

- (IBAction)play:(id)sender;
- (void)PlayingVideoAtOnce;
- (void)clearVideoRequest;

//加载数据
- (void)applyData:(NSMutableDictionary *)data;
+ (float)calculateCellHeightwithText:(NSString *)text labelWidth:(float)labelWidth;
@end

@interface VideoDetailView : UIView

- (void)reset;

- (void)setupUIWithIsZan:(BOOL)isZan zanNum:(NSInteger)zanNum commentNum:(NSInteger)commentNum;

@end
