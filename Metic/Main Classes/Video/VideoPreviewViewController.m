//
//  VideoPreviewViewController.m
//  WeShare
//
//  Created by ligang6 on 14-9-4.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "VideoPreviewViewController.h"
#import "VideoWallViewController.h"
#import "CommonUtils.h"
#import "MTMessageTextView.h"
#import <MediaPlayer/MediaPlayer.h>
#import "MTMPMoviePlayerViewController.h"
#import "MobClick.h"
#import "THProgressView.h"
#import "SVProgressHUD.h"
#import "SDAVAssetExportSession.h"
#import "Reachability.h"
#import "AppDelegate.h"
#import "BOAlertController.h"

#define mp4Quality AVAssetExportPreset640x480

static const CGSize progressViewSize = { 180.0f, 30.0f };

@interface VideoPreviewViewController () <UIAlertViewDelegate>
@property(nonatomic,strong) UIScrollView* scrollView;
@property(nonatomic,strong) MTMessageTextView* textView;
@property(nonatomic,strong) UIView* videoView;
@property(nonatomic,strong) UIButton* videoBtn;
@property(nonatomic,strong) UIButton* confirmBtn;
@property(nonatomic,strong) UIImage* preViewImage;
@property(nonatomic,strong) UIView* waitingView;
@property(nonatomic,strong) THProgressView *progressView;
@property(nonatomic,strong) PhotoGetter *uploader;
@property(nonatomic,strong) UIAlertView *alertView;
@property BOOL isKeyBoard;
@property BOOL hasEncode;
@end

@implementation VideoPreviewViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initData];
    [self initUI];
    [self startLoop];
//    [self encodeVideo];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [MobClick beginLogPageView:@"视频预览"];
    _scrollView.frame = CGRectMake(0, 0, self.view.frame.size.width,self.view.frame.size.height);
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name: @"uploadFile" object:nil];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [MobClick endLogPageView:@"视频预览"];
    [SVProgressHUD dismiss];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [self clearVideoFile];
}

-(void)initData
{
    _preViewImage = [self getVideoPreViewImage:_videoURL];
    _isKeyBoard = NO;
    _hasEncode = NO;
}

-(void)initUI
{
    [CommonUtils addLeftButton:self isFirstPage:NO];
    [self.navigationItem setTitle:@"上传视频"];
    CGFloat colorValue = 242.0/255.0;
    [self.view setBackgroundColor:[UIColor colorWithRed:colorValue green:colorValue blue:colorValue alpha:colorValue]];
    [self.view setAlpha:1];
    
    _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,self.view.frame.size.height)];
    [_scrollView setShowsHorizontalScrollIndicator:NO];
    [_scrollView setShowsVerticalScrollIndicator:NO];
    [_scrollView setBounces:NO];
    _scrollView.delegate = self;
    [self.view addSubview:_scrollView];
    
    _textView = [[MTMessageTextView alloc]initWithFrame:CGRectMake(10, 10, 300, 60)];
    [_textView setBackgroundColor:[UIColor whiteColor]];
    [_textView.layer setCornerRadius:4];
    _textView.layer.masksToBounds = YES;
    [_textView setFont:[UIFont systemFontOfSize:16]];
    _textView.delegate = self;
    _textView.placeHolder = @"这一刻的想法...";
    [_scrollView addSubview:_textView];
    
    _videoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_videoBtn setFrame:CGRectMake(0, 0, 300,300)];
    if (_preViewImage) {
//        [_videoBtn setFrame:CGRectMake(0, 0, 300,_preViewImage.size.height * 300/_preViewImage.size.width)];
        [_videoBtn setImage:_preViewImage forState:UIControlStateNormal];
        [_videoBtn.imageView setContentMode:UIViewContentModeScaleAspectFill];
    }else{
        [_videoBtn setBackgroundImage:[CommonUtils createImageWithColor:[UIColor lightGrayColor]] forState:UIControlStateNormal];
        [_videoBtn setBackgroundImage:[CommonUtils createImageWithColor:[CommonUtils colorWithValue:0x909090]] forState:UIControlStateHighlighted];
    }
    
    _videoView = [[UIView alloc]initWithFrame:CGRectMake(10, 80, _videoBtn.frame.size.width, _videoBtn.frame.size.height)];
    [_scrollView addSubview:_videoView];
    
    [_videoBtn addTarget:self action:@selector(play:) forControlEvents:UIControlEventTouchUpInside];
    [_videoView addSubview:_videoBtn];
    
    UIImageView* videoIc = [[UIImageView alloc]initWithFrame:CGRectMake((300-75)/2, (_videoBtn.frame.size.height -75)/2, 75,75)];
    [videoIc setUserInteractionEnabled:NO];
    videoIc.image = [UIImage imageNamed:@"视频按钮"];
    [_videoView addSubview:videoIc];
    
    UIView* rightView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 71, 33)];
    [rightView setBackgroundColor:[UIColor clearColor]];
    
    UIButton* rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn setFrame:CGRectMake(0, 0, 90, 33)];
    [rightBtn setImage:[UIImage imageNamed:@"头部小按钮"] forState:UIControlStateNormal];
    [rightBtn setImage:[UIImage imageNamed:@"头部小按钮按下效果"] forState:UIControlStateHighlighted];
    [rightBtn setTitle:@"" forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(confirm:) forControlEvents:UIControlEventTouchUpInside];
    _confirmBtn = rightBtn;
    [rightView addSubview:rightBtn];
    
    UILabel* label = [[UILabel alloc]initWithFrame:CGRectMake(30, 5, 42, 21)];
    [label setFont:[UIFont systemFontOfSize:15]];
    label.text = @"确定";
    [label setTextColor:[CommonUtils colorWithValue:0xf2f2f2]];
    [rightView addSubview:label];
    
    UIBarButtonItem *rightBtnItem=[[UIBarButtonItem alloc]initWithCustomView:rightView];
    self.navigationItem.rightBarButtonItem = rightBtnItem;
}

- (void)startLoop {
    __weak typeof(self) weakSelf = self;
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC, 1 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(timer, ^{
        if (weakSelf) {
            [UIApplication sharedApplication].idleTimerDisabled = NO;
            [UIApplication sharedApplication].idleTimerDisabled = YES;
        } else {
            [UIApplication sharedApplication].idleTimerDisabled = YES;
            [UIApplication sharedApplication].idleTimerDisabled = NO;
            dispatch_source_cancel(timer);
        }
    });
    dispatch_resume(timer);
}

//返回上一层
-(void)MTpopViewController{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)confirm:(id)sender
{
    [sender setEnabled:NO];
    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == 0){
        [CommonUtils showSimpleAlertViewWithTitle:@"提示" WithMessage:@"未连接网络" WithDelegate:nil WithCancelTitle:@"确定"];
        [sender setEnabled:YES];
        return;
    }
    if (!_hasEncode) {
        MTLOG(@"开始转码");
        [self encodeVideo];
    }else{
        MTLOG(@"开始上传");
        [self upload];
    }
    
}

- (void)upload
{
    
    [_textView resignFirstResponder];
    [self showWaitingView];
    self.uploader = [[PhotoGetter alloc]initUploadMethod:self.preViewImage type:1];
    self.uploader.mDelegate = self;
    [self.uploader uploadVideoThumb];
}

- (void)encodeVideo
{
    [_textView resignFirstResponder];
    [SVProgressHUD showWithStatus:@"视频处理中,请稍候" maskType:SVProgressHUDMaskTypeBlack];

    // output file
    NSString* docFolder = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString* outputPath = [docFolder stringByAppendingPathComponent:@"tmp.mp4"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:outputPath])
        [[NSFileManager defaultManager] removeItemAtPath:outputPath error:nil];
    
    // input file
    //AVAsset* asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:filePath]];
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:_videoURL options:nil];
    
    SDAVAssetExportSession *encoder = [SDAVAssetExportSession.alloc initWithAsset:asset];
    encoder.shouldOptimizeForNetworkUse = YES;
    encoder.outputFileType = AVFileTypeMPEG4;
    encoder.outputURL = [NSURL fileURLWithPath:outputPath];
    NSNumber* width,*height;
    AVAssetTrack* videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    
    CGFloat widthValue = videoTrack.naturalSize.width;
    CGFloat heightValue = videoTrack.naturalSize.height;
    
//    CGFloat maxWidth = 640.0;
    CGFloat maxHeight = 720;
    
    CGFloat heightRatio;
    
    if (widthValue > heightValue) {
//        widthRatio = maxWidth / widthValue;
        heightRatio = maxHeight / heightValue;
    } else {
        heightRatio = maxHeight / widthValue;
//        heightRatio = maxWidth / heightValue;
    }
    
//    CGFloat ratio = MIN(widthRatio, heightRatio);
    if (heightRatio < 1) {
        widthValue = ceil(widthValue * heightRatio);
        heightValue = ceil(heightValue * heightRatio);
    }
    
    NSNumber *MTBitRateLow = @800000;
    NSNumber *MTBitRateHigh = @1200000;
    
    NSNumber *bitRate = MTBitRateLow;
    if (MIN(widthValue, heightValue) == maxHeight) {
        bitRate = MTBitRateHigh;
    }
    
    if (_preViewImage.size.height > _preViewImage.size.width && videoTrack.naturalSize.height < videoTrack.naturalSize.width){
        encoder.isVerticalVideo = YES;
        width = [NSNumber numberWithFloat:heightValue];
        height = [NSNumber numberWithFloat:widthValue];
    }
    else{
        encoder.isVerticalVideo = NO;
        width = [NSNumber numberWithFloat:widthValue];
        height = [NSNumber numberWithFloat:heightValue];
    }
    encoder.videoSettings = @
    {
        
    AVVideoCodecKey: AVVideoCodecH264,
    AVVideoWidthKey: width,
    AVVideoHeightKey: height,
    AVVideoCompressionPropertiesKey: @
        {
        AVVideoAverageNonDroppableFrameRateKey:@15,
        AVVideoAverageBitRateKey: bitRate,
        AVVideoProfileLevelKey: AVVideoProfileLevelH264HighAutoLevel,
        },
    };
    
    encoder.audioSettings = @
    {
    AVFormatIDKey: @(kAudioFormatMPEG4AAC),
    AVNumberOfChannelsKey: @2,
    AVSampleRateKey: @44100,
    AVEncoderBitRateKey: @128000,
    };
    
    [encoder exportAsynchronouslyWithCompletionHandler:^
     {
         NSString *path = [[_videoURL absoluteString] substringFromIndex:16];
         if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
             [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
         }
         _videoURL = nil;
         NSString* docFolder = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
         NSString* outputPath = [docFolder stringByAppendingPathComponent:@"tmp.mp4"];
         _videoURL = [NSURL fileURLWithPath:outputPath];
         if (encoder.status == AVAssetExportSessionStatusCompleted)
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 [SVProgressHUD dismissWithSuccess:@"转码成功" afterDelay:1.0f];
                 dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.2f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                     [self upload];
                 });
             });
             _hasEncode = YES;
             MTLOG(@"Video export succeeded");
         }
         else if (encoder.status == AVAssetExportSessionStatusCancelled)
         {
             MTLOG(@"Video export cancelled");
             _confirmBtn.enabled = YES;
         }
         else
         {
             dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                 [SVProgressHUD dismiss];
                 [CommonUtils showSimpleAlertViewWithTitle:@"提示" WithMessage:@"视频无法处理" WithDelegate:nil WithCancelTitle:@"确定"];
                 [self.navigationController popViewControllerAnimated:YES];
             });
             [self clearVideoFile];
         }
     }];
}

- (void)clearVideoFile {
    NSFileManager *fileManager=[NSFileManager defaultManager];
    if (self.videoURL) {
        [fileManager removeItemAtURL:self.videoURL error:nil];
    }
}

-(void)play:(id)sender
{
    if (_isKeyBoard) {
        [_textView resignFirstResponder];
        return;
    }else if(!_confirmBtn.isEnabled){
        return;
    }
    MTMPMoviePlayerViewController *movie = [[MTMPMoviePlayerViewController alloc]initWithContentURL:_videoURL];
    [movie.moviePlayer prepareToPlay];
    [self presentMoviePlayerViewControllerAnimated:movie];
    [movie.moviePlayer setControlStyle:MPMovieControlStyleFullscreen];
    [movie.view setBackgroundColor:[UIColor clearColor]];
    [movie.view setFrame:self.navigationController.view.bounds];
    [[NSNotificationCenter defaultCenter] removeObserver:movie
                                                    name:MPMoviePlayerPlaybackDidFinishNotification object:movie.moviePlayer];
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(movieFinishedCallback:)
                                                name:MPMoviePlayerPlaybackDidFinishNotification
                                              object:movie.moviePlayer];
}

-(void)showWaitingView
{
    if (!_waitingView) {
        CGRect frame = [UIScreen mainScreen].bounds;
        _waitingView = [[UIView alloc] initWithFrame:frame];
        [_waitingView setBackgroundColor:[UIColor blackColor]];
        [_waitingView setAlpha:0.7f];
        [self.view addSubview:_waitingView];
        
        _progressView = [[THProgressView alloc] initWithFrame:CGRectMake(0, 0, progressViewSize.width, progressViewSize.height)];
        _progressView.center = CGPointMake(_waitingView.center.x - 10, _waitingView.center.y);
        _progressView.borderTintColor = [UIColor whiteColor];
        _progressView.progressTintColor = [UIColor whiteColor];
        [_progressView setProgress:0 animated:NO];
        [_waitingView addSubview:_progressView];
        
        UIButton *cancelUploadBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [cancelUploadBtn setTag:130];
        [cancelUploadBtn setTintColor:[UIColor whiteColor]];
        [cancelUploadBtn setFrame:CGRectMake(0, 0, 28, 28)];
        [cancelUploadBtn setImage:[UIImage imageNamed:@"cancelUpload"] forState:UIControlStateNormal];
        [cancelUploadBtn setTitle:@"" forState:UIControlStateNormal];
        [cancelUploadBtn setCenter:CGPointMake(CGRectGetMaxX(_progressView.frame) + 20, CGRectGetMidY(_progressView.frame))];
        [cancelUploadBtn addTarget:self action:@selector(cancelUpload) forControlEvents:UIControlEventTouchUpInside];
        [cancelUploadBtn setHidden:NO];
        [_waitingView addSubview:cancelUploadBtn];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(modifyProgress:) name: @"uploadFile" object:nil];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"shouldIgnoreTurnToNotifiPage"];
        [[UIApplication sharedApplication].keyWindow addSubview:_waitingView];
    }
    UIView *cancelUploadBtn  = [_waitingView viewWithTag:130];
    [cancelUploadBtn setHidden:NO];
}

-(void)removeWaitingView
{
    if (_waitingView) {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"shouldIgnoreTurnToNotifiPage"];
        [_waitingView removeFromSuperview];
        [[NSNotificationCenter defaultCenter] removeObserver:self name: @"uploadFile" object:nil];
        _waitingView = nil;
    }
    _confirmBtn.enabled = YES;
}

- (void)cancelUpload {
    self.alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"确定要停止上传吗" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"停止上传", nil];
    [self.alertView show];
}

- (void)cannotCancel {
    UIView *cancelUploadBtn  = [_waitingView viewWithTag:130];
    [cancelUploadBtn setHidden:YES];
    [self.alertView dismissWithClickedButtonIndex:self.alertView.cancelButtonIndex animated:YES];
}

-(void)modifyProgress:(id)sender
{
    float progress = [[[sender userInfo] objectForKey:@"progress"] floatValue];
    float finished = [[[sender userInfo] objectForKey:@"finished"] floatValue];
    float weight = [[[sender userInfo] objectForKey:@"weight"] floatValue];
    progress*=(weight+finished);
    if (_progressView) {
        [_progressView setProgress:progress animated:YES];
    }
}

-(void)movieFinishedCallback:(NSNotification*)notify{
    // 视频播放完或者在presentMoviePlayerViewControllerAnimated下的Done按钮被点击响应的通知。
    MPMoviePlayerController* theMovie = [notify object];
    int value = [[notify.userInfo valueForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];
    if (value == MPMovieFinishReasonUserExited) {
        MPMoviePlayerController* theMovie = [notify object];
        
        [[NSNotificationCenter defaultCenter]removeObserver:self
                                                       name:MPMoviePlayerPlaybackDidFinishNotification
                                                     object:theMovie];
        [self dismissMoviePlayerViewControllerAnimated];
    }else if(value == MPMovieFinishReasonPlaybackEnded){
        [theMovie play];
        [theMovie pause];
    }
}

#pragma mark - PhotoGetterDelegate
-(void)finishwithNotification:(UIImageView *)imageView image:(UIImage *)image type:(int)type container:(id)container
{
    if (imageView) {
        imageView.image = image;
    }
    else if (type == 100){
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
        [dictionary setValue:[MTUser sharedInstance].userid forKey:@"id"];
        [dictionary setValue:self.eventId forKey:@"event_id"];
        [dictionary setValue:@"upload" forKey:@"cmd"];
        [dictionary setValue:container[0] forKey:@"video_name"];
        [dictionary setValue:self.textView.text forKey:@"title"];
        MTLOG(@"%@",dictionary);
        HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
        [httpSender sendVideoMessage:dictionary withOperationCode: VIDEOSERVER finshedBlock:^(NSData *rData) {
            if (rData) {
                NSString* temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
                MTLOG(@"received Data: %@",temp);
                NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableContainers error:nil];
                NSNumber *cmd = [response1 valueForKey:@"cmd"];
                MTLOG(@"%@     =   %@",cmd,response1  );
                switch ([cmd intValue]) {
                    case NORMAL_REPLY:
                    {
                        [self cannotCancel];
                        //复制tmp.mp4到videocache文件夹
                        NSString* docFolder = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
                        NSString* mp4path = [docFolder stringByAppendingPathComponent:@"tmp.mp4"];
                        NSString* mp4Thumbpath = [docFolder stringByAppendingPathComponent:@"tmp.mp4.thumb"];
                        NSString *CacheDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
                        NSString *cachePath = [CacheDirectory stringByAppendingPathComponent:@"VideoCache"];
                        NSFileManager *fileManager=[NSFileManager defaultManager];
                        if(![fileManager fileExistsAtPath:cachePath])
                        {
                            [fileManager createDirectoryAtPath:cachePath withIntermediateDirectories:YES attributes:nil error:nil];
                        }
                        NSString* filepath = [cachePath stringByAppendingPathComponent:container[0]];
                        
                        [fileManager copyItemAtPath:mp4path toPath:filepath error:nil];
                        if ([fileManager fileExistsAtPath:mp4path])
                            [fileManager removeItemAtPath:mp4path error:nil];
                        if ([fileManager fileExistsAtPath:mp4Thumbpath])
                            [fileManager removeItemAtPath:mp4Thumbpath error:nil];
                        [self clearVideoFile];
                        
                        [_progressView setProgress:1.0f animated:YES];
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [self removeWaitingView];
                            NSUInteger index = self.navigationController.viewControllers.count - 2;
                            VideoWallViewController* controller = (VideoWallViewController*)self.navigationController.viewControllers[index];
                            controller.shouldReload = YES;
                            [self.navigationController popViewControllerAnimated:YES];
                        });
                        
                        
                    }
                        break;
                    case EVENT_NOT_EXIST:{
                        UIAlertView* alert = [CommonUtils showSimpleAlertViewWithTitle:@"信息" WithMessage:@"您不在此活动中" WithDelegate:self WithCancelTitle:@"确定"];
                        [alert setTag:103];
                        
                        NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:_eventId,@"eventId", nil];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"deleteItem" object:nil userInfo:dict];
                        break;
                    }
                    case NOT_IN_EVENT:{
                        UIAlertView* alert = [CommonUtils showSimpleAlertViewWithTitle:@"信息" WithMessage:@"您不在此活动中" WithDelegate:self WithCancelTitle:@"确定"];
                        [alert setTag:103];
                        
                        NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:_eventId,@"eventId", nil];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"deleteItem" object:nil userInfo:dict];
                        break;
                    }
                    default:
                    {
                        UIAlertView* alert = [CommonUtils showSimpleAlertViewWithTitle:@"信息" WithMessage:@"视频上传失败" WithDelegate:self WithCancelTitle:@"确定"];
                        [alert setTag:102];
                    }
                }
            }
        }];
        
        
    }else if (type == 106){
        UIAlertView* alert = [CommonUtils showSimpleAlertViewWithTitle:@"信息" WithMessage:@"网络异常" WithDelegate:self WithCancelTitle:@"确定"];
        [alert setTag:102];
    }
}

#pragma mark - private Method

- (NSInteger) getFileSize:(NSString*) path
{
    NSFileManager * filemanager = [[NSFileManager alloc]init];
    if([filemanager fileExistsAtPath:path]){
        NSDictionary * attributes = [filemanager attributesOfItemAtPath:path error:nil];
        NSNumber *theFileSize;
        if ( (theFileSize = [attributes objectForKey:NSFileSize]) )
            return  [theFileSize intValue]/1024;
        else
            return -1;
    }
    else
    {
        return -1;
    }
}

- (CGFloat) getVideoDuration:(NSURL*) URL
{
    NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                                                     forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:URL options:opts];
    float second = 0;
    second = urlAsset.duration.value/urlAsset.duration.timescale;
    return second;
}


#pragma mark - UITextView Delegate Method
-(void)textViewDidChange:(UITextView *)textView
{
    CGSize size = _textView.contentSize;
    CGRect frame = _textView.frame;
    frame.size.height = size.height < 50? 60:size.height+10;
    _textView.frame = frame;
    
    frame = _videoView.frame;
    frame.origin.y = _textView.frame.origin.y + _textView.frame.size.height + 10;
    [_videoView setFrame:frame];

    float height = _textView.frame.size.height + _videoView.frame.size.height + 30;
    if (height < self.view.frame.size.height + _scrollView.contentOffset.y) height = self.view.frame.size.height + _scrollView.contentOffset.y;
    [_scrollView setContentSize:CGSizeMake(self.view.bounds.size.width, height)];

}

#pragma mark - Alert Delegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex;{
    // the user clicked OK
    if (buttonIndex == 0)
    {
        if ([alertView tag] == 100) {
            NSUInteger index = self.navigationController.viewControllers.count - 2;
            VideoWallViewController* controller = (VideoWallViewController*)self.navigationController.viewControllers[index];
            controller.shouldReload = YES;
            [self.navigationController popViewControllerAnimated:YES];
            [self clearVideoFile];
        }else if([alertView tag] == 102){
            [_confirmBtn setEnabled:YES];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self removeWaitingView];
            });
        }else if([alertView tag] == 103){
            [_confirmBtn setEnabled:YES];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self removeWaitingView];
                NSArray *naviVC = [self.navigationController.viewControllers copy];
                UIViewController* home = ((AppDelegate*)[UIApplication sharedApplication].delegate).homeViewController;
                if ([naviVC containsObject:home]) {
                    [self.navigationController popToViewController:home animated:YES];
                    [self clearVideoFile];
                }
            });
        }
    }
}

#pragma mark - private Method
- (UIImage*) getVideoPreViewImage:(NSURL*)videoPath
{
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoPath options:nil];
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    gen.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    UIImage *img = [[UIImage alloc] initWithCGImage:image];
    CGImageRelease(image);
    return img;
}
// Handle keyboard show/hide changes
- (void)keyboardWillShow: (NSNotification *)notification
{
    _isKeyBoard = YES;
}

- (void)keyboardWillHide: (NSNotification *)notification
{
    _isKeyBoard = NO;
}

#pragma mark - UIAlertView Delegate 
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != alertView.cancelButtonIndex) {
        [self.uploader cancelUploadViedo];
        [_confirmBtn setEnabled:YES];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self removeWaitingView];
        });
    }
}

@end
