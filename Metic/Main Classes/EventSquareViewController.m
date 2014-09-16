//
//  EventSquareViewController.m
//  WeShare
//
//  Created by ligang6 on 14-9-13.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "EventSquareViewController.h"
#import "MobClick.h"


#define bannerWidth self.view.bounds.size.width
#define bannerHeight self.view.bounds.size.width*300/640


@interface EventSquareViewController ()
@property (nonatomic,strong) UIScrollView* scrollView;
@property (nonatomic,strong) UIPageControl* pagecontrol;
@property (nonatomic,strong) NSMutableArray* images;
@property (nonatomic,strong) NSMutableArray* imageViews;
@property (nonatomic,strong) UIImageView* imageView1;
@property (nonatomic,strong) UIImageView* imageView2;
@property (nonatomic,strong) UIImageView* imageView3;
@property (nonatomic,strong) NSTimer* timer;

@property int firstIndex;
@property BOOL shouldDo;
@property BOOL canDo;

@end


@implementation EventSquareViewController
@synthesize imageView1;
@synthesize imageView2;
@synthesize imageView3;



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

//返回上一层
-(void)MTpopViewController{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)initData
{
    UIImage *image1 = [UIImage imageNamed:@"square_3.jpg"];
    UIImage *image2 = [UIImage imageNamed:@"square_1.jpg"];
    UIImage *image3 = [UIImage imageNamed:@"square_2.jpg"];
    //UIImage *image4 = [UIImage imageNamed:@"3兜风.jpg"];
    _images = [[NSMutableArray alloc]initWithObjects:image1,image2,image3,nil];
    _shouldDo = NO;
    _canDo = YES;
}

-(void)initUI
{
    [self.view setBackgroundColor:[UIColor colorWithWhite:0.94 alpha:1.0]];
    
    _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, bannerWidth, bannerHeight)];
    [_scrollView setContentSize:CGSizeMake(bannerWidth*3, bannerHeight)];
    [_scrollView setShowsHorizontalScrollIndicator:NO];
    [_scrollView setBounces:YES];
    [_scrollView setPagingEnabled:YES];
    [_scrollView setContentOffset:CGPointMake(bannerWidth * 1, 0)];
    _scrollView.delegate = self;
    
    imageView1 = [[UIImageView alloc]initWithFrame:CGRectMake(bannerWidth * 0, 0, bannerWidth, bannerHeight)];
    imageView1.image = _images[0];
    [_scrollView addSubview:imageView1];
    
    imageView2 = [[UIImageView alloc]initWithFrame:CGRectMake(bannerWidth * 1, 0, bannerWidth, bannerHeight)];
    imageView2.image = _images[1];
    [_scrollView addSubview:imageView2];
    
    imageView3 = [[UIImageView alloc]initWithFrame:CGRectMake(bannerWidth * 2, 0, bannerWidth, bannerHeight)];
    imageView3.image = _images[2];
    [_scrollView addSubview:imageView3];
    
    _imageViews = [[NSMutableArray alloc]initWithObjects:imageView1,imageView2,imageView3, nil];
    
    [self.view addSubview:_scrollView];
    
    _pagecontrol = [[UIPageControl alloc] initWithFrame:CGRectMake(bannerWidth*0.3,bannerHeight*0.8, bannerWidth*0.4, bannerHeight*0.2)];
    _pagecontrol.backgroundColor = [UIColor clearColor];
    _pagecontrol.hidesForSinglePage = YES;
    _pagecontrol.userInteractionEnabled = NO;
    _pagecontrol.numberOfPages = _images.count;
    [self.view addSubview:_pagecontrol];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:2.5f target:self selector:@selector(showBanner) userInfo:nil repeats:YES];
    
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

-(void)showBanner
{
    _canDo = YES;
    _shouldDo = NO;
    CGPoint curPoint = _scrollView.contentOffset;
    if (curPoint.x >= bannerWidth*2) {
        UIImage* tmp = _images[0];
        [_images removeObject:tmp];
        [_images addObject:tmp];
        _firstIndex --;
        if (_firstIndex < 0) _firstIndex = _images.count - 1;
        curPoint.x = bannerWidth;
        [_scrollView setContentOffset:curPoint];
        imageView1.image = _images[0];
        imageView2.image = _images[1];
        imageView3.image = _images[2];
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
    [self performSegueWithIdentifier:@"toNearbyEvent" sender:self];
}

-(void)toHot:(id)sender
{
    
}

-(void)toSearch:(id)sender
{
    
}




#pragma mark - UIScrollView Delegate -
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    int index = fabs(scrollView.contentOffset.x) / scrollView.frame.size.width;   //当前是第几个视图
    int photoIndex = [_images indexOfObject:((UIImageView*)_imageViews[index]).image];
    int realIndex = photoIndex - _firstIndex;
    if (realIndex < 0) realIndex += _images.count;
    NSLog(@"%d %d %d %d",index,photoIndex,realIndex,_firstIndex);
    _pagecontrol.currentPage = realIndex;
}


-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    NSLog(@"aaaaa");
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.x < 0) {
        UIImage* tmp = [_images lastObject];
        [_images removeObject:tmp];
        [_images insertObject:tmp atIndex:0];
        _firstIndex ++;
        if (_firstIndex >= _images.count) _firstIndex = 0;
        CGPoint curPoint = _scrollView.contentOffset;
        curPoint.x += bannerWidth;
        [scrollView setContentOffset:curPoint];
    }else if (scrollView.contentOffset.x > bannerWidth*2){
        UIImage* tmp = _images[0];
        [_images removeObject:tmp];
        [_images addObject:tmp];
        _firstIndex --;
        if (_firstIndex < 0) _firstIndex = _images.count - 1;
        CGPoint curPoint = _scrollView.contentOffset;
        curPoint.x -= bannerWidth;
        [scrollView setContentOffset:curPoint];
    }else{
        if (_canDo) {
            if (_shouldDo) {
                int index = fabs(scrollView.contentOffset.x) / scrollView.frame.size.width;   //当前是第几个视图
                int photoIndex = [_images indexOfObject:((UIImageView*)_imageViews[index]).image];
                int realIndex = photoIndex - _firstIndex;
                if (realIndex < 0) realIndex += _images.count;
                NSLog(@"%d %d %d %d",index,photoIndex,realIndex,_firstIndex);
                _pagecontrol.currentPage = realIndex;
            }
            _shouldDo = !_shouldDo;
        }
        return;
    };
    
    imageView1.image = _images[0];
    imageView2.image = _images[1];
    imageView3.image = _images[2];
    
    
    
}

#pragma mark - UIScrollView Delegate -
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [_timer setFireDate:[NSDate distantFuture]];
    _canDo = NO;
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [_timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:2]];
    int index = fabs(scrollView.contentOffset.x) / scrollView.frame.size.width;   //当前是第几个视图
    int photoIndex = [_images indexOfObject:((UIImageView*)_imageViews[index]).image];
    int realIndex = photoIndex - _firstIndex;
    if (realIndex < 0) realIndex += _images.count;
    NSLog(@"%d %d %d %d",index,photoIndex,realIndex,_firstIndex);
    _pagecontrol.currentPage = realIndex;
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
    }else{
        //self.shadowView.hidden = YES;
        //[self.view sendSubviewToBack:self.shadowView];
    }
}
@end
