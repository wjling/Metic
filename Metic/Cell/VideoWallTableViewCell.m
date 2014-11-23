//
//  VideoWallTableViewCell.m
//  WeShare
//
//  Created by ligang6 on 14-8-31.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "VideoWallTableViewCell.h"
#import <MediaPlayer/MediaPlayer.h>
#import "../Main Classes/MTMPMoviePlayerViewController.h"
#import "../Utils/PhotoGetter.h"
#import "CommonUtils.h"
#import "UIImageView+WebCache.h"
#import "../Main Classes/UserInfo/UserInfoViewController.h"
#import "../Main Classes/Friends/FriendsViewController.h"
#import "../Source/DAProgressOverlayView/DAProgressOverlayView.h"
#import "../Main Classes/Video/VideoDetailViewController.h"
#import "VideoPlayerViewController.h"
#import "../Main Classes/Video/MTVideoPlayerViewController.h"

#define widthspace 10
#define deepspace 4

@interface VideoWallTableViewCell ()
@property (nonatomic,strong) MTMPMoviePlayerViewController* movie;
@property (strong, nonatomic) DAProgressOverlayView *progressOverlayView;
@property (nonatomic, retain) VideoPlayerViewController *myPlayerViewController;
@property __block unsigned long long receivedBytes;

//test
@property (strong, nonatomic) AVPlayerItem* videoItem;
@property (strong, nonatomic) AVPlayer* videoPlayer;
@property (strong, nonatomic) AVPlayerLayer* avLayer;
@property BOOL isPlaying;

@end

@implementation VideoWallTableViewCell

- (void)awakeFromNib
{
    [_video_button setBackgroundImage:[CommonUtils createImageWithColor:[UIColor lightGrayColor]] forState:UIControlStateNormal];
    [_video_button setBackgroundImage:[CommonUtils createImageWithColor:[CommonUtils colorWithValue:0x909090]] forState:UIControlStateHighlighted];
    [_good_button setBackgroundImage:[CommonUtils createImageWithColor:[CommonUtils colorWithValue:0xe0e0e0]] forState:UIControlStateHighlighted];
    [_comment_button setBackgroundImage:[CommonUtils createImageWithColor:[CommonUtils colorWithValue:0xe0e0e0]] forState:UIControlStateHighlighted];
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    [self.good_button addTarget:self action:@selector(good:) forControlEvents:UIControlEventTouchUpInside];
    [self.comment_button addTarget:self action:@selector(toDetail:) forControlEvents:UIControlEventTouchUpInside];
    UITapGestureRecognizer * tapRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(pushToFriendView:)];
    [self.avatar addGestureRecognizer:tapRecognizer];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(PlayingVideoAtOnce) name: @"initLVideo" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(Playfrompause) name: @"Playfrompause" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pauseVideo) name: @"pauseVideo" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(repeatPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    _isPlaying = NO;
    // Initialization code
}


-(void)dealloc
{
    [self clearVideoRequest];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"initLVideo" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Playfrompause" object:nil];
    
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

- (IBAction)play:(id)sender {
    
    NSString *videoName = [_videoInfo valueForKey:@"video_name"];
    NSString *url = [_videoInfo valueForKey:@"url"];
    NSLog(@"%@",url);
//    [self openmovie:url];
//    [self videoPlay:videoName url:url];
    [self downloadVideo:videoName url:url];
}

-(void)setISZan:(BOOL)isZan
{
    self.isZan = isZan;
    if (isZan) {
        [self.good_button setImage:[UIImage imageNamed:@"活动详情_点赞图按下效果"] forState:UIControlStateNormal];
    }else{
        [self.good_button setImage:[UIImage imageNamed:@"活动详情_点赞图"] forState:UIControlStateNormal];
    }
}

-(void)setGood_buttonNum:(NSNumber *)num
{
    [self.good_button setTitle:[CommonUtils TextFromInt:[num intValue]] forState:UIControlStateNormal];
}

-(void)setComment_buttonNum:(NSNumber *)num
{
    [self.comment_button setTitle:[CommonUtils TextFromInt:[num intValue]] forState:UIControlStateNormal];
}

-(void)refresh
{
    _isVideoReady = NO;
    if (_progressOverlayView) {
        [_progressOverlayView removeFromSuperview];
        _progressOverlayView = nil;
    }
    [self clearVideoRequest];
    if (_myPlayerViewController) {
        [_myPlayerViewController.view removeFromSuperview];
        _myPlayerViewController = nil;
    }
    
    _isPlaying = NO;
    [ self.videoPlayer pause];
    [self.avLayer removeFromSuperlayer];
    
    
    
    //显示备注名
    NSString* alias = [[MTUser sharedInstance].alias_dic objectForKey:[NSString stringWithFormat:@"%@",[_videoInfo valueForKey:@"author_id"]]];
    if (alias == nil || [alias isEqual:[NSNull null]]) {
        alias = [_videoInfo valueForKey:@"author"];
    }
    self.author.text = alias;
    self.time.text = [[_videoInfo valueForKey:@"time"] substringToIndex:10];
    self.authorId = [_videoInfo valueForKey:@"author_id"];
    PhotoGetter* avatarGetter = [[PhotoGetter alloc]initWithData:self.avatar authorId:self.authorId];
    [avatarGetter getAvatar];
    
    _videoName = [_videoInfo valueForKey:@"video_name"];
    NSString* text = [_videoInfo valueForKey:@"title"];
    //float height = [self.controller calculateTextHeight:text width:280 fontSize:16.0f];
    CGRect frame = self.textViewContainer.frame;
    frame.size.height = _height + 20;
    self.textViewContainer.frame = frame;
    self.title.text = text;
    
    CGRect cframe = self.controlContainer.frame;
    cframe.origin.y = frame.origin.y + frame.size.height;
    self.controlContainer.frame = cframe;
    
    [self.good_button setEnabled:YES];
    [self setISZan:[[_videoInfo valueForKey:@"isZan"] boolValue]];
    [self setGood_buttonNum:[_videoInfo valueForKey:@"good"]];
    [self setComment_buttonNum:[_videoInfo valueForKey:@"comment_num"]];
    
    NSString *url = [_videoInfo valueForKey:@"thumb"];
    
    [_video_button setImage:nil forState:UIControlStateNormal];
    [_video_button setBackgroundImage:[CommonUtils createImageWithColor:[UIColor lightGrayColor]] forState:UIControlStateNormal];
    [_video_button setBackgroundImage:[CommonUtils createImageWithColor:[CommonUtils colorWithValue:0x909090]] forState:UIControlStateHighlighted];
    self.videoThumb = nil;
    
    [self.video_button.imageView sd_setImageWithURL:[NSURL URLWithString:url] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (image) {
            [self.video_button setImage:image forState:UIControlStateNormal];
            self.video_button.imageView.contentMode = UIViewContentModeScaleAspectFill;
            self.videoThumb = image;
        }
    }];
    
    NSString *CacheDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *cachePath = [CacheDirectory stringByAppendingPathComponent:@"VideoCache"];
    
    NSFileManager *fileManager=[NSFileManager defaultManager];
    if( _videoInfo && [fileManager fileExistsAtPath:[cachePath stringByAppendingPathComponent:_videoName]])
    {
        self.videoPlayImg.hidden = YES;
        [self PlayingVideoAtOnce];
    }else if([_controller.loadingVideo containsObject:_videoName]){
        //self.videoPlayImg.hidden = YES;
        if(!_progressOverlayView) [self play:nil];
    }else{
        self.videoPlayImg.hidden = NO;
    }

}

- (void)clearVideoRequest
{
    if (videoRequest) {
        if (_progressOverlayView) {
            self.progressOverlayView.hidden = YES;
            [self closeProgressOverlayView];
        }
        [videoRequest clearDelegatesAndCancel];
        videoRequest = nil;
    }
}

-(void)animationBegin
{
    if (!_controller.shouldFlash) {
        return;
    }
    [self setAlpha:0.5];
    [UIView beginAnimations:@"shadowViewDisappear" context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDelegate:self];
    self.alpha = 1;
    [UIView commitAnimations];
}

-(void)good:(UIButton*)button
{
    [button setEnabled:NO];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self && ![button isEnabled]) {
            [button setEnabled:YES];
        }
    });

    BOOL isZan = [[_videoInfo valueForKey:@"isZan"] boolValue];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:[MTUser sharedInstance].userid forKey:@"id"];
    [dictionary setValue:[_videoInfo valueForKey:@"video_id"] forKey:@"video_id"];
    [dictionary setValue:[NSNumber numberWithInt:isZan? 4:5]  forKey:@"operation"];
    [dictionary setValue:self.eventId forKey:@"event_id"];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    NSLog(@"%@",[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding]);
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:ADD_GOOD finshedBlock:^(NSData *rData) {
        [self.good_button setEnabled:YES];
        if (rData) {
            NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
            NSNumber *cmd = [response1 valueForKey:@"cmd"];
            if ([cmd intValue] == NORMAL_REPLY) {
                [_videoInfo setValue:[NSNumber numberWithBool:!isZan] forKey:@"isZan"];
                int zan_num = [[_videoInfo valueForKey:@"good"] intValue];
                if (isZan) {
                    zan_num --;
                }else{
                    zan_num ++;
                }
                [_videoInfo setValue:[NSNumber numberWithInt:zan_num] forKey:@"good"];
                [VideoWallViewController updateVideoInfoToDB:[[NSMutableArray alloc]initWithObjects:_videoInfo, nil] eventId:_eventId];
                _controller.shouldFlash = NO;
                [self setGood_buttonNum:[_videoInfo valueForKey:@"good"]];
                [self setISZan:[[_videoInfo valueForKey:@"isZan"] boolValue]];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    _controller.shouldFlash = YES;
                });
            }
        }
    }];

}

-(void)toDetail:(UIButton*)button
{
    _controller.seleted_videoInfo = _videoInfo;
    _controller.seleted_videoThumb = _videoThumb;
    [_controller performSegueWithIdentifier:@"toVideoDetail" sender:_controller];
}

- (void)pushToFriendView:(id)sender {
    _authorId = [_videoInfo valueForKey:@"author_id"];
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone"
															 bundle: nil];
    if ([_authorId intValue] == [[MTUser sharedInstance].userid intValue]) {
        UserInfoViewController* userInfoView = [mainStoryboard instantiateViewControllerWithIdentifier: @"UserInfoViewController"];
        userInfoView.needPopBack = YES;
        [_controller.navigationController pushViewController:userInfoView animated:YES];
        
    }else{
        FriendInfoViewController *friendView = [mainStoryboard instantiateViewControllerWithIdentifier: @"FriendInfoViewController"];
        friendView.fid = self.authorId;
        [_controller.navigationController pushViewController:friendView animated:YES];
    }
	
}



- (void)downloadVideo:(NSString*)videoName url:(NSString*)url{
    
    NSString *CacheDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *webPath = [CacheDirectory stringByAppendingPathComponent:@"VideoTemp"];
    NSString *cachePath = [CacheDirectory stringByAppendingPathComponent:@"VideoCache"];
    
    __block unsigned long long totalBytes = 0;
    _receivedBytes = 0;
    __block BOOL canReplay = YES;
    
    
    //plan b 缓存视频
    NSFileManager *fileManager=[NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:cachePath])
    {
        [fileManager createDirectoryAtPath:cachePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    if ([fileManager fileExistsAtPath:[cachePath stringByAppendingPathComponent:videoName]]) {

        MTVideoPlayerViewController* player = [[MTVideoPlayerViewController alloc]init];
        player.videoName = _videoName;
        player.wall = _controller;
        player.cell = self;
        [self.controller presentViewController:player animated:YES completion:nil];
        
        
        
        
        
        
        return;
        MTMPMoviePlayerViewController *playerViewController = [[MTMPMoviePlayerViewController alloc]initWithContentURL:[NSURL fileURLWithPath:[cachePath stringByAppendingPathComponent:videoName]]];
        
        playerViewController.moviePlayer.controlStyle = MPMovieControlStyleFullscreen;
        [self.controller presentMoviePlayerViewControllerAnimated:playerViewController];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"pauseVideo" object:nil userInfo:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self
         
                                                selector:@selector(movieFinishedCallback:)
         
                                                    name:MPMoviePlayerPlaybackDidFinishNotification
         
                                                  object:playerViewController.moviePlayer];
        
        videoRequest = nil;
    }else{
        if (videoRequest){
            return;
        }
        
        if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == 0) {
            NSLog(@"没有网络");
            return;
        }

        
        else{
            
            [self readyProgressOverlayView];
            
            ASIHTTPRequest *request=[[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:url]];
            //下载完存储目录
            [request setDownloadDestinationPath:[cachePath stringByAppendingPathComponent:videoName]];
            //临时存储目录
            [request setTemporaryFileDownloadPath:[webPath stringByAppendingPathComponent:videoName]];

            [request setBytesReceivedBlock:^(unsigned long long size, unsigned long long total) {
                totalBytes = total;
                _receivedBytes += size;
                CGFloat progress = _receivedBytes*1.0f / total;
                self.progressOverlayView.progress = progress;
                if (!(_controller.navigationController.viewControllers.lastObject == _controller)) {
                    [self clearVideoRequest];
                }
            }];
            [_controller.loadingVideo addObject:_videoName];
            NSString*VideoName = [NSString stringWithString:_videoName];
            [request setCompletionBlock:^{
                if ([_videoName isEqualToString:VideoName]) {
                    [self closeProgressOverlayView];
                    if ([_controller.loadingVideo containsObject:_videoName]) {
                        [_controller.loadingVideo removeObject:_videoName];
                    }
                    if (_controller) {
                        NSURL* url = [NSURL fileURLWithPath:[cachePath stringByAppendingPathComponent:VideoName]];
                        AVPlayerItem *videoItem = [AVPlayerItem playerItemWithURL:url];
                        AVPlayer *videoPlayer = [AVPlayer playerWithPlayerItem:videoItem];
                        AVPlayerLayer* playerLayer = [AVPlayerLayer playerLayerWithPlayer:videoPlayer];
                        [_controller.AVPlayerItems setObject:videoItem forKey:videoName];
                        [_controller.AVPlayers setObject:videoPlayer forKey:videoName];
                        [_controller.AVPlayerLayers setObject:playerLayer forKey:videoName];
                        [self PlayingVideoAtOnce];
                    }
                }
            
                
                
                
                
                return;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    // my video player
                    float tableY = _controller.tableView.contentOffset.y;
                    float cellY = self.frame.origin.y;
                    if (tableY <= cellY + 57 && tableY + _controller.tableView.frame.size.height >=cellY + 57 + 225 && _controller &&_controller.navigationController.viewControllers.lastObject == _controller ) {
                        //[self downloadVideo:videoName url:url];
                    }
                    //[self PlayingVideoAtOnce];
                });
                
            }];
            //断点续载
            [request setAllowResumeForFileDownloads:YES];
            [request startAsynchronous];
            videoRequest = request;
            
        }
        
    }
}

-(void)readyProgressOverlayView
{
    [self.videoPlayImg setHidden:YES];
    if (!self.progressOverlayView)
        self.progressOverlayView = [[DAProgressOverlayView alloc] initWithFrame:self.video_button.bounds];
    [self.progressOverlayView setHidden:NO];
    self.progressOverlayView.progress = 0;
    [self.video_button addSubview:self.progressOverlayView];
    [self.progressOverlayView displayOperationWillTriggerAnimation];
}

-(void)closeProgressOverlayView
{
    if (self.progressOverlayView) {
        [self.progressOverlayView displayOperationDidFinishAnimation];
        double delayInSeconds = self.progressOverlayView.stateChangeAnimationDuration;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [_progressOverlayView removeFromSuperview];
            _progressOverlayView = nil;

        });
    }
    
}

-(void)PlayingVideoAtOnce
{
    // my video player
    
    if(_isPlaying) return;
    NSLog(@"play");
    
    
    
    
    NSString *CacheDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *cachePath = [CacheDirectory stringByAppendingPathComponent:@"VideoCache"];
    
    NSFileManager *fileManager=[NSFileManager defaultManager];
    if( _videoInfo && [fileManager fileExistsAtPath:[cachePath stringByAppendingPathComponent:_videoName]])
    {
        _isPlaying = YES;
        
//        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0ul);
//        
//        dispatch_async(queue, ^{

            self.videoItem = [_controller.AVPlayerItems objectForKey:_videoName];
            self.videoPlayer = [_controller.AVPlayers objectForKey:_videoName];
            self.avLayer = [_controller.AVPlayerLayers objectForKey:_videoName];
            self.videoPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;

//            dispatch_sync(dispatch_get_main_queue(), ^{
        
                CGRect Bframe = _video_button.frame;
                CGRect frame = Bframe;
                AVAssetTrack* videoTrack = [[_videoItem.asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
                CGFloat width = videoTrack.naturalSize.width;
                CGFloat height = videoTrack.naturalSize.height;
                if (width/height > Bframe.size.width/Bframe.size.height) {
                    frame.origin.y = 0;
                    frame.origin.x = 0.5*(Bframe.size.width - width*Bframe.size.height/height);
                    frame.size.width = width*Bframe.size.height/height;
                }else{
                    frame.origin.x = 0;
                    frame.origin.y = 0.5*(Bframe.size.height - height*Bframe.size.width/width);
                    frame.size.height = height*Bframe.size.width/width;
                }
     
                
                self.avLayer.frame = frame;
                [self.videoContainer.layer addSublayer:self.avLayer];
                self.videoPlayer.volume = 0;
                [self.videoPlayer play];
//            });
//        });
    }
    
}

- (void)repeatPlaying:(NSNotification *)n
{
    NSLog(@"repeat");
    AVPlayerItem* item = [n valueForKey:@"object"];
    if (item != _videoItem) return;
    UIViewController* controllerr = _controller.navigationController.viewControllers.lastObject;
    if (![controllerr isKindOfClass:[VideoWallViewController class]] && ![controllerr isKindOfClass:[VideoDetailViewController class]]) {
        _isPlaying = NO;
        [self.avLayer removeFromSuperlayer];
        return;
    }
    [self.videoItem seekToTime:kCMTimeZero];
    [self.videoPlayer play];
    
}

- (void)Playfrompause
{
    if (_videoPlayer) {
        [_videoPlayer play];
    }
}

- (void)pauseVideo
{
    if (_videoPlayer) {
        [_videoPlayer pause];
    }
}

- (void)playVideo:(NSString*)videoName{
    MTMPMoviePlayerViewController *playerViewController =[[MTMPMoviePlayerViewController alloc]initWithContentURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://127.0.0.1:12345/%@",videoName]]];
    playerViewController.moviePlayer.controlStyle = MPMovieControlStyleFullscreen;
    _movie = playerViewController;
    [_movie.moviePlayer prepareToPlay];
    _movie.moviePlayer.movieSourceType = MPMovieSourceTypeFile;
    _movie.moviePlayer.shouldAutoplay = YES;
    [self.controller presentMoviePlayerViewControllerAnimated:playerViewController];
    [[NSNotificationCenter defaultCenter]addObserver:self
     
                                            selector:@selector(movieFinishedCallback:)
     
                                                name:MPMoviePlayerPlaybackDidFinishNotification
     
                                              object:playerViewController.moviePlayer];
}


-(void)movieFinishedCallback:(NSNotification*)notify{
    // 视频播放完或者在presentMoviePlayerViewControllerAnimated下的Done按钮被点击响应的通知。
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Playfrompause" object:nil userInfo:nil];
    MPMoviePlayerController* theMovie = [notify object];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self
     
                                                  name:MPMoviePlayerPlaybackDidFinishNotification
     
                                                object:theMovie];
    

//    planb
//    NSString *CacheDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
//    NSString *webPath = [CacheDirectory stringByAppendingPathComponent:@"VideoTemp"];
//    NSString *filePath = [webPath stringByAppendingPathComponent:[_videoInfo valueForKey:@"video_name"]];
    [videoRequest clearDelegatesAndCancel];
    videoRequest = nil;
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    if ([fileManager fileExistsAtPath:filePath]) {
//        [fileManager removeItemAtPath:filePath error:nil];
//    }
    _controller.canPlay = YES;
}


@end

