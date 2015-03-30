//
//  PhotoTableViewCell.m
//  Metic
//
//  Created by ligang6 on 14-6-30.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "PhotoTableViewCell.h"
#import "PhotoDetailViewController.h"
#import "UploaderManager.h"
#import "uploaderOperation.h"
#import "TMQuiltView.h"

@interface PhotoTableViewCell ()
@property (nonatomic,strong) UIView* progressView;
@property (nonatomic,weak) uploaderOperation *uploadTask;
@property (nonatomic,strong) NSTimer* timer;

@end

@implementation PhotoTableViewCell


- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    _imgView = [[UIImageView alloc]initWithFrame:CGRectZero];
    _imgView.clipsToBounds = YES;
    [self addSubview:_imgView];
    
    _infoView = [[UIView alloc]initWithFrame:CGRectZero];
    [_infoView setBackgroundColor:[UIColor whiteColor]];
    [self addSubview:_infoView];
    
    UIView* line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 145, 3)];
    [line setBackgroundColor:[UIColor colorWithRed:246.0/255.0 green:92.0/255.0 blue:35.0/255.0 alpha:1.0]];
    [_infoView addSubview:line];
    
    _avatar = [[UIImageView alloc]initWithFrame:CGRectMake(5, 8, 20, 20)];
    [_infoView addSubview:_avatar];
    
    _author = [[UILabel alloc]initWithFrame:CGRectMake(30, 5, 110, 15)];
    _author.font = [UIFont systemFontOfSize:12];
    _author.textColor = [UIColor colorWithWhite:51.0/255.0 alpha:1.0f];
    [_infoView addSubview:_author];
    
    _publish_date = [[UILabel alloc]initWithFrame:CGRectMake(30, 20, 110, 10)];
    _publish_date.font = [UIFont systemFontOfSize:11];
    _publish_date.textColor = [UIColor colorWithWhite:145.0/255.0 alpha:1.0f];
    [_infoView addSubview:_publish_date];
    
    UITapGestureRecognizer* tapRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(button_DetailPressed:)];
    [self.infoView addGestureRecognizer:tapRecognizer];
    
    
    
    
    
    return self;
}



- (void)awakeFromNib
{
    // Initialization code
    UITapGestureRecognizer* tapRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(button_DetailPressed:)];
    [self.infoView addGestureRecognizer:tapRecognizer];
}

- (void)button_DetailPressed:(id)sender {
    NSLog(@"pressed");
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone"
															 bundle: nil];
	PhotoDetailViewController *viewcontroller = [mainStoryboard instantiateViewControllerWithIdentifier: @"PhotoDetailViewController"];
    
    viewcontroller.photoId = self.photo_id;
    viewcontroller.eventId = self.PhotoWall.eventId;
    viewcontroller.eventLauncherId = _PhotoWall.eventLauncherId;
    viewcontroller.photoInfo = self.photoInfo;
    viewcontroller.eventName = _PhotoWall.eventName;
    viewcontroller.controller = self.PhotoWall;
    viewcontroller.type = 2;
    [self.PhotoWall.navigationController pushViewController:viewcontroller animated:YES];

}

-(void)animationBegin
{
    if (_isloading) return;
    [self setAlpha:0.5];
    [UIView beginAnimations:@"shadowViewDisappear" context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDelegate:self];
    self.alpha = 1;
    [UIView commitAnimations];
}

-(void)beginUpdateProgress
{
    if (_isUploading) {
        _uploadTask = [[UploaderManager sharedManager].taskswithPhotoName valueForKey:_photoName];
        if (_timer) {
            [_timer invalidate];
            _timer = nil;
        }
        if (_uploadTask) {
            _timer = [NSTimer scheduledTimerWithTimeInterval:0.2f target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
        }
        int width = [[_photoInfo valueForKey:@"width"] intValue];
        int height = [[_photoInfo valueForKey:@"height"] intValue];
        float RealHeight = height * 145.0f / width + 33;
        
        if (!_progressView) {
            _progressView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 145, RealHeight)];
            _progressView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
            UIActivityIndicatorView* activity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(42.5, RealHeight/2 - 30, 60, 60)];//指定进度轮的大小
            activity.transform = CGAffineTransformMakeScale(1.6, 1.6);
//            activity.layer.borderColor = [UIColor greenColor].CGColor;
//            activity.layer.borderWidth = 2;
            [activity setTag:320];
            [activity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];//设置进度轮显示类型
            [_progressView addSubview:activity];
            [activity startAnimating];
            
            UILabel* progress_numLab = [[UILabel alloc]initWithFrame:CGRectMake(50, RealHeight/2 - 22.5, 45, 45)];
//            progress_numLab.layer.borderColor = [UIColor blueColor].CGColor;
//            progress_numLab.layer.borderWidth = 2;
            [progress_numLab setTag:330];
            progress_numLab.font = [UIFont systemFontOfSize:12];
            progress_numLab.text = @"0%";
            progress_numLab.textAlignment = NSTextAlignmentCenter;
            progress_numLab.textColor = [UIColor colorWithWhite:0.9 alpha:1.0];
            [self.progressView addSubview:progress_numLab];
            
            UIButton* cancel = [UIButton buttonWithType:UIButtonTypeCustom];
            [cancel setFrame:CGRectMake(17, RealHeight/2 - 23.5, 47, 47)];
            cancel.layer.borderColor = [UIColor redColor].CGColor;
            cancel.layer.borderWidth = 2;
            [cancel setTag:340];
            [cancel setHidden:YES];
            [cancel addTarget:self action:@selector(cancelUploadTask) forControlEvents:UIControlEventTouchUpInside];
            [_progressView addSubview:cancel];
            
            UIButton* retry = [UIButton buttonWithType:UIButtonTypeCustom];
            [retry setFrame:CGRectMake(17*2+47, RealHeight/2 - 23.5, 47, 47)];
            retry.layer.borderColor = [UIColor redColor].CGColor;
            retry.layer.borderWidth = 2;
            [retry setTag:350];
            [retry setHidden:YES];
            [retry addTarget:self action:@selector(retryUploadTask) forControlEvents:UIControlEventTouchUpInside];
            [_progressView addSubview:retry];
            
            [self addSubview:_progressView];
        }
        [_progressView setFrame:CGRectMake(0, 0, 145, RealHeight)];
        UIActivityIndicatorView* activity = (UIActivityIndicatorView*)[_progressView viewWithTag:320];
        [activity setFrame:CGRectMake(42.5, RealHeight/2 - 30, 60, 60)];//指定进度轮中心点
        
        UILabel* progress_numLab = (UILabel*)[_progressView viewWithTag:330];
        [progress_numLab setFrame:CGRectMake(50, RealHeight/2 - 22.5, 45, 45)];
        NSNumber* progress = [_photoInfo valueForKey:@"progress"];
        progress_numLab.text = progress? [NSString stringWithFormat:@"%.0f%%",[progress floatValue]*100] : @"0%";
        
        UIButton* cancel = (UIButton*)[_progressView viewWithTag:340];
        [cancel setFrame:CGRectMake(17, RealHeight/2 - 23.5, 47, 47)];
        
        UIButton* retry = (UIButton*)[_progressView viewWithTag:350];
        [retry setFrame:CGRectMake(17*2+47, RealHeight/2 - 23.5, 47, 47)];
        
        NSNumber* isFailed = [_photoInfo valueForKey:@"isFailed"];
        
        if (isFailed && [isFailed boolValue]) {
            [cancel setHidden:NO];
            [retry setHidden:NO];
            [activity stopAnimating];
            [progress_numLab setHidden:YES];
            if (_timer) {
                [_timer invalidate];
                _timer = nil;
            }
        }else{
            [cancel setHidden:YES];
            [retry setHidden:YES];
            [activity startAnimating];
            [progress_numLab setHidden:NO];
        }
    }
}

-(void)stopUpdateProgress
{
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    if (_uploadTask) {
        _uploadTask = nil;
    }
    if (_progressView) {
        [_progressView removeFromSuperview];
        _progressView = nil;
    }
}

-(void)updateProgress
{
    if (!self.PhotoWall) {
        [self stopUpdateProgress];
        return;
    }
    if (_uploadTask) {
        float progress = _uploadTask.progress;
        NSLog(@"updateProgress: %f", progress);
        [_photoInfo setValue:[NSNumber numberWithFloat:progress] forKey:@"progress"];
        if (_progressView) {
            UILabel* progress_numLab = (UILabel*)[_progressView viewWithTag:330];
            if (progress_numLab) {
                progress_numLab.text = [NSString stringWithFormat:@"%.0f%%",_uploadTask.progress*100];
            }
        }
        NSMutableDictionary* realPhotoInfo = _uploadTask.photoInfo;
        BOOL isFinished = _uploadTask.isFinished;
        if (realPhotoInfo) {
            [self stopUpdateProgress];
            [_photoInfo setDictionary:realPhotoInfo];
            self.isUploading = NO;
            
        }else if (isFinished){
            NSLog(@"上传失败");
            if (_progressView) {
                if (_photoInfo) {
                    [_photoInfo setValue:[NSNumber numberWithBool:YES] forKey:@"isFailed"];
                }
                if (_timer) {
                    [_timer invalidate];
                    _timer = nil;
                }
                [self beginUpdateProgress];
            }
        }
    }else NSLog(@"error");
    
}

-(void)cancelUploadTask
{
    NSLog(@"取消上传任务");
}

-(void)retryUploadTask
{
    NSLog(@"重试上传任务");
}

-(void)dealloc
{
    NSLog(@"dealloc");
}
@end
