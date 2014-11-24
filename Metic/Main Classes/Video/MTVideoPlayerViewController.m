//
//  MTVideoPlayerViewController.m
//  WeShare
//
//  Created by ligang6 on 14-11-23.
//  Copyright (c) 2014年 WeShare. All rights reserved.
//

#import "MTVideoPlayerViewController.h"

@interface MTVideoPlayerViewController ()
@property (strong, nonatomic) AVPlayerItem* videoItem;
@property (strong, nonatomic) AVPlayer* videoPlayer;
@property (strong, nonatomic) AVPlayerLayer* avLayer;
@property CGRect originFrame;
@end

@implementation MTVideoPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //[_avLayer removeFromSuperlayer];
    self.videoItem = [_wall.AVPlayerItems objectForKey:_videoName];
    self.videoPlayer = [_wall.AVPlayers objectForKey:_videoName];
    self.avLayer = [_wall.AVPlayerLayers objectForKey:_videoName];
    UITapGestureRecognizer* tapRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(back)];
    [self.view addGestureRecognizer:tapRecognizer];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _originFrame = _avLayer.frame;
    _avLayer.frame = self.view.frame;
    [self.videoItem seekToTime:kCMTimeZero];
    self.videoPlayer.volume = 1.0f;
    [self.view.layer addSublayer:_avLayer];
    [self.videoPlayer play];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)back{
    self.videoPlayer.volume = 0;
    [self.videoItem seekToTime:kCMTimeZero];
    _avLayer.frame = _originFrame;
    [self dismissViewControllerAnimated:YES completion:^{
        _wall.shouldFlash = NO;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (_wall) {
                _wall.shouldFlash = YES;
            }
        });
        [_wall.tableView reloadRowsAtIndexPaths:[[NSArray alloc]initWithObjects:[_wall.tableView indexPathForCell:_cell], nil] withRowAnimation:UITableViewRowAnimationNone];
    }];
}

@end
