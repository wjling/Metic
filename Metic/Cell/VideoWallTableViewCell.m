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
#define widthspace 10
#define deepspace 4

@interface VideoWallTableViewCell ()
@property (nonatomic,strong) MTMPMoviePlayerViewController* movie;
@property __block unsigned long long receivedBytes;
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
    // Initialization code
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
    NSString *url = [CommonUtils getUrl:[NSString stringWithFormat:@"/video/%@",videoName]];
    NSLog(@"%@",url);
//    [self openmovie:url];
    [self videoPlay:videoName url:url];
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
    if (videoRequest) {
        [videoRequest clearDelegatesAndCancel];
        videoRequest = nil;
    }
    
    self.author.text = [_videoInfo valueForKey:@"author"];
    self.time.text = [[_videoInfo valueForKey:@"time"] substringToIndex:10];
    self.authorId = [_videoInfo valueForKey:@"author_id"];
    PhotoGetter* avatarGetter = [[PhotoGetter alloc]initWithData:self.avatar authorId:self.authorId];
    [avatarGetter getAvatar];
    
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
    
    NSString *url = [CommonUtils getUrl:[NSString stringWithFormat:@"/video/%@.thumb",[_videoInfo valueForKey:@"video_name"]]];
    
    [self.video_button.imageView sd_setImageWithURL:[NSURL URLWithString:url] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (image) {
            [self.video_button setImage:image forState:UIControlStateNormal];
            self.video_button.imageView.contentMode = UIViewContentModeScaleAspectFill;
            self.videoThumb = image;
        }else{
            [_video_button setImage:nil forState:UIControlStateNormal];
            [_video_button setBackgroundImage:[CommonUtils createImageWithColor:[UIColor lightGrayColor]] forState:UIControlStateNormal];
            [_video_button setBackgroundImage:[CommonUtils createImageWithColor:[CommonUtils colorWithValue:0x909090]] forState:UIControlStateHighlighted];
            self.videoThumb = nil;
        }
    }];

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
                _controller.shouldFlash = NO;
                [_controller.tableView reloadData];
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


- (void)videoPlay:(NSString*)videoName url:(NSString*)url{
    
    NSString *CacheDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *webPath = [CacheDirectory stringByAppendingPathComponent:@"VideoTemp"];
    NSString *cachePath = [CacheDirectory stringByAppendingPathComponent:@"VideoCache"];
    
    __block unsigned long long totalBytes = 0;
    _receivedBytes = 0;
    __block BOOL canReplay = YES;
    
    
//    //plan a 在线播放 同时下载视频
//    NSFileManager *fileManager=[NSFileManager defaultManager];
//    if(![fileManager fileExistsAtPath:cachePath])
//    {
//        [fileManager createDirectoryAtPath:cachePath withIntermediateDirectories:YES attributes:nil error:nil];
//    }
//    if ([fileManager fileExistsAtPath:[cachePath stringByAppendingPathComponent:videoName]]) {
//        MTMPMoviePlayerViewController *playerViewController = [[MTMPMoviePlayerViewController alloc]initWithContentURL:[NSURL fileURLWithPath:[cachePath stringByAppendingPathComponent:videoName]]];
//        _movie = playerViewController;
//        [[NSNotificationCenter defaultCenter]addObserver:self
//         
//                                                selector:@selector(movieFinishedCallback:)
//         
//                                                    name:MPMoviePlayerPlaybackDidFinishNotification
//         
//                                                  object:playerViewController.moviePlayer];
//
//        
//        //        MTMPMoviePlayerViewController *playerViewController =[[MTMPMoviePlayerViewController alloc]initWithContentURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://127.0.0.1:12345/%@",videoName]]];
//        
//        playerViewController.moviePlayer.controlStyle = MPMovieControlStyleFullscreen;
//        [self.controller presentMoviePlayerViewControllerAnimated:playerViewController];
//        return;
//    }
//    MTMPMoviePlayerViewController *playerViewController =[[MTMPMoviePlayerViewController alloc]initWithContentURL:[NSURL URLWithString:url]];
//    [[NSNotificationCenter defaultCenter]addObserver:self
//     
//                                            selector:@selector(movieFinishedCallback:)
//     
//                                                name:MPMoviePlayerPlaybackDidFinishNotification
//     
//                                              object:playerViewController.moviePlayer];
//
//    playerViewController.moviePlayer.controlStyle = MPMovieControlStyleFullscreen;
//    _movie = playerViewController;
//    _movie.moviePlayer.shouldAutoplay = YES;
//
//    [self.controller presentMoviePlayerViewControllerAnimated:playerViewController];
//    [_movie.moviePlayer prepareToPlay];
//    [_movie.moviePlayer play];
//    if (!videoRequest) {
//        ASIHTTPRequest *request=[[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:url]];
//        //下载完存储目录
//        [request setDownloadDestinationPath:[cachePath stringByAppendingPathComponent:videoName]];
//        //临时存储目录
//        [request setTemporaryFileDownloadPath:[webPath stringByAppendingPathComponent:videoName]];
//        //断点续载
//        [request setAllowResumeForFileDownloads:YES];
//        [request startAsynchronous];
//        videoRequest = request;
//    }

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    //plan b 缓存视频
    NSFileManager *fileManager=[NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:cachePath])
    {
        [fileManager createDirectoryAtPath:cachePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    if ([fileManager fileExistsAtPath:[cachePath stringByAppendingPathComponent:videoName]]) {
        if (!_controller.canPlay) return;
        else _controller.canPlay = NO;
            
        MTMPMoviePlayerViewController *playerViewController = [[MTMPMoviePlayerViewController alloc]initWithContentURL:[NSURL fileURLWithPath:[cachePath stringByAppendingPathComponent:videoName]]];
        
//        MTMPMoviePlayerViewController *playerViewController =[[MTMPMoviePlayerViewController alloc]initWithContentURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://127.0.0.1:12345/%@",videoName]]];
        
        playerViewController.moviePlayer.controlStyle = MPMovieControlStyleFullscreen;
        [self.controller presentMoviePlayerViewControllerAnimated:playerViewController];
        
        [[NSNotificationCenter defaultCenter]addObserver:self
         
                                                selector:@selector(movieFinishedCallback:)
         
                                                    name:MPMoviePlayerPlaybackDidFinishNotification
         
                                                  object:playerViewController.moviePlayer];

        videoRequest = nil;
    }else{
        if (!_controller.canPlay) return;
        if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == 0) {
            NSLog(@"没有网络");
            return;
        }
        _controller.canPlay = NO;
        if (videoRequest){
            if (_isVideoReady) {
                NSLog(@"trytrytrytry");
                [self playVideo:videoName];
            }
            
        }
        else{
            _isVideoReady = NO;
            ASIHTTPRequest *request=[[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:url]];
            //下载完存储目录
            [request setDownloadDestinationPath:[cachePath stringByAppendingPathComponent:videoName]];
            //临时存储目录
            [request setTemporaryFileDownloadPath:[webPath stringByAppendingPathComponent:videoName]];
            __block BOOL isPlay = NO;
            [request setBytesReceivedBlock:^(unsigned long long size, unsigned long long total) {
                totalBytes = total;
                _receivedBytes += size;
                //            NSLog(@"%lld   %lld   %f",_receivedBytes,total,_receivedBytes*1.0f/total);
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                if (_movie) [_movie.moviePlayer prepareToPlay];
                [userDefaults setDouble:total forKey:@"file_length"];
                //            [userDefaults setDouble:_receivedBytes forKey:@"existedfile_length"];
                
                //            float duration = _movie.moviePlayer.duration;
                //            float cur = _movie.moviePlayer.currentPlaybackTime;
                //
                //            NSLog(@"%f",receivedBytes - total*1.0f* cur/duration);
                ////            if (receivedBytes - total*1.0f* cur/duration > 500000 || receivedBytes*1.0/total > 0.8) {
                ////                NSLog(@"play");
                ////                canReplay = NO;
                ////                [_movie.moviePlayer prepareToPlay];
                ////                [_movie.moviePlayer play];
                ////            }else [_movie.moviePlayer pause];
                
                if (!isPlay && _receivedBytes > 30000) {
                    isPlay = YES;
                    _isVideoReady = YES;
                    
                    [self playVideo:videoName];
                    //if(_movie) [_movie.moviePlayer play];
                }
            }];
            
            [request setCompletionBlock:^{
                
                [fileManager copyItemAtPath:[cachePath stringByAppendingPathComponent:videoName] toPath:[webPath stringByAppendingPathComponent:videoName] error:nil];
                if (totalBytes != 0) [[NSUserDefaults standardUserDefaults] setDouble:totalBytes forKey:@"file_length"];
                [[NSUserDefaults standardUserDefaults] setDouble:_receivedBytes forKey:@"existedfile_length"];
                if(!isPlay){
                    isPlay = YES;
                    _isVideoReady = YES;
                    [self playVideo:videoName];
                }
                
            }];
            //断点续载
            [request setAllowResumeForFileDownloads:YES];
            [request startAsynchronous];
            videoRequest = request;
            
        }

    }
}



- (void)playVideo:(NSString*)videoName{
    MTMPMoviePlayerViewController *playerViewController =[[MTMPMoviePlayerViewController alloc]initWithContentURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://127.0.0.1:12345/%@",videoName]]];
    playerViewController.moviePlayer.controlStyle = MPMovieControlStyleFullscreen;
    _movie = playerViewController;
    [_movie.moviePlayer prepareToPlay];
    _movie.moviePlayer.movieSourceType = MPMovieSourceTypeFile;
    _movie.moviePlayer.shouldAutoplay = YES;
    //[_movie.moviePlayer play];
    //[playerViewController.moviePlayer pause];
    [self.controller presentMoviePlayerViewControllerAnimated:playerViewController];
    [[NSNotificationCenter defaultCenter]addObserver:self
     
                                            selector:@selector(movieFinishedCallback:)
     
                                                name:MPMoviePlayerPlaybackDidFinishNotification
     
                                              object:playerViewController.moviePlayer];
}

//-(void)openmovie:(NSString*)url
//{
//
//    MTMPMoviePlayerViewController *movie = [[MTMPMoviePlayerViewController alloc]initWithContentURL:[NSURL URLWithString:url]];
//    
//    [movie.moviePlayer prepareToPlay];
//    [self.controller presentMoviePlayerViewControllerAnimated:movie];
//    [movie.moviePlayer setControlStyle:MPMovieControlStyleFullscreen];
//    [movie.view setBackgroundColor:[UIColor clearColor]];
//    
//    [movie.view setFrame:self.controller.navigationController.view.bounds];
//    [[NSNotificationCenter defaultCenter]addObserver:self
//     
//                                           selector:@selector(movieFinishedCallback:)
//     
//                                               name:MPMoviePlayerPlaybackDidFinishNotification
//     
//                                             object:movie.moviePlayer];
//    
//}
-(void)movieFinishedCallback:(NSNotification*)notify{
    // 视频播放完或者在presentMoviePlayerViewControllerAnimated下的Done按钮被点击响应的通知。
    
    MPMoviePlayerController* theMovie = [notify object];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self
     
                                                  name:MPMoviePlayerPlaybackDidFinishNotification
     
                                                object:theMovie];
    

//    planb
    NSString *CacheDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *webPath = [CacheDirectory stringByAppendingPathComponent:@"VideoTemp"];
    NSString *filePath = [webPath stringByAppendingPathComponent:[_videoInfo valueForKey:@"video_name"]];
    [videoRequest clearDelegatesAndCancel];
    videoRequest = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath]) {
        [fileManager removeItemAtPath:filePath error:nil];
    }
    _controller.canPlay = YES;
}


@end
