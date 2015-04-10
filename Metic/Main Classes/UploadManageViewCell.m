//
//  UploadManageViewCell.m
//  WeShare
//
//  Created by 俊健 on 15/4/10.
//  Copyright (c) 2015年 WeShare. All rights reserved.
//

#import "UploadManageViewCell.h"
#import "UploadManageViewController.h"
#import "UIImageView+WebCache.h"
#import "uploaderOperation.h"
#import "UploaderManager.h"
#import "CommonUtils.h"
#import "MTprogressView.h"

typedef enum {
    UPLOAD_UNKNOWN = -1,        ///<状态未知
    UPLOAD_WAITING = 0,        ///<上传等待
    UPLOAD_EXECUTING = 1,        ///<上传中
    UPLOAD_FINISH = 2,			///<上传完成
    UPLOAD_FAIL = 3,		///<上传失败
}uploadState;

@interface UploadManageViewCell ()
@property (strong, nonatomic) UIImageView *imgView;
@property (strong, nonatomic) NSNumber *photo_id;
@property (strong, nonatomic) NSString *photoName;
@property (nonatomic,weak) uploaderOperation *uploadTask;
@property (nonatomic,strong) UIView* progressView;
@property (nonatomic,strong) NSTimer* timer;
@property uploadState uploadState;
@property float progress;
@end


@implementation UploadManageViewCell

- (void)applyData:(NSMutableDictionary *)photoInfo
{
    self.hidden = NO;
    self.alpha = 1.0f;
    _photoInfo = photoInfo;
    _photoName = [photoInfo valueForKey:@"imgName"];
    NSString* url = [photoInfo valueForKey:@"url"];
    if (!_imgView) {
        _imgView = [[UIImageView alloc]initWithFrame:self.bounds];
        [self addSubview:_imgView];
    }
    [_imgView setClipsToBounds:YES];
    [_imgView setContentMode:UIViewContentModeScaleAspectFit];
    [_imgView setBackgroundColor:[UIColor colorWithWhite:204.0/255 alpha:1.0f]];
    [_imgView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"活动图片的默认图片"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (image) {
            [_imgView setContentMode:UIViewContentModeScaleAspectFill];
        }else{
            _imgView.image = [UIImage imageNamed:@"加载失败"];
        }
    }];
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(checkState) userInfo:nil repeats:YES];
    [_timer fire];
}

-(void)checkState
{
    self.uploadState = UPLOAD_UNKNOWN;
    _uploadTask = [[UploaderManager sharedManager].taskswithPhotoName valueForKey:_photoName];
    NSMutableDictionary* realPhotoInfo;
    BOOL isFinished = false;
    BOOL wait = false;
    BOOL isExecuting = false;
    _progress = 0;
    if (_uploadTask) {
        realPhotoInfo = _uploadTask.photoInfo;
        isFinished = _uploadTask.isFinished;
        isExecuting = _uploadTask.executing;
        wait = _uploadTask.wait;
        _progress = _uploadTask.progress;
    }
    if (!_uploadTask || (!realPhotoInfo && (isFinished || !wait))) {
        //上传失败
        self.uploadState = UPLOAD_FAIL;
    }else if(realPhotoInfo){
        //上传完成
        self.uploadState = UPLOAD_FINISH;
    }else if(isExecuting){
        //正在上传
        self.uploadState = UPLOAD_EXECUTING;
    }else{
        //正在等待上传
        self.uploadState = UPLOAD_WAITING;
    }
    [self refreshUI];
    if (self.uploadState == UPLOAD_FINISH || self.uploadState == UPLOAD_FAIL ) {
        if (_timer) {
            [_timer invalidate];
            _timer = nil;
        }
    }
}

-(void)refreshUI
{
    if (!_progressView) {
        _progressView = [[UIView alloc]initWithFrame:self.bounds];
        _progressView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];

        MTprogressView* progreView = [[MTprogressView alloc]initWithFrame:self.bounds];
        progreView.triggersDownloadDidFinishAnimationAutomatically = NO;
        [progreView setTag:330];
        [progreView setHidden:YES];
        progreView.progress = 0;
        [_progressView addSubview:progreView];
        [progreView displayOperationWillTriggerAnimation];
        
        UIButton* retry = [UIButton buttonWithType:UIButtonTypeCustom];
        [retry setFrame:CGRectMake(self.bounds.size.width/2 - 25, self.bounds.size.height/2 - 40, 50, 70)];
        [retry setImage:[UIImage imageNamed:@"重新上传"] forState:UIControlStateNormal];
        [retry setTag:350];
        [retry setHidden:YES];
        [retry addTarget:self action:@selector(retryUploadTask) forControlEvents:UIControlEventTouchUpInside];
        [_progressView addSubview:retry];
        
        UIButton* cancel = [UIButton buttonWithType:UIButtonTypeCustom];
        [cancel setFrame:CGRectMake(self.bounds.size.width - 40, -10, 50, 50)];
        [cancel setImage:[UIImage imageNamed:@"上传任务删除"] forState:UIControlStateNormal];
        [cancel setTag:340];
        [cancel setHidden:YES];
        [cancel addTarget:self action:@selector(cancelUploadTask) forControlEvents:UIControlEventTouchUpInside];
        [_progressView addSubview:cancel];
        
        UILabel* label = [[UILabel alloc]initWithFrame:CGRectMake(0, 50, 50, 20)];
        [label setText:@"重新上传"];
        [label setFont:[UIFont systemFontOfSize:12]];
        [label setTextColor:[UIColor whiteColor]];
        [label setTextAlignment:NSTextAlignmentCenter];
        [retry addSubview:label];
        [self addSubview:_progressView];
    }
    MTprogressView* progreView = (MTprogressView*)[_progressView viewWithTag:330];
    UIButton* cancel = (UIButton*)[_progressView viewWithTag:340];
    UIButton* retry = (UIButton*)[_progressView viewWithTag:350];
    
    if(_uploadState == UPLOAD_WAITING){
        [progreView setHidden:YES];
        [cancel setHidden:YES];
        [retry setHidden:YES];
        [_progressView setHidden:NO];
    }else if(_uploadState == UPLOAD_FAIL){
        [progreView setHidden:YES];
        [cancel setHidden:NO];
        [retry setHidden:NO];
        [_progressView setHidden:NO];
    }else if(_uploadState == UPLOAD_EXECUTING){
        progreView.progress = _progress;
        [progreView setHidden:NO];
        [cancel setHidden:YES];
        [retry setHidden:YES];
        [_progressView setHidden:NO];
    }else{
        progreView.progress = 1.0f;
        [progreView setHidden:NO];
        [UIView animateWithDuration:1 animations:^{
            _progressView.alpha = 0;
        } completion:^(BOOL finished) {
            [_progressView setHidden:YES];
            _progressView.alpha = 1.0f;
        }];
    }
}

-(void)cancelUploadTask
{
    NSLog(@"取消上传任务");
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        self.hidden = YES;
        self.alpha = 1.0f;
        if (_uploadTask && [_photoInfo valueForKey:@"alasset"]) {
            [_uploadTask removeuploadTaskInDB];
        }
        [_uploadManagerView.uploadingPhotos removeObject:self.photoInfo];
        [_uploadManagerView.collelctionView reloadData];
    }];
}

-(void)retryUploadTask
{
    NSLog(@"重试上传任务");
    if ([_photoInfo valueForKey:@"alasset"]) {
        NSString* alassetStr = [_photoInfo valueForKey:@"alasset"];
        NSString* eventId = [_photoInfo valueForKey:@"event_id"];
        NSString* imgName = [_photoInfo valueForKey:@"imgName"];
        [[UploaderManager sharedManager] uploadImageStr:alassetStr eventId:[CommonUtils NSNumberWithNSString:eventId] imageName:imgName];
    }
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(checkState) userInfo:nil repeats:YES];
    [_timer fire];
}

@end
