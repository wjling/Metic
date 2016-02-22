//
//  PhotoDisplayViewController.m
//  Metic
//
//  Created by ligang6 on 14-7-2.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "PhotoDisplayViewController.h"
#import "PhotoDetailViewController.h"
#import "ReportViewController.h"
#import "MRZoomScrollView.h"
#import "PhotoGetter.h"
#import "CommonUtils.h"
#import "NSString+JSON.h"
#import "Reachability.h"
#import "LCAlertView.h"
#import "MTDatabaseHelper.h"
#import "MegUtils.h"
#import "MTImageGetter.h"


@interface PhotoDisplayViewController ()
@property BOOL isZan;
@property int goodindex;
@property int lastViewIndex;
@property int movedown;
@property (nonatomic,strong)SDWebImageManager *manager;
@property (nonatomic,strong)UIView* shadowView;
@property (nonatomic,strong)UIView* optionView;
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
    
    //[self.InfoView setHidden:YES];
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
    _manager = [SDWebImageManager sharedManager];
    [self.InfoView setHidden:NO];
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
    [self fixUI];
}

-(void)viewWillDisappear:(BOOL)animated {
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    UIDevice *device = [UIDevice currentDevice]; //Get the device object
    [nc removeObserver:self name:UIDeviceOrientationDidChangeNotification object:device];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//

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


- (void)updatePhotoInfoToDB:(NSDictionary*)photoInfo
{
    NSString *photoInfoS = [NSString jsonStringWithDictionary:photoInfo];
    NSArray *columns = [[NSArray alloc]initWithObjects:@"'photo_id'",@"'event_id'",@"'photoInfo'", nil];
    NSArray *values = [[NSArray alloc]initWithObjects:[NSString stringWithFormat:@"%@",[photoInfo valueForKey:@"photo_id"]],[NSString stringWithFormat:@"%@",_eventId],[NSString stringWithFormat:@"'%@'",photoInfoS], nil];
    [[MTDatabaseHelper sharedInstance]insertToTable:@"eventPhotos" withColumns:columns andValues:values];
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
    NSString* alias = [[MTUser sharedInstance].alias_dic objectForKey:[NSString stringWithFormat:@"%@",[dict valueForKey:@"author_id"]]];
    if (alias == nil || [alias isEqual:[NSNull null]] || [alias isEqualToString:@""]) {
        alias = [dict valueForKey:@"author"];
    }
    self.pictureAuthor.text = alias;
    self.publishTime.text = [[dict valueForKey:@"time"] substringToIndex:10];
    self.photoId = [dict valueForKey:@"photo_id"];
    PhotoGetter *getter = [[PhotoGetter alloc]initWithData:self.avatar authorId:[dict valueForKey:@"author_id"]];
    [getter getAvatar];
    
    
    
}





-(void)handleSingleTap
{
    [UIView animateWithDuration:0.5 animations:^{
        if(self.navigationController.navigationBarHidden){
            [self.navigationController setNavigationBarHidden:NO];
            [[UIApplication sharedApplication] setStatusBarHidden:NO];
            [self rotation:0.0];
            [self loadPictureDescription];
            [self.InfoView setHidden:NO];
            [self.view bringSubviewToFront:self.InfoView];
        }else{
            [self.navigationController setNavigationBarHidden:YES];
            [[UIApplication sharedApplication] setStatusBarHidden:YES];
            [self.InfoView setHidden:YES];

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
    if (self.navigationController.navigationBarHidden) return;
    if (sender.state != UIGestureRecognizerStateBegan) return;
    int index = self.scrollView.contentOffset.x/320;
    NSNumber* authorId = [self.photo_list[index] valueForKey:@"author_id"];
    if ([authorId integerValue] == [[MTUser sharedInstance].userid integerValue]) {
//        LCAlertView *alert = [[LCAlertView alloc]initWithTitle:@"操作" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"删除",@"举报",nil];
//        alert.alertAction = ^(NSInteger buttonIndex){
//            if (buttonIndex == 1) {
//                [self deleteComment];
//            }
//            if (buttonIndex == 2) {
//                [self report];
//            }
//        };
//        [alert show];
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
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    if ([dictionary valueForKey:@"alasset"]) return;
    [dictionary setValue:[MTUser sharedInstance].userid forKey:@"id"];
    [dictionary setValue:self.eventId forKey:@"event_id"];
    [dictionary setValue:self.photoId forKey:@"photo_id"];
    [dictionary setValue:[NSNumber numberWithInt:isZan? 2:3]  forKey:@"operation"];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    MTLOG(@"%@",[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding]);
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:ADD_GOOD finshedBlock:^(NSData *rData) {
        if (rData) {
            //
        }
    }];
    
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
    [self updatePhotoInfoToDB:dict];
    
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

//#pragma mark - HttpSenderDelegate
//
//-(void)finishWithReceivedData:(NSData *)rData
//{
//    [self.goodButton setEnabled:YES];
//    NSString* temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
//    MTLOG(@"received Data: %@",temp);
//    NSMutableDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
//    NSNumber *cmd = [response1 valueForKey:@"cmd"];
//    if ([cmd intValue] == NORMAL_REPLY || [cmd intValue] == REQUEST_FAIL || [cmd intValue] == DATABASE_ERROR) {
//        
//    }else{
////        [CommonUtils showSimpleAlertViewWithTitle:@"信息" WithMessage:@"网络异常" WithDelegate:self WithCancelTitle:@"确定"];
//    }
//
//}

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
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    UIView* touchedView = [touch view];
    if([touchedView isKindOfClass:[UIButton class]]) {
        
        return NO;
    }
    
    return YES;
}


@end
