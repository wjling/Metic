//
//  PhotoDetailViewController.m
//  Metic
//
//  Created by ligang6 on 14-7-4.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "PhotoDetailViewController.h"
#import "PhotoDisplayViewController.h"
#import "Friends/FriendInfoViewController.h"
#import "UserInfoViewController.h"
#import "PhotoBrowserViewController.h"
#import "BannerViewController.h"
#import "PcommentTableViewCell.h"
#import "HomeViewController.h"
#import "CommonUtils.h"
#import "MobClick.h"
#import "MLEmojiLabel.h"
#import "emotion_Keyboard.h"
#import "UIImageView+MTWebCache.h"
#import "NSString+JSON.h"
#import "TMQuiltView.h"
#import "MTDatabaseHelper.h"
#import "MTDatabaseAffairs.h"
#import "SVProgressHUD.H"
#import "MegUtils.h"
#import "MTImageGetter.h"
#import "MTOperation.h"
#import "SocialSnsApi.h"
#import "JGActionSheet.h"
#import "KxMenu.h"

@interface PhotoDetailViewController ()
@property (nonatomic,strong)NSNumber *sequence;
@property (nonatomic,strong)UIImageView *photoView;
@property (nonatomic,strong)UIImageView *avatarView;
@property (nonatomic,strong)UIButton *edit_button;
@property (nonatomic,strong)UIButton *editFinishButton;
@property (nonatomic,strong)UIButton *optionButton;
@property (nonatomic,strong)UIButton *shareButton;
@property (nonatomic,strong)UILabel *specification;
@property (nonatomic,strong)UIButton *shadow;
@property (nonatomic,strong)UITextField *specificationEditTextfield;
@property (strong, nonatomic) UIButton *good_button;
@property (strong, nonatomic) IBOutlet UIButton *download_button;
@property float specificationHeight;
@property (strong, nonatomic) IBOutlet UIView *controlView;
@property(nonatomic,strong) emotion_Keyboard *emotionKeyboard;
@property (nonatomic,strong) NSNumber* repliedId;
@property (nonatomic,strong) NSString* herName;
@property BOOL shouldExit;
@property BOOL Footeropen;
@property BOOL isLoading;
@property long Selete_section;

@end

@implementation PhotoDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [CommonUtils addLeftButton:self isFirstPage:NO];
    [self initUI];
    [self initData];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [self.inputTextView resignFirstResponder];
    [MobClick beginLogPageView:@"图片主页"];

}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [MobClick endLogPageView:@"图片主页"];
}

- (void)viewWillDisappear:(BOOL)animated {
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

-(void)dealloc {
    NSLog(@"dealloc");
}

//返回上一层
- (void)MTpopViewController{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) initButtons
{
    for (int i = 0; i < self.buttons.count; i++) {
        UIButton* button = [self.buttons objectAtIndex:i];
        UIImage *colorImage = [CommonUtils createImageWithColor:[UIColor colorWithRed:85/255.0 green:203/255.0 blue:171/255.0 alpha:1.0] ];
        [button setBackgroundImage:colorImage forState:UIControlStateHighlighted];
        [button resignFirstResponder];
    }
}

-(void)initUI
{
    self.view.autoresizesSubviews = YES;
    
    //右上角按钮
    if (![self.parentViewController isKindOfClass:[PhotoBrowserViewController class]]) {
        [self tabbarButtonOption];
    }
    
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
    [self.view bringSubviewToFront:_controlView];
    
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
}

-(void)initData
{
    self.sequence = @0;
    self.isKeyBoard = NO;
    self.Footeropen = NO;
    self.shouldExit = NO;
    self.isLoading = YES;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.pcomment_list = [[NSMutableArray alloc]init];
    //[self initButtons];
    [self setGoodButton];
    dispatch_barrier_async(dispatch_get_main_queue(), ^{
        if (!_photoInfo) [self pullPhotoInfoFromDB];
        [self pullPhotoInfoFromAir];
        [self pullMainCommentFromAir];
    });
}

-(void)setPhotoInfo:(NSMutableDictionary *)photoInfo
{
    _photoInfo = photoInfo;
}

-(void)pullPhotoInfoFromDB
{
    NSArray *seletes = [[NSArray alloc]initWithObjects:@"photoInfo", nil];
    NSDictionary *wheres = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%@",self.photoId],@"photo_id", nil];
    [[MTDatabaseHelper sharedInstance]queryTable:@"photoInfo" withSelect:seletes andWhere:wheres completion:^(NSMutableArray *resultsArray) {
        if (resultsArray.count) {
            NSString *tmpa = [resultsArray[0] valueForKey:@"photoInfo"];
            NSData *tmpb = [tmpa dataUsingEncoding:NSUTF8StringEncoding];
            self.photoInfo =  [NSJSONSerialization JSONObjectWithData:tmpb options:NSJSONReadingMutableContainers error:nil];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }
    }];
}

-(void)pullPhotoInfoFromAir
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:[MTUser sharedInstance].userid forKey:@"id"];
    [dictionary setValue:self.photoId forKey:@"photo_id"];
    [dictionary setValue:self.eventId forKey:@"event_id"];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    MTLOG(@"拉取图片%@",[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding]);
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:GET_OBJECT_INFO finshedBlock:^(NSData *rData) {
        if(rData){
            NSString* temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
            MTLOG(@"received Data: %@",temp);
            NSMutableDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableContainers error:nil];
            NSNumber *cmd = [response1 valueForKey:@"cmd"];
            switch ([cmd integerValue]) {
                case NORMAL_REPLY:
                {
                    dispatch_barrier_async(dispatch_get_main_queue(), ^{
                        if(_photoInfo)[_photoInfo addEntriesFromDictionary:response1];
                        else _photoInfo = response1;
                        [MTDatabaseAffairs updatePhotoInfoToDB:@[response1] eventId:_eventId];
                        [_tableView reloadData];
                    });
                }
                    break;
                case PHOTO_NOT_EXIST:
                {
                    if (!_shouldExit) {
                        _shouldExit = YES;
                        [self deleteLocalData];
                        UIAlertView *alert = [CommonUtils showSimpleAlertViewWithTitle:@"信息" WithMessage:@"图片已删除" WithDelegate:self WithCancelTitle:@"确定"];
                        [alert setTag:1];
                    }
                    break;
                }
                default:
                {
                    [CommonUtils showSimpleAlertViewWithTitle:@"信息" WithMessage:@"网络异常" WithDelegate:self WithCancelTitle:@"确定"];
                    
                }
            }
        }
    }];
}

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
        //[self.view bringSubviewToFront:_emotionKeyboard];
        //[self.view addSubview:_emotionKeyboard];
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
    [self clearCommentView];
    
    CGRect containerFrame = self.commentView.frame;
    containerFrame.size.height = 45.f;
    containerFrame.origin.y = self.view.bounds.size.height - containerFrame.size.height;
    
    CGRect inputViewFrame = self.inputTextView.frame;
    inputViewFrame.size.height = 36.f;
    
    CGRect emotionFrame = _emotionKeyboard.frame;
    emotionFrame.origin.y = self.view.frame.size.height;
    
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.25];
    [UIView setAnimationCurve:7];
    
    self.commentView.frame = containerFrame;
    self.inputTextView.frame = inputViewFrame;
    self.emotionKeyboard.frame = emotionFrame;
    
    [UIView commitAnimations];
}

-(void) setGoodButton
{
    if (_photoInfo && [[self.photoInfo valueForKey:@"isZan"] boolValue]) {
        [self.good_button setImage:[UIImage imageNamed:@"icon_detail_like_yes"] forState:UIControlStateNormal];
    }else [self.good_button setImage:[UIImage imageNamed:@"icon_detail_like_no"] forState:UIControlStateNormal];
}

- (void)pullMainCommentFromAir
{
    _isLoading = YES;
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:[MTUser sharedInstance].userid forKey:@"id"];
    long sequence = [self.sequence longValue];
    [dictionary setValue:self.sequence forKey:@"sequence"];
    [dictionary setValue:self.photoId forKey:@"photo_id"];
    MTLOG(@"%@",dictionary);
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:GET_PCOMMENTS finshedBlock:^(NSData *rData) {
        if(rData){
            NSString* temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
            MTLOG(@"received Data: %@",temp);
            NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
            NSNumber *cmd = [response1 valueForKey:@"cmd"];
            switch ([cmd integerValue]) {
                case NORMAL_REPLY:
                {
                    if ([response1 valueForKey:@"pcomment_list"]) {
                        NSMutableArray *newComments = [[NSMutableArray alloc]initWithArray:[response1 valueForKey:@"pcomment_list"]];
                        dispatch_barrier_async(dispatch_get_main_queue(), ^{
                            if ([_sequence longValue] == sequence) {
                                if (sequence == 0) [_pcomment_list removeAllObjects];
                                [self.pcomment_list addObjectsFromArray:newComments];
                                if(newComments.count < 10) _sequence = [NSNumber numberWithInteger:-1];
                                else self.sequence = [response1 valueForKey:@"sequence"];
                            }
                            _isLoading = NO;
                            [self.tableView reloadData];
                        });
                    }
                }
                    break;
                case PHOTO_NOT_EXIST:
                {
                    if (!_shouldExit) {
                        _shouldExit = YES;
                        [self deleteLocalData];
                        UIAlertView *alert = [CommonUtils showSimpleAlertViewWithTitle:@"信息" WithMessage:@"图片已删除" WithDelegate:self WithCancelTitle:@"确定"];
                        [alert setTag:1];
                    }
                    break;
                }
                default:
                {
                    [CommonUtils showSimpleAlertViewWithTitle:@"信息" WithMessage:@"网络异常" WithDelegate:nil WithCancelTitle:@"确定"];
                    
                }
            }
        }
        _isLoading = NO;
    }];
}

- (void)commentNumPlus
{
    NSInteger comN = [[self.photoInfo valueForKey:@"comment_num"]integerValue];
    comN ++;
    [self.photoInfo setValue:[NSNumber numberWithInteger:comN] forKey:@"comment_num"];
    [MTDatabaseAffairs updatePhotoInfoToDB:@[_photoInfo] eventId:_eventId];
}

- (void)commentNumMinus
{
    NSInteger comN = [[self.photoInfo valueForKey:@"comment_num"]integerValue];
    comN --;
    if (comN < 0) comN = 0;
    [self.photoInfo setValue:[NSNumber numberWithInteger:comN] forKey:@"comment_num"];
    [MTDatabaseAffairs updatePhotoInfoToDB:@[_photoInfo] eventId:_eventId];
}

- (IBAction)good:(id)sender {
    if (![self checkCanManaged]) return;
    if(!_photoInfo) return;
    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == 0)
    {
        [CommonUtils showSimpleAlertViewWithTitle:@"信息" WithMessage:@"网络异常" WithDelegate:self WithCancelTitle:@"确定"];
        return;
    }
    
    BOOL iszan = [[self.photoInfo valueForKey:@"isZan"] boolValue];
    
    [[MTOperation sharedInstance] likeOperationWithType:MTMediaTypePhoto mediaId:self.photoId eventId:self.eventId like:!iszan finishBlock:^(BOOL isValid) {
        if (!isValid) {
            if (!_shouldExit) {
                _shouldExit = YES;
                [self deleteLocalData];
                UIAlertView *alert = [CommonUtils showSimpleAlertViewWithTitle:@"信息" WithMessage:@"图片已删除" WithDelegate:self WithCancelTitle:@"确定"];
                [alert setTag:1];
            }
        }
    }];
    
    BOOL isZan = [[self.photoInfo valueForKey:@"isZan"]boolValue];
    NSInteger good = [[self.photoInfo valueForKey:@"good"]integerValue];
    if (isZan) {
        good --;
    }else good ++;
    [self.photoInfo setValue:[NSNumber numberWithBool:!isZan] forKey:@"isZan"];
    [self.photoInfo setValue:[NSNumber numberWithInteger:good] forKey:@"good"];
    [MTDatabaseAffairs updatePhotoInfoToDB:@[_photoInfo] eventId:_eventId];
    [self setGoodButton];
}

- (BOOL)checkCanManaged {
    if (_canManage) {
        return YES;
    } else {
        [CommonUtils showSimpleAlertViewWithTitle:@"温馨提示" WithMessage:@"您尚未加入该活动中，无法点赞和评论" WithDelegate:nil WithCancelTitle:@"确定"];
        return NO;
    }
}

- (IBAction)comment:(id)sender {
    if (![self checkCanManaged]) return;
    self.inputTextView.placeHolder = @"说点什么吧";
    [self.inputTextView becomeFirstResponder];
}

- (IBAction)share:(id)sender {
    if (_photo) {
        NSString *shareText = self.photoInfo[@"specification"];
        if (![shareText isKindOfClass:[NSString class]] || shareText.length == 0) {
            shareText = @" ";
        }
        [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeImage;
        [UMSocialData defaultData].extConfig.qqData.qqMessageType = UMSocialQQMessageTypeImage;
        [UMSocialData defaultData].extConfig.qqData.title = @"【活动宝图片分享】";
        [UMSocialData defaultData].extConfig.sinaData.urlResource = nil;
        [UMSocialData defaultData].extConfig.smsData.urlResource = nil;
        
        [UMSocialConfig hiddenNotInstallPlatforms:@[UMShareToQQ,UMShareToSina,UMShareToWechatSession,UMShareToWechatTimeline]];
        NSMutableArray *shareToSns = [[NSMutableArray alloc] initWithObjects:UMShareToWechatSession,UMShareToWechatTimeline,UMShareToQQ,UMShareToSina, nil];
        if (![WXApi isWXAppInstalled] || ![WeiboSDK isWeiboAppInstalled] || ![QQApiInterface isQQInstalled]) {
            [shareToSns addObject:UMShareToSms];
        }
        UIViewController *vc = self.presentedViewController;
        if (!vc)
            vc = self;
        [UMSocialSnsService presentSnsIconSheetView:vc
                                             appKey:@"53bb542e56240ba6e80a4bfb"
                                          shareText:shareText
                                         shareImage:self.photo
                                    shareToSnsNames:shareToSns
                                           delegate:self];
    }
}

- (IBAction)download:(id)sender {
    if (_photo) {
        [self.download_button setEnabled:NO];
        [SVProgressHUD showWithStatus:@"正在保存" maskType:SVProgressHUDMaskTypeClear];
        UIImageWriteToSavedPhotosAlbum(self.photo,self, @selector(downloadComplete:hasBeenSavedInPhotoAlbumWithError:usingContextInfo:), nil);
    }
}

- (void)report {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle: nil];
    ReportViewController *reportVC = [mainStoryboard instantiateViewControllerWithIdentifier: @"ReportViewController"];
    
    reportVC.photoId = self.photoId;
    reportVC.eventId = self.eventId;
    reportVC.event = self.eventName;
    reportVC.type = 3;
    [[SlideNavigationController sharedInstance] pushViewController:reportVC animated:YES];
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
    UIViewController *vc = self;
    if ([vc.parentViewController isKindOfClass:[PhotoBrowserViewController class]]) {
        vc = vc.parentViewController;
    }
    vc.navigationItem.rightBarButtonItem = rightButtonItem;
}

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
    UIViewController *vc = self;
    if ([vc.parentViewController isKindOfClass:[PhotoBrowserViewController class]]) {
        vc = vc.parentViewController;
    }
    vc.navigationItem.rightBarButtonItem = rightButtonItem;
}

- (void)removeOptionBtn {
    UIViewController *vc = self;
    if ([vc.parentViewController isKindOfClass:[PhotoBrowserViewController class]]) {
        vc = vc.parentViewController;
    }
    vc.navigationItem.rightBarButtonItem = nil;
}
- (void)optionBtnPressed {
    if (!self || !self.photoInfo) {
        return;
    }
    NSMutableArray *menuItems = [[NSMutableArray alloc]init];
    
    if ([[self.photoInfo valueForKey:@"author_id"] integerValue] == [[MTUser sharedInstance].userid integerValue] || [self.eventLauncherId integerValue] == [[MTUser sharedInstance].userid integerValue]) {
        [menuItems addObjectsFromArray:@[[KxMenuItem menuItem:@"编辑描述"
                                                        image:nil
                                                       target:self
                                                       action:@selector(editSpecification:)],

                                         [KxMenuItem menuItem:@"删除图片"
                                                        image:nil
                                                       target:self
                                                       action:@selector(deletePhoto:)],
                                         ]];
    }
    
    [menuItems addObjectsFromArray:@[[KxMenuItem menuItem:@"保存图片"
                                                    image:nil
                                                   target:self
                                                   action:@selector(download:)]]];

    if ([[self.photoInfo valueForKey:@"author_id"] integerValue]  != [[MTUser sharedInstance].userid integerValue]) {
        [menuItems addObjectsFromArray:@[[KxMenuItem menuItem:@"举报图片"
                                                        image:nil
                                                       target:self
                                                       action:@selector(report)]]];
    }

    [KxMenu setTintColor:[UIColor whiteColor]];
    [KxMenu setTitleFont:[UIFont systemFontOfSize:17]];
    [KxMenu showMenuInView:self.navigationController.view
                  fromRect:CGRectMake(self.view.bounds.size.width*0.9, 60, 0, 0)
                 menuItems:menuItems];
}

-(void)editSpecification:(UIButton*)button
{
    if (!_canManage) return;
    //进入编辑模式
    if (!self.specificationEditTextfield) {
        //图片浏览页停止滑动
        PhotoBrowserViewController *browser = (PhotoBrowserViewController *)self.parentViewController;
        if (browser && [browser isKindOfClass:[PhotoBrowserViewController class]]) {
            [browser setTableViewScrollEnabled:NO];
        }
        [self hiddenCommentViewAndEmotionView];
        self.specification.hidden = YES;
        
        [self tabbarButtonEdit];
        
        self.tableView.scrollEnabled = NO;
        float height = _photoInfo? ([[_photoInfo valueForKey:@"height"] longValue] *320.0/[[_photoInfo valueForKey:@"width"] longValue]):180;
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
            specificationEditTextfield.placeholder = @"请输入新的图片描述";
            [specificationEditTextfield setFont:[UIFont systemFontOfSize:12]];
            specificationEditTextfield.text = [self.photoInfo valueForKey:@"specification"];
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
        //图片浏览页恢复滑动
        PhotoBrowserViewController *browser = (PhotoBrowserViewController *)self.parentViewController;
        if (browser && [browser isKindOfClass:[PhotoBrowserViewController class]]) {
            [browser setTableViewScrollEnabled:YES];
        }
        [self.specificationEditTextfield removeFromSuperview];
        [self.specificationEditTextfield resignFirstResponder];
        self.specificationEditTextfield = nil;
        [self.shadow removeFromSuperview];
        self.specification.hidden = NO;

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
    [[MTOperation sharedInstance] modifyPhotoSpecification:newSpecification withPhotoId:self.photoId eventId:self.eventId success:^{
        [SVProgressHUD dismissWithSuccess:@"修改成功" afterDelay:1.f];
        self.specification.text = newSpecification;
        [self.photoInfo setValue:newSpecification forKey:@"specification"];
        [MTDatabaseAffairs updatePhotoInfoToDB:@[self.photoInfo] eventId:_eventId];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        [self editSpecification:nil];
    } failure:^(NSString *message) {
        [SVProgressHUD dismissWithError:message afterDelay:1.f];
    }];
}

-(void)deletePhoto:(UIButton*)button
{
    if (!_canManage) return;
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"确定要删除这张照片？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert show];
}

-(void)resendComment:(id)sender
{
    if (![self checkCanManaged]) return;
    id cell = [sender superview];
    while (![cell isKindOfClass:[UITableViewCell class]] ) {
        cell = [cell superview];
    }
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    if (!indexPath) {
        return;
    }
    
    NSString *comment = ((PcommentTableViewCell*)cell).comment.text;
    NSInteger row = indexPath.row;
    NSDictionary* waitingComment = ([_sequence integerValue] == -1)? self.pcomment_list[_pcomment_list.count - row ]:self.pcomment_list[_pcomment_list.count - row + 1];
    [waitingComment setValue:[NSNumber numberWithInt:-1] forKey:@"pcomment_id"];
    
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:[MTUser sharedInstance].userid forKey:@"id"];
    [dictionary setValue:self.photoId forKey:@"photo_id"];
    [dictionary setValue:self.eventId forKey:@"event_id"];
    [dictionary setValue:comment forKey:@"content"];
    [dictionary setValue:[waitingComment valueForKey:@"replied"] forKey:@"replied"];
    
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    
    void (^resendCommentBlock)(void) = ^(void){
        //再次发送评论
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
        MTLOG(@"%@",[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding]);
        HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
        [httpSender sendMessage:jsonData withOperationCode:ADD_PCOMMENT finshedBlock:^(NSData *rData) {
            dispatch_barrier_async(dispatch_get_main_queue(), ^{
                if (rData) {
                    NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
                    NSNumber *cmd = [response1 valueForKey:@"cmd"];
                    if ([cmd integerValue] == PHOTO_NOT_EXIST) {
                        if (!_shouldExit) {
                            _shouldExit = YES;
                            [self deleteLocalData];
                            UIAlertView *alert = [CommonUtils showSimpleAlertViewWithTitle:@"信息" WithMessage:@"图片已删除" WithDelegate:self WithCancelTitle:@"确定"];
                            [alert setTag:1];
                        }
                        return;
                    }
                    if ([cmd integerValue] == NORMAL_REPLY && [response1 valueForKey:@"pcomment_id"]) {
                        [waitingComment setValue:[response1 valueForKey:@"pcomment_id"] forKey:@"pcomment_id"];
                        [waitingComment setValue:[response1 valueForKey:@"time"] forKey:@"time"];
                        [self commentNumPlus];
                    }else{
                        [waitingComment setValue:[NSNumber numberWithInt:-2] forKey:@"pcomment_id"];
                    }
                }else{
                    [waitingComment setValue:[NSNumber numberWithInt:-2] forKey:@"pcomment_id"];
                }
                
                dispatch_barrier_async(dispatch_get_main_queue(), ^{
                    NSInteger row = self.pcomment_list.count - [self.pcomment_list indexOfObject:waitingComment];
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
                if ([cmd integerValue] == NORMAL_REPLY && [response1 valueForKey:@"token"]) {
                    NSString* token = [response1 valueForKey:@"token"];
                    @synchronized(self)
                    {
                        if (![waitingComment valueForKey:@"token"]) {
                            [waitingComment setValue:token forKey:@"token"];
                        }
                    }
                    [dictionary setValue:[waitingComment valueForKey:@"token"] forKey:@"token"];
                    resendCommentBlock();
                    return ;
                }else{
                    [waitingComment setValue:[NSNumber numberWithInt:-2] forKey:@"pcomment_id"];
                }
            }else {
                [waitingComment setValue:[NSNumber numberWithInt:-2] forKey:@"pcomment_id"];
            }
            
            dispatch_barrier_async(dispatch_get_main_queue(), ^{
                NSInteger row = self.pcomment_list.count - [self.pcomment_list indexOfObject:waitingComment];
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
    if (!_photoInfo) return;
    NSString *comment = self.inputTextView.text;
    if ([[comment stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]) {
        self.inputTextView.text = @"";
        return;
    }
    [self.inputTextView resignFirstResponder];
    if (_isEmotionOpen) [self button_Emotionpress:nil];
    self.inputTextView.text = @"";
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self textViewDidChange:self.inputTextView];
        self.inputTextView.text = @"";
    });
    MTLOG(comment,nil);
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    NSMutableDictionary* newComment = [[NSMutableDictionary alloc]init];
    if (_repliedId && [_repliedId integerValue]!=[[MTUser sharedInstance].userid integerValue]){
        [dictionary setValue:_repliedId forKey:@"replied"];
        [newComment setValue:_repliedId forKey:@"replied"];
        [newComment setValue:_herName forKey:@"replier"];
    }
    [dictionary setValue:[MTUser sharedInstance].userid forKey:@"id"];
    [dictionary setValue:self.photoId forKey:@"photo_id"];
    [dictionary setValue:self.eventId forKey:@"event_id"];
    [dictionary setValue:comment forKey:@"content"];
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSString*time = [dateFormatter stringFromDate:[NSDate date]];
    
    [newComment setValue:[NSNumber numberWithInt:0] forKey:@"good"];
    [newComment setValue:_photoId forKey:@"photo_id"];
    [newComment setValue:[MTUser sharedInstance].name forKey:@"author"];
    [newComment setValue:[NSNumber numberWithInt:-1] forKey:@"pcomment_id"];
    [newComment setValue:comment forKey:@"content"];
    [newComment setValue:time forKey:@"time"];
    [newComment setValue:[MTUser sharedInstance].userid forKey:@"author_id"];
    [newComment setValue:[NSNumber numberWithInt:0] forKey:@"isZan"];
    
    
    if ([_pcomment_list isKindOfClass:[NSArray class]]) {
        _pcomment_list = [[NSMutableArray alloc]initWithArray:_pcomment_list];
    }
    [_pcomment_list insertObject:newComment atIndex:0];
    
    NSInteger row = self.pcomment_list.count;
    if ([_sequence integerValue] != -1)
        row ++;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    [_tableView beginUpdates];
    [_tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [_tableView endUpdates];
    [_tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
    self.inputTextView.text = @"";
    [self.inputTextView resignFirstResponder];
    
    void (^sendCommentBlock)(void) = ^(void){
        //发送评论
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
        MTLOG(@"%@",[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding]);
        HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
        [httpSender sendMessage:jsonData withOperationCode:ADD_PCOMMENT finshedBlock:^(NSData *rData) {
            dispatch_barrier_async(dispatch_get_main_queue(), ^{
                if (rData) {
                    NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
                    NSNumber *cmd = [response1 valueForKey:@"cmd"];
                    if ([cmd integerValue] == PHOTO_NOT_EXIST) {
                        if (!_shouldExit) {
                            _shouldExit = YES;
                            [self deleteLocalData];
                            UIAlertView *alert = [CommonUtils showSimpleAlertViewWithTitle:@"信息" WithMessage:@"图片已删除" WithDelegate:self WithCancelTitle:@"确定"];
                            [alert setTag:1];
                        }
                        return;
                    }
                    if ([cmd integerValue] == NORMAL_REPLY && [response1 valueForKey:@"pcomment_id"]) {
                        {
                            [newComment setValue:[response1 valueForKey:@"pcomment_id"] forKey:@"pcomment_id"];
                            [newComment setValue:[response1 valueForKey:@"time"] forKey:@"time"];
                            [self commentNumPlus];
                        }
                    }else{
                        [newComment setValue:[NSNumber numberWithInt:-2] forKey:@"pcomment_id"];
                    }
                }else{
                    [newComment setValue:[NSNumber numberWithInt:-2] forKey:@"pcomment_id"];
                }
                
                dispatch_barrier_async(dispatch_get_main_queue(), ^{
                    NSInteger row = self.pcomment_list.count - [self.pcomment_list indexOfObject:newComment];
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
            if ([cmd integerValue] == NORMAL_REPLY && [response1 valueForKey:@"token"]) {
                NSString* token = [response1 valueForKey:@"token"];
                @synchronized(self)
                {
                    if (![newComment valueForKey:@"token"]) {
                        [newComment setValue:token forKey:@"token"];
                    }
                }
                [dictionary setValue:[newComment valueForKey:@"token"] forKey:@"token"];
                sendCommentBlock();
                return;
                
            }else{
                [newComment setValue:[NSNumber numberWithInt:-2] forKey:@"pcomment_id"];
            }
        }else{
            [newComment setValue:[NSNumber numberWithInt:-2] forKey:@"pcomment_id"];
        }
        
        dispatch_barrier_async(dispatch_get_main_queue(), ^{
            NSInteger row = self.pcomment_list.count - [self.pcomment_list indexOfObject:newComment];
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
    self.inputTextView.text = @"";
    self.inputTextView.placeHolder = @"说点什么吧";
    self.herName = @"";
    self.repliedId = nil;
}

- (void)downloadComplete:(UIImage *)image hasBeenSavedInPhotoAlbumWithError:(NSError *)error usingContextInfo:(void*)ctxInfo{
    [self.download_button setEnabled:YES];
    if (error){
        [SVProgressHUD dismissWithSuccess:@"保存失败" afterDelay:.7f];
    }else{
        [SVProgressHUD dismissWithSuccess:@"保存成功" afterDelay:.7f];
    }
}

-(void)backToDisplay
{
    if (_isKeyBoard) {
        [self.inputTextView resignFirstResponder];
    }else if (_isEmotionOpen)
        [self button_Emotionpress:nil];
    else {
        if (self.photo) {
            BannerViewController* bannerView = [[BannerViewController alloc] init];
            bannerView.banner = self.photo;
            [self presentViewController:bannerView animated:YES completion:^{}];
            UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(photoOptions:)];
            [bannerView.view addGestureRecognizer:longPress];
        }
    }
}

- (void)photoOptions:(UIGestureRecognizer*)sender
{
    if (sender.state != UIGestureRecognizerStateBegan) return;
    
    NSArray *funtion = @[@"图片分享",@"保存图片", @"举报图片"];
    
    if ([self.eventLauncherId isEqualToNumber:[MTUser sharedInstance].userid]) {
        funtion = [funtion subarrayWithRange:NSMakeRange(0, 2)];
    }
    
    JGActionSheetSection *section1 = [JGActionSheetSection sectionWithTitle:nil message:nil buttonTitles:funtion buttonStyle:JGActionSheetButtonStyleDefault];
    JGActionSheetSection *cancelSection = [JGActionSheetSection sectionWithTitle:nil message:nil buttonTitles:@[@"取消"] buttonStyle:JGActionSheetButtonStyleCancel];
    
    NSArray *sections = @[section1, cancelSection];
    
    JGActionSheet *sheet = [JGActionSheet actionSheetWithSections:sections];
    
    [sheet setButtonPressedBlock:^(JGActionSheet *sheet, NSIndexPath *indexPath) {
        if (indexPath.section == 0) {
            switch (indexPath.row) {
                case 0:{
                    [sheet dismissAnimated:YES];
                    [self share:nil];
                }
                    break;
                case 1:{
                    [sheet dismissAnimated:YES];
                    [self download:nil];
                }
                    break;
                case 2:{
                    [sheet dismissAnimated:YES];
                    [self.presentedViewController dismissViewControllerAnimated:YES completion:^{
                        [self report];
                    }];
                }
                    break;
                    
                default:
                    break;
            }
        } else {
            [sheet dismissAnimated:YES];
        }
    }];
    
    [sheet setOutsidePressBlock:^(JGActionSheet *sheet) {
        [sheet dismissAnimated:YES];
    }];
    
    UIViewController *bannerViewController = self.presentedViewController;
    
    [sheet showInView:bannerViewController.view animated:YES];
    
}

-(void)closeRJ
{
    [self.tableView reloadData];
}

-(void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)deleteLocalData
{
    if (_photoId) {
        [self deletePhotoInfoFromDB];
    }
    [[NSNotificationCenter defaultCenter]postNotificationName:@"deletePhotoItem" object:nil userInfo:self.photoInfo];
}

- (void)deletePhotoInfoFromDB
{
    NSDictionary *wheres = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%@",_photoId],@"photo_id", nil];
    [[MTDatabaseHelper sharedInstance]deleteTurpleFromTable:@"eventPhotos" withWhere:wheres];
}


- (void)pushToFriendView:(id)sender {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone"
                                                             bundle: nil];

    FriendInfoViewController *friendView = [mainStoryboard instantiateViewControllerWithIdentifier: @"FriendInfoViewController"];
    friendView.fid = [self.photoInfo valueForKey:@"author_id"];
    [self.navigationController pushViewController:friendView animated:YES];

}


#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger comment_num = 0;
    if (self.pcomment_list) {
        comment_num = [self.pcomment_list count];
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
        float height = _photoInfo? ([[_photoInfo valueForKey:@"height"] longValue] *320.0/[[_photoInfo valueForKey:@"width"] longValue]):180;
        cell = [[UITableViewCell alloc]initWithFrame:CGRectMake(0, 0, 320, self.specificationHeight)];
        if (!self.photoView) {
            self.photoView = [[UIImageView alloc] init];
        }
        [self.photoView setFrame:CGRectMake(0, 0, 320,height)];

        [self.photoView setBackgroundColor:[UIColor colorWithWhite:204.0/255 alpha:1.0f]];
        
        MTImageGetter *imageGetter = [[MTImageGetter alloc]initWithImageView:self.photoView imageId:nil imageName:_photoInfo[@"photo_name"] type:MTImageGetterTypePhoto];
        [imageGetter getImageComplete:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (image) {
                _photo = image;
                [self.photoView setContentMode:UIViewContentModeScaleToFill];
            }else{
                self.photoView.image = [UIImage imageNamed:@"加载失败"];
            }
        }];
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, height, 320, 3)];
        [label setBackgroundColor:[UIColor colorWithRed:252/255.0 green:109/255.0 blue:67/255.0 alpha:1.0]];
        
        [cell addSubview:self.photoView];
        [cell addSubview:label];
        
        UIButton* back = [UIButton buttonWithType:UIButtonTypeCustom];
        [back setFrame:self.photoView.frame];
        [back addTarget:self action:@selector(backToDisplay) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:back];
        
        //显示备注名
        NSString* alias = [[MTUser sharedInstance].alias_dic objectForKey:[NSString stringWithFormat:@"%@",[_photoInfo valueForKey:@"author_id"]]];
        if (alias == nil || [alias isEqual:[NSNull null]] || [alias isEqualToString:@""]) {
            alias = [_photoInfo valueForKey:@"author"];
        }
        
        UILabel* author = [[UILabel alloc]initWithFrame:CGRectMake(50, height+11, 150, 17)];
        [author setFont:[UIFont systemFontOfSize:14]];
        [author setTextColor:[UIColor colorWithRed:0/255.0 green:133/255.0 blue:186/255.0 alpha:1.0]];
        [author setBackgroundColor:[UIColor clearColor]];
        author.text = alias;
        [cell addSubview:author];
        
        UILabel* date = [[UILabel alloc]initWithFrame:CGRectMake(50, height+28, 150, 13)];
        [date setFont:[UIFont systemFontOfSize:11]];
        [date setTextColor:[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0]];
        date.text = [self.photoInfo valueForKey:@"time"];
        [date setBackgroundColor:[UIColor clearColor]];
        [cell addSubview:date];
        
        MTLOG(@"%f",self.specificationHeight);
        CGFloat specificationWidth = CGRectGetWidth(self.view.frame) - 10 - 50;
        if (!self.specification) {
            UILabel* specification = [[UILabel alloc]initWithFrame:CGRectMake(50, CGRectGetMaxY(date.frame)+1, specificationWidth, self.specificationHeight+15)];
            [specification setFont:[UIFont systemFontOfSize:12]];
            [specification setNumberOfLines:0];
            [specification setBackgroundColor:[UIColor clearColor]];
            self.specification = specification;
        }
        [self.specification setFrame:CGRectMake(50, CGRectGetMaxY(date.frame)+1, specificationWidth, self.specificationHeight+15)];
        self.specification.text = [self.photoInfo valueForKey:@"specification"];
        [cell addSubview:self.specification];
        
        //shareBtn
        if (!self.shareButton) {
            self.shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [self.shareButton setImage:[UIImage imageNamed:@"icon_detail_share"] forState:UIControlStateNormal];
            [self.shareButton setImageEdgeInsets:UIEdgeInsetsMake(10, 12, 10, 8)];
            [self.shareButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
            [self.shareButton setTitleColor:[UIColor colorWithRed:0/255.0 green:133/255.0 blue:186/255.0 alpha:1.0] forState:UIControlStateNormal];
            [self.shareButton setTitleColor:[UIColor colorWithRed:0/255.0 green:133/255.0 blue:186/255.0 alpha:0.5] forState:UIControlStateHighlighted];
            [self.shareButton addTarget:self action:@selector(share:) forControlEvents:UIControlEventTouchUpInside];
        }
        [self.shareButton setFrame:CGRectMake(CGRectGetWidth(self.view.frame) - 40 - 40, height + 3 + 2, 40, 40)];
        [cell addSubview:self.shareButton];

        //good button
        if (!self.good_button) {
            self.good_button = [UIButton buttonWithType:UIButtonTypeCustom];
            [self.good_button setImageEdgeInsets:UIEdgeInsetsMake(10, 8, 10, 12)];
            [self.good_button addTarget:self action:@selector(good:) forControlEvents:UIControlEventTouchUpInside];
        }
        [self.good_button setFrame:CGRectMake(CGRectGetWidth(self.view.frame) - 40 , height + 3 + 2, 40, 40)];
        [cell addSubview:self.good_button];
        [self setGoodButton];
        
        if (!self.avatarView) {
            self.avatarView = [[UIImageView alloc] init];
        }
        self.avatarView.frame = CGRectMake(10, height+13, 30, 30);
        PhotoGetter *getter = [[PhotoGetter alloc]initWithData:self.avatarView authorId:[self.photoInfo valueForKey:@"author_id"]];
        [getter getAvatar];
        [cell addSubview:self.avatarView];
        
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
            label.backgroundColor = (_pcomment_list.count == 0)? [UIColor clearColor]:[UIColor colorWithWhite:230.0f/255.0 alpha:1.0f];
            label.tag = 555;
            [cell addSubview:label];
            return cell;
        }
        
        static NSString *CellIdentifier = @"pCommentCell";
        BOOL nibsRegistered = NO;
        if (!nibsRegistered) {
            UINib *nib = [UINib nibWithNibName:NSStringFromClass([PcommentTableViewCell class]) bundle:nil];
            [tableView registerNib:nib forCellReuseIdentifier:CellIdentifier];
            nibsRegistered = YES;
        }
        cell = (PcommentTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        NSDictionary* Pcomment = ([_sequence integerValue] == -1)? self.pcomment_list[_pcomment_list.count - indexPath.row ]:self.pcomment_list[_pcomment_list.count - indexPath.row + 1];
        
        //显示备注名
        NSString* alias = [[MTUser sharedInstance].alias_dic objectForKey:[NSString stringWithFormat:@"%@",[Pcomment valueForKey:@"author_id"]]];
        if (alias == nil || [alias isEqual:[NSNull null]] || [alias isEqualToString:@""]) {
            alias = [Pcomment valueForKey:@"author"];
        }
        
        ((PcommentTableViewCell *)cell).PcommentDict = Pcomment;
        ((PcommentTableViewCell *)cell).author.text = alias;
        ((PcommentTableViewCell *)cell).authorName = alias;
        ((PcommentTableViewCell *)cell).authorId = [Pcomment valueForKey:@"author_id"];
        ((PcommentTableViewCell *)cell).origincomment = [Pcomment valueForKey:@"content"];
        ((PcommentTableViewCell *)cell).controller = self;
        ((PcommentTableViewCell *)cell).date.text = [[Pcomment valueForKey:@"time"] substringWithRange:NSMakeRange(5, 11)];
        float commentWidth = 0;
        ((PcommentTableViewCell *)cell).pcomment_id = [Pcomment valueForKey:@"pcomment_id"];
        if ([[Pcomment valueForKey:@"pcomment_id"] integerValue] == -1 ) {
            commentWidth = 230;
            [((PcommentTableViewCell *)cell).waitView startAnimating];
            [((PcommentTableViewCell *)cell).resend_Button setHidden:YES];
        } else if([[Pcomment valueForKey:@"pcomment_id"] integerValue] == -2 ){
            [((PcommentTableViewCell *)cell).waitView stopAnimating];
            commentWidth = 230;
            [((PcommentTableViewCell *)cell).resend_Button setHidden:NO];
            [((PcommentTableViewCell *)cell).resend_Button addTarget:self action:@selector(resendComment:) forControlEvents:UIControlEventTouchUpInside];
        } else{
            commentWidth = 255;
            [((PcommentTableViewCell *)cell).waitView stopAnimating];
            [((PcommentTableViewCell *)cell).resend_Button setHidden:YES];
        }
        
        PhotoGetter *getter = [[PhotoGetter alloc]initWithData:((PcommentTableViewCell *)cell).avatar authorId:[Pcomment valueForKey:@"author_id"]];
        [getter getAvatar];
        
        NSString* text = [Pcomment valueForKey:@"content"];
        NSString*alias2;
        if ([[Pcomment valueForKey:@"replied"] integerValue] != 0) {
            //显示备注名
            alias2 = [[MTUser sharedInstance].alias_dic objectForKey:[NSString stringWithFormat:@"%@",[Pcomment valueForKey:@"replied"]]];
            if (alias2 == nil || [alias2 isEqual:[NSNull null]] || [alias2 isEqualToString:@""]) {
                alias2 = [Pcomment valueForKey:@"replier"];
            }
            text = [NSString stringWithFormat:@"回复%@ : %@",alias2,text];
        }
        
        int height = [CommonUtils calculateTextHeight:text width:commentWidth fontSize:12.0 isEmotion:YES];
        
        MLEmojiLabel* comment =((PcommentTableViewCell *)cell).comment;
        if (!comment){
            comment = [[MLEmojiLabel alloc]initWithFrame:CGRectMake(50, 24, commentWidth, height)];
            ((PcommentTableViewCell *)cell).comment = comment;
        }
        else [comment setFrame:CGRectMake(50, 24, commentWidth, height)];
        [comment setDisableThreeCommon:YES];
        comment.numberOfLines = 0;
        comment.font = [UIFont systemFontOfSize:12.0f];
        comment.backgroundColor = [UIColor clearColor];
        comment.lineBreakMode = NSLineBreakByCharWrapping;
        comment.emojiText = text;
        //[comment.layer setBackgroundColor:[UIColor clearColor].CGColor];
        [comment setBackgroundColor:[UIColor clearColor]];
        [cell setFrame:CGRectMake(0, 0, 320, 32 + height)];
        
        UIView* backguand = ((PcommentTableViewCell *)cell).background;
        if (!backguand){
            backguand = [[UIView alloc]initWithFrame:CGRectMake(10, 0, 300, 32+height)];
            ((PcommentTableViewCell *)cell).background = backguand;
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
        self.specificationHeight = _photoInfo? [CommonUtils calculateTextHeight:[self.photoInfo valueForKey:@"specification"] width:specificationWidth fontSize:12.0 isEmotion:NO]:0;
        if (self.specificationHeight < 18) {
            self.specificationHeight = 18;
        }
        MTLOG(@"%f",self.specificationHeight);
        height = _photoInfo? ([[_photoInfo valueForKey:@"height"] longValue] *320.0/[[_photoInfo valueForKey:@"width"] longValue]):180;
        height += 3;
        height += 50;
        height += self.specificationHeight;
        height += 5;//margin

    }else{
        if ([_sequence integerValue] != -1 && indexPath.row == 1) {
            return 45;
        }
        NSDictionary* Pcomment = ([_sequence integerValue] == -1)? self.pcomment_list[_pcomment_list.count - indexPath.row ]:self.pcomment_list[_pcomment_list.count - indexPath.row + 1];
        float commentWidth = 0;
        NSString* commentText = [Pcomment valueForKey:@"content"];
        
        NSString*alias2;
        if ([[Pcomment valueForKey:@"replied"] integerValue] != 0) {
            //显示备注名
            alias2 = [[MTUser sharedInstance].alias_dic objectForKey:[NSString stringWithFormat:@"%@",[Pcomment valueForKey:@"replied"]]];
            if (alias2 == nil || [alias2 isEqual:[NSNull null]] || [alias2 isEqualToString:@""]) {
                alias2 = [Pcomment valueForKey:@"replier"];
            }
            commentText = [NSString stringWithFormat:@"回复%@ : %@",alias2,commentText];
        }
        
        
        if ([[Pcomment valueForKey:@"pcomment_id"] integerValue] > 0) {
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
    if (self.isEmotionOpen) {
        [self button_Emotionpress:nil];
        return;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        //[self.navigationController popToViewController:self.photoDisplayController animated:YES];
    }else{
        if ([_sequence integerValue] != -1 && indexPath.row == 1) {
            if (_isLoading) return;
            if (!_photoInfo || [[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == 0) {
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
        MTLOG(@"aaa");
        PcommentTableViewCell *cell = (PcommentTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
        [cell.background setAlpha:0.5];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [cell.background setAlpha:1.0];
        });
        if ([cell.pcomment_id integerValue] < 0){
            [self resendComment: cell.resend_Button];
            return;
        }
        self.herName = cell.authorName;
        if ([cell.authorId integerValue] != [[MTUser sharedInstance].userid integerValue]) {
            self.inputTextView.placeHolder = [NSString stringWithFormat:@"回复%@:",_herName];
        }else self.inputTextView.placeHolder = @"说点什么吧";
        [self.inputTextView becomeFirstResponder];
        self.repliedId = cell.authorId;
    }
}

#pragma mark 代理方法-进入刷新状态就会调用
- (void)refreshViewBeginRefreshing:(MJRefreshBaseView *)refreshView
{
    if (!_photoInfo || [[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == 0) {
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
        self.isEmotionOpen = NO;
    }
    if (self.specificationEditTextfield) {
        return;
    }
    // get keyboard size and loctaion
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    if (CGRectGetHeight(keyboardBounds) == 0) {
        return;
    }
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
    // get a rect for the textView frame
    CGRect containerFrame = self.commentView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - (keyboardBounds.size.height + containerFrame.size.height);
    
    CGRect emotionFrame = _emotionKeyboard.frame;
    emotionFrame.origin.y = self.view.frame.size.height;
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve integerValue]];
    
    // set views with new info
    self.commentView.frame = containerFrame;
    self.emotionKeyboard.frame = emotionFrame;
    
    // commit animations
    [UIView commitAnimations];
}

-(void) keyboardWillHide:(NSNotification *)note{
    self.isKeyBoard = NO;
    if (self.specificationEditTextfield) {
        return;
    }
    if(self.isEmotionOpen) {
        return;
    }
    [self clearCommentView];
    //self.inputField.text = @"";
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // get a rect for the textView frame
    CGRect containerFrame = self.commentView.frame;
    containerFrame.size.height = 45.f;
    containerFrame.origin.y = self.view.bounds.size.height - containerFrame.size.height;
    
    CGRect inputViewFrame = self.inputTextView.frame;
    inputViewFrame.size.height = 36.f;
    
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve integerValue]];
    
    // set views with new info
    self.commentView.frame = containerFrame;
    self.inputTextView.frame = inputViewFrame;
    
    // commit animations
    [UIView commitAnimations];
}

#pragma mark - UMSocialUIDelegate
-(void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response
{
    //根据`responseCode`得到发送结果,如果分享成功
    if(response.responseCode == UMSResponseCodeSuccess)
    {
        //得到分享到的微博平台名
        MTLOG(@"share to sns name is %@",[[response.data allKeys] objectAtIndex:0]);
        [CommonUtils showSimpleAlertViewWithTitle:@"信息" WithMessage:@"成功分享" WithDelegate:self WithCancelTitle:@"确定"];
    }
}
#pragma mark - UITextView Delegate
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
        case 0:{
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
                [dictionary setValue:self.photoId forKey:@"photo_id"];
                HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
                [httpSender sendPhotoMessage:dictionary withOperationCode: UPLOADPHOTO finshedBlock:^(NSData *rData) {
                    if (rData) {
                        NSString* temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
                        MTLOG(@"received Data: %@",temp);
                        NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
                        NSNumber *cmd = [response1 valueForKey:@"cmd"];
                        switch ([cmd integerValue]) {
                            case NORMAL_REPLY:
                            {
                                //百度云 删除
                                CloudOperation * cloudOP = [[CloudOperation alloc]initWithDelegate:self];
                                [cloudOP deletePhoto:[NSString stringWithFormat:@"/images/%@",[self.photoInfo valueForKey:@"photo_name"]]];
                            }
                                break;
                            case PHOTO_NOT_EXIST:
                            {
                                [self deleteLocalData];
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
        [self deleteLocalData];
        [SVProgressHUD dismissWithSuccess:@"图片删除成功" afterDelay:1];
        [self back];
    }else{
        [SVProgressHUD dismissWithError:@"网络异常，请重试" afterDelay:1];
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

@end
