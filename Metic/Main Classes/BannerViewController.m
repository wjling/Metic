//
//  BannerViewController.m
//  WeShare
//
//  Created by ligang6 on 14-8-16.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "BannerViewController.h"

@interface BannerViewController ()

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
    [self.view setBackgroundColor:[UIColor blackColor]];
    if (_banner) {
        float width = _banner.size.width;
        float height = _banner.size.height * (self.view.frame.size.width / width);
        _imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, (self.view.frame.size.height -  height)/2, self.view.frame.size.width, height)];
        _imageView.image = _banner;
        [self.view addSubview:_imageView];
    }
    UITapGestureRecognizer* tapRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(back)];
    [self.view addGestureRecognizer:tapRecognizer];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)back{
    [self dismissViewControllerAnimated:YES completion:^{}];
}

@end
