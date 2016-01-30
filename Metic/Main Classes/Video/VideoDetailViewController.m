//
//  VideoDetailViewController.m
//  WeShare
//
//  Created by ligang6 on 14-9-2.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "VideoDetailViewController.h"
#import "VideoWallViewController.h"
#import "VCommentTableViewCell.h"
#import "HomeViewController.h"
#import "CommonUtils.h"
#import "MobClick.h"
#import "MLEmojiLabel.h"
#import "emotion_Keyboard.h"
#import "UIImageView+MTWebCache.h"
#import <MediaPlayer/MediaPlayer.h>
#import "MTMPMoviePlayerViewController.h"
#import "FriendInfoViewController.h"
#import "UserInfoViewController.h"
#import "DAProgressOverlayView.h"
#import "MTVideoPlayerViewController.h"
#import "UIButton+MTWebCache.h"
#import "MTDatabaseHelper.h"
#import "SVProgressHUD.h"
#import "MegUtils.h"
#import "MTImageGetter.h"
#import "MTOperation.h"
#import "LCAlertView.h"

#define chooseArray @[@[@"举报视频"]]
@interface VideoDetailViewController ()<UMSocialUIDelegate>
@property (nonatomic,strong) MTMPMoviePlayerViewController* movie;
@property (nonatomic,strong) MTMPMoviePlayerViewController *playerViewController;
@property BOOL isVideoReady;
@property (nonatomic,strong)NSNumber* sequence;
@property (nonatomic,strong)UIButton *edit_button;
@property (nonatomic,strong)UIButton *editFinishButton;
@property (nonatomic,strong)UIButton *shareButton;
@property (nonatomic,strong)UIButton *delete_button;
@property (nonatomic,strong)UILabel *specification;
@property (nonatomic,strong)UIButton *shadow;
@property (nonatomic,strong)UITextField *specificationEditTextfield;
@property (nonatomic,strong)NSString *videoShareLink;
@property float specificationHeight;
@property(nonatomic,strong) emotion_Keyboard *emotionKeyboard;
@property (nonatomic,strong) NSNumber* repliedId;
@property (nonatomic,strong) NSString* herName;
@property (strong, nonatomic) DAProgressOverlayView *progressOverlayView;
@property (strong, nonatomic) UIButton *video_button;
@property (strong, nonatomic) UIImageView *videoPlayImg;
@property __block unsigned long long receivedBytes;
@property BOOL shouldExit;
@property BOOL Footeropen;
@property BOOL isLoading;
@property long Selete_section;
@end

@implementation VideoDetailViewController

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
    [CommonUtils addLeftButton:self isFirstPage:NO];
    [self initUI];
    [self initData];
    // Do any additional setup after loading the view.
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [self.inputTextView resignFirstResponder];
    [MobClick beginLogPageView:@"视频详情"];
    self.sequence = [NSNumber numberWithInt:0];
    [self pullMainCommentFromAir];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [MobClick endLogPageView:@"视频详情"];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    if (self.isKeyBoard) {
        [self.inputTextView resignFirstResponder];
        [self keyboardWillHide:nil];
        return;
    }
    if (self.isEmotionOpen) {
        [self button_Emotionpress:nil];
        return;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//返回上一层
-(void)MTpopViewController{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)initUI
{
    self.view.autoresizesSubviews = YES;
    //初始化评论框
    UIView *commentV = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height - 45, self.view.frame.size.width,45)];
    commentV.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [commentV setBackgroundColor:[UIColor whiteColor]];
    _commentView = commentV;
    
    UIButton *emotionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [emotionBtn setFrame:CGRectMake(0, 0, 35, 45)];
    [emotionBtn setImage:[UIImage imageNamed:@"button_emotion"] forState:UIControlStateNormal];
    [emotionBtn addTarget:self action:@selector(button_Emotionpress:) forControlEvents:UIControlEventTouchUpInside];
    [commentV addSubview:emotionBtn];
    
    UIButton *sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [sendBtn setFrame:CGRectMake(282, 5, 35, 35)];
    [sendBtn setImage:[UIImage imageNamed:@"输入框"] forState:UIControlStateNormal];
    [sendBtn addTarget:self action:@selector(publishComment:) forControlEvents:UIControlEventTouchUpInside];
    [commentV addSubview:sendBtn];
    
    [self.view addSubview:commentV];
    
    // 初始化输入框
    MTMessageTextView *textView = [[MTMessageTextView  alloc] initWithFrame:CGRectZero];
    
    // 这个是仿微信的一个细节体验
    textView.returnKeyType = UIReturnKeySend;
    textView.enablesReturnKeyAutomatically = YES; // UITextView内部判断send按钮是否可以用
    
    textView.placeHolder = @"发送新消息";
    textView.delegate = self;
    
    [self.commentView addSubview:textView];
    _inputTextView = textView;
    
    _inputTextView.frame = CGRectMake(38, 5, 240, 35);
    _inputTextView.backgroundColor = [UIColor clearColor];
    _inputTextView.layer.borderColor = [UIColor colorWithWhite:0.8f alpha:1.0f].CGColor;
    _inputTextView.layer.borderWidth = 0.65f;
    _inputTextView.layer.cornerRadius = 6.0f;
    
    //初始化表情面板
    _emotionKeyboard = [[emotion_Keyboard alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width,200)];
    _emotionKeyboard.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:_emotionKeyboard];
    _emotionKeyboard.textView = _inputTextView;
    [_emotionKeyboard initCollectionView];
    
    //右上角按钮
    [self tabbarButtonShare];
    
}

- (void)initData
{
    self.sequence = [NSNumber numberWithInt:0];
    if (_videoInfo) self.videoId = [_videoInfo valueForKey:@"video_id"];
    self.isKeyBoard = NO;
    self.Footeropen = NO;
    self.shouldExit = NO;
    self.isLoading = YES;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.vcomment_list = [[NSMutableArray alloc]init];
    
    if (!_videoInfo) [self pullVideoInfoFromDB];
    [self pullVideoInfoFromAir];
}

#pragma mark - Navigation
- (void)pushToFriendView:(id)sender {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone"
                                                             bundle: nil];
    if ([[self.videoInfo valueForKey:@"author_id"] intValue] == [[MTUser sharedInstance].userid intValue]) {
        UserInfoViewController* userInfoView = [mainStoryboard instantiateViewControllerWithIdentifier: @"UserInfoViewController"];
        userInfoView.needPopBack = YES;
        [self.navigationController pushViewController:userInfoView animated:YES];
        
    }else{
        FriendInfoViewController *friendView = [mainStoryboard instantiateViewControllerWithIdentifier: @"FriendInfoViewController"];
        friendView.fid = [self.videoInfo valueForKey:@"author_id"];
        [self.navigationController pushViewController:friendView animated:YES];
    }
}

- (void)report:(id)sender {
    
    [self performSegueWithIdentifier:@"VideoToReport" sender:self];
}

-(void)back
{
    NSInteger index = self.navigationController.viewControllers.count - 2;
    NSArray * controllers = self.navigationController.viewControllers;
    if (controllers.count > index+1 && [controllers[index] isKindOfClass:[VideoWallViewController class]]) {
        VideoWallViewController* controller = (VideoWallViewController*)self.navigationController.viewControllers[index];
        controller.shouldReload = YES;
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - videoInfo
-(BOOL)pullVideoInfoFromDB
{
    BOOL ret = NO;
    NSArray *seletes = [[NSArray alloc]initWithObjects:@"videoInfo", nil];
    NSDictionary *wheres = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%@",self.videoId],@"video_id", nil];
    //    NSMutableArray *result = [sql queryTable:@"eventVideo" withSelect:seletes andWhere:wheres];
    [[MTDatabaseHelper sharedInstance] queryTable:@"eventVideo" withSelect:seletes andWhere:wheres completion:^(NSMutableArray *resultsArray) {
        if (resultsArray.count) {
            NSString *tmpa = [resultsArray[0] valueForKey:@"videoInfo"];
            NSData *tmpb = [tmpa dataUsingEncoding:NSUTF8StringEncoding];
            self.videoInfo =  [NSJSONSerialization JSONObjectWithData:tmpb options:NSJSONReadingMutableContainers error:nil];
            [self.tableView reloadData];
        }
    }];
    return ret;
}

-(void)pullVideoInfoFromAir
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:[MTUser sharedInstance].userid forKey:@"id"];
    [dictionary setValue:self.videoId forKey:@"video_id"];
    [dictionary setValue:self.eventId forKey:@"event_id"];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    MTLOG(@"拉取视频%@",[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding]);
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:GET_OBJECT_INFO finshedBlock:^(NSData *rData) {
        if(rData){
            NSMutableDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableContainers error:nil];
            NSNumber *cmd = [response1 valueForKey:@"cmd"];
            switch ([cmd intValue]) {
                case NORMAL_REPLY:{
                    if(_videoInfo)[_videoInfo addEntriesFromDictionary:response1];
                    else _videoInfo = response1;
                    [VideoWallViewController updateVideoInfoToDB:@[response1] eventId:_eventId];
                    [_tableView reloadData];
                }
                    break;
                case VIDEO_NOT_EXIST:{
                    if (_shouldExit == NO) {
                        _shouldExit = YES;
                        [self deleteLocalData];
                        UIAlertView *alert = [CommonUtils showSimpleAlertViewWithTitle:@"信息" WithMessage:@"视频已删除" WithDelegate:self WithCancelTitle:@"确定"];
                        [alert setTag:1];
                    }
                }
                    break;
            }
        }
    }];
}

- (void)updateVideoInfo {
    if(_controller && [_controller isKindOfClass:[VideoWallViewController class]]){
        [_controller.tableView reloadRowsAtIndexPaths:@[self.index] withRowAnimation:UITableViewRowAnimationNone];
    }
    [VideoWallViewController updateVideoInfoToDB:@[self.videoInfo] eventId:_eventId];
}

-(void)closeRJ
{
    [self.tableView reloadData];
}

- (void)deleteVideoInfoFromDB
{
    NSDictionary *wheres = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%@",_videoId],@"video_id", nil];
    [[MTDatabaseHelper sharedInstance] deleteTurpleFromTable:@"eventVideo" withWhere:wheres];
}

- (void)deleteLocalData
{
    if (_videoId) {
        [self deleteVideoInfoFromDB];
    }
}

#pragma mark - video play

- (void)play:(id)sender {
    if (_isKeyBoard) {
        [_inputTextView resignFirstResponder];
        return;
    }
    if (_isEmotionOpen) {
        [self button_Emotionpress:nil];
        return;
    }
    if (!_videoInfo) {
        [self pullVideoInfoFromAir];
        return;
    }
    NSString *videoName = [_videoInfo valueForKey:@"video_name"];
    [[MTOperation sharedInstance] getVideoUrlFromServerWith:videoName success:^(NSString *url) {
        if ([[_videoInfo valueForKey:@"video_name"] isEqualToString:videoName]) {
            [self downloadVideo:videoName url:url];
        }
    } failure:^(NSString *message) {
        MTLOG(@"获取视频URL失败");
    }];
}

- (void)downloadVideo:(NSString*)videoName url:(NSString*)url{
    
    NSString *CacheDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *webPath = [CacheDirectory stringByAppendingPathComponent:@"VideoTemp"];
    NSString *cachePath = [CacheDirectory stringByAppendingPathComponent:@"VideoCache"];
    
    if([url isEqualToString:@"existed"]) {
        
        _playerViewController = [[MTMPMoviePlayerViewController alloc]initWithContentURL:[NSURL fileURLWithPath:[cachePath stringByAppendingPathComponent:videoName]]];
        
        _playerViewController.moviePlayer.controlStyle = MPMovieControlStyleFullscreen;
        [self presentMoviePlayerViewControllerAnimated:_playerViewController];
        [[NSNotificationCenter defaultCenter] removeObserver:_playerViewController
                                                        name:MPMoviePlayerPlaybackDidFinishNotification object:_playerViewController.moviePlayer];
        [[NSNotificationCenter defaultCenter] addObserver:self
         
                                                 selector:@selector(movieFinishedCallback:)
         
                                                     name:MPMoviePlayerPlaybackDidFinishNotification
         
                                                   object:_playerViewController.moviePlayer];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playTheMPMoviePlayer:) name: @"playTheMPMoviePlayer" object:nil];
        
        videoRequest = nil;
    }else{
        if (videoRequest){
            return;
        }
        
        if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == 0) {
            MTLOG(@"没有网络");
            return;
        }
        else{
            __block unsigned long long totalBytes = 0;
            _receivedBytes = 0;
            
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
                if (!(self.navigationController.viewControllers.lastObject == self)) {
                    [self clearVideoRequest];
                }
            }];
            
            [request setCompletionBlock:^{
                [self closeProgressOverlayView];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    // my video player
                    if (self && self.navigationController.viewControllers.lastObject == self ) {
                        [self downloadVideo:videoName url:url];
                    }
                });
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
        self.progressOverlayView.hidden = YES;
        [self closeProgressOverlayView];
        [videoRequest clearDelegatesAndCancel];
        videoRequest = nil;
    }
}

- (void)playVideo:(NSString*)videoName{
    MTMPMoviePlayerViewController *playerViewController =[[MTMPMoviePlayerViewController alloc]initWithContentURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://127.0.0.1:12345/%@",videoName]]];
    playerViewController.moviePlayer.controlStyle = MPMovieControlStyleFullscreen;
    _movie = playerViewController;
    [_movie.moviePlayer prepareToPlay];
    _movie.moviePlayer.movieSourceType = MPMovieSourceTypeFile;
    _movie.moviePlayer.shouldAutoplay = YES;
    [self presentMoviePlayerViewControllerAnimated:playerViewController];
    [[NSNotificationCenter defaultCenter]addObserver:self
     
                                            selector:@selector(movieFinishedCallback:)
     
                                                name:MPMoviePlayerPlaybackDidFinishNotification
     
                                              object:playerViewController.moviePlayer];
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

#pragma mark - Function
- (IBAction)button_Emotionpress:(id)sender {
    if(!_canManage)return;
    if (!_emotionKeyboard) {
        _emotionKeyboard = [[emotion_Keyboard alloc]initWithPoint:CGPointMake(0, self.view.frame.size.height - 200)];
    }
    if (!_isEmotionOpen) {
        _isEmotionOpen = YES;
        if (_isKeyBoard) {
            [_inputTextView resignFirstResponder];
        }
        CGRect keyboardBounds = _emotionKeyboard.frame;
        // get a rect for the textView frame
        CGRect containerFrame = self.commentView.frame;
        containerFrame.origin.y = self.view.bounds.size.height - (keyboardBounds.size.height + containerFrame.size.height);
        // animations settings
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:0.25];
        [UIView setAnimationCurve:7];
        
        // set views with new info
        self.commentView.frame = containerFrame;
        CGRect frame = _emotionKeyboard.frame;
        frame.origin.y = self.view.frame.size.height - frame.size.height;
        [_emotionKeyboard setFrame:frame];
        
        // commit animations
        [UIView commitAnimations];
    }else {
        [self hiddenCommentViewAndEmotionView];
    }
}

- (void)hiddenCommentViewAndEmotionView {
    _isEmotionOpen = NO;
    CGRect containerFrame = self.commentView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - containerFrame.size.height;
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.25];
    [UIView setAnimationCurve:7];
    self.commentView.frame = containerFrame;
    CGRect frame = _emotionKeyboard.frame;
    frame.origin.y = self.view.frame.size.height;
    [_emotionKeyboard setFrame:frame];
    [UIView commitAnimations];
}

-(void)editSpecification:(UIButton*)button
{
    if (!_canManage) return;
    //进入编辑模式
    if (!self.specificationEditTextfield) {
        [self hiddenCommentViewAndEmotionView];
        self.specification.hidden = YES;
        
        [self tabbarButtonEdit];
        self.tableView.scrollEnabled = NO;
        float height = _video_thumb? self.video_thumb.size.height *320.0/self.video_thumb.size.width:180;
        [self.tableView setContentOffset:CGPointMake(0, height) animated:YES];
        if (!self.shadow) {
            UIButton *shadow = [UIButton buttonWithType:UIButtonTypeCustom];
            shadow.frame = self.view.bounds;
            [shadow addTarget:self action:@selector(editSpecification:) forControlEvents:UIControlEventTouchUpInside];
            shadow.userInteractionEnabled = YES;
            self.shadow = shadow;
        }
        [self.view addSubview:self.shadow];
        
        if (!self.specificationEditTextfield) {
            CGRect textfieldFrame = self.specification.frame;
            textfieldFrame.size.height = 30;
            textfieldFrame.origin.y = CGRectGetMinY(self.specification.frame) - height;
            UITextField* specificationEditTextfield = [[UITextField alloc]initWithFrame:textfieldFrame];
            specificationEditTextfield.placeholder = @"请输入新的视频描述";
            [specificationEditTextfield setFont:[UIFont systemFontOfSize:12]];
            specificationEditTextfield.text = [self.videoInfo valueForKey:@"title"];
            [specificationEditTextfield setBackgroundColor:[UIColor whiteColor]];
            specificationEditTextfield.hidden = YES;
            specificationEditTextfield.layer.borderColor = [UIColor colorWithWhite:0.9f alpha:1.0f].CGColor;
            specificationEditTextfield.layer.borderWidth = 1;
            specificationEditTextfield.layer.cornerRadius = 4;
            specificationEditTextfield.layer.masksToBounds = YES;
            specificationEditTextfield.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, 10)];
            specificationEditTextfield.leftViewMode = UITextFieldViewModeAlways;
            specificationEditTextfield.rightView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, 10)];
            specificationEditTextfield.rightViewMode = UITextFieldViewModeAlways;
            self.specificationEditTextfield = specificationEditTextfield;
        }
        [self.shadow addSubview:self.specificationEditTextfield];
        [self.specificationEditTextfield becomeFirstResponder];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.specificationEditTextfield.hidden = NO;
        });
    } else {
        
        [self.specificationEditTextfield removeFromSuperview];
        [self.specificationEditTextfield resignFirstResponder];
        self.specificationEditTextfield = nil;
        [self.shadow removeFromSuperview];
        self.specification.hidden = NO;
        [self tabbarButtonShare];
        self.tableView.scrollEnabled = YES;
        [self.tableView setContentOffset:CGPointZero animated:YES];
    }
}

- (void)finishEdit {
    [self.specificationEditTextfield resignFirstResponder];
    NSString *newSpecification = self.specificationEditTextfield.text;
    if (!newSpecification) {
        [SVProgressHUD showErrorWithStatus:@"请输入图片描述" duration:1.f];
        return;
    }
    [SVProgressHUD showWithStatus:@"请稍候" maskType:SVProgressHUDMaskTypeBlack];
    [[MTOperation sharedInstance] modifyVideoSpecification:newSpecification withVideoId:self.videoId eventId:self.eventId success:^{
        [SVProgressHUD dismissWithSuccess:@"修改成功" afterDelay:1.f];
        self.specification.text = newSpecification;
        [self.videoInfo setValue:newSpecification forKey:@"title"];
        [self updateVideoInfo];
        [self editSpecification:nil];
    } failure:^(NSString *message) {
        [SVProgressHUD dismissWithError:message afterDelay:1.f];
    }];
}

- (void)tabbarButtonEdit {
    if (!self.editFinishButton) {
        self.editFinishButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.editFinishButton setFrame:CGRectMake(10, 2.5f, 51, 28)];
        [self.editFinishButton setBackgroundImage:[UIImage imageNamed:@"小按钮绿色"] forState:UIControlStateNormal];
        [self.editFinishButton setTitle:@"确定" forState:UIControlStateNormal];
        [self.editFinishButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [self.editFinishButton.titleLabel setLineBreakMode:NSLineBreakByClipping];
        [self.editFinishButton addTarget:self action:@selector(finishEdit) forControlEvents:UIControlEventTouchUpInside];
    }
    UIBarButtonItem *rightButtonItem=[[UIBarButtonItem alloc]initWithCustomView:self.editFinishButton];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
}

- (void)tabbarButtonShare {
    if (!self.shareButton) {
        self.shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.shareButton setFrame:CGRectMake(20, 0, 70, 40)];
        [self.shareButton setImageEdgeInsets:UIEdgeInsetsMake(7, 14, 7, 0)];
        [self.shareButton setImage:[UIImage imageNamed:@"video_share_btn"] forState:UIControlStateNormal];
        [self.shareButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [self.shareButton addTarget:self action:@selector(shareVideo) forControlEvents:UIControlEventTouchUpInside];
    }
    UIView *container = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 70, 40)];
    [container addSubview:self.shareButton];
    UIBarButtonItem *rightButtonItem=[[UIBarButtonItem alloc]initWithCustomView:container];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
}

- (void)shareVideo {
    void (^share)(NSString *shareLink) = ^(NSString *shareLink){
        NSString *user = [MTUser sharedInstance].name;
        if (!user || ![user isKindOfClass:[NSString class]]) {
            user = @"";
        } else {
            user =  [NSString stringWithFormat:@"【%@】", user];
        }
        NSString *shareText = [NSString stringWithFormat:@"%@分享了活动宝的一个视频给你，点击观看", user];
        
        [UMSocialData defaultData].extConfig.wechatSessionData.url = shareLink;
        [UMSocialData defaultData].extConfig.wechatTimelineData.url = shareLink;
        [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeWeb;
        [UMSocialData defaultData].extConfig.qqData.qqMessageType = UMSocialQQMessageTypeDefault;
        [UMSocialData defaultData].extConfig.qqData.url = shareLink;
        [[UMSocialData defaultData].extConfig.sinaData setUrlResource:[[UMSocialUrlResource alloc] initWithSnsResourceType:UMSocialUrlResourceTypeVideo url:shareLink]];

        [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeWeb;
        [UMSocialConfig hiddenNotInstallPlatforms:@[UMShareToQQ,UMShareToSina,UMShareToWechatSession,UMShareToWechatFavorite,UMShareToWechatTimeline]];
        [UMSocialSnsService presentSnsIconSheetView:self
                                             appKey:@"53bb542e56240ba6e80a4bfb"
                                          shareText:shareText
                                         shareImage:self.video_thumb?self.video_thumb:[UIImage imageNamed:@"AppIcon57x57"]
                                    shareToSnsNames:@[UMShareToWechatSession,UMShareToWechatTimeline,UMShareToQQ,UMShareToSina]
                                           delegate:self];
        [UMSocialData defaultData].extConfig.wechatSessionData.title = @"【活动宝视频分享】";
    };
    
    if ([self.videoShareLink isKindOfClass:[NSString class]] && ![self.videoShareLink isEqualToString:@""]) {
        share(self.videoShareLink);
    } else {
        [SVProgressHUD showWithStatus:@"请稍候" maskType:SVProgressHUDMaskTypeBlack];
        [[MTOperation sharedInstance] getVideoShareLinkEventId:self.eventId videoId:self.videoId success:^(NSString *shareLink) {
            self.videoShareLink = shareLink;
            [SVProgressHUD dismiss];
            share(shareLink);
        } failure:^(NSString *message) {
            [SVProgressHUD dismissWithError:message afterDelay:1.5f];
        }];
    }
}

-(void)deleteVideo:(UIButton*)button
{
    if(!_canManage)return;
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"确定要删除这段视频？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert setTag:100];
    [alert show];
}

#pragma 长按菜单
-(void)showOption:(UIGestureRecognizer*)sender
{
    if (sender.state != UIGestureRecognizerStateBegan) return;
    NSNumber* authorId = [self.videoInfo valueForKey:@"author_id"];
    if ([authorId integerValue] == [[MTUser sharedInstance].userid integerValue]) {

    }else{
        LCAlertView *alert = [[LCAlertView alloc]initWithTitle:@"操作" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"举报",nil];
        alert.alertAction = ^(NSInteger buttonIndex){
            if (buttonIndex == 1) {
                [self report:nil];
            }
        };
        [alert show];
    }
}

#pragma mark - 评论
- (void)pullMainCommentFromAir
{
    _isLoading = YES;
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:[MTUser sharedInstance].userid forKey:@"id"];
    long sequence = [self.sequence longValue];
    [dictionary setValue:self.sequence forKey:@"sequence"];
    [dictionary setValue:self.videoId forKey:@"video_id"];
    MTLOG(@"%@",dictionary);
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:GET_VCOMMENTS finshedBlock:^(NSData *rData) {
        if(rData){
            NSString* temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
            MTLOG(@"received Data: %@",temp);
            NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
            NSNumber *cmd = [response1 valueForKey:@"cmd"];
            switch ([cmd intValue]) {
                case NORMAL_REPLY:
                {
                    if ([response1 valueForKey:@"vcomment_list"]) {
                        NSMutableArray *newComments = [[NSMutableArray alloc]initWithArray:[response1 valueForKey:@"vcomment_list"]];
                        if ([_sequence longValue] == sequence) {
                            if (sequence == 0) [self.vcomment_list removeAllObjects];
                            [self.vcomment_list addObjectsFromArray:newComments] ;
                            if (newComments.count < 10) _sequence = [NSNumber numberWithInteger:-1];
                            else self.sequence = [response1 valueForKey:@"sequence"];
                        }
                        _isLoading = NO;
                        [self.tableView reloadData];
                    }
                }
                    break;
                case VIDEO_NOT_EXIST:{
                    if (_shouldExit == NO) {
                        _shouldExit = YES;
                        [self deleteLocalData];
                        UIAlertView *alert = [CommonUtils showSimpleAlertViewWithTitle:@"信息" WithMessage:@"视频已删除" WithDelegate:self WithCancelTitle:@"确定"];
                        [alert setTag:1];
                    }
                }
                    break;
                default:
                {
                    [CommonUtils showSimpleAlertViewWithTitle:@"信息" WithMessage:@"网络异常" WithDelegate:self WithCancelTitle:@"确定"];
                }
            }
        }
        _isLoading = NO;
    }];
}

-(void)resendComment:(id)sender
{
    if (!_videoInfo) return;
    id cell = [sender superview];
    while (![cell isKindOfClass:[UITableViewCell class]] ) {
        cell = [cell superview];
    }
    
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    if (!indexPath) {
        return;
    }
    
    NSString *comment = ((VCommentTableViewCell*)cell).comment.text;
    NSInteger row = indexPath.row;
    NSDictionary* waitingComment = ([_sequence integerValue] == -1)? self.vcomment_list[_vcomment_list.count - row ]:self.vcomment_list[_vcomment_list.count - row + 1];
    [waitingComment setValue:[NSNumber numberWithInt:-1] forKey:@"vcomment_id"];
    
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:[MTUser sharedInstance].userid forKey:@"id"];
    [dictionary setValue:self.videoId forKey:@"video_id"];
    [dictionary setValue:self.eventId forKey:@"event_id"];
    [dictionary setValue:comment forKey:@"content"];
    [dictionary setValue:[waitingComment valueForKey:@"replied"] forKey:@"replied"];
    
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    
    void (^resendCommentBlock)(void) = ^(void){
        //再次发送评论
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
        MTLOG(@"%@",[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding]);
        HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
        [httpSender sendMessage:jsonData withOperationCode:ADD_VCOMMENT finshedBlock:^(NSData *rData) {
            dispatch_barrier_async(dispatch_get_main_queue(), ^{
                if (rData) {
                    NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
                    NSNumber *cmd = [response1 valueForKey:@"cmd"];
                    if ([cmd intValue] == VIDEO_NOT_EXIST) {
                        if (_shouldExit == NO) {
                            _shouldExit = YES;
                            [self deleteLocalData];
                            UIAlertView *alert = [CommonUtils showSimpleAlertViewWithTitle:@"信息" WithMessage:@"视频已删除" WithDelegate:self WithCancelTitle:@"确定"];
                            [alert setTag:1];
                        }
                        return ;
                    }
                    if ([cmd intValue] == NORMAL_REPLY && [response1 valueForKey:@"vcomment_id"]) {
                        [waitingComment setValue:[response1 valueForKey:@"vcomment_id"] forKey:@"vcomment_id"];
                        [waitingComment setValue:[response1 valueForKey:@"time"] forKey:@"time"];
                        [self commentNumPlus];
                    }else{
                        [waitingComment setValue:[NSNumber numberWithInt:-2] forKey:@"vcomment_id"];
                    }
                }else{
                    [waitingComment setValue:[NSNumber numberWithInt:-2] forKey:@"vcomment_id"];
                }
                
                dispatch_barrier_async(dispatch_get_main_queue(), ^{
                    NSInteger row = self.vcomment_list.count - [self.vcomment_list indexOfObject:waitingComment];
                    if ([_sequence integerValue] != -1)
                        row ++;
                    NSInteger section = 0;
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
                    NSArray *visibleIndexPath = self.tableView.indexPathsForVisibleRows;
                    if ([visibleIndexPath containsObject:indexPath]) {
                        [_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                    }
                });
            });
        }];
    };
    
    //检查token
    if([waitingComment valueForKey:@"token"]){
        [dictionary setValue:[waitingComment valueForKey:@"token"] forKey:@"token"];
        resendCommentBlock();
    }else{
        //获取token
        NSMutableDictionary *token_dict = [[NSMutableDictionary alloc] init];
        //    [token_dict setValue:[MTUser sharedInstance].userid forKey:@"id"];
        NSData *jsonData1 = [NSJSONSerialization dataWithJSONObject:token_dict options:NSJSONWritingPrettyPrinted error:nil];
        HttpSender *httpSender1 = [[HttpSender alloc]initWithDelegate:self];
        [httpSender1 sendMessage:jsonData1 withOperationCode:TOKEN finshedBlock:^(NSData *rData) {
            if (rData) {
                NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
                NSNumber *cmd = [response1 valueForKey:@"cmd"];
                if ([cmd intValue] == NORMAL_REPLY && [response1 valueForKey:@"token"]) {
                    NSString* token = [response1 valueForKey:@"token"];
                    @synchronized(self)
                    {
                        if (![waitingComment valueForKey:@"token"]) {
                            [waitingComment setValue:token forKey:@"token"];
                        }
                    }
                    [dictionary setValue:[waitingComment valueForKey:@"token"] forKey:@"token"];
                    resendCommentBlock();
                    
                }else{
                    [waitingComment setValue:[NSNumber numberWithInt:-2] forKey:@"vcomment_id"];
                }
            }else {
                [waitingComment setValue:[NSNumber numberWithInt:-2] forKey:@"vcomment_id"];
            }
            dispatch_barrier_async(dispatch_get_main_queue(), ^{
                NSInteger row = self.vcomment_list.count - [self.vcomment_list indexOfObject:waitingComment];
                if ([_sequence integerValue] != -1)
                    row ++;
                NSInteger section = 0;
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
                NSArray *visibleIndexPath = self.tableView.indexPathsForVisibleRows;
                if ([visibleIndexPath containsObject:indexPath]) {
                    [_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                }
            });
        }];
    }
}

- (IBAction)publishComment:(id)sender {
    if (!_videoInfo) return;
    NSString *comment = self.inputTextView.text;
    if ([[comment stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]) {
        self.inputTextView.text = @"";
        return;
    }
    [self.inputTextView resignFirstResponder];
    if (_isEmotionOpen) [self button_Emotionpress:nil];
    self.inputTextView.text = @"";
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self textViewDidChange:nil];
        self.inputTextView.text = @"";
    });
    MTLOG(comment,nil);
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    NSMutableDictionary* newComment = [[NSMutableDictionary alloc]init];
    if (_repliedId && [_repliedId intValue]!=[[MTUser sharedInstance].userid intValue]){
        [dictionary setValue:_repliedId forKey:@"replied"];
        [newComment setValue:_repliedId forKey:@"replied"];
        [newComment setValue:_herName forKey:@"replier"];
    }
    [dictionary setValue:[MTUser sharedInstance].userid forKey:@"id"];
    [dictionary setValue:self.videoId forKey:@"video_id"];
    [dictionary setValue:self.eventId forKey:@"event_id"];
    [dictionary setValue:comment forKey:@"content"];
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSString*time = [dateFormatter stringFromDate:[NSDate date]];
    
    [newComment setValue:[NSNumber numberWithInt:0] forKey:@"good"];
    [newComment setValue:_videoId forKey:@"video_id"];
    [newComment setValue:[MTUser sharedInstance].name forKey:@"author"];
    [newComment setValue:[NSNumber numberWithInt:-1] forKey:@"vcomment_id"];
    [newComment setValue:comment forKey:@"content"];
    [newComment setValue:time forKey:@"time"];
    [newComment setValue:[MTUser sharedInstance].userid forKey:@"author_id"];
    [newComment setValue:[NSNumber numberWithInt:0] forKey:@"isZan"];
    
    if ([_vcomment_list isKindOfClass:[NSArray class]]) {
        _vcomment_list = [[NSMutableArray alloc]initWithArray:_vcomment_list];
    }
    [_vcomment_list insertObject:newComment atIndex:0];
    
    NSInteger row = self.vcomment_list.count;
    if ([_sequence integerValue] != -1)
        row ++;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    [_tableView beginUpdates];
    [_tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [_tableView endUpdates];
    
    self.inputTextView.text = @"";
    [self.inputTextView resignFirstResponder];
    
    void (^sendCommentBlock)(void) = ^(void){
        //发送评论
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
        MTLOG(@"%@",[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding]);
        HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
        [httpSender sendMessage:jsonData withOperationCode:ADD_VCOMMENT finshedBlock:^(NSData *rData) {
            dispatch_barrier_async(dispatch_get_main_queue(), ^{
                if (rData) {
                    NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
                    NSNumber *cmd = [response1 valueForKey:@"cmd"];
                    if ([cmd intValue] == VIDEO_NOT_EXIST) {
                        if (_shouldExit == NO) {
                            _shouldExit = YES;
                            [self deleteLocalData];
                            UIAlertView *alert = [CommonUtils showSimpleAlertViewWithTitle:@"信息" WithMessage:@"视频已删除" WithDelegate:self WithCancelTitle:@"确定"];
                            [alert setTag:1];
                        }
                        return ;
                    }
                    if ([cmd intValue] == NORMAL_REPLY && [response1 valueForKey:@"vcomment_id"]) {
                        {
                            [newComment setValue:[response1 valueForKey:@"vcomment_id"] forKey:@"vcomment_id"];
                            [newComment setValue:[response1 valueForKey:@"time"] forKey:@"time"];
                            [self commentNumPlus];
                        }
                    }else{
                        [newComment setValue:[NSNumber numberWithInt:-2] forKey:@"vcomment_id"];
                    }
                }else{
                    [newComment setValue:[NSNumber numberWithInt:-2] forKey:@"vcomment_id"];
                }
                dispatch_barrier_async(dispatch_get_main_queue(), ^{
                    NSInteger row = self.vcomment_list.count - [self.vcomment_list indexOfObject:newComment];
                    if ([_sequence integerValue] != -1)
                        row ++;
                    NSInteger section = 0;
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
                    NSArray *visibleIndexPath = self.tableView.indexPathsForVisibleRows;
                    if ([visibleIndexPath containsObject:indexPath]) {
                        [_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                    }
                });
            });
        }];
    };
    
    //获取token
    NSMutableDictionary *token_dict = [[NSMutableDictionary alloc] init];
    //    [token_dict setValue:[MTUser sharedInstance].userid forKey:@"id"];
    NSData *jsonData1 = [NSJSONSerialization dataWithJSONObject:token_dict options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender *httpSender1 = [[HttpSender alloc]initWithDelegate:self];
    [httpSender1 sendMessage:jsonData1 withOperationCode:TOKEN finshedBlock:^(NSData *rData) {
        if (rData) {
            NSString* content = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
            MTLOG(@"%@",content);
            NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
            NSNumber *cmd = [response1 valueForKey:@"cmd"];
            if ([cmd intValue] == NORMAL_REPLY && [response1 valueForKey:@"token"]) {
                NSString* token = [response1 valueForKey:@"token"];
                @synchronized(self)
                {
                    if (![newComment valueForKey:@"token"]) {
                        [newComment setValue:token forKey:@"token"];
                    }
                }
                [dictionary setValue:[newComment valueForKey:@"token"] forKey:@"token"];
                sendCommentBlock();
                
            }else{
                [newComment setValue:[NSNumber numberWithInt:-2] forKey:@"vcomment_id"];
            }
        }else{
            [newComment setValue:[NSNumber numberWithInt:-2] forKey:@"vcomment_id"];
        }
        dispatch_barrier_async(dispatch_get_main_queue(), ^{
            NSInteger row = self.vcomment_list.count - [self.vcomment_list indexOfObject:newComment];
            if ([_sequence integerValue] != -1)
                row ++;
            NSInteger section = 0;
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
            NSArray *visibleIndexPath = self.tableView.indexPathsForVisibleRows;
            if ([visibleIndexPath containsObject:indexPath]) {
                [_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            }
        });
    }];
}

- (void)commentNumPlus
{
    NSInteger comN = [[_videoInfo valueForKey:@"comment_num"]intValue];
    comN ++;
    [self.videoInfo setValue:[NSNumber numberWithInteger:comN] forKey:@"comment_num"];
    [self updateVideoInfo];
}

- (void)commentNumMinus
{
    NSInteger comN = [[_videoInfo valueForKey:@"comment_num"]intValue];
    comN --;
    if (comN < 0) comN = 0;
    [self.videoInfo setValue:[NSNumber numberWithInteger:comN] forKey:@"comment_num"];
    [self updateVideoInfo];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger comment_num = 0;
    if (self.vcomment_list) {
        comment_num = [self.vcomment_list count];
        if ([_sequence integerValue] != -1) {
            comment_num ++;
        }
    }
    return 1 + comment_num;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.row == 0) {
        
        float height = _video_thumb? self.video_thumb.size.height *320.0/self.video_thumb.size.width:180;
        if (videoRequest) {
            self.progressOverlayView.hidden = YES;
            [self closeProgressOverlayView];
            [videoRequest clearDelegatesAndCancel];
            videoRequest = nil;
        }
        cell = [[UITableViewCell alloc]initWithFrame:CGRectMake(0, 0, 320, self.specificationHeight)];
        UIButton* video = [UIButton buttonWithType:UIButtonTypeCustom];
        _video_button = video;
        [video setFrame:CGRectMake(0, 0, 320,height)];
        [video addTarget:self action:@selector(play:) forControlEvents:UIControlEventTouchUpInside];
        if (!_video_thumb) {
            [video setBackgroundImage:[CommonUtils createImageWithColor:[UIColor lightGrayColor]] forState:UIControlStateNormal];
            [video setBackgroundImage:[CommonUtils createImageWithColor:[CommonUtils colorWithValue:0x909090]] forState:UIControlStateHighlighted];
            
        }
        
        //长按手势
        UILongPressGestureRecognizer * longRecognizer = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(showOption:)];
        [video addGestureRecognizer:longRecognizer];
        
        MTImageGetter *imageGetter = [[MTImageGetter alloc]initWithImageView:video.imageView imageId:nil imageName:_videoInfo[@"video_name"] type:MTImageGetterTypeVideoThumb];
        [imageGetter getImageComplete:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (image) {
                _video_thumb = image;
                [video setImage:image forState:UIControlStateNormal];
                video.imageView.contentMode = UIViewContentModeScaleAspectFill;
            }
        }];
        
        UIImageView* videoIc = [[UIImageView alloc]initWithFrame:CGRectMake((320-75)/2, (height-75)/2, 75,75)];
        [videoIc setUserInteractionEnabled:NO];
        videoIc.image = [UIImage imageNamed:@"视频按钮"];
        _videoPlayImg = videoIc;
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, height, 320, 3)];
        [label setBackgroundColor:[UIColor colorWithRed:252/255.0 green:109/255.0 blue:67/255.0 alpha:1.0]];
        
        [cell addSubview:video];
        [cell addSubview:videoIc];
        [cell addSubview:label];
        //显示备注名
        NSString* alias = [[MTUser sharedInstance].alias_dic objectForKey:[NSString stringWithFormat:@"%@",[_videoInfo valueForKey:@"author_id"]]];
        if (alias == nil || [alias isEqual:[NSNull null]] || [alias isEqualToString:@""]) {
            alias = [_videoInfo valueForKey:@"author"];
        }
        
        UILabel* author = [[UILabel alloc]initWithFrame:CGRectMake(50, height+11, 200, 17)];
        [author setFont:[UIFont systemFontOfSize:14]];
        [author setTextColor:[UIColor colorWithRed:0/255.0 green:133/255.0 blue:186/255.0 alpha:1.0]];
        [author setBackgroundColor:[UIColor clearColor]];
        author.text = alias;
        [cell addSubview:author];
        
        UILabel* date = [[UILabel alloc]initWithFrame:CGRectMake(50, height+28, 150, 13)];
        [date setFont:[UIFont systemFontOfSize:11]];
        [date setTextColor:[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0]];
        date.text = [self.videoInfo valueForKey:@"time"];
        [date setBackgroundColor:[UIColor clearColor]];
        [cell addSubview:date];
        
        CGFloat specificationWidth = CGRectGetWidth(self.view.frame) - 10 - 50;
        if (!self.specification) {
            UILabel* specification = [[UILabel alloc]initWithFrame:CGRectMake(50, CGRectGetMaxY(date.frame)+1, specificationWidth, self.specificationHeight+15)];
            [specification setFont:[UIFont systemFontOfSize:12]];
            [specification setNumberOfLines:0];
            specification.text = [self.videoInfo valueForKey:@"title"];
            [specification setBackgroundColor:[UIColor clearColor]];
            self.specification = specification;
        }
        self.specification.frame = CGRectMake(50, CGRectGetMaxY(date.frame)+1, specificationWidth, self.specificationHeight+15);
        [cell addSubview:self.specification];
        
        if ([[self.videoInfo valueForKey:@"author_id"] intValue] == [[MTUser sharedInstance].userid intValue] || [self.eventLauncherId intValue] == [[MTUser sharedInstance].userid intValue]) {
            if (!self.edit_button) {
                self.edit_button = [UIButton buttonWithType:UIButtonTypeCustom];
                [self.edit_button setImage:[UIImage imageNamed:@"图片视频描述修改"] forState:UIControlStateNormal];
                [self.edit_button setImageEdgeInsets:UIEdgeInsetsMake(11, 13, 11, 9)];
                [self.edit_button.titleLabel setFont:[UIFont systemFontOfSize:12]];
                [self.edit_button setTitleColor:[UIColor colorWithRed:0/255.0 green:133/255.0 blue:186/255.0 alpha:1.0] forState:UIControlStateNormal];
                [self.edit_button setTitleColor:[UIColor colorWithRed:0/255.0 green:133/255.0 blue:186/255.0 alpha:0.5] forState:UIControlStateHighlighted];
                [self.edit_button addTarget:self action:@selector(editSpecification:) forControlEvents:UIControlEventTouchUpInside];
            }
            [self.edit_button setFrame:CGRectMake(CGRectGetWidth(self.view.frame) - 40 - 40 - 5, height + 3 + 2, 40, 40)];
            [cell addSubview:self.edit_button];
        }

        if ([[self.videoInfo valueForKey:@"author_id"] intValue] == [[MTUser sharedInstance].userid intValue] || [self.eventLauncherId intValue] == [[MTUser sharedInstance].userid intValue]) {
            if (!self.delete_button) {
                self.delete_button = [UIButton buttonWithType:UIButtonTypeCustom];
                [self.delete_button setImage:[UIImage imageNamed:@"图片视频描述删除"] forState:UIControlStateNormal];
                [self.delete_button setImageEdgeInsets:UIEdgeInsetsMake(10, 8, 10, 12)];
                [self.delete_button.titleLabel setFont:[UIFont systemFontOfSize:12]];
                [self.delete_button setTitleColor:[UIColor colorWithRed:0/255.0 green:133/255.0 blue:186/255.0 alpha:1.0] forState:UIControlStateNormal];
                [self.delete_button setTitleColor:[UIColor colorWithRed:0/255.0 green:133/255.0 blue:186/255.0 alpha:0.5] forState:UIControlStateHighlighted];
                [self.delete_button addTarget:self action:@selector(deleteVideo:) forControlEvents:UIControlEventTouchUpInside];
            }
            [self.delete_button setFrame:CGRectMake(CGRectGetWidth(self.view.frame) - 40 - 5, height + 3 + 2, 40, 40)];
            [cell addSubview:self.delete_button];
        }
        
        UIImageView* avatar = [[UIImageView alloc]initWithFrame:CGRectMake(10, height+13, 30, 30)];
        PhotoGetter *getter = [[PhotoGetter alloc]initWithData:avatar authorId:[self.videoInfo valueForKey:@"author_id"]];
        [getter getAvatar];
        [cell addSubview:avatar];
        
        UIButton* avatarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [avatarBtn setFrame:CGRectMake(0, height+13, 50, 50)];
        [avatarBtn setBackgroundColor:[UIColor clearColor]];
        [avatarBtn addTarget:self action:@selector(pushToFriendView:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:avatarBtn];
        
        
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell setBackgroundColor:[UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0]];
        return cell;
        
        
    }else{
        if ([_sequence integerValue] != -1 && indexPath.row == 1) {
            
            UITableViewCell* cell = [[UITableViewCell alloc]init];
            cell.backgroundColor = [UIColor clearColor];
            
            UILabel* label = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 300, 45)];
            label.text = _isLoading? @"正在加载...":@"查看更早的评论";
            label.textAlignment = NSTextAlignmentCenter;
            label.textColor = [UIColor colorWithWhite:0.2 alpha:1.0];
            label.font = [UIFont systemFontOfSize:13];
            label.backgroundColor = (_vcomment_list.count == 0)? [UIColor clearColor]:[UIColor colorWithWhite:230.0f/255.0 alpha:1.0f];
            label.tag = 555;
            [cell addSubview:label];
            return cell;
        }
        
        static NSString *CellIdentifier = @"VCommentTableViewCell";
        BOOL nibsRegistered = NO;
        if (!nibsRegistered) {
            UINib *nib = [UINib nibWithNibName:NSStringFromClass([VCommentTableViewCell class]) bundle:nil];
            [tableView registerNib:nib forCellReuseIdentifier:CellIdentifier];
            nibsRegistered = YES;
        }
        cell = (VCommentTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        NSDictionary* Vcomment = ([_sequence integerValue] == -1)? self.vcomment_list[_vcomment_list.count - indexPath.row ]:self.vcomment_list[_vcomment_list.count - indexPath.row + 1];
        NSString* alias = [[MTUser sharedInstance].alias_dic objectForKey:[NSString stringWithFormat:@"%@",[Vcomment valueForKey:@"author_id"]]];
        if (alias == nil || [alias isEqual:[NSNull null]] || [alias isEqualToString:@""]) {
            alias = [Vcomment valueForKey:@"author"];
        }
        ((VCommentTableViewCell *)cell).VcommentDict = Vcomment;
        ((VCommentTableViewCell *)cell).author.text = alias;
        ((VCommentTableViewCell *)cell).authorName = alias;
        ((VCommentTableViewCell *)cell).authorId = [Vcomment valueForKey:@"author_id"];
        ((VCommentTableViewCell *)cell).origincomment = [Vcomment valueForKey:@"content"];
        ((VCommentTableViewCell *)cell).controller = self;
        ((VCommentTableViewCell *)cell).date.text = [[Vcomment valueForKey:@"time"] substringWithRange:NSMakeRange(5, 11)];
        float commentWidth = 0;
        ((VCommentTableViewCell *)cell).vcomment_id = [Vcomment valueForKey:@"vcomment_id"];
        if ([[Vcomment valueForKey:@"vcomment_id"] intValue] == -1 ) {
            commentWidth = 230;
            [((VCommentTableViewCell *)cell).waitView startAnimating];
            [((VCommentTableViewCell *)cell).resend_Button setHidden:YES];
        }else if([[Vcomment valueForKey:@"vcomment_id"] intValue] == -2 ){
            [((VCommentTableViewCell *)cell).waitView stopAnimating];
            commentWidth = 230;
            [((VCommentTableViewCell *)cell).resend_Button setHidden:NO];
            [((VCommentTableViewCell *)cell).resend_Button addTarget:self action:@selector(resendComment:) forControlEvents:UIControlEventTouchUpInside];
        }else{
            commentWidth = 255;
            [((VCommentTableViewCell *)cell).waitView stopAnimating];
            [((VCommentTableViewCell *)cell).resend_Button setHidden:YES];
        }
        
        PhotoGetter *getter = [[PhotoGetter alloc]initWithData:((VCommentTableViewCell *)cell).avatar authorId:[Vcomment valueForKey:@"author_id"]];
        [getter getAvatar];
        
        NSString* text = [Vcomment valueForKey:@"content"];
        NSString*alias2;
        if ([[Vcomment valueForKey:@"replied"] intValue] != 0) {
            //显示备注名
            alias2 = [[MTUser sharedInstance].alias_dic objectForKey:[NSString stringWithFormat:@"%@",[Vcomment valueForKey:@"replied"]]];
            if (alias2 == nil || [alias2 isEqual:[NSNull null]] || [alias isEqualToString:@""]) {
                alias2 = [Vcomment valueForKey:@"replier"];
            }
            text = [NSString stringWithFormat:@"回复%@ : %@",alias2,text];
        }
        
        int height = [CommonUtils calculateTextHeight:text width:commentWidth fontSize:12.0 isEmotion:YES];
        
        MLEmojiLabel* comment =((VCommentTableViewCell *)cell).comment;
        if (!comment){
            comment = [[MLEmojiLabel alloc]initWithFrame:CGRectMake(50, 24, commentWidth, height)];
            ((VCommentTableViewCell *)cell).comment = comment;
        }
        else [comment setFrame:CGRectMake(50, 24, commentWidth, height)];
        [comment setDisableThreeCommon:YES];
        comment.numberOfLines = 0;
        comment.font = [UIFont systemFontOfSize:12.0f];
        comment.backgroundColor = [UIColor clearColor];
        comment.lineBreakMode = NSLineBreakByCharWrapping;
        
        comment.emojiText = text;
        [comment setBackgroundColor:[UIColor clearColor]];
        [cell setFrame:CGRectMake(0, 0, 320, 32 + height)];
        
        UIView* backguand = ((VCommentTableViewCell *)cell).background;
        if (!backguand){
            backguand = [[UIView alloc]initWithFrame:CGRectMake(10, 0, 300, 32+height)];
            ((VCommentTableViewCell *)cell).background = backguand;
        }
        else [backguand setFrame:CGRectMake(10, 0, 300, 32+height)];
        [backguand setBackgroundColor:[UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1.0]];
        [cell setBackgroundColor:[UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0]];
        [cell addSubview:backguand];
        [cell sendSubviewToBack:backguand];
        [cell addSubview:comment];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell setUserInteractionEnabled:YES];
        return cell;
    }
}

#pragma mark - Table view delegate


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    float height = 0;
    if (indexPath.row == 0) {
        CGFloat specificationWidth = CGRectGetWidth(self.view.frame) - 10 - 50;
        self.specificationHeight = _videoInfo? [CommonUtils calculateTextHeight:[self.videoInfo valueForKey:@"title"] width:specificationWidth fontSize:12.0 isEmotion:NO]:0;
        if (self.specificationHeight < 18) {
            self.specificationHeight = 18;
        }
        height = _video_thumb? self.video_thumb.size.height *320.0/self.video_thumb.size.width:180;
        height += 3;
        height += 50;
        height += self.specificationHeight;
        height += 5;//margin
        
    }else{
        if ([_sequence integerValue] != -1 && indexPath.row == 1) {
            return 45;
        }
        NSDictionary* Vcomment = ([_sequence integerValue] == -1)? self.vcomment_list[_vcomment_list.count - indexPath.row ]:self.vcomment_list[_vcomment_list.count - indexPath.row + 1];
        
        float commentWidth = 0;
        NSString* commentText = [Vcomment valueForKey:@"content"];
        NSString*alias2;
        if ([[Vcomment valueForKey:@"replied"] intValue] != 0) {
            //显示备注名
            alias2 = [[MTUser sharedInstance].alias_dic objectForKey:[NSString stringWithFormat:@"%@",[Vcomment valueForKey:@"replied"]]];
            if (alias2 == nil || [alias2 isEqual:[NSNull null]] || [alias2 isEqualToString:@""]) {
                alias2 = [Vcomment valueForKey:@"replier"];
            }
            commentText = [NSString stringWithFormat:@"回复%@ : %@",alias2,commentText];
        }
        if ([[Vcomment valueForKey:@"vcomment_id"] intValue] > 0) {
            commentWidth = 255;
        }else commentWidth = 230;
        
        height = [CommonUtils calculateTextHeight:commentText width:commentWidth fontSize:12.0 isEmotion:YES];
        height += 32;
    }
    return height;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isKeyBoard) {
        [self.inputTextView resignFirstResponder];
        return;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        //[self.navigationController popToViewController:self.photoDisplayController animated:YES];
    }else{
        if ([_sequence integerValue] != -1 && indexPath.row == 1) {
            if (_isLoading) return;
            if (!_videoInfo || [[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == 0) {
                MTLOG(@"没有网络");
                return;
            }
            
            [self pullMainCommentFromAir];
            UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
            UILabel* label = (UILabel*)[cell viewWithTag:555];
            if (label) {
                label.text = @"正在加载...";
            }
            
            return ;
        }
        if(!_canManage)return;
        VCommentTableViewCell *cell = (VCommentTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
        [cell.background setAlpha:0.5];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [cell.background setAlpha:1.0];
        });
        if ([cell.vcomment_id intValue] < 0){
            [self resendComment: cell.resend_Button];
            return;
        }
        self.herName = cell.authorName;
        if ([cell.authorId intValue] != [[MTUser sharedInstance].userid intValue]) {
            self.inputTextView.placeHolder = [NSString stringWithFormat:@"回复%@:",_herName];
        }else self.inputTextView.placeHolder = @"说点什么吧";
        [self.inputTextView becomeFirstResponder];
        self.repliedId = cell.authorId;
    }
}

#pragma mark 代理方法-进入刷新状态就会调用
- (void)refreshViewBeginRefreshing:(MJRefreshBaseView *)refreshView
{
    if (!_videoInfo || [[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == 0) {
        MTLOG(@"没有网络");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [refreshView endRefreshing];
        });
        return;
    }
    [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(closeRJ) userInfo:nil repeats:NO];
    _Footeropen = YES;
    [self pullMainCommentFromAir];
}
#pragma mark - keyboard observer method
//Code from Brett Schumann
-(void) keyboardWillShow:(NSNotification *)note{
    self.isKeyBoard = YES;
    if (self.isEmotionOpen) {
        [self button_Emotionpress:nil];
    }
    if (self.specificationEditTextfield) {
        return;
    }
    // get keyboard size and loctaion
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
    // get a rect for the textView frame
    CGRect containerFrame = self.commentView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - (keyboardBounds.size.height + containerFrame.size.height);
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    // set views with new info
    self.commentView.frame = containerFrame;
    
    
    // commit animations
    [UIView commitAnimations];
}

-(void) keyboardWillHide:(NSNotification *)note{
    self.isKeyBoard = NO;
    if (self.specificationEditTextfield) {
        return;
    }
    //self.inputField.text = @"";
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // get a rect for the textView frame
    CGRect containerFrame = self.commentView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - containerFrame.size.height;
    
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    // set views with new info
    self.commentView.frame = containerFrame;
    
    // commit animations
    [UIView commitAnimations];
}

#pragma mark - UITextView Delegate
-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if(!_canManage){
        ((MTMessageTextView*)textView).placeHolder = @"请先加入活动";
        return NO;
    }else return YES;
    
}

-(void)textViewDidChange:(UITextView *)textView
{
    CGRect frame = _inputTextView.frame;
    float change = _inputTextView.contentSize.height - frame.size.height;
    if (change != 0 && _inputTextView.contentSize.height < 120) {
        frame.size.height = _inputTextView.contentSize.height;
        [_inputTextView setFrame:frame];
        frame = _commentView.frame;
        frame.origin.y -= change;
        frame.size.height += change;
        [_commentView setFrame:frame];
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case 100:{
            NSInteger cancelBtnIndex = alertView.cancelButtonIndex;
            NSInteger okBtnIndex = alertView.firstOtherButtonIndex;
            if (buttonIndex == cancelBtnIndex) {
                ;
            }
            else if (buttonIndex == okBtnIndex)
            {
                [SVProgressHUD showWithStatus:@"正在删除" maskType:SVProgressHUDMaskTypeClear];
                NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
                [dictionary setValue:[MTUser sharedInstance].userid forKey:@"id"];
                [dictionary setValue:self.eventId forKey:@"event_id"];
                [dictionary setValue:@"delete" forKey:@"cmd"];
                [dictionary setValue:self.videoId forKey:@"video_id"];
                MTLOG(@"%@",dictionary);
                HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
                [httpSender sendVideoMessage:dictionary withOperationCode: VIDEOSERVER finshedBlock:^(NSData *rData) {
                    if (rData) {
                        NSString* temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
                        MTLOG(@"received Data: %@",temp);
                        NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
                        NSNumber *cmd = [response1 valueForKey:@"cmd"];
                        switch ([cmd intValue]) {
                            case NORMAL_REPLY:
                            {
                                //百度云 删除
                                CloudOperation * cloudOP = [[CloudOperation alloc]initWithDelegate:nil];
                                [cloudOP deletePhoto:[NSString stringWithFormat:@"/video/%@.thumb",[self.videoInfo valueForKey:@"video_name"]]];
                                CloudOperation * cloudOP1 = [[CloudOperation alloc]initWithDelegate:self];
                                [cloudOP1 deletePhoto:[NSString stringWithFormat:@"/video/%@",[self.videoInfo valueForKey:@"video_name"]]];
                                //数据库 删除
                                [self deleteVideoInfoFromDB];
                            }
                                break;
                            case VIDEO_NOT_EXIST:
                            {
                                [self deleteVideoInfoFromDB];
                                [SVProgressHUD dismissWithSuccess:@"图片删除成功" afterDelay:1];
                                [self back];
                            }
                                break;
                            default:
                            {
                                [SVProgressHUD dismissWithError:@"服务器异常" afterDelay:1];
                            }
                        }
                        
                    }else{
                        [SVProgressHUD dismissWithError:@"网络异常，请重试" afterDelay:1];
                    }
                }];
            }
        }
            break;
        case 1:{
            NSInteger index = self.navigationController.viewControllers.count - 2;
            NSArray * controllers = self.navigationController.viewControllers;
            if (controllers.count > index+1 && [controllers[index] isKindOfClass:[VideoWallViewController class]]) {
                VideoWallViewController* controller = (VideoWallViewController*)self.navigationController.viewControllers[index];
                controller.shouldReload = YES;
            }
            [self.navigationController popViewControllerAnimated:YES];
        }
        default:
            break;
    }
}

#pragma mark - CloudOperationDelegate
-(void)finishwithOperationStatus:(BOOL)status type:(int)type data:(NSData *)mdata path:(NSString *)path
{
    if (status){
        [SVProgressHUD dismissWithSuccess:@"图片删除成功" afterDelay:1];
        [self back];
    }else{
        [SVProgressHUD dismissWithError:@"网络异常，请重试" afterDelay:1];
    }
}
#pragma mark - MPlayer Delegate

-(void)playTheMPMoviePlayer:(NSNotification*)notify{
    MPMoviePlayerController* theMovie = _playerViewController.moviePlayer;
    [theMovie play];
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
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:@"playTheMPMoviePlayer"
                                                      object:nil];
        
        
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
        [self dismissMoviePlayerViewControllerAnimated];
    }else if(value == MPMovieFinishReasonPlaybackEnded){
        [theMovie play];
        [theMovie pause];
    }
    
}

#pragma mark - TextView view delegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [self publishComment:nil];
        return NO;
    }
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //这里我很谨慎的对sender和目标视图控制器作了判断
    if ([sender isKindOfClass:[VideoDetailViewController class]]) {
        if ([segue.destinationViewController isKindOfClass:[ReportViewController class]]) {
            ReportViewController *nextViewController = segue.destinationViewController;
            nextViewController.eventId = _eventId;
            nextViewController.videoId = _videoId;
            nextViewController.event = self.eventName;
            nextViewController.type = 5;
        }
    }
}

#pragma mark - UMSocialUIDelegate 友盟推荐回调
//实现回调方法（可选）：
-(void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response
{
    //根据`responseCode`得到发送结果,如果分享成功
    if(response.responseCode == UMSResponseCodeSuccess)
    {
        [SVProgressHUD showSuccessWithStatus:@"分享成功" duration:2.f];
    }
}

@end

