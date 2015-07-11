//
//  BannerViewController.m
//  WeShare
//
//  Created by ligang6 on 14-8-16.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "BannerViewController.h"
#import "MRZoomScrollView.h"
#import "SVProgressHUD.h"
#import "SDImageCache.h"
#import "SDWebImageDownloader.h"
#import "SDImageCache.h"
#import "MTOperation.h"

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
    self.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self.view setBackgroundColor:[UIColor blackColor]];
    [self initIMG];
    [self downloadHQphoto];
    UITapGestureRecognizer* tapRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(back)];
    tapRecognizer.numberOfTapsRequired=1;
    [self.view addGestureRecognizer:tapRecognizer];
    UITapGestureRecognizer* doubleTapRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTap)];
    doubleTapRecognizer.numberOfTapsRequired=2;
    [tapRecognizer requireGestureRecognizerToFail:doubleTapRecognizer];
    [self.view addGestureRecognizer:doubleTapRecognizer];
    
    // Do any additional setup after loading the view.
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [SVProgressHUD dismiss];
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

-(void)initIMG
{
    if (_banner) {
        if (!_zoomScrollview) {
            _zoomScrollview = [[MRZoomScrollView alloc]initWithFrame:self.view.bounds];
            [self.view addSubview:_zoomScrollview];
            _zoomScrollview.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin |UIViewAutoresizingFlexibleRightMargin;
        }
        
        _zoomScrollview.imageView.image = _banner;
        [_zoomScrollview fitImageView];
    }
}

- (void)downloadHQphoto
{
    if (_url) {
        if ([[SDImageCache sharedImageCache]diskImageExistsWithKey:_url]) {
            _banner = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:_url];
            [self initIMG];
        }else{
            __weak typeof(self) wself = self;
            NSString* locURL = [NSString stringWithString:_url];
            [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeNone];
            [[SDWebImageDownloader sharedDownloader]downloadImageWithURL:[NSURL URLWithString:_url] options:SDWebImageDownloaderHighPriority progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                //
            } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                if (image) {
                    if (wself) {
                        wself.banner = image;
                        [wself initIMG];
                        [SVProgressHUD dismiss];
                    }
                    [[SDImageCache sharedImageCache]storeImage:image forKey:locURL];
                }else{
                    [SVProgressHUD dismiss];
                }
                
            }];
        }
    }else if (_path){
        [[MTOperation sharedInstance]getUrlFromServer:_path success:^(NSString *url) {
            _url = url;
            [self downloadHQphoto];
        } failure:^(NSString *message) {
            NSLog(@"%@",message);
        }];
    }
}

@end
