//
//  EventSquareViewController.m
//  WeShare
//
//  Created by ligang6 on 14-9-13.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "EventSquareViewController.h"
#import "NearbyEventViewController.h"
#import "EventSearchViewController.h"
#import "EventDetailViewController.h"
#import "MenuViewController.h"
#import "AdViewController.h"
#import "MobClick.h"
#import "AppConstants.h"
#import "HttpSender.h"
#import "UIImageView+WebCache.h"
#import "SVProgressHUD.h"


#define bannerWidth self.view.bounds.size.width
#define bannerHeight self.view.bounds.size.width*300/640


@interface EventSquareViewController ()
@property (nonatomic,strong) UIScrollView* scrollView;
@property (nonatomic,strong) UIPageControl* pagecontrol;
@property (nonatomic,strong) NSTimer* timer;
@property (nonatomic,strong) NSMutableArray* posterList;
@property (nonatomic,strong) NSNumber* processingEventId;

@property int firstIndex;
@property int type;
@property BOOL isAuto;

@end


@implementation EventSquareViewController




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
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _firstIndex = 1;
    [_shadowView setFrame:self.view.bounds];
    [MobClick beginLogPageView:@"活动广场"];
    [self.shadowView setAlpha:0];
    if (_timer) [_timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:2]];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [MobClick endLogPageView:@"活动广场"];
    if (_timer) [_timer setFireDate:[NSDate distantFuture]];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name: @"PopToFirstPageAndTurnToNotificationPage" object:nil];
}

//返回上一层
-(void)MTpopViewController{
    [self.navigationController popViewControllerAnimated:YES];
}

//返回本页并跳转到消息页
-(void)PopToHereAndTurnToNotificationPage:(id)sender
{
    NSLog(@"PopToHereAndTurnToNotificationPage  from  square");
    
    if ([[SlideNavigationController sharedInstance].viewControllers containsObject:self]){
        NSLog(@"Here");
        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"shouldIgnoreTurnToNotifiPage"]) {
            [[SlideNavigationController sharedInstance] popToViewController:self animated:NO];
            [self ToNotificationCenter];
        }
    }else{
        NSLog(@"NotHere");
    }
}

-(void)ToNotificationCenter
{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone"
                                                             bundle: nil];
    UIViewController* vc = [MenuViewController sharedInstance].notificationsViewController;
    if(!vc){
        vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"NotificationsViewController"];
        [MenuViewController sharedInstance].notificationsViewController = vc;
    }
    
    [[SlideNavigationController sharedInstance] openMenuAndSwitchToViewController:vc withCompletion:nil];
}

-(void)initData
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(PopToHereAndTurnToNotificationPage:) name: @"PopToFirstPageAndTurnToNotificationPage" object:nil];
    _isAuto = YES;
    [self getPoster];
}

-(void)initUI
{
    [self.view setBackgroundColor:[UIColor colorWithWhite:0.94 alpha:1.0]];
    
    _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, bannerWidth, bannerHeight)];
    [_scrollView setContentSize:CGSizeMake(bannerWidth, bannerHeight)];
    [_scrollView setShowsHorizontalScrollIndicator:NO];
    [_scrollView setBounces:YES];
    [_scrollView setPagingEnabled:YES];
    [_scrollView setContentOffset:CGPointMake(bannerWidth * 1, 0)];
    _scrollView.delegate = self;

    [self.view addSubview:_scrollView];
    
    CGRect frame = self.view.frame;
    float originY = CGRectGetHeight(_scrollView.frame) + 20;
    float height = CGRectGetWidth(frame)/4;
    float interval = height / 4;
    
    UIButton* button1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [button1 setFrame:CGRectMake(interval*1 + height*0, originY, height, height)];
    [button1.layer setCornerRadius:5];
    button1.layer.masksToBounds = YES;
    button1.layer.borderWidth = 1;
    button1.layer.borderColor = [UIColor colorWithWhite:0.82 alpha:1.0].CGColor;
    [button1 setBackgroundImage:[CommonUtils createImageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    [button1 setBackgroundImage:[CommonUtils createImageWithColor:[UIColor colorWithWhite:0.84f alpha:1.0f]] forState:UIControlStateHighlighted];
    UIImageView* icon1 = [[UIImageView alloc]initWithFrame:CGRectMake(height*0.25, height*0.1, height*0.5, height*0.5)];
    icon1.image = [UIImage imageNamed:@"ic_recom_events_nearby"];
    [button1 addSubview:icon1];
    UILabel* label1 = [[UILabel alloc]initWithFrame:CGRectMake(height*0.1, height*0.6, height*0.8, height*0.4)];
    [label1 setTextAlignment:NSTextAlignmentCenter];
    label1.text = @"周边活动";
    [label1 setFont:[UIFont systemFontOfSize:14]];
    [button1 addSubview:label1];
    [button1 addTarget:self action:@selector(toNearby:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button1];
    
    UIButton* button2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [button2 setFrame:CGRectMake(interval*2 + height*1, originY, height, height)];
    [button2.layer setCornerRadius:5];
    button2.layer.masksToBounds = YES;
    button2.layer.borderWidth = 1;
    button2.layer.borderColor = [UIColor colorWithWhite:0.82 alpha:1.0].CGColor;
    [button2 setBackgroundImage:[CommonUtils createImageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    [button2 setBackgroundImage:[CommonUtils createImageWithColor:[UIColor colorWithWhite:0.84f alpha:1.0f]] forState:UIControlStateHighlighted];
    UIImageView* icon2 = [[UIImageView alloc]initWithFrame:CGRectMake(height*0.25, height*0.1, height*0.5, height*0.5)];
    icon2.image = [UIImage imageNamed:@"ic_recom_events_hot"];
    [button2 addSubview:icon2];
    UILabel* label2 = [[UILabel alloc]initWithFrame:CGRectMake(height*0.1, height*0.6, height*0.8, height*0.4)];
    [label2 setTextAlignment:NSTextAlignmentCenter];
    label2.text = @"热门活动";
    [label2 setFont:[UIFont systemFontOfSize:14]];
    [button2 addSubview:label2];
    [button2 addTarget:self action:@selector(toHot:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button2];
    
    UIButton* button3 = [UIButton buttonWithType:UIButtonTypeCustom];
    [button3 setFrame:CGRectMake(interval*3 + height*2, originY, height, height)];
    [button3.layer setCornerRadius:5];
    button3.layer.masksToBounds = YES;
    button3.layer.borderWidth = 1;
    button3.layer.borderColor = [UIColor colorWithWhite:0.82 alpha:1.0].CGColor;
    [button3 setBackgroundImage:[CommonUtils createImageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    [button3 setBackgroundImage:[CommonUtils createImageWithColor:[UIColor colorWithWhite:0.84f alpha:1.0f]] forState:UIControlStateHighlighted];
    UIImageView* icon3 = [[UIImageView alloc]initWithFrame:CGRectMake(height*0.25, height*0.1, height*0.5, height*0.5)];
    icon3.image = [UIImage imageNamed:@"ic_recom_events_search"];
    [button3 addSubview:icon3];
    UILabel* label3 = [[UILabel alloc]initWithFrame:CGRectMake(height*0.1, height*0.6, height*0.8, height*0.4)];
    [label3 setTextAlignment:NSTextAlignmentCenter];
    label3.text = @"查找活动";
    [label3 setFont:[UIFont systemFontOfSize:14]];
    [button3 addSubview:label3];
    [button3 addTarget:self action:@selector(toSearch:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button3];

    [CommonUtils addLeftButton:self isFirstPage:YES];
    _shadowView = [[UIView alloc]initWithFrame:self.view.bounds];
    [_shadowView setBackgroundColor:[UIColor blackColor]];
    [_shadowView setAlpha:0];
    [_shadowView setTag:101];
    [self.view addSubview:_shadowView];
}

-(void)initScrollView
{
    if (_posterList && _posterList.count>0) {

        [_scrollView setBackgroundColor:[UIColor colorWithWhite:204.0/255.0 alpha:1.0f]];
        [_scrollView setContentSize:CGSizeMake(bannerWidth*(_posterList.count+1), bannerHeight)];
        int i = 0;
        for (int j = 0; j < _posterList.count; j++) {
            NSDictionary* dict = [_posterList objectAtIndex:j];
            if (i == _posterList.count-1) {
                UIImageView* img = [[UIImageView alloc]init];
                [img setUserInteractionEnabled:YES];
                [img setFrame:CGRectMake(bannerWidth*0, 0, bannerWidth, bannerHeight)];
                [img setTag:i];
                UITapGestureRecognizer* tap  = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapEvent:)];
                [img addGestureRecognizer:tap];
                NSString* url = [dict valueForKey:@"image_url"];
                NSLog(@"%@",url);
                img.contentMode = UIViewContentModeScaleAspectFit;
                [img sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"活动图片的默认图片"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    if (image) {
                        img.contentMode = UIViewContentModeScaleAspectFill;
                    }else{
                        img.image = [UIImage imageNamed:@"加载失败"];
                    }
                }];
                [_scrollView addSubview:img];
            }
            
            
            UIImageView* img = [[UIImageView alloc]init];
            [img setUserInteractionEnabled:YES];
            [img setFrame:CGRectMake(bannerWidth*(i+1), 0, bannerWidth, bannerHeight)];
            
            [img setContentMode:UIViewContentModeScaleAspectFill];
            [img setTag:i];
            UITapGestureRecognizer* tap  = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapEvent:)];
            [img addGestureRecognizer:tap];
            NSString* url = [dict valueForKey:@"image_url"];
            NSLog(@"%@",url);
            img.contentMode = UIViewContentModeScaleAspectFit;
            [img sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"活动图片的默认图片"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                if (image) {
                    img.contentMode = UIViewContentModeScaleAspectFill;
                }else{
                    img.image = [UIImage imageNamed:@"加载失败"];
                }
            }];
            [_scrollView addSubview:img];
            i++;
        }
        
        if (_posterList.count == 1) return;
        _pagecontrol = [[UIPageControl alloc] initWithFrame:CGRectMake(bannerWidth*0.3,bannerHeight*0.8, bannerWidth*0.4, bannerHeight*0.2)];
        _pagecontrol.backgroundColor = [UIColor clearColor];
        _pagecontrol.hidesForSinglePage = YES;
        _pagecontrol.userInteractionEnabled = NO;
        _pagecontrol.numberOfPages = _posterList.count;
        [self.view addSubview:_pagecontrol];
        
        _timer = [NSTimer scheduledTimerWithTimeInterval:2.5f target:self selector:@selector(showBanner) userInfo:nil repeats:YES];

         
    }else{
        [_scrollView setBackgroundColor:[UIColor colorWithWhite:204/255.0 alpha:1.0]];
        UIImageView* tmp = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_scrollView.frame), CGRectGetHeight(_scrollView.frame))];
        [tmp setContentMode:UIViewContentModeScaleAspectFit];
        tmp.image = [UIImage imageNamed:@"活动图片的默认图片"];
        [self.view addSubview:tmp];
    }
}





-(void)tapEvent:(UITapGestureRecognizer*)tap
{
    NSInteger index = tap.view.tag;
    NSDictionary* dict = _posterList[index];
    if ([[dict valueForKey:@"type"] isEqualToString:@"event"]) {
        NSNumber* eventId = [CommonUtils NSNumberWithNSString:[dict valueForKey:@"content"]];
        
        [self checkEvent:eventId];
        return;
    }else if([[dict valueForKey:@"type"] isEqualToString:@"url"]){

        NSString*extra = [dict valueForKey:@"extra"];
        NSLog(@"%@",extra);
        NSData* rData = [extra dataUsingEncoding:NSUTF8StringEncoding];
         NSLog(@"%@",rData);
        NSDictionary *extraDict = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
         NSLog(@"%@",extraDict);
        
        NSString* url = [dict valueForKey:@"content"];
        NSString* title = [extraDict valueForKey:@"title"];
        NSString* method =[extraDict valueForKey:@"method"];
        NSArray* args = [extraDict valueForKey:@"args"];
        
        AdViewController* adViewController = [[AdViewController alloc]init];
        adViewController.args = args;
        adViewController.AdUrl = url;
        adViewController.method = method;
        if (title && ![title isEqual:[NSNull null]]){
            NSLog(@"%@",title);
            adViewController.URLtitle = title;
        }
        
        [self.navigationController pushViewController:adViewController animated:YES];

    }else if([[dict valueForKey:@"type"] isEqualToString:@"None"]){
        return;
    }
}

-(void)checkEvent:(NSNumber*)eventId{
    if (!eventId) return;
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    _processingEventId = nil;
    NSArray* eventids = @[eventId];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:eventids forKey:@"sequence"];
    [dictionary setValue:[MTUser sharedInstance].userid forKey:@"id"];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:GET_EVENTS finshedBlock:^(NSData *rData) {
        if (rData) {
            NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableContainers error:nil];
            NSLog(@"%@", response1);
            if (((NSArray*)[response1 valueForKey:@"event_list"]).count > 0) {
                NSDictionary* dist = [response1 valueForKey:@"event_list"][0];
                
                if ([[dist valueForKey:@"isIn"] boolValue]) {
                    [SVProgressHUD dismiss];
                    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle: nil];
                    
                    EventDetailViewController* eventDetailView = [mainStoryboard instantiateViewControllerWithIdentifier: @"EventDetailViewController"];
                    eventDetailView.eventId = eventId;
                    [self.navigationController pushViewController:eventDetailView animated:YES];
                    }else{
                        [SVProgressHUD dismiss];
                        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"系统消息" message:@"你尚未加入到此活动中" delegate:self cancelButtonTitle:@"返回" otherButtonTitles:@"立即加入", nil];
                        _processingEventId = eventId;
                        [alert setTag:233];
                        [alert show];
                    }
            }else{
                [SVProgressHUD dismissWithError:@"此活动已经解散"];
            }
            
        }else{
            [SVProgressHUD dismissWithError:@"网络异常"];
        }
        
    }];
    
    
}

-(void)getPoster
{
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendGetPosterMessage:GET_POSTER finshedBlock:^(NSData *rData) {
        if (rData) {
            NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
            NSNumber *cmd = [response1 valueForKey:@"cmd"];
            switch ([cmd intValue]) {
                case NORMAL_REPLY:
                {
                    _posterList = [[NSMutableArray alloc]initWithArray:[response1 valueForKey:@"poster_list"]];
                    NSLog(@"%@",_posterList);
                    for (int i = 0; i < _posterList.count; i++) {
                        NSMutableDictionary* dictionary = [[NSMutableDictionary alloc]initWithDictionary:_posterList[i]];
                        _posterList[i] = dictionary;
                    }
                    [self initScrollView];
                    
                }
                    break;
                default:
                    [self initScrollView];
                    break;
                    
            }

        }else{
             [self initScrollView];
        }
    }];
}

-(void)showBanner
{
    CGPoint curPoint = _scrollView.contentOffset;
    if (curPoint.x == bannerWidth*_posterList.count) {
        [_scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
        curPoint.x = 0;
    }
    curPoint.x += bannerWidth;
    [UIView beginAnimations:@"slideBanner" context:nil];
    [UIView setAnimationDuration:1];
    [UIView setAnimationDelegate:self];
    _scrollView.contentOffset = curPoint;
    [UIView commitAnimations];
    [_scrollView setContentOffset:curPoint animated:YES];
}

-(void)toNearby:(id)sender
{
    _type = 0;
    [self performSegueWithIdentifier:@"toNearbyEvent" sender:self];
}

-(void)toHot:(id)sender
{
    _type = 1;
    [self performSegueWithIdentifier:@"toNearbyEvent" sender:self];
}

-(void)toSearch:(id)sender
{
    [self performSegueWithIdentifier:@"toSearchEvent" sender:self];
}



#pragma mark - UIScrollView Delegate -

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    _isAuto = NO;
    [_timer setFireDate:[NSDate distantFuture]];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    _isAuto = YES;
    [_timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:2]];
    float x = scrollView.contentOffset.x;
    int page = x/bannerWidth - 1;
    if (page < 0) page += _posterList.count;
//    NSLog(@"page:%d",page);
    if (page < _posterList.count && page != _pagecontrol.currentPage) {
        [_pagecontrol setCurrentPage:page];
    }
}


-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    float x = scrollView.contentOffset.x;
    if (x > bannerWidth* _posterList.count) {
        [_scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
    }else if(x < 0){
        [_scrollView setContentOffset:CGPointMake(bannerWidth*_posterList.count, 0) animated:NO];
    }
    if (_isAuto) {
        float x = scrollView.contentOffset.x;
        int page = x/bannerWidth - 1;
        if (page < 0) page += _posterList.count;
//        NSLog(@"page:%d",page);
        if (page < _posterList.count && page != _pagecontrol.currentPage) {
            [_pagecontrol setCurrentPage:page];
        }
    }
}



#pragma mark - SlideNavigationController Methods -

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
	return YES;
}

- (BOOL)slideNavigationControllerShouldDisplayRightMenu
{
	return NO;
}
-(void)sendDistance:(float)distance
{
    if (distance > 0) {
        self.shadowView.hidden = NO;
        [self.view bringSubviewToFront:self.shadowView];
        [self.shadowView setAlpha:distance/400.0];
        self.navigationController.navigationBar.alpha = 1 - distance/400.0;
    }else{
        //self.shadowView.hidden = YES;
        //[self.view sendSubviewToBack:self.shadowView];
    }
}

#pragma mark 用segue跳转时传递参数eventid
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //这里我很谨慎的对sender和目标视图控制器作了判断
    if ([segue.destinationViewController isKindOfClass:[NearbyEventViewController class]]) {
        NearbyEventViewController *nextViewController = segue.destinationViewController;
        nextViewController.type = _type;
    }
    
    
}
#pragma mark - AlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if([alertView tag] == 233){
        //从活动广场进来
        NSLog(@"从活动广场进来,申请加入活动");
        if(buttonIndex == 0){
        }else if(buttonIndex == 1){
            UIAlertView* confirmAlert = [[UIAlertView alloc]initWithTitle:@"系统消息" message:@"请输入申请加入信息：" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
            confirmAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
            confirmAlert.tag = 244;
            [confirmAlert show];
        }
        return;
    }else if([alertView tag] == 244){
        
        if(buttonIndex == 0){
            [self.navigationController popViewControllerAnimated:YES];
        }else if(buttonIndex == 1){
            
            NSString* cm = [alertView textFieldAtIndex:0].text;
            NSDictionary* dictionary = [CommonUtils packParamsInDictionary:[NSNumber numberWithInt:995],@"cmd",[MTUser sharedInstance].userid,@"id",cm,@"confirm_msg", _processingEventId,@"event_id",nil];
            NSLog(@"%@",dictionary);
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
            [SVProgressHUD showWithStatus:@"正在发送..." maskType:SVProgressHUDMaskTypeClear];
            HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
            [httpSender sendMessage:jsonData withOperationCode:PARTICIPATE_EVENT finshedBlock:^(NSData *rData) {
                if (rData) {
                    NSString* temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
                    NSLog(@"received Data: %@",temp);
                    NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
                    NSNumber *cmd = [response1 valueForKey:@"cmd"];
                    switch ([cmd intValue]) {
                        case NORMAL_REPLY:
                        {
                            [SVProgressHUD dismissWithSuccess:@"请等待发起人验证" afterDelay:2];
                        }
                            break;
                        default:{
                            [SVProgressHUD dismissWithSuccess:@"暂时无法加入活动" afterDelay:2];
                        }
                    }

                }else{
                    [SVProgressHUD dismissWithError:@"网络异常"];
                }
            }];
        }
        return;
    }
    
    
    switch (buttonIndex) {
        case 0:
            [self.navigationController popViewControllerAnimated:YES];
            break;
        case 1:
            [self.navigationController popViewControllerAnimated:YES];
            break;
            
        default:
            break;
    }
}
@end
