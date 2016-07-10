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
#import "MTMediaInfoView.h"
#import "MTMPMoviePlayerViewController.h"
#import "FriendInfoViewController.h"
#import "UserInfoViewController.h"
#import "DAProgressOverlayView.h"
#import "MTVideoPlayerViewController.h"
#import "UIButton+MTWebCache.h"
#import "MTDatabaseHelper.h"
#import "MTDatabaseAffairs.h"
#import "SVProgressHUD.h"
#import "MegUtils.h"
#import "MTImageGetter.h"
#import "MTOperation.h"
#import "LCAlertView.h"
#import "SocialSnsApi.h"
#import "KxMenu.h"

@interface VideoDetailViewController ()<UMSocialUIDelegate>
@property (nonatomic,strong) MTMPMoviePlayerViewController* movie;
@property (nonatomic,strong) MTMPMoviePlayerViewController *playerViewController;
@property (nonatomic,strong) MTMediaInfoView *videoInfoView;
@property BOOL isVideoReady;
@property (nonatomic,strong)NSNumber* sequence;
@property (nonatomic,strong)UIButton *editFinishButton;
@property (nonatomic,strong)UIButton *optionButton;
@property (nonatomic,strong)UIButton *delete_button;
@property (nonatomic,strong)UIButton *shadow;
@property (nonatomic,strong)UITextField *specificationEditTextfield;
@property (nonatomic,strong) UIButton *good_button;
@property (nonatomic,strong)NSString *videoShareLink;
@property float specificationHeight;
@property (nonatomic,strong) NSNumber* repliedId;
@property (nonatomic,strong) NSString* herName;
@property (strong, nonatomic) DAProgressOverlayView *progressOverlayView;
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
    [self.textInputView addKeyboardObserver];
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
    
    [self.textInputView dismissKeyboard];
    [self.textInputView removeKeyboardObserver];
    
    [KxMenu dismissMenu];
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
   
    //右上角按钮
    [self tabbarButtonOption];
    
    if (!_canManage) {
        self.tableView.bounds = self.view.bounds;
        return;
    }
    self.textInputView = [[MTTextInputView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame) - 45, kMainScreenWidth, 45) style:MTInputSytleComment];
    self.textInputView.delegate = self;
    self.textInputView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:self.textInputView];
}

- (void)initData
{
    self.sequence = [NSNumber numberWithInt:0];
    if (_videoInfo) self.videoId = [_videoInfo valueForKey:@"video_id"];
    
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

    FriendInfoViewController *friendView = [mainStoryboard instantiateViewControllerWithIdentifier: @"FriendInfoViewController"];
    friendView.fid = [self.videoInfo valueForKey:@"author_id"];
    [self.navigationController pushViewController:friendView animated:YES];

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
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
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
                    [MTDatabaseAffairs updateVideoInfoToDB:@[response1] eventId:_eventId];
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
    [MTDatabaseAffairs updateVideoInfoToDB:@[self.videoInfo] eventId:_eventId];
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
    if ([self.textInputView dismissKeyboard]) {
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
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self closeProgressOverlayView];
                    // my video player
                    if (self && self.navigationController.viewControllers.lastObject == self ) {
                        [self downloadVideo:videoName url:@"existed"];
                    }
                });
                return;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self closeProgressOverlayView];
                    // my video player
                    if (self && self.navigationController.viewControllers.lastObject == self ) {
                        [self downloadVideo:videoName url:@"existed"];
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
    [self.videoInfoView.playIcon setHidden:YES];
    if (!self.progressOverlayView)
        self.progressOverlayView = [[DAProgressOverlayView alloc] initWithFrame:self.videoInfoView.photoView.bounds];
    [self.progressOverlayView setHidden:NO];
    self.progressOverlayView.progress = 0;
    [self.videoInfoView.photoView addSubview:self.progressOverlayView];
    [self.progressOverlayView displayOperationWillTriggerAnimation];
}

-(void)closeProgressOverlayView
{
    [self.videoInfoView.playIcon setHidden:NO];
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

- (void)hiddenCommentViewAndEmotionView {
    [self.textInputView dismissKeyboard];
}

-(void)editSpecification:(UIButton*)button
{
    if (!_canManage) return;
    //进入编辑模式
    if (!self.specificationEditTextfield) {
        [self.textInputView dismissKeyboard];
        [self.textInputView removeKeyboardObserver];
        self.videoInfoView.descriptionLabel.hidden = YES;
        
        [self tabbarButtonEdit];
        self.tableView.scrollEnabled = NO;
        float height = CGRectGetMaxY(self.videoInfoView.photoView.superview.frame);
        [self.tableView setContentOffset:CGPointMake(0, height - 80) animated:YES];
        if (!self.shadow) {
            UIButton *shadow = [UIButton buttonWithType:UIButtonTypeCustom];
            shadow.frame = self.view.bounds;
            [shadow addTarget:self action:@selector(editSpecification:) forControlEvents:UIControlEventTouchUpInside];
            shadow.userInteractionEnabled = YES;
            self.shadow = shadow;
        }
        [self.view addSubview:self.shadow];
        
        if (!self.specificationEditTextfield) {
            CGRect textfieldFrame = self.videoInfoView.descriptionLabel.frame;
            textfieldFrame.size.height = 30;
            textfieldFrame.origin.y = 80 + 5;
            UITextField* specificationEditTextfield = [[UITextField alloc]initWithFrame:textfieldFrame];
            specificationEditTextfield.placeholder = @"请输入新的视频描述";
            [specificationEditTextfield setFont:[UIFont systemFontOfSize:14]];
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
        [self.textInputView addKeyboardObserver];
        
        [self.specificationEditTextfield removeFromSuperview];
        [self.specificationEditTextfield resignFirstResponder];
        self.specificationEditTextfield = nil;
        [self.shadow removeFromSuperview];
        self.videoInfoView.descriptionLabel.hidden = NO;
        [self tabbarButtonOption];
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
        [self.videoInfo setValue:newSpecification forKey:@"title"];
        [self.tableView reloadData];
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

//- (void)tabbarButtonShare {
//    if (!self.shareButton) {
//        self.shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        [self.shareButton setFrame:CGRectMake(0, 0, 70, 43)];
//        [self.shareButton setImageEdgeInsets:UIEdgeInsetsMake(8, 34, 8, -20)];
//        [self.shareButton setImage:[UIImage imageNamed:@"video_share_btn"] forState:UIControlStateNormal];
//        [self.shareButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
//        [self.shareButton addTarget:self action:@selector(shareVideo) forControlEvents:UIControlEventTouchUpInside];
//    }
//    UIBarButtonItem *rightButtonItem=[[UIBarButtonItem alloc]initWithCustomView:self.shareButton];
//    self.navigationItem.rightBarButtonItem = rightButtonItem;
//}

- (void)tabbarButtonOption {
    if(!_canManage)
        return;
    if (!self.optionButton) {
        self.optionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.optionButton setFrame:CGRectMake(0, 0, 70, 43)];
        [self.optionButton setImageEdgeInsets:UIEdgeInsetsMake(4, 34, 4, -5)];
        [self.optionButton setImage:[UIImage imageNamed:@"头部右上角图标-更多"] forState:UIControlStateNormal];
        [self.optionButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [self.optionButton addTarget:self action:@selector(optionBtnPressed) forControlEvents:UIControlEventTouchUpInside];
    }
    UIBarButtonItem *rightButtonItem=[[UIBarButtonItem alloc]initWithCustomView:self.optionButton];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
}

- (void)optionBtnPressed {
    if (!self || !self.videoInfo) {
        return;
    }
    NSMutableArray *menuItems = [[NSMutableArray alloc]init];
    
    if ([[self.videoInfo valueForKey:@"author_id"] integerValue] == [[MTUser sharedInstance].userid integerValue] || [self.eventLauncherId integerValue] == [[MTUser sharedInstance].userid integerValue]) {
        [menuItems addObjectsFromArray:@[[KxMenuItem menuItem:@"编辑描述"
                                                        image:nil
                                                       target:self
                                                       action:@selector(editSpecification:)],
                                         
                                         [KxMenuItem menuItem:@"保存视频"
                                                        image:nil
                                                       target:self
                                                       action:@selector(saveVideo)],
                                         
                                         [KxMenuItem menuItem:@"删除视频"
                                                        image:nil
                                                       target:self
                                                       action:@selector(deleteVideo:)],
                                         ]];
    } else {
        [menuItems addObject: [KxMenuItem menuItem:@"保存视频"
                                             image:nil
                                            target:self
                                            action:@selector(saveVideo)]];
    }
    
    if ([[self.videoInfo valueForKey:@"author_id"] integerValue]  != [[MTUser sharedInstance].userid integerValue]) {
        [menuItems addObjectsFromArray:@[[KxMenuItem menuItem:@"举报视频"
                                                        image:nil
                                                       target:self
                                                       action:@selector(report:)]]];
    }
    
    [KxMenu setTintColor:[UIColor whiteColor]];
    [KxMenu setTitleFont:[UIFont systemFontOfSize:17]];
    [KxMenu showMenuInView:self.navigationController.view
                  fromRect:CGRectMake(self.view.bounds.size.width*0.9, 60, 0, 0)
                 menuItems:menuItems];
}

- (void)shareVideo {
    [self.textInputView dismissKeyboard];
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
        [UMSocialData defaultData].extConfig.wechatSessionData.title = @"【活动宝视频分享】";
        [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeWeb;
        [UMSocialData defaultData].extConfig.qqData.qqMessageType = UMSocialQQMessageTypeDefault;
        [UMSocialData defaultData].extConfig.qqData.url = shareLink;
        [UMSocialData defaultData].extConfig.qqData.title = @"【活动宝视频分享】";
        [[UMSocialData defaultData].extConfig.sinaData setUrlResource:[[UMSocialUrlResource alloc] initWithSnsResourceType:UMSocialUrlResourceTypeVideo url:shareLink]];
        [UMSocialData defaultData].extConfig.smsData.urlResource = nil;
        [UMSocialData defaultData].extConfig.smsData.shareText = [NSString stringWithFormat:@"%@ %@",shareText,shareLink];
        [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeWeb;
        [UMSocialConfig hiddenNotInstallPlatforms:@[UMShareToQQ,UMShareToSina,UMShareToWechatSession,UMShareToWechatFavorite,UMShareToWechatTimeline]];

        NSMutableArray *shareToSns = [[NSMutableArray alloc] initWithObjects:UMShareToWechatSession,UMShareToWechatTimeline,UMShareToQQ,UMShareToSina, nil];
        if (![WXApi isWXAppInstalled] || ![WeiboSDK isWeiboAppInstalled] || ![QQApiInterface isQQInstalled]) {
            [shareToSns addObject:UMShareToSms];
        }
        [UMSocialSnsService presentSnsIconSheetView:self
                                             appKey:@"53bb542e56240ba6e80a4bfb"
                                          shareText:shareText
                                         shareImage:self.videoInfoView.photo?self.videoInfoView.photo:[UIImage imageNamed:@"AppIcon57x57"]
                                    shareToSnsNames:shareToSns
                                           delegate:self];
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

- (BOOL)checkCanManaged {
    if (_canManage) {
        return YES;
    } else {
        [CommonUtils showSimpleAlertViewWithTitle:@"温馨提示" WithMessage:@"您尚未加入该活动中，无法点赞和评论" WithDelegate:nil WithCancelTitle:@"确定"];
        return NO;
    }
}

- (IBAction)good:(id)sender {
    if(![self checkCanManaged]) return;
    if(!_videoInfo) return;
    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == 0)
    {
        [CommonUtils showSimpleAlertViewWithTitle:@"信息" WithMessage:@"网络异常" WithDelegate:self WithCancelTitle:@"确定"];
        return;
    }
    
    BOOL iszan = [[self.videoInfo valueForKey:@"isZan"] boolValue];
    
    [[MTOperation sharedInstance] likeOperationWithType:MTMediaTypeVideo mediaId:self.videoId eventId:self.eventId like:!iszan finishBlock:NULL];
    
    BOOL isZan = [[self.videoInfo valueForKey:@"isZan"]boolValue];
    NSInteger good = [[self.videoInfo valueForKey:@"good"]integerValue];
    if (isZan) {
        good --;
    }else good ++;
    [self.videoInfo setValue:[NSNumber numberWithBool:!isZan] forKey:@"isZan"];
    [self.videoInfo setValue:[NSNumber numberWithInteger:good] forKey:@"good"];
    [MTDatabaseAffairs updateVideoInfoToDB:@[_videoInfo] eventId:_eventId];
    [self.videoInfoView setupLikeButton];
}

-(void)deleteVideo:(UIButton*)button
{
    if(!_canManage)return;
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"确定要删除这段视频？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert setTag:100];
    [alert show];
}

- (void)saveVideo
{
    if(!_canManage)return;
    NSString *videoName = [self.videoInfo valueForKey:@"video_name"];
    if (videoName) {
        NSString *CacheDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        NSString *cachePath = [CacheDirectory stringByAppendingPathComponent:@"VideoCache"];
        NSString *path = [cachePath stringByAppendingPathComponent:videoName];
        //plan b 缓存视频
        NSFileManager *fileManager=[NSFileManager defaultManager];
        if([fileManager fileExistsAtPath:cachePath] && [fileManager fileExistsAtPath:path]) {
            [SVProgressHUD showWithStatus:@"正在保存" maskType:SVProgressHUDMaskTypeClear];
            UISaveVideoAtPathToSavedPhotosAlbum(path, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
        } else {
            [SVProgressHUD showErrorWithStatus:@"视频尚未下载"];
        }
    }
}

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo: (void *)contextInfo {
    if (!error) {
        [SVProgressHUD dismissWithSuccess:@"保存成功"];
    } else {
        [SVProgressHUD dismissWithError:@"保存失败"];
    }
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
    if (![self checkCanManaged]) return;
    if (!_videoInfo) return;
    NSString *comment = self.textInputView.text;
    NSString *herName = self.herName;
    NSNumber *repliedId = self.repliedId;
    
    [self.textInputView clear];

    if ([[comment stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]) {
        return;
    }

    MTLOG(comment,nil);
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    NSMutableDictionary* newComment = [[NSMutableDictionary alloc]init];
    if (repliedId && ![repliedId isEqualToNumber:[MTUser sharedInstance].userid]){
        [dictionary setValue:repliedId forKey:@"replied"];
        [newComment setValue:repliedId forKey:@"replied"];
        [newComment setValue:herName forKey:@"replier"];
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
    @synchronized(self) {
        [_tableView beginUpdates];
        [_tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        [_tableView endUpdates];
    }
    [_tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
    [self.textInputView clear];
    
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

- (void)clearCommentView {
    self.textInputView.placeHolder = @"说点什么吧";
    self.textInputView.text = @"";
    self.herName = @"";
    self.repliedId = nil;
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
        
        if (!self.videoInfoView) {
            static NSString *CellIdentifier = @"pPhotoInfoView";
            UINib *nib = [UINib nibWithNibName:NSStringFromClass([MTMediaInfoView class]) bundle:nil];
            [tableView registerNib:nib forCellReuseIdentifier:CellIdentifier];
            self.videoInfoView = (MTMediaInfoView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(play:)];
            [self.videoInfoView.photoView addGestureRecognizer:tap];
            
            [self.videoInfoView.likeBtn addTarget:self action:@selector(good:) forControlEvents:UIControlEventTouchUpInside];
            [self.videoInfoView.shareBtn addTarget:self action:@selector(shareVideo) forControlEvents:UIControlEventTouchUpInside];
            
        }
        [self.videoInfoView applyData:self.videoInfo type:MTMediaTypeVideo containerWidth:CGRectGetWidth(self.view.frame)];
        
        if (videoRequest) {
            self.progressOverlayView.hidden = YES;
            [self closeProgressOverlayView];
            [videoRequest clearDelegatesAndCancel];
            videoRequest = nil;
        }
        
        return self.videoInfoView;
        
    }else{
        if ([_sequence integerValue] != -1 && indexPath.row == 1) {
            
            UITableViewCell* cell = [[UITableViewCell alloc]init];
            cell.backgroundColor = [UIColor clearColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            UILabel* label = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, kMainScreenWidth - 20, 45)];
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
        NSString *alias = [MTOperation getAliasWithUserId:Vcomment[@"author_id"] userName:Vcomment[@"author"]];

        ((VCommentTableViewCell *)cell).VcommentDict = Vcomment;
        ((VCommentTableViewCell *)cell).author.text = alias;
        ((VCommentTableViewCell *)cell).authorName = alias;
        ((VCommentTableViewCell *)cell).authorId = [Vcomment valueForKey:@"author_id"];
        ((VCommentTableViewCell *)cell).origincomment = [Vcomment valueForKey:@"content"];
        ((VCommentTableViewCell *)cell).controller = self;
        ((VCommentTableViewCell *)cell).date.text = [CommonUtils calculateTimeStr:Vcomment[@"time"] shortVersion:NO];
    
        float commentWidth = 0;
        ((VCommentTableViewCell *)cell).vcomment_id = [Vcomment valueForKey:@"vcomment_id"];
        if ([[Vcomment valueForKey:@"vcomment_id"] intValue] == -1 ) {
            commentWidth = kMainScreenWidth - 90;
            [((VCommentTableViewCell *)cell).waitView startAnimating];
            [((VCommentTableViewCell *)cell).resend_Button setHidden:YES];
        }else if([[Vcomment valueForKey:@"vcomment_id"] intValue] == -2 ){
            [((VCommentTableViewCell *)cell).waitView stopAnimating];
            commentWidth = kMainScreenWidth - 90;
            [((VCommentTableViewCell *)cell).resend_Button setHidden:NO];
            [((VCommentTableViewCell *)cell).resend_Button addTarget:self action:@selector(resendComment:) forControlEvents:UIControlEventTouchUpInside];
        }else{
            commentWidth = kMainScreenWidth - 65;
            [((VCommentTableViewCell *)cell).waitView stopAnimating];
            [((VCommentTableViewCell *)cell).resend_Button setHidden:YES];
        }
        
        PhotoGetter *getter = [[PhotoGetter alloc]initWithData:((VCommentTableViewCell *)cell).avatar authorId:[Vcomment valueForKey:@"author_id"]];
        [getter getAvatar];
        
        NSString* text = [Vcomment valueForKey:@"content"];
        NSString*alias2;
        if ([[Vcomment valueForKey:@"replied"] intValue] != 0) {
            //显示备注名
            alias2 = [MTOperation getAliasWithUserId:Vcomment[@"replied"] userName:Vcomment[@"replier"]];
            text = [NSString stringWithFormat:@"回复%@ : %@",alias2,text];
        }
        
        float height = [CommonUtils calculateTextHeight:text width:commentWidth fontSize:12.0 isEmotion:YES];
        
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
        [cell setFrame:CGRectMake(0, 0, kMainScreenWidth, 32 + height)];
        
        UIView* backguand = ((VCommentTableViewCell *)cell).background;
        if (!backguand){
            backguand = [[UIView alloc]initWithFrame:CGRectMake(10, 0, kMainScreenWidth - 20, 32+height)];
            ((VCommentTableViewCell *)cell).background = backguand;
        }
        else [backguand setFrame:CGRectMake(10, 0, kMainScreenWidth - 20, 32+height)];
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
        height = [MTMediaInfoView calculateCellHeightwithMediaInfo:self.videoInfo type:MTMediaTypeVideo containerWidth:CGRectGetWidth(self.view.frame)];
        
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
            alias2 = [MTOperation getAliasWithUserId:Vcomment[@"replied"] userName:Vcomment[@"replier"]];
            commentText = [NSString stringWithFormat:@"回复%@ : %@",alias2,commentText];
        }
        if ([[Vcomment valueForKey:@"vcomment_id"] intValue] > 0) {
            commentWidth = kMainScreenWidth - 65;
        }else commentWidth = kMainScreenWidth - 90;
        
        height = [CommonUtils calculateTextHeight:commentText width:commentWidth fontSize:12.0 isEmotion:YES];
        height += 32;
    }
    return height;
}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
    }else{
        if ([_sequence integerValue] != -1 && indexPath.row == 1) {
            if (self.isLoading) return;
            UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
            UILabel* label = (UILabel*)[cell viewWithTag:555];
            [label setAlpha:0.5];
            return ;
        }
        VCommentTableViewCell *cell = (VCommentTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        [cell.background setAlpha:0.5];
    }
}

- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row == 0) {
    }else{
        if ([_sequence integerValue] != -1 && indexPath.row == 1) {
            if (self.isLoading) return;
            UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
            UILabel* label = (UILabel*)[cell viewWithTag:555];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [label setAlpha:1.0];
            });
            return ;
        }
        VCommentTableViewCell *cell = (VCommentTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [cell.background setAlpha:1.0];
        });
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.textInputView dismissKeyboard]) {
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
        if ([cell.vcomment_id intValue] < 0){
            [self resendComment: cell.resend_Button];
            return;
        }
        self.herName = cell.authorName;
        if ([cell.authorId intValue] != [[MTUser sharedInstance].userid intValue]) {
            self.textInputView.placeHolder = [NSString stringWithFormat:@"回复%@:",_herName];
        }else self.textInputView.placeHolder = @"说点什么吧";
        [self.textInputView openKeyboard];
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

#pragma mark - UITextView Delegate
-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if(!_canManage){
        self.textInputView.placeHolder = @"请先加入活动";
        return NO;
    }else return YES;
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

#pragma mark - MTTextInputView delegate
- (void)textInputView:(MTTextInputView *)textInputView sendMessage:(NSString *)message {
    [self publishComment:nil];
}

-(void)textInputViewDidDismissKeyboard {
    [self clearCommentView];
}

#pragma mark - ScrollView Delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.textInputView dismissKeyboard];
}
@end

