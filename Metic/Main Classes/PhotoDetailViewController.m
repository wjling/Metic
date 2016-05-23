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
#import "MTMediaInfoView.h"
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
@property (nonatomic,strong)MTMediaInfoView *photoInfoView;
@property (nonatomic,strong)UIButton *edit_button;
@property (nonatomic,strong)UIButton *editFinishButton;
@property (nonatomic,strong)UIButton *optionButton;
@property (nonatomic,strong)UIButton *shareButton;
//@property (nonatomic,strong)UILabel *specification;
@property (nonatomic,strong)UIButton *shadow;
@property (nonatomic,strong)UITextField *specificationEditTextfield;
@property (strong, nonatomic) UIButton *good_button;
@property (strong, nonatomic) IBOutlet UIButton *download_button;
@property float specificationHeight;
@property (strong, nonatomic) IBOutlet UIView *controlView;
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
    [MobClick beginLogPageView:@"图片主页"];
    [self.textInputView addKeyboardObserver];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [MobClick endLogPageView:@"图片主页"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.textInputView dismissKeyboard];
    [self.textInputView removeKeyboardObserver];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    self.textInputView = [[MTTextInputView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame) - 45, kMainScreenWidth, 45)];
    self.textInputView.delegate = self;
    [self.view addSubview:self.textInputView];
}

-(void)initData
{
    self.sequence = @0;
    self.Footeropen = NO;
    self.shouldExit = NO;
    self.isLoading = YES;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.pcomment_list = [[NSMutableArray alloc]init];
    //[self initButtons];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
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

- (void)hiddenCommentViewAndEmotionView {
    [self.textInputView dismissKeyboard];
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
    [self.photoInfoView setupLikeButton];
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
    self.textInputView.placeHolder = @"说点什么吧";
    [self.textInputView openKeyboard];
}

- (IBAction)share:(id)sender {
    if (self.photoInfoView.photo) {
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
        
        UIViewController *delegate = self;
        if ([self.parentViewController isKindOfClass:[PhotoBrowserViewController class]]) {
            delegate = self.parentViewController;
        }

        [UMSocialSnsService presentSnsIconSheetView:[SlideNavigationController sharedInstance]
                                             appKey:@"53bb542e56240ba6e80a4bfb"
                                          shareText:shareText
                                         shareImage:self.photoInfoView.photo
                                    shareToSnsNames:shareToSns
                                           delegate:delegate];
    }
}

- (IBAction)download:(id)sender {
    if (self.photoInfoView.photo) {
        [self.download_button setEnabled:NO];
        [SVProgressHUD showWithStatus:@"正在保存" maskType:SVProgressHUDMaskTypeClear];
        UIImageWriteToSavedPhotosAlbum(self.photoInfoView.photo,self, @selector(downloadComplete:hasBeenSavedInPhotoAlbumWithError:usingContextInfo:), nil);
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
                                         
                                         [KxMenuItem menuItem:@"保存图片"
                                                        image:nil
                                                       target:self
                                                       action:@selector(download:)],

                                         [KxMenuItem menuItem:@"删除图片"
                                                        image:nil
                                                       target:self
                                                       action:@selector(deletePhoto:)],
                                         ]];
    }else {
        [menuItems addObjectsFromArray:@[[KxMenuItem menuItem:@"保存图片"
                                                        image:nil
                                                       target:self
                                                       action:@selector(download:)]]];
    }

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
        self.photoInfoView.descriptionLabel.hidden = YES;

        [self tabbarButtonEdit];
        
        self.tableView.scrollEnabled = NO;
        float height = CGRectGetMaxY(self.photoInfoView.photoView.superview.frame);
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
            CGRect textfieldFrame = self.photoInfoView.descriptionLabel.frame;
            textfieldFrame.size.height = 30;
            textfieldFrame.origin.y = 80 + 5;
            UITextField* specificationEditTextfield = [[UITextField alloc]initWithFrame:textfieldFrame];
            specificationEditTextfield.placeholder = @"请输入新的图片描述";
            [specificationEditTextfield setFont:[UIFont systemFontOfSize:14]];
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
        self.photoInfoView.descriptionLabel.hidden = NO;

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
        [self.photoInfo setValue:newSpecification forKey:@"specification"];
        [MTDatabaseAffairs updatePhotoInfoToDB:@[self.photoInfo] eventId:_eventId];
        [self.tableView reloadData];
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

- (void)publishComment:(id)sender {
    if (![self checkCanManaged]) return;
    if (!_photoInfo) return;
    NSString *comment = self.textInputView.text;
    NSString *herName = self.herName;
    NSNumber *repliedId = self.repliedId;
    
    [self.textInputView clear];

    if ([[comment stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]) {
        [self.textInputView clear];
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
    [self.textInputView clear];
    self.textInputView.placeHolder = @"说点什么吧";
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
    if (![self.textInputView dismissKeyboard]) {
        if ([self.parentViewController isKindOfClass:[PhotoBrowserViewController class]]) {
            PhotoBrowserViewController *browserVC = (PhotoBrowserViewController *)self.parentViewController;
            [browserVC showPhotos];
        } else if(self.photoInfoView.photo){
            BannerViewController* bannerView = [[BannerViewController alloc] init];
            bannerView.banner = self.photoInfoView.photo;
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
        if (!self.photoInfoView) {
            static NSString *CellIdentifier = @"pPhotoInfoView";
            UINib *nib = [UINib nibWithNibName:NSStringFromClass([MTMediaInfoView class]) bundle:nil];
            [tableView registerNib:nib forCellReuseIdentifier:CellIdentifier];
            self.photoInfoView = (MTMediaInfoView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backToDisplay)];
            [self.photoInfoView.photoView addGestureRecognizer:tap];
            
            [self.photoInfoView.likeBtn addTarget:self action:@selector(good:) forControlEvents:UIControlEventTouchUpInside];
            [self.photoInfoView.shareBtn addTarget:self action:@selector(share:) forControlEvents:UIControlEventTouchUpInside];

        }
        [self.photoInfoView applyData:self.photoInfo type:MTMediaTypePhoto containerWidth:CGRectGetWidth(self.view.frame)];
        
        return self.photoInfoView;
        
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
        NSString* alias = [MTOperation getAliasWithUserId:Pcomment[@"author_id"] userName:Pcomment[@"author"]];
        
        ((PcommentTableViewCell *)cell).PcommentDict = Pcomment;
        ((PcommentTableViewCell *)cell).author.text = alias;
        ((PcommentTableViewCell *)cell).authorName = alias;
        ((PcommentTableViewCell *)cell).authorId = [Pcomment valueForKey:@"author_id"];
        ((PcommentTableViewCell *)cell).origincomment = [Pcomment valueForKey:@"content"];
        ((PcommentTableViewCell *)cell).controller = self;
        ((PcommentTableViewCell *)cell).date.text = [CommonUtils calculateTimeStr:Pcomment[@"time"] shortVersion:NO];
        float commentWidth = 0;
        ((PcommentTableViewCell *)cell).pcomment_id = [Pcomment valueForKey:@"pcomment_id"];
        if ([[Pcomment valueForKey:@"pcomment_id"] integerValue] == -1 ) {
            commentWidth = kMainScreenWidth - 90;
            [((PcommentTableViewCell *)cell).waitView startAnimating];
            [((PcommentTableViewCell *)cell).resend_Button setHidden:YES];
        } else if([[Pcomment valueForKey:@"pcomment_id"] integerValue] == -2 ){
            [((PcommentTableViewCell *)cell).waitView stopAnimating];
            commentWidth = kMainScreenWidth - 90;
            [((PcommentTableViewCell *)cell).resend_Button setHidden:NO];
            [((PcommentTableViewCell *)cell).resend_Button addTarget:self action:@selector(resendComment:) forControlEvents:UIControlEventTouchUpInside];
        } else{
            commentWidth = kMainScreenWidth - 65;
            [((PcommentTableViewCell *)cell).waitView stopAnimating];
            [((PcommentTableViewCell *)cell).resend_Button setHidden:YES];
        }
        
        PhotoGetter *getter = [[PhotoGetter alloc]initWithData:((PcommentTableViewCell *)cell).avatar authorId:[Pcomment valueForKey:@"author_id"]];
        [getter getAvatar];
        
        NSString* text = [Pcomment valueForKey:@"content"];
        NSString*alias2;
        if ([[Pcomment valueForKey:@"replied"] integerValue] != 0) {
            //显示备注名
            alias2 = [MTOperation getAliasWithUserId:Pcomment[@"replied"] userName:Pcomment[@"replier"]];

            text = [NSString stringWithFormat:@"回复%@ : %@",alias2,text];
        }
        
        float height = [CommonUtils calculateTextHeight:text width:commentWidth fontSize:12.0 isEmotion:YES];
        
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
        [cell setFrame:CGRectMake(0, 0, kMainScreenWidth, 32 + height)];
        
        UIView* backguand = ((PcommentTableViewCell *)cell).background;
        if (!backguand){
            backguand = [[UIView alloc]initWithFrame:CGRectMake(10, 0, kMainScreenWidth - 20, 32+height)];
            ((PcommentTableViewCell *)cell).background = backguand;
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
        
        height = [MTMediaInfoView calculateCellHeightwithMediaInfo:self.photoInfo type:MTMediaTypePhoto containerWidth:CGRectGetWidth(self.view.frame)];
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
            alias2 = [MTOperation getAliasWithUserId:Pcomment[@"replied"] userName:Pcomment[@"replier"]];
            commentText = [NSString stringWithFormat:@"回复%@ : %@",alias2,commentText];
        }
        
        
        if ([[Pcomment valueForKey:@"pcomment_id"] integerValue] > 0) {
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
        PcommentTableViewCell *cell = (PcommentTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
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
        PcommentTableViewCell *cell = (PcommentTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
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
        if ([cell.pcomment_id integerValue] < 0){
            [self resendComment: cell.resend_Button];
            return;
        }
        self.herName = cell.authorName;
        if ([cell.authorId integerValue] != [[MTUser sharedInstance].userid integerValue]) {
            self.textInputView.placeHolder = [NSString stringWithFormat:@"回复%@:",_herName];
        }else self.textInputView.placeHolder = @"说点什么吧";
        [self.textInputView openKeyboard];
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

#pragma mark - UMSocialUIDelegate
-(void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response
{
    //根据`responseCode`得到发送结果,如果分享成功
    if(response.responseCode == UMSResponseCodeSuccess)
    {
        //得到分享到的微博平台名
        MTLOG(@"share to sns name is %@",[[response.data allKeys] objectAtIndex:0]);
        [SVProgressHUD showSuccessWithStatus:@"分享成功" duration:2.f];
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

#pragma mark - MTTextInputView delegate
- (void)textInputView:(MTTextInputView *)textInputView sendMessage:(NSString *)message {
    [self publishComment:nil];
}

@end
