//
//  WelcomePageViewController.m
//  Metic
//
//  Created by mac on 14-8-12.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "WelcomePageViewController.h"

@interface WelcomePageViewController ()
{
    NSInteger numberOfPages;
}

@end

@implementation WelcomePageViewController
@synthesize rootView;
@synthesize page_scrollview;
@synthesize pageControl;

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
    numberOfPages = 4;
    self.page_scrollview.pagingEnabled = YES;
    self.page_scrollview.showsHorizontalScrollIndicator = NO;
    self.page_scrollview.showsVerticalScrollIndicator = NO;
    self.page_scrollview.delegate = self;
    
    pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(0, self.rootView.frame.size.height - 20, self.rootView.frame.size.width, 15)];
    pageControl.numberOfPages = numberOfPages;
    pageControl.currentPage = 0;
    UIColor* indicatorTintColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5];
    pageControl.pageIndicatorTintColor = indicatorTintColor;
    [pageControl addTarget:self action:@selector(pageControlClicked:) forControlEvents:UIControlEventValueChanged];
    [self.rootView addSubview:pageControl];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    self.page_scrollview.contentSize = CGSizeMake(self.rootView.frame.size.width, self.rootView.frame.size.height);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)buttonClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)pageControlClicked:(id)sender
{
    NSInteger page = pageControl.currentPage;
    
    CGRect kFrame = self.page_scrollview.frame;
    kFrame.origin.x = kFrame.size.width * page;
    kFrame.origin.y = 0;
    [self.page_scrollview scrollRectToVisible:kFrame animated:YES];
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

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView               // any offset changes
{
    if (scrollView == self.page_scrollview) {
        if (pageControl.currentPage == numberOfPages - 1) {
            
        }
        CGFloat page_width = page_scrollview.frame.size.width;
        int page_index = floor((page_scrollview.contentOffset.x - page_width/2) / page_width) +1;
        pageControl.currentPage = page_index;
        
    }
}

@end
