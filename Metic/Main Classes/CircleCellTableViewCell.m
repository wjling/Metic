//
//  CircleCellTableViewCell.m
//  WeShare
//
//  Created by ligang6 on 14-12-2.
//  Copyright (c) 2014年 WeShare. All rights reserved.
//

#import "CircleCellTableViewCell.h"
#import "../Source/SDWebImage/UIImageView+WebCache.h"
#import "../Utils/CommonUtils.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "../Utils/Reachability.h"
#import "../Source/DAProgressOverlayView/DAProgressOverlayView.h"
#import "MJPhotoBrowser.h"
#import "MJPhoto.h"

@interface CircleCellTableViewCell ()

@property(nonatomic,strong) NSString* videoName;
@property(nonatomic,strong) AVPlayer* videoPlayer;
@property(nonatomic,strong) AVPlayerItem* videoItem;
@property(nonatomic,strong) UIImageView* playIcon;
@property(nonatomic,strong) UIImageView* videoThumb;
@property (strong, nonatomic) DAProgressOverlayView *progressOverlayView;

@property(nonatomic,strong) NSString* cachePath;
@property(nonatomic,strong) NSString* webPath;
@property(nonatomic,strong) NSMutableArray* urls;

@property BOOL isPlaying;
@property BOOL isVideoDownloaded;
@end


@implementation CircleCellTableViewCell

- (void)awakeFromNib {
    //data
    NSString *CacheDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    _cachePath = [CacheDirectory stringByAppendingPathComponent:@"VideoCache"];
    _webPath = [CacheDirectory stringByAppendingPathComponent:@"VideoTemp"];
    NSFileManager *fileManager=[NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:_cachePath])
    {
        [fileManager createDirectoryAtPath:_cachePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    //ui
    _avatar = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 32, 32)];
    [_avatar sd_setImageWithURL:nil placeholderImage:[UIImage imageNamed:@"默认用户头像"]];
    [self addSubview:_avatar];
    
    _name = [[UILabel alloc]initWithFrame:CGRectMake(52, 10, 200, 16)];
    _name.font = [UIFont systemFontOfSize:13];
    _name.textColor = [UIColor colorWithRed:52.0/255.0 green:171.0/255.0 blue:139.0/255.0 alpha:1.0f];
    [self addSubview:_name];
    
    _textView = [[UILabel alloc]initWithFrame:CGRectMake(52, 30, 258, 0)];
    _textView.lineBreakMode = NSLineBreakByTruncatingTail;
    _textView.numberOfLines = 0;
    _textView.font = [UIFont systemFontOfSize:14];
    _textView.textColor = [UIColor colorWithWhite:53.0/255.0 alpha:1.0];
    [self addSubview:_textView];
    
    _controlView = [[UIView alloc]initWithFrame:CGRectMake(52, 42, 258, 34)];
    [self addSubview:_controlView];
    
    _publishTime = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 120, 34)];
    _publishTime.textColor = [UIColor colorWithWhite:147.0/255.0 alpha:1.0f];
    _publishTime.font = [UIFont systemFontOfSize:9];
    [_controlView addSubview:_publishTime];
    
    _zanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _zanBtn.frame = CGRectMake(150, 4, 50, 26);
    [_zanBtn setTitle:@"点赞" forState:UIControlStateNormal];
    _zanBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [_zanBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [_zanBtn setBackgroundColor:[UIColor colorWithWhite:238.0/255.0 alpha:1.0f]];
    [_controlView addSubview:_zanBtn];
    
    _commentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _commentBtn.frame = CGRectMake(210, 4, 50, 26);
    [_commentBtn setTitle:@"评论" forState:UIControlStateNormal];
    _commentBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [_commentBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [_commentBtn setBackgroundColor:[UIColor colorWithWhite:238.0/255.0 alpha:1.0f]];
    [_controlView addSubview:_commentBtn];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(PlayingVideoAtOnce) name: @"initLVideo" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(repeatPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)drawCell
{
    _name.text = @"我是海贼王";
    _publishTime.text = @"两小时前发布";
    _text = @"冬日的天，带着些许凄凉往返于街道两旁，吹冷了谁孤寂的心，我在这里等你。你有在哪里呢......";
    _textView.text = _text;
    
    
    
    if (_photosView) {
        [_photosView removeFromSuperview];
        _photosView = nil;
    }
    
    if (_videoView) {
        [_videoView removeFromSuperview];
        _videoLayerView.hidden = YES;
        _videoView = nil;
    }
    
    
    if(_type == 1) [self drawPhotosView];
    else if(_type == 2) [self drawVideoView];
    
    [self adjustHeight];
}

- (void)drawPhotosView
{
    _photosView = [[UIView alloc]initWithFrame:CGRectMake(52, CGRectGetMaxY(_textView.frame) + 10, 220, 220)];
    [self addSubview:_photosView];
    _photosView.layer.borderColor = [UIColor redColor].CGColor;
    _photosView.layer.borderWidth = 2;
    
    if (!_urls) {
        _urls = [[NSMutableArray alloc]init];
    }else [_urls removeAllObjects];
    for (int i = 0; i < 9; i++) {
        
        NSString* url = @"http://bcs.duapp.com/whatsact/images/1052014120206084074000.png?sign=MBO:V7M9qLLWzuCYRFRQgaHvOn3f:jvp2XgmY7yz3D652HT/B/d5pHes%3D";
        
        UIImageView* img = [[UIImageView alloc]initWithFrame:CGRectMake(75*(i%3), 75*(i/3), 70, 70)];
        [img sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"活动图片的默认图片"]];
        img.contentMode = UIViewContentModeScaleAspectFill;
        img.userInteractionEnabled = YES;
        img.clipsToBounds = YES;
        img.tag = i;
        [_photosView addSubview:img];
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(displayPhoto:)];
        [img addGestureRecognizer:tap];
        
        [_urls addObject:url];

    }
}

- (void)drawVideoView
{
    //data
    _videoName = @"201411091332510860022.mp4";
    
    _isPlaying = NO;
    
    
    
    NSFileManager *fileManager=[NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:[_cachePath stringByAppendingPathComponent:_videoName]])
    {
        _isVideoDownloaded = YES;
    }else _isVideoDownloaded = NO;
    
    //ui
    _videoView = [[UIView alloc]initWithFrame:CGRectMake(52, CGRectGetMaxY(_textView.frame) + 10, 220, 110)];
    [self addSubview:_videoView];
    _videoView.layer.borderWidth = 2;
    _videoView.layer.borderColor = [UIColor redColor].CGColor;
    
    UIImageView* videoThumb = [[UIImageView alloc]initWithFrame:_videoView.bounds];
    _videoThumb = videoThumb;
    videoThumb.contentMode = UIViewContentModeScaleAspectFill;
    videoThumb.backgroundColor = [UIColor lightGrayColor];
    videoThumb.clipsToBounds = YES;
    [videoThumb sd_setImageWithURL:[NSURL URLWithString:@"http:\/\/bcs.duapp.com\/whatsact\/video\/201411091332510860022.mp4.thumb?sign=MBO:V7M9qLLWzuCYRFRQgaHvOn3f:JBlijs9SofPRIeilEirt8Xz%2B15Y%3D"]];
    videoThumb.userInteractionEnabled = YES;
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(playVideo:)];
    [videoThumb addGestureRecognizer:tap];
    
    
    [_videoView addSubview:videoThumb];
    
    if (!_isVideoDownloaded) {
        _playIcon = [[UIImageView alloc]initWithFrame:CGRectMake(90, 35, 40, 40)];
        _playIcon.image = [UIImage imageNamed:@"视频按钮"];
        _playIcon.contentMode = UIViewContentModeScaleToFill;
        [videoThumb addSubview:_playIcon];
    }else _playIcon = nil;
    
    
    _videoLayerView = [[UIView alloc]initWithFrame:_videoView.bounds];
    _videoLayerView.clipsToBounds = YES;
    _videoLayerView.userInteractionEnabled = NO;
    [_videoView addSubview:_videoLayerView];
    
    
    
    
}

- (void)displayPhoto:(UITapGestureRecognizer*)tap
{
    NSLog(@"tap no.%d photo",tap.view.tag);
    int count = _urls.count;
    NSMutableArray *photos = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i<count; i++) {
        // 替换为中等尺寸图片
        NSString *url = _urls[i];
        MJPhoto *photo = [[MJPhoto alloc] init];
        photo.url = [NSURL URLWithString:url]; // 图片路径
        photo.srcImageView = self.photosView.subviews[i]; // 来源于哪个UIImageView
        [photos addObject:photo];
    }
    // 2.显示相册
    MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
    browser.currentPhotoIndex = tap.view.tag; // 弹出相册时显示的第一张图片是？
    browser.photos = photos; // 设置所有的图片
    [browser show];
}

- (void)playVideo:(UITapGestureRecognizer*)tap
{

    //plan b 缓存视频
    if (_isVideoDownloaded) {
        MPMoviePlayerViewController *playerViewController = [[MPMoviePlayerViewController alloc]initWithContentURL:[NSURL fileURLWithPath:[_cachePath stringByAppendingPathComponent:_videoName]]];
        
        playerViewController.moviePlayer.controlStyle = MPMovieControlStyleFullscreen;
        [self.controller presentMoviePlayerViewControllerAnimated:playerViewController];
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"pauseVideo" object:nil userInfo:nil];
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
            NSString* url = @"";
            
            
            [self readyProgressOverlayView];
            
            ASIHTTPRequest *request=[[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:url]];
            //下载完存储目录
            [request setDownloadDestinationPath:[_cachePath stringByAppendingPathComponent:_videoName]];
            //临时存储目录
            [request setTemporaryFileDownloadPath:[_webPath stringByAppendingPathComponent:_videoName]];
            __block unsigned long long totalBytes = 0;
            __block unsigned long long receivedBytes = 0;
            [request setBytesReceivedBlock:^(unsigned long long size, unsigned long long total) {
                totalBytes = total;
                receivedBytes += size;
                CGFloat progress = receivedBytes*1.0f / total;
                self.progressOverlayView.progress = progress;
                NSLog(@"%f",progress);
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
                    if (self) {
                        _isVideoDownloaded = YES;
                        [self PlayingVideoAtOnce];
                    }
                }
                return;
            }];
            //断点续载
            [request setAllowResumeForFileDownloads:YES];
            [request startAsynchronous];
            videoRequest = request;
            
        }
        
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

-(void)movieFinishedCallback:(NSNotification*)notify{
    // 视频播放完或者在presentMoviePlayerViewControllerAnimated下的Done按钮被点击响应的通知。
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"Playfrompause" object:nil userInfo:nil];
}


-(void)PlayingVideoAtOnce
{
    if (_type != 2 || _isPlaying == YES) {
        return;
    }
    
    if(_isVideoDownloaded)
    {
        _isPlaying = YES;
        NSURL* url = [NSURL fileURLWithPath:[_cachePath stringByAppendingPathComponent:_videoName]];
        _videoItem = [AVPlayerItem playerItemWithURL:url];
        
        if(!_videoPlayer){
            _videoPlayer = [AVPlayer playerWithPlayerItem:_videoItem];
            _videoPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
        }else{
            [_videoPlayer replaceCurrentItemWithPlayerItem:_videoItem];
        }
        AVPlayerLayer* avLayer = [AVPlayerLayer playerLayerWithPlayer:_videoPlayer];

        
        

        CGRect Bframe = _videoLayerView.frame;
        CGRect frame = Bframe;
        AVAssetTrack* videoTrack = [[_videoItem.asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
        CGFloat width = videoTrack.naturalSize.width;
        CGFloat height = videoTrack.naturalSize.height;
        if(width == 0 || height == 0)return;
        if (width/height > Bframe.size.width/Bframe.size.height) {
            frame.origin.y = 0;
            frame.origin.x = 0.5*(Bframe.size.width - width*Bframe.size.height/height);
            frame.size.width = width*Bframe.size.height/height;
        }else{
            frame.origin.x = 0;
            frame.origin.y = 0.5*(Bframe.size.height - height*Bframe.size.width/width);
            frame.size.height = height*Bframe.size.width/width;
        }
        
        
        avLayer.frame = frame;
        _videoPlayer.muted = YES;
        [self.videoLayerView.layer addSublayer:avLayer];
        _videoLayerView.hidden = NO;
        [_videoPlayer play];
    }
    
}

-(void)readyProgressOverlayView
{
    [self.playIcon setHidden:YES];
    if (!self.progressOverlayView)
        self.progressOverlayView = [[DAProgressOverlayView alloc] initWithFrame:self.videoThumb.bounds];
    [self.progressOverlayView setHidden:NO];
    self.progressOverlayView.progress = 0;
    [self.videoThumb addSubview:self.progressOverlayView];
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

- (void)repeatPlaying:(NSNotification *)n
{
    if (_type!= 2 || _videoLayerView.isHidden) {
        return;
    }
    AVPlayerItem* item = [n valueForKey:@"object"];
    if (item != _videoItem) return;
    NSLog(@"repeat");
//    UIViewController* controllerr = _controller.navigationController.viewControllers.lastObject;
//    if (![controllerr isKindOfClass:[VideoWallViewController class]] && ![controllerr isKindOfClass:[VideoDetailViewController class]]) {
//        _isPlaying = NO;
//        _layerOn = NO;
//        [self.avLayer removeFromSuperlayer];
//        return;
//    }
    [item seekToTime:kCMTimeZero];
    [self.videoPlayer play];
    
}

- (void)adjustHeight
{
    
    float textHeight = [CommonUtils calculateTextHeight:_text width:258 fontSize:14 isEmotion:NO];
    
    CGRect frame = _textView.frame;
    frame.size.height = textHeight;
    _textView.frame = frame;
    
    if (_type == 0) {
        frame = _controlView.frame;
        frame.origin.y = CGRectGetMaxY(_textView.frame) + 10;
        _controlView.frame = frame;
    }else if (_type == 1) {
        frame = _photosView.frame;
        frame.origin.y = CGRectGetMaxY(_textView.frame) + 10;
        _photosView.frame = frame;
        
        frame = _controlView.frame;
        frame.origin.y = CGRectGetMaxY(_photosView.frame) + 10;
        _controlView.frame = frame;
    }else if (_type == 2){
        frame = _videoView.frame;
        frame.origin.y = CGRectGetMaxY(_textView.frame) + 10;
        _videoView.frame = frame;
        
        frame = _controlView.frame;
        frame.origin.y = CGRectGetMaxY(_videoView.frame) + 10;
        _controlView.frame = frame;
    }

}

@end
