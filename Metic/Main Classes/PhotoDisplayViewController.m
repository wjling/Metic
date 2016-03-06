//
//  PhotoDisplayViewController.m
//  Metic
//
//  Created by ligang6 on 14-7-2.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "PhotoDisplayViewController.h"
#import "PhotoDetailViewController.h"
#import "PhotoBrowserViewController.h"
#import "ReportViewController.h"
#import "MRZoomScrollView.h"
#import "PhotoGetter.h"
#import "CommonUtils.h"
#import "NSString+JSON.h"
#import "Reachability.h"
#import "LCAlertView.h"
#import "MTDatabaseHelper.h"
#import "MTDatabaseAffairs.h"
#import "MegUtils.h"
#import "MTImageGetter.h"
#import "MTOperation.h"
#import "JGActionSheet.h"
#import "SVProgressHUD.h"
#import "SocialSnsApi.h"

@interface PhotoDisplayViewController () <UMSocialUIDelegate>
@property BOOL isZan;
@property int goodindex;
@property int lastViewIndex;
@property int movedown;
@property (nonatomic,strong)UIView* shadowView;
@property (nonatomic,strong)UIView* optionView;
@property (nonatomic,weak) UIImage* photo;
@end

@implementation PhotoDisplayViewController

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
    //[self.navigationController setNavigationBarHidden:YES animated:NO];
    
    self.view.autoresizesSubviews = YES;
    self.lastViewIndex = self.photoIndex;
    self.photos = [[NSMutableDictionary alloc]init];
    CGRect frame = self.view.bounds;
    self.scrollView = [[UIScrollView alloc]initWithFrame:frame];
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.scrollView setPagingEnabled:YES];
    self.scrollView.delegate = self;
    [self.scrollView setClipsToBounds:YES];
    [self.scrollView setContentSize:CGSizeMake(320*self.photo_list.count, self.view.bounds.size.height)];
    [self.scrollView setContentOffset:CGPointMake(320*self.photoIndex, 0)];
    [self.scrollView setShowsHorizontalScrollIndicator:NO];
    [self.scrollView setShowsVerticalScrollIndicator:NO];
    [self.view addSubview:self.scrollView];

    [self.InfoView setHidden:YES];
    [self.view bringSubviewToFront:self.InfoView];
    //单击手势
    UITapGestureRecognizer * singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap)];
    singleRecognizer.numberOfTapsRequired=1;
    //双击手势
    UITapGestureRecognizer * doubleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap)];
    doubleRecognizer.numberOfTapsRequired=2;
    //长按手势
    UILongPressGestureRecognizer * longRecognizer = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(showOption:)];
    [singleRecognizer requireGestureRecognizerToFail:doubleRecognizer];
    [self.scrollView addGestureRecognizer:singleRecognizer];
    [self.scrollView addGestureRecognizer:doubleRecognizer];
    [self.scrollView addGestureRecognizer:longRecognizer];
    
    [self displaythreePhoto:self.photoIndex];
    [self showInFullScreen];

    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.commentImg.image = [UIImage imageNamed:@"评论icon"];
    [self refreshGood];
    UIDevice *device = [UIDevice currentDevice]; //Get the device object
    [device beginGeneratingDeviceOrientationNotifications]; //Tell it to start monitoring the accelerometer for orientation
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter]; //Get the notification centre for the app
    [nc addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification  object:device];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self fixUI];
    [self showInFullScreen];
}

-(void)viewWillDisappear:(BOOL)animated {
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    UIDevice *device = [UIDevice currentDevice]; //Get the device object
    [nc removeObserver:self name:UIDeviceOrientationDidChangeNotification object:device];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self leaveFullScreen];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

//返回上一层
-(void)MTpopViewController{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)fixUI
{
    for (NSString* key in [_photos keyEnumerator]) {
        MRZoomScrollView* zoomView = [_photos valueForKey:key];
        if (zoomView) {
            [zoomView fitImageView];
        }
    }
    [self.scrollView setContentSize:CGSizeMake(320*self.photo_list.count, self.view.bounds.size.height)];
}

-(void)rotation:(float)n {
    MTLOG(@"%dth",_lastViewIndex);
    float offsetX = (int)n%180 == 0? self.view.bounds.size.width:self.view.bounds.size.height;
    CGPoint contentOffset = CGPointMake(_lastViewIndex*offsetX, 0);
    [UIView animateWithDuration:0.5 animations:^{
        
        MTLOG(@"aft %f  %f",self.view.frame.size.width,self.view.bounds.size.width);
        
        _scrollView.transform = CGAffineTransformMakeRotation(n*M_PI/180.0);
        _scrollView.frame = self.view.bounds;
        _scrollView.contentOffset = contentOffset;
        for (NSString* key in [_photos keyEnumerator]) {
            MRZoomScrollView* zoomView = [_photos valueForKey:key];
            if (zoomView) {
                [zoomView fitImageView];
            }
        }
        
    } completion:^(BOOL finished) {
        [self.scrollView setContentSize:CGSizeMake(_scrollView.bounds.size.width*self.photo_list.count, _scrollView.bounds.size.height)];
        
    }];
    
}

- (void)orientationChanged:(NSNotification *)note  {
    if (!self.navigationController.navigationBarHidden) return;
    UIDeviceOrientation o = [[UIDevice currentDevice] orientation];
    switch (o) {
        case UIDeviceOrientationPortrait:            // Device oriented vertically, home button on the bottom
            MTLOG(@"UIDeviceOrientationPortrait");
            [self rotation:0.0];
            break;
        case UIDeviceOrientationPortraitUpsideDown:  // Device oriented vertically, home button on the top
            MTLOG(@"UIDeviceOrientationPortraitUpsideDown");
            [self rotation:180.0];
            break;
        case UIDeviceOrientationLandscapeLeft:      // Device oriented horizontally, home button on the right
            MTLOG(@"UIDeviceOrientationLandscapeLeft");
            [self rotation:90.0];
            break;
        case UIDeviceOrientationLandscapeRight:      // Device oriented horizontally, home button on the left
            MTLOG(@"UIDeviceOrientationLandscapeRight");
            [self rotation:90.0*3];
            break;
        default:
            break;
    }
}

-(void)refreshGood
{
    if (self.navigationController.navigationBarHidden) return;
    int index = self.scrollView.contentOffset.x/320;
    NSDictionary* dict = self.photo_list[index];
    self.zan_num.text = [NSString stringWithFormat:@"%@",[dict valueForKey:@"good"]];
    if ([dict valueForKey:@"comment_num"]) {
        self.comment_num.text = [NSString stringWithFormat:@"%@",[dict valueForKey:@"comment_num"]];
    }else self.comment_num.text = @"";
    BOOL iszan = [[self.photo_list[index] valueForKey:@"isZan"]boolValue];
    UIImage* zanImage = !iszan? [UIImage imageNamed:@"点赞icon"]:[UIImage imageNamed:@"实心点赞图"];
    self.goodImg.image = zanImage;
}

-(void)loadPictureDescription
{
    if (self.navigationController.navigationBarHidden) return;
    int index = self.scrollView.contentOffset.x/320;
    
    NSDictionary* dict = self.photo_list[index];
    if ([dict valueForKey:@"good"]) {
        self.zan_num.text = [NSString stringWithFormat:@"%@",[dict valueForKey:@"good"]];
    }else self.zan_num.text = @"";
    BOOL iszan = [[self.photo_list[index] valueForKey:@"isZan"]boolValue];
    UIImage* zanImage = !iszan? [UIImage imageNamed:@"点赞icon"]:[UIImage imageNamed:@"实心点赞图"];
    self.commentImg.image = [UIImage imageNamed:@"评论icon"];
    self.goodImg.image = zanImage;
    if ([dict valueForKey:@"comment_num"]) {
        self.comment_num.text = [NSString stringWithFormat:@"%@",[dict valueForKey:@"comment_num"]];
    }else self.comment_num.text = @"";
    NSString* specification = [dict valueForKey:@"specification"];
    if (specification && ![specification isEqualToString:@""]) {
        self.pictureDescription.hidden = NO;
        self.pictureDescription.text = specification;
    }else{
        self.pictureDescription.hidden = YES;
        self.pictureDescription.text = @"";
    }
    self.pictureDescription.text = [dict valueForKey:@"specification"];
    //显示备注名
    NSString *alias = [MTOperation getAliasWithUserId:dict[@"author_id"] userName:dict[@"author"]];
    self.pictureAuthor.text = alias;
    self.publishTime.text = [[dict valueForKey:@"time"] substringToIndex:10];
    self.photoId = [dict valueForKey:@"photo_id"];
    PhotoGetter *getter = [[PhotoGetter alloc]initWithData:self.avatar authorId:[dict valueForKey:@"author_id"]];
    [getter getAvatar];

}

-(void)handleSingleTap
{
    PhotoBrowserViewController *viewController = (PhotoBrowserViewController *)self.navigationController.viewControllers[self.navigationController.viewControllers.count - 2];
    if ([viewController isKindOfClass:[PhotoBrowserViewController class]]) {
        [viewController showPhotoInIndex:self.lastViewIndex];
    }
    [self leaveFullScreen];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showInFullScreen {
    [UIView animateWithDuration:0.5 animations:^{
        if(self.navigationController.navigationBarHidden){
            return ;
            [self.navigationController setNavigationBarHidden:NO];
            [[UIApplication sharedApplication] setStatusBarHidden:NO];
            [self rotation:0.0];
            [self loadPictureDescription];
//            [self.InfoView setHidden:NO];
            [self.view bringSubviewToFront:self.InfoView];
        }else{
            [self.navigationController setNavigationBarHidden:YES];
            [[UIApplication sharedApplication] setStatusBarHidden:YES];
//            [self.InfoView setHidden:YES];
            
        }
        for (NSString* key in [_photos keyEnumerator]) {
            MRZoomScrollView* zoomView = [_photos valueForKey:key];
            if (zoomView) {
                [zoomView fitImageView];
            }
        }
    }];
}

- (void)leaveFullScreen {
    [UIView animateWithDuration:0.5 animations:^{
        if(self.navigationController.navigationBarHidden){
            [self.navigationController setNavigationBarHidden:NO];
            [[UIApplication sharedApplication] setStatusBarHidden:NO];
            [self rotation:0.0];
            [self loadPictureDescription];
//            [self.InfoView setHidden:NO];
            [self.view bringSubviewToFront:self.InfoView];
        }else{
            return ;
            [self.navigationController setNavigationBarHidden:YES];
            [[UIApplication sharedApplication] setStatusBarHidden:YES];
//            [self.InfoView setHidden:YES];
            
        }
        for (NSString* key in [_photos keyEnumerator]) {
            MRZoomScrollView* zoomView = [_photos valueForKey:key];
            if (zoomView) {
                [zoomView fitImageView];
            }
        }
    }];
}

-(void)handleDoubleTap
{
}

-(void)showOption:(UIGestureRecognizer*)sender
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
                    [self report];
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
    
    [sheet showInView:self.view animated:YES];
        
    
    
    return;
    
    
    if (self.navigationController.navigationBarHidden) return;
    if (sender.state != UIGestureRecognizerStateBegan) return;
    int index = self.scrollView.contentOffset.x/320;
    NSNumber* authorId = [self.photo_list[index] valueForKey:@"author_id"];
    if ([authorId integerValue] == [[MTUser sharedInstance].userid integerValue]) {
    }else{
        LCAlertView *alert = [[LCAlertView alloc]initWithTitle:@"操作" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"举报",nil];
        alert.alertAction = ^(NSInteger buttonIndex){
            if (buttonIndex == 1) {
                [self report];
            }
        };
        [alert show];
    }

    return;
    if (sender.state == UIGestureRecognizerStateBegan) {
        MTLOG(@"showOption");
        if (!_shadowView) {
            CGRect frame = self.view.frame;
            frame.origin = CGPointMake(0, 0);
            _shadowView = [[UIView alloc]initWithFrame:frame];
            [_shadowView setBackgroundColor:[UIColor blackColor]];
            [_shadowView setAlpha:0.7];
            //单击手势
            UITapGestureRecognizer * singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissOption)];
            [_shadowView addGestureRecognizer:singleRecognizer];
            
            UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
            _optionView = button;
            frame.origin = CGPointMake(40, (frame.size.height - 40)/2);
            frame.size = CGSizeMake(frame.size.width-80, 40);
            [button setFrame:frame];
            [button setTitle:@"匿名举报" forState:UIControlStateNormal];
            [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
            [button addTarget:self action:@selector(report) forControlEvents:UIControlEventTouchUpInside];
            [button setUserInteractionEnabled:YES];
            [self.view addSubview:_shadowView];
            [self.view addSubview:button];
            [button setBackgroundColor:[UIColor whiteColor]];
            [button.layer setBorderColor:[UIColor darkGrayColor].CGColor];
            [button.layer setBorderWidth:2];
            button.layer.masksToBounds = YES;
            [button.layer setCornerRadius:5];
            [button setAlpha:1.0];
        }

    }
}

-(void)dismissOption
{
    MTLOG(@"dismissOption");
    if (_shadowView) {
        [_shadowView removeFromSuperview];
        _shadowView = nil;
    }
    if (_optionView) {
        [_optionView removeFromSuperview];
        _optionView = nil;
    }
}

-(void)report{
    MTLOG(@"匿名投诉");
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self leaveFullScreen];
        [self performSegueWithIdentifier:@"photoToreport" sender:self];
    });
}
-(void)displaythreePhoto:(int)photoIndex
{
    [self displaynthPhoto:photoIndex];
    [self loadPictureDescription];
    photoIndex++;
    if (photoIndex>=0 && photoIndex<self.photo_list.count) {
        [self displaynthPhoto:photoIndex];
    }
    photoIndex-=2;
    if (photoIndex>=0 && photoIndex<self.photo_list.count) {
        [self displaynthPhoto:photoIndex];
    }
}

-(void)displaynthPhoto:(int)photoIndex
{
    MRZoomScrollView *photoScrollView = [self.photos valueForKey:[NSString stringWithFormat:@"%d",photoIndex]];
    if (photoScrollView) {
        return;
    }
    MRZoomScrollView* zoomScrollView = [[MRZoomScrollView alloc]init];
    zoomScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |UIViewAutoresizingFlexibleTopMargin |UIViewAutoresizingFlexibleBottomMargin;
    float containerWidth = _scrollView.bounds.size.width;
    float containerHeight = _scrollView.bounds.size.height;
    [zoomScrollView setFrame:CGRectMake(containerWidth*photoIndex+2,0,containerWidth - 4, containerHeight)];

    [self.photos setValue:zoomScrollView forKey:[NSString stringWithFormat:@"%d",photoIndex]];
    
    MTImageGetter *imageGetter = [[MTImageGetter alloc]initWithImageView:zoomScrollView.imageView imageId:nil imageName:_photo_list[photoIndex][@"photo_name"] type:MTImageGetterTypePhoto];
    [imageGetter getImageComplete:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (image) {
            if (photoIndex == self.lastViewIndex) {
                self.photo = image;
            }
            [zoomScrollView fitImageView];
        }else{
            zoomScrollView.imageView.image = [UIImage imageNamed:@"加载失败"];
            [zoomScrollView fitImageView];
        }
    }];
    
    if (zoomScrollView.imageView.image) {
        [zoomScrollView fitImageView];
    }
    
    [self.scrollView addSubview:zoomScrollView];
}


#pragma mark - UiScrollViewDelegate
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    float containerWidth = _scrollView.bounds.size.width;
    int position = self.scrollView.contentOffset.x/containerWidth;
    if (self.lastViewIndex != position) {
        MRZoomScrollView *photoScrollView = [self.photos valueForKey:[NSString stringWithFormat:@"%d",self.lastViewIndex]];
        [photoScrollView zoomToNormal];
    }
    self.lastViewIndex = position;
    [self displaythreePhoto:position];
}


- (IBAction)appreciate:(id)sender {
    if (!_canManage) return;
    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == 0) {
        [CommonUtils showSimpleAlertViewWithTitle:@"信息" WithMessage:@"网络异常" WithDelegate:self WithCancelTitle:@"确定"];
        return;
    }

    self.goodindex = self.scrollView.contentOffset.x/320;
    BOOL isZan = [[self.photo_list[self.goodindex] valueForKey:@"isZan"]boolValue];

    [[MTOperation sharedInstance] likeOperationWithType:MTMediaTypePhoto mediaId:self.photoId eventId:self.eventId like:!isZan finishBlock:NULL];
    
    NSMutableDictionary* dict = self.photo_list[self.goodindex];
    BOOL iszan = [[dict valueForKey:@"isZan"]boolValue];
    int zan_number = [[dict valueForKey:@"good"]intValue];
    if (iszan) {
        zan_number --;
        self.goodImg.image = [UIImage imageNamed:@"点赞icon"];
        
    }else{
        zan_number ++;
        self.goodImg.image = [UIImage imageNamed:@"实心点赞图"];
    }
    self.zan_num.text = [NSString stringWithFormat:@"%d",zan_number];
    [dict setValue:[NSNumber numberWithBool:!iszan] forKey:@"isZan"];
    [dict setValue:[NSNumber numberWithInt:zan_number] forKey:@"good"];
    [MTDatabaseAffairs updatePhotoInfoToDB:@[dict] eventId:self.eventId];
}

- (IBAction)comment:(id)sender {
    self.commentImg.image = [UIImage imageNamed:@"评论icon"];

    int index = self.scrollView.contentOffset.x/320;
    NSDictionary* photoInfo = self.photo_list[index];
    if ([photoInfo valueForKey:@"alasset"]) return;
    [self performSegueWithIdentifier:@"displayTophotoDetail" sender:self];
    
}

- (IBAction)comment_buttonDown:(id)sender {
    self.commentImg.image = [UIImage imageNamed:@"评论按下按钮icon"];
}

#pragma mark - function 
- (void)share:(id)sender {
    if (self.photo) {
        NSString *shareText = self.pictureDescription.text;
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

- (void)download:(id)sender {
    if (_photo) {
        [SVProgressHUD showWithStatus:@"正在保存" maskType:SVProgressHUDMaskTypeClear];
        UIImageWriteToSavedPhotosAlbum(self.photo,self, @selector(downloadComplete:hasBeenSavedInPhotoAlbumWithError:usingContextInfo:), nil);
    }
}

- (void)downloadComplete:(UIImage *)image hasBeenSavedInPhotoAlbumWithError:(NSError *)error usingContextInfo:(void*)ctxInfo{
    if (error){
        // Do anything needed to handle the error or display it to the user
    }else{
        [SVProgressHUD showSuccessWithStatus:@"保存成功" duration:0.7f];
    }
}

#pragma mark 用segue跳转时传递参数eventid
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //这里我很谨慎的对sender和目标视图控制器作了判断
    if ([segue.sourceViewController isKindOfClass:[PhotoDisplayViewController class]]) {
        if ([segue.destinationViewController isKindOfClass:[PhotoDetailViewController class]]) {
            
            PhotoDetailViewController *nextViewController = segue.destinationViewController;
            int index = self.scrollView.contentOffset.x/320;
            
            nextViewController.photoId = [self.photo_list[index] valueForKey:@"photo_id"];
            nextViewController.eventLauncherId = self.eventLauncherId;
            nextViewController.eventId = _eventId;
            nextViewController.photoInfo = self.photo_list[index];
            nextViewController.photoDisplayController = self;
            nextViewController.eventName = _eventName;
            nextViewController.canManage = self.canManage;
        }
        if ([segue.destinationViewController isKindOfClass:[ReportViewController class]]) {
            
            ReportViewController *nextViewController = segue.destinationViewController;
            int index = self.scrollView.contentOffset.x/320;
            
            nextViewController.photoId = [self.photo_list[index] valueForKey:@"photo_id"];
            nextViewController.eventId = _eventId;
            nextViewController.event = self.eventName;
            nextViewController.type = 3;
        }
        
    }
}

#pragma mark - UIGestureRecognizer Delegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    UIView* touchedView = [touch view];
    if([touchedView isKindOfClass:[UIButton class]]) {
        
        return NO;
    }
    
    return YES;
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

@end
