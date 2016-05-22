//
//  WelcomePageViewController.m
//  Metic
//
//  Created by mac on 14-8-12.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "WelcomePageViewController.h"
#import "MobClick.h"
#import "AppDelegate.h"

@interface WelcomePageViewController ()
{
    NSInteger numberOfPages;
    UITapGestureRecognizer* tapRecognizer;
//    UISwipeGestureRecognizer* swipeRecognizer;
}

@end

@implementation WelcomePageViewController
@synthesize page_scrollview;
@synthesize pageControl;
@synthesize page1;
@synthesize page2;
@synthesize page3;
@synthesize page4;
@synthesize scrollContentView;

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
    // Do any additional setup after loading the view.
//    [self.navigationController setNavigationBarHidden:YES];
//    NSUserDefaults *userDf = [NSUserDefaults standardUserDefaults];
//    if ([userDf boolForKey:@"firstLaunched"]) {
//        MTLOG(@"welcomeviewcontroller: it is the first launch");
//        
//    }
//    else
//    {
//        MTLOG(@"welcomeviewcontroller: it is not the first launch");
//        UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone"
//                                                             bundle: nil];
//        UIViewController* vc = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
//        UINavigationController* nav = [storyboard instantiateViewControllerWithIdentifier:@"SlideNavigationController"];
//        
//        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
//        {
////            [self.navigationController showViewController:vc sender:self];
////            [self.navigationController popViewControllerAnimated:YES];
//            
//            
//        }
//
//        //            [self showLaunchView];
//        //            [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(dismissLaunchView) userInfo:nil repeats:NO];
//    }

    
    
    numberOfPages = 4;
    
//    self.page_scrollview = [[UIScrollView alloc]init];
//    [self.page_scrollview setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    UIColor* bgColor = [CommonUtils colorWithValue:0x57caab];
    self.page_scrollview.scrollEnabled = YES;
    self.page_scrollview.pagingEnabled = YES;
    self.page_scrollview.autoresizesSubviews = YES;
    self.page_scrollview.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.page_scrollview.showsHorizontalScrollIndicator = NO;
    self.page_scrollview.showsVerticalScrollIndicator = NO;
    self.page_scrollview.delegate = self;
    [self.page_scrollview setBackgroundColor:bgColor];
//    self.page_scrollview.clipsToBounds = YES;
    self.page_scrollview.directionalLockEnabled = YES;
//    self.page_scrollview.bounces = NO;
//    self.page_scrollview.alwaysBounceVertical = NO;
//    self.page_scrollview.alwaysBounceHorizontal = NO;
//    self.page_scrollview.delaysContentTouches = NO;
    
    CGRect bounds = [UIScreen mainScreen].bounds;
    MTLOG(@"welcome_bounds: width: %f, height: %f",bounds.size.width, bounds.size.height);
    CGFloat y;
    if (bounds.size.height <= 480) {
        y = 40;
    }
    else if(bounds.size.height <= 600) {
        y = 70;
    }
    else {
        y = 90;
    }
//    CGFloat view_width = bounds.size.width;
//    CGFloat view_height = bounds.size.height;
    CGFloat view_width = self.view.frame.size.width;
    CGFloat view_height = self.view.frame.size.height;
    
    MTLOG(@"welcome_view: width: %f, height: %f",view_width,view_height);
    scrollContentView = [[UIView alloc]initWithFrame:CGRectMake(0, 0,view_width * numberOfPages, view_height)];
    
    page1 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, view_width, view_height)];
    UIImageView* imgV1_1 = [[UIImageView alloc]initWithFrame:CGRectMake(21, y, view_width - 42, 115)];
    imgV1_1.contentMode = UIViewContentModeScaleAspectFill;
    UIImageView* imgV1_2 = [[UIImageView alloc]initWithFrame:CGRectMake(-60, view_height - 225 - 2 * y, view_width + 120, 385)];
    imgV1_2.contentMode = UIViewContentModeScaleAspectFill;
//    [page1 setBackgroundColor:[UIColor redColor]];
    [page1 setBackgroundColor:bgColor];
    imgV1_1.image = [UIImage imageNamed:@"splash_text1"];
    imgV1_2.image = [UIImage imageNamed:@"splash_img1"];
//    page1.clipsToBounds = YES;
    [page1 addSubview:imgV1_1];
    [page1 addSubview:imgV1_2];
    
    page2 = [[UIView alloc]initWithFrame:CGRectMake(view_width, 0, view_width, view_height)];
    UIImageView* imgV2_1 = [[UIImageView alloc]initWithFrame:CGRectMake(21, y, view_width - 42, 115)];
    imgV2_1.contentMode = UIViewContentModeScaleAspectFill;
    UIImageView* imgV2_2 = [[UIImageView alloc]initWithFrame:CGRectMake(-60, view_height - 225 - 2 * y, view_width + 120, 385)];
    imgV2_2.contentMode = UIViewContentModeScaleAspectFill;
//    [page2 setBackgroundColor:[UIColor blueColor]];
    [page2 setBackgroundColor:bgColor];
    imgV2_1.image = [UIImage imageNamed:@"splash_text2"];
    imgV2_2.image = [UIImage imageNamed:@"splash_img2"];
//    page2.clipsToBounds = YES;
    [page2 addSubview:imgV2_1];
    [page2 addSubview:imgV2_2];
    
    page3 = [[UIView alloc]initWithFrame:CGRectMake(view_width * 2, 0, view_width, view_height)];
    UIImageView* imgV3_1 = [[UIImageView alloc]initWithFrame:CGRectMake(21, y, view_width - 42, 115)];
    UIImageView* imgV3_2 = [[UIImageView alloc]initWithFrame:CGRectMake(-60, view_height - 225 - 2 * y, view_width + 120, 385)];
    imgV3_1.contentMode = UIViewContentModeScaleAspectFill;
    imgV3_2.contentMode = UIViewContentModeScaleAspectFill;
//    [page3 setBackgroundColor:[UIColor greenColor]];
    [page3 setBackgroundColor:bgColor];
    imgV3_1.image = [UIImage imageNamed:@"splash_text3"];
    imgV3_2.image = [UIImage imageNamed:@"splash_img3"];
//    page3.clipsToBounds = YES;
    [page3 addSubview:imgV3_1];
    [page3 addSubview:imgV3_2];
    
    page4 = [[UIView alloc]initWithFrame:CGRectMake(view_width * 3, 0, view_width, view_height)];
    UIImageView* imgV4_1 = [[UIImageView alloc]initWithFrame:CGRectMake(21, y, view_width - 42, 115)];
    UIImageView* imgV4_2 = [[UIImageView alloc]initWithFrame:CGRectMake(-60, view_height - 225 - 2 * y, view_width + 120, 385)];
    imgV4_1.contentMode = UIViewContentModeScaleAspectFill;
    imgV4_2.contentMode = UIViewContentModeScaleAspectFill;
//    [page4 setBackgroundColor:[UIColor orangeColor]];
    [page4 setBackgroundColor:bgColor];
    imgV4_1.image = [UIImage imageNamed:@"splash_text4"];
    imgV4_2.image = [UIImage imageNamed:@"splash_img4"];
//    page4.clipsToBounds = YES;
    [page4 addSubview:imgV4_1];
    [page4 addSubview:imgV4_2];
    
    
//    [page_scrollview addSubview:page1];
//    [page_scrollview addSubview:page2];
//    [page_scrollview addSubview:page3];
//    [page_scrollview addSubview:page4];
    [scrollContentView addSubview:page1];
    [scrollContentView addSubview:page2];
    [scrollContentView addSubview:page3];
    [scrollContentView addSubview:page4];
    [page_scrollview addSubview:scrollContentView];
    [self.view addSubview:page_scrollview];
    
    
    
    pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height - 80, self.view.frame.size.width, 50)];
    pageControl.numberOfPages = numberOfPages;
    pageControl.currentPage = 0;
    UIColor* indicatorTintColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5];
    pageControl.pageIndicatorTintColor = indicatorTintColor;
    [pageControl addTarget:self action:@selector(pageControlClicked:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:pageControl];
    
    tapRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissWelcome)];
    [page4 addGestureRecognizer:tapRecognizer];
    
//    swipeRecognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(dismissWelcome)];
//    swipeRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
//    [page4 addGestureRecognizer:swipeRecognizer];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [MobClick beginLogPageView:@"启动页"];
    self.page_scrollview.contentSize = CGSizeMake(self.view.frame.size.width * numberOfPages, self.view.frame.size.height - 50);
    MTLOG(@"welcomeviewcontroller did appear");
    MTLOG(@"content size: width: %f, height: %f",self.page_scrollview.contentSize.width, self.page_scrollview.contentSize.height);
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [MobClick endLogPageView:@"启动页"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dismissWelcome
{
    [self dismissViewControllerAnimated:YES completion:nil];
    MTLOG(@"dismiss welcome");
//    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone"
//                                                         bundle: nil];
//    UIViewController* vc = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
//    [self.navigationController pushViewController:vc animated:YES];
//    [self.navigationController popViewControllerAnimated:YES];

}
- (IBAction)pageControlClicked:(id)sender
{
    NSInteger page = pageControl.currentPage;
    
    CGRect kFrame = self.page_scrollview.frame;
    kFrame.origin.x = kFrame.size.width * page;
    kFrame.origin.y = 0;
//    [self.page_scrollview scrollRectToVisible:kFrame animated:YES];
    [self.page_scrollview setContentOffset:kFrame.origin animated:YES];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
//-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    MTLOG(@"touched begin");
//}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView               // any offset changes
{
    if (scrollView == self.page_scrollview) {
        if (pageControl.currentPage == numberOfPages - 1) {
            if (page_scrollview.contentOffset.x > page_scrollview.frame.size.width * (numberOfPages - 1)) {
                [self dismissWelcome];
            }
        }
        CGFloat page_width = page_scrollview.frame.size.width;
        int page_index = floor((page_scrollview.contentOffset.x - page_width/2) / page_width) +1;
        pageControl.currentPage = page_index;
        
    }
}

@end
