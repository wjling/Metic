//
//  VideoPreviewViewController.m
//  WeShare
//
//  Created by ligang6 on 14-9-4.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "VideoPreviewViewController.h"
#import "CommonUtils.h"
#import <MediaPlayer/MediaPlayer.h>

@interface VideoPreviewViewController ()
@property(nonatomic,strong) UIScrollView* scrollView;
@property(nonatomic,strong) UITextView* textView;
@property(nonatomic,strong) UIView* videoView;
@property(nonatomic,strong) UIButton* videoBtn;
@property(nonatomic,strong) UIImage* preViewImage;
@property BOOL isKeyBoard;
@end

@implementation VideoPreviewViewController

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
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _scrollView.frame = CGRectMake(0, 0, self.view.frame.size.width,self.view.frame.size.height);
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initData
{
    _preViewImage = [self getVideoPreViewImage:_videoURL];
    _isKeyBoard = NO;
}

-(void)initUI
{
    [self.navigationItem setTitle:@"上传视频"];
    CGFloat colorValue = 242.0/255.0;
    [self.view setBackgroundColor:[UIColor colorWithRed:colorValue green:colorValue blue:colorValue alpha:colorValue]];
    [self.view setAlpha:1];
    
    _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,self.view.frame.size.height)];
    [_scrollView setShowsHorizontalScrollIndicator:NO];
    [_scrollView setShowsVerticalScrollIndicator:NO];
    [_scrollView setBounces:NO];
    _scrollView.delegate = self;
    [self.view addSubview:_scrollView];
    
    _textView = [[UITextView alloc]initWithFrame:CGRectMake(10, 10, 300, 60)];
    [_textView setBackgroundColor:[UIColor whiteColor]];
    [_textView.layer setCornerRadius:4];
    _textView.layer.masksToBounds = YES;
    [_textView setFont:[UIFont systemFontOfSize:16]];
    _textView.delegate = self;
    [_scrollView addSubview:_textView];
    
    _videoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_videoBtn setFrame:CGRectMake(0, 0, 300,300)];
    if (_preViewImage) {
        [_videoBtn setFrame:CGRectMake(0, 0, 300,_preViewImage.size.height * 300/_preViewImage.size.width)];
        [_videoBtn setImage:_preViewImage forState:UIControlStateNormal];
    }else{
        [_videoBtn setBackgroundImage:[CommonUtils createImageWithColor:[UIColor lightGrayColor]] forState:UIControlStateNormal];
        [_videoBtn setBackgroundImage:[CommonUtils createImageWithColor:[CommonUtils colorWithValue:0x909090]] forState:UIControlStateHighlighted];
    }
    
    _videoView = [[UIView alloc]initWithFrame:CGRectMake(10, 80, _videoBtn.frame.size.width, _videoBtn.frame.size.height)];
    [_scrollView addSubview:_videoView];
    
    [_videoBtn addTarget:self action:@selector(play:) forControlEvents:UIControlEventTouchUpInside];
    [_videoView addSubview:_videoBtn];
    
    UIImageView* videoIc = [[UIImageView alloc]initWithFrame:CGRectMake((300-75)/2, (_videoBtn.frame.size.height -75)/2, 75,75)];
    [videoIc setUserInteractionEnabled:NO];
    videoIc.image = [UIImage imageNamed:@"视频按钮"];
    [_videoView addSubview:videoIc];

}

-(void)play:(id)sender
{
    if (_isKeyBoard) {
        [_textView resignFirstResponder];
        return;
    }
    MPMoviePlayerViewController *movie = [[MPMoviePlayerViewController alloc]initWithContentURL:_videoURL];
    
    [movie.moviePlayer prepareToPlay];
    [self presentMoviePlayerViewControllerAnimated:movie];
    [movie.moviePlayer setControlStyle:MPMovieControlStyleFullscreen];
    [movie.view setBackgroundColor:[UIColor clearColor]];
    
    [movie.view setFrame:self.navigationController.view.bounds];
    [[NSNotificationCenter defaultCenter]addObserver:self
     
                                            selector:@selector(movieFinishedCallback:)
     
                                                name:MPMoviePlayerPlaybackDidFinishNotification
     
                                              object:movie.moviePlayer];
    
}
-(void)movieFinishedCallback:(NSNotification*)notify{

    MPMoviePlayerController* theMovie = [notify object];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self
     
                                                   name:MPMoviePlayerPlaybackDidFinishNotification
     
                                                 object:theMovie];
    
    [self dismissMoviePlayerViewControllerAnimated];
    
}


#pragma mark - UITextView Delegate Method
-(void)textViewDidChange:(UITextView *)textView
{
    CGSize size = _textView.contentSize;
    CGRect frame = _textView.frame;
    frame.size.height = size.height < 50? 60:size.height+10;
    _textView.frame = frame;
    
    frame = _videoView.frame;
    frame.origin.y = _textView.frame.origin.y + _textView.frame.size.height + 10;
    [_videoView setFrame:frame];
    
//    float y = _textView.frame.size.height - 70;
//    if (y<0) y = 0;
//    [_scrollView setContentOffset:CGPointMake(0, y) animated:YES];
    
    float height = _textView.frame.size.height + _videoView.frame.size.height + 30;
    if (height < self.view.frame.size.height + _scrollView.contentOffset.y) height = self.view.frame.size.height + _scrollView.contentOffset.y;
    [_scrollView setContentSize:CGSizeMake(self.view.bounds.size.width, height)];

}

#pragma mark - private Method
- (UIImage*) getVideoPreViewImage:(NSURL*)videoPath
{
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoPath options:nil];
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    gen.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    UIImage *img = [[UIImage alloc] initWithCGImage:image];
    CGImageRelease(image);
    return img;
}
// Handle keyboard show/hide changes
- (void)keyboardWillShow: (NSNotification *)notification
{
    _isKeyBoard = YES;
}

- (void)keyboardWillHide: (NSNotification *)notification
{
    _isKeyBoard = NO;
}
@end
