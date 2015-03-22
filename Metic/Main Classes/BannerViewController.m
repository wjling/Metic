//
//  BannerViewController.m
//  WeShare
//
//  Created by ligang6 on 14-8-16.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "BannerViewController.h"
#import "MRZoomScrollView.h"

@interface BannerViewController ()
@property (nonatomic,strong)MRZoomScrollView* zoomScrollview;
@end

@implementation BannerViewController

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
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self.view setBackgroundColor:[UIColor blackColor]];
    if (_banner) {
        _zoomScrollview = [[MRZoomScrollView alloc]initWithFrame:self.view.bounds];
        _zoomScrollview.imageView.image = _banner;
        [_zoomScrollview fitImageView];
        [self.view addSubview:_zoomScrollview];
        _zoomScrollview.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin |UIViewAutoresizingFlexibleRightMargin;

    }
    UITapGestureRecognizer* tapRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(back)];
    tapRecognizer.numberOfTapsRequired=1;
    [self.view addGestureRecognizer:tapRecognizer];
    UITapGestureRecognizer* doubleTapRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTap)];
    doubleTapRecognizer.numberOfTapsRequired=2;
    [tapRecognizer requireGestureRecognizerToFail:doubleTapRecognizer];
    [self.view addGestureRecognizer:doubleTapRecognizer];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)shouldAutorotate
{
    return YES;
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    _zoomScrollview.frame=self.view.bounds;
    [_zoomScrollview fitImageView];
    
    
    return;
    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
        toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        _zoomScrollview.frame=self.view.bounds;
        [_zoomScrollview fitImageView];
    }
    else
    {
        _zoomScrollview.frame=self.view.bounds;
        [_zoomScrollview fitImageView];
    }
}

-(void)back{
    [self dismissViewControllerAnimated:YES completion:^{}];
}

-(void)doubleTap{
}

@end
