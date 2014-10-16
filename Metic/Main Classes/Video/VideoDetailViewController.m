//
//  VideoDetailViewController.m
//  WeShare
//
//  Created by ligang6 on 14-9-2.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "VideoDetailViewController.h"
#import "VideoWallViewController.h"
#import "../../Cell/VcommentTableViewCell.h"
#import "HomeViewController.h"
#import "../../Utils/CommonUtils.h"
#import "MobClick.h"
#import "MLEmojiLabel.h"
#import "../../Custom Wedgets/emotion_Keyboard.h"
#import "UIImageView+WebCache.h"
#import <MediaPlayer/MediaPlayer.h>
#import "MTMPMoviePlayerViewController.h"
#import "../Friends/FriendInfoViewController.h"
#import "../UserInfo/UserInfoViewController.h"

#define chooseArray @[@[@"举报视频"]]
@interface VideoDetailViewController ()
@property (nonatomic,strong) MTMPMoviePlayerViewController* movie;
@property BOOL isReady;
@property (nonatomic,strong)NSNumber* sequence;
@property (nonatomic,strong)UIButton * delete_button;
@property float specificationHeight;
@property (nonatomic,strong) NSMutableArray * vcomment_list;
@property (strong, nonatomic) IBOutlet emotion_Keyboard *emotionKeyboard;
@property (nonatomic,strong) NSNumber* repliedId;
@property (nonatomic,strong) NSString* herName;
@property (nonatomic,strong) UIView* moreView;
@property BOOL isKeyBoard;
@property BOOL Footeropen;
@property long Selete_section;
@end

@implementation VideoDetailViewController

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
    [self initUI];
    //[self getthumb];
    self.sequence = [NSNumber numberWithInt:0];
    self.videoId = [_videoInfo valueForKey:@"video_id"];
    self.isKeyBoard = NO;
    self.Footeropen = NO;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    _emotionKeyboard.textView = _inputTextView;
    self.vcomment_list = [[NSMutableArray alloc]init];

    //初始化上拉加载更多
    _footer = [[MJRefreshFooterView alloc]init];
    _footer.delegate = self;
    _footer.scrollView = _tableView;
    
    
    
    
    // Do any additional setup after loading the view.
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [self.inputTextView resignFirstResponder];
    [MobClick beginLogPageView:@"视频详情"];
    self.sequence = [NSNumber numberWithInt:0];
    [self pullMainCommentFromAir];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [MobClick endLogPageView:@"视频详情"];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [self closeMoreview];
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

- (void)dealloc

{
    [_footer free];
}

-(void)initUI
{
    // 初始化输入框
    MTMessageTextView *textView = [[MTMessageTextView  alloc] initWithFrame:CGRectZero];
    
    // 这个是仿微信的一个细节体验
    textView.returnKeyType = UIReturnKeySend;
    textView.enablesReturnKeyAutomatically = YES; // UITextView内部判断send按钮是否可以用
    
    textView.placeHolder = @"发送新消息";
    textView.delegate = self;
    
    [self.commentView addSubview:textView];
	_inputTextView = textView;
    
    _inputTextView.frame = CGRectMake(38, 5, 240, 35);
    _inputTextView.backgroundColor = [UIColor clearColor];
    _inputTextView.layer.borderColor = [UIColor colorWithWhite:0.8f alpha:1.0f].CGColor;
    _inputTextView.layer.borderWidth = 0.65f;
    _inputTextView.layer.cornerRadius = 6.0f;
    
    [_emotionKeyboard initCollectionView];
    
}

- (void)play:(id)sender {
    if (_isKeyBoard) {
        [_inputTextView resignFirstResponder];
        return;
    }
    NSString *videoName = [_videoInfo valueForKey:@"video_name"];
    NSString *url = [CommonUtils getUrl:[NSString stringWithFormat:@"/video/%@",[_videoInfo valueForKey:@"video_name"]]];
    NSLog(@"%@",url);
    [self videoPlay:videoName url:url];
    //[self openmovie:url];
}


- (void)videoPlay:(NSString*)videoName url:(NSString*)url{
    
    NSString *CacheDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *webPath = [CacheDirectory stringByAppendingPathComponent:@"VideoTemp"];
    NSString *cachePath = [CacheDirectory stringByAppendingPathComponent:@"VideoCache"];
    
    __block unsigned long long totalBytes = 0;
    
    NSFileManager *fileManager=[NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:cachePath])
    {
        [fileManager createDirectoryAtPath:cachePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    if ([fileManager fileExistsAtPath:[cachePath stringByAppendingPathComponent:videoName]]) {
        MTMPMoviePlayerViewController *playerViewController = [[MTMPMoviePlayerViewController alloc]initWithContentURL:[NSURL fileURLWithPath:[cachePath stringByAppendingPathComponent:videoName]]];
        [self presentMoviePlayerViewControllerAnimated:playerViewController];
        
        [[NSNotificationCenter defaultCenter]addObserver:self
         
                                                selector:@selector(movieFinishedCallback:)
         
                                                    name:MPMoviePlayerPlaybackDidFinishNotification
         
                                                  object:playerViewController.moviePlayer];
        
        videoRequest = nil;
    }else if ([fileManager fileExistsAtPath:[webPath stringByAppendingPathComponent:videoName]]){
        if (_isReady) {
            [self playVideo:videoName];
        }
        
    }
    else{
        _isReady = NO;
        ASIHTTPRequest *request=[[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:url]];
        //下载完存储目录
        [request setDownloadDestinationPath:[cachePath stringByAppendingPathComponent:videoName]];
        //临时存储目录
        [request setTemporaryFileDownloadPath:[webPath stringByAppendingPathComponent:videoName]];
        __block BOOL isPlay = NO;
        [request setBytesReceivedBlock:^(unsigned long long size, unsigned long long total) {
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setDouble:total forKey:@"file_length"];
            totalBytes = total;
            if (size/total > 0.3) {
                [_movie.moviePlayer play];
            }
            if (!isPlay) {
                isPlay = YES;
                _isReady = YES;
                
                [self playVideo:videoName];
                //if(_movie) [_movie.moviePlayer play];
            }
        }];
        [request setCompletionBlock:^{
            
            [fileManager copyItemAtPath:[cachePath stringByAppendingPathComponent:videoName] toPath:[webPath stringByAppendingPathComponent:videoName] error:nil];
            if (totalBytes != 0) [[NSUserDefaults standardUserDefaults] setDouble:totalBytes forKey:@"file_length"];
        }];
        //断点续载
        [request setAllowResumeForFileDownloads:YES];
        [request startAsynchronous];
        videoRequest = request;
        
        
    }
}

- (void)playVideo:(NSString*)videoName{
    MTMPMoviePlayerViewController *playerViewController =[[MTMPMoviePlayerViewController alloc]initWithContentURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://127.0.0.1:12345/%@",videoName]]];
    _movie = playerViewController;
    [playerViewController.moviePlayer pause];
    [self presentMoviePlayerViewControllerAnimated:playerViewController];
    [[NSNotificationCenter defaultCenter]addObserver:self
     
                                            selector:@selector(movieFinishedCallback:)
     
                                                name:MPMoviePlayerPlaybackDidFinishNotification
     
                                              object:playerViewController.moviePlayer];
}


//-(void)openmovie:(NSString*)url
//{
//    MTMPMoviePlayerViewController *movie = [[MTMPMoviePlayerViewController alloc]initWithContentURL:[NSURL URLWithString:url]];
//    
//    [movie.moviePlayer prepareToPlay];
//    [self presentMoviePlayerViewControllerAnimated:movie];
//    [movie.moviePlayer setControlStyle:MPMovieControlStyleFullscreen];
//    [movie.view setBackgroundColor:[UIColor clearColor]];
//    
//    [movie.view setFrame:self.navigationController.view.bounds];
//    [[NSNotificationCenter defaultCenter]addObserver:self
//     
//                                            selector:@selector(movieFinishedCallback:)
//     
//                                                name:MPMoviePlayerPlaybackDidFinishNotification
//     
//                                              object:movie.moviePlayer];
//    
//}

- (IBAction)more:(id)sender {
    if (_moreView) {
        //删除
        [_moreView removeFromSuperview];
        _moreView = nil;
    }else{
        //创建
        _moreView = [[UIView alloc]initWithFrame:self.view.bounds];
        [_moreView setBackgroundColor:[UIColor clearColor]];
        UITapGestureRecognizer*tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(closeMoreview)];
        [self.view addSubview:_moreView];
        [self.view addGestureRecognizer:tap];
        
        CGRect frame = _moreView.frame;
        UIButton* moreItem = [UIButton buttonWithType:UIButtonTypeCustom];
        moreItem.frame = CGRectMake(CGRectGetWidth(frame)*0.6,5, CGRectGetWidth(frame)*0.35 , 45);
        
        [moreItem setBackgroundColor:[UIColor whiteColor]];
        
        [moreItem.titleLabel setFont:[UIFont systemFontOfSize:16]];
        [moreItem setTitle:@"举报视频" forState:UIControlStateNormal];
        [moreItem addTarget:self action:@selector(report:) forControlEvents:UIControlEventTouchUpInside];
        [moreItem setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [moreItem setTitleColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5] forState:UIControlStateHighlighted];
        moreItem.layer.shadowColor = [UIColor darkGrayColor].CGColor;
        moreItem.layer.shadowRadius = 5;
        moreItem.layer.shadowPath = [UIBezierPath bezierPathWithRect:moreItem.bounds].CGPath;
        moreItem.layer.shadowOpacity = 1;
        
        [_moreView addSubview:moreItem];
        
        
        
        
        
    }
}

- (void)closeMoreview{
    if (_moreView) {
        [self more:nil];
    }
}

- (void)report:(id)sender {
    
    [self performSegueWithIdentifier:@"VideoToReport" sender:self];
    
}

- (IBAction)button_Emotionpress:(id)sender {
    if (!_emotionKeyboard) {
        _emotionKeyboard = [[emotion_Keyboard alloc]initWithPoint:CGPointMake(0, self.view.frame.size.height - 200)];
        
        
        
    }
    if (!_isEmotionOpen) {
        _isEmotionOpen = YES;
        if (_isKeyBoard) {
            [_inputTextView resignFirstResponder];
        }
        //[self.view bringSubviewToFront:_emotionKeyboard];
        //[self.view addSubview:_emotionKeyboard];
        CGRect keyboardBounds = _emotionKeyboard.frame;
        // get a rect for the textView frame
        CGRect containerFrame = self.commentView.frame;
        containerFrame.origin.y = self.view.bounds.size.height - (keyboardBounds.size.height + containerFrame.size.height);
        // animations settings
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:0.25];
        [UIView setAnimationCurve:7];
        
        // set views with new info
        self.commentView.frame = containerFrame;
        CGRect frame = _emotionKeyboard.frame;
        frame.origin.y = self.view.frame.size.height - frame.size.height;
        [_emotionKeyboard setFrame:frame];
        
        // commit animations
        [UIView commitAnimations];
    }else {
        _isEmotionOpen = NO;
        CGRect containerFrame = self.commentView.frame;
        containerFrame.origin.y = self.view.bounds.size.height - containerFrame.size.height;
        // animations settings
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:0.25];
        [UIView setAnimationCurve:7];
        self.commentView.frame = containerFrame;
        CGRect frame = _emotionKeyboard.frame;
        frame.origin.y = self.view.frame.size.height;
        [_emotionKeyboard setFrame:frame];
        [UIView commitAnimations];
        //[_emotionKeyboard removeFromSuperview];
    }
    
    
}


- (void)pullMainCommentFromAir
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:[MTUser sharedInstance].userid forKey:@"id"];
    [dictionary setValue:self.sequence forKey:@"sequence"];
    [dictionary setValue:self.videoId forKey:@"video_id"];
    NSLog(@"%@",dictionary);
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:GET_VCOMMENTS];
}



-(void)deleteVideo:(UIButton*)button
{
    [button setEnabled:NO];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (button) {
            [button setEnabled:YES];
        }
    });
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"确定要删除这段视频？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert setTag:100];
    [alert show];
}

-(void)resendComment:(id)sender
{
    
    id cell = [sender superview];
    while (![cell isKindOfClass:[UITableViewCell class]] ) {
        cell = [cell superview];
    }
    NSString *comment = ((VcommentTableViewCell*)cell).comment.text;
    int row = [_tableView indexPathForCell:cell].row;
    NSMutableDictionary *waitingComment = _vcomment_list[row-1];
    [waitingComment setValue:[NSNumber numberWithInt:-1] forKey:@"vcomment_id"];
    
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:[MTUser sharedInstance].userid forKey:@"id"];
    [dictionary setValue:self.videoId forKey:@"video_id"];
    [dictionary setValue:self.eventId forKey:@"event_id"];
    [dictionary setValue:comment forKey:@"content"];
    [dictionary setValue:[waitingComment valueForKey:@"replied"] forKey:@"replied"];

    [_tableView reloadData];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if(waitingComment && [[waitingComment valueForKey:@"vcomment_id"] intValue]== -1){
            [waitingComment setValue:[NSNumber numberWithInt:-2] forKey:@"vcomment_id"];
            [_tableView reloadData];
            
        }
    });
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    NSLog(@"%@",[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding]);
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:ADD_VCOMMENT finshedBlock:^(NSData *rData) {
        if (rData) {
            NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
            NSNumber *cmd = [response1 valueForKey:@"cmd"];
            if ([cmd intValue] == NORMAL_REPLY && [response1 valueForKey:@"vcomment_id"]) {
                {
                    [waitingComment setValue:[response1 valueForKey:@"vcomment_id"] forKey:@"vcomment_id"];
                    [waitingComment setValue:[response1 valueForKey:@"time"] forKey:@"time"];
                    [_vcomment_list removeObject:waitingComment];
                    [_vcomment_list insertObject:waitingComment atIndex:0];
                    [_tableView reloadData];
                }
            }else{
                [waitingComment setValue:[NSNumber numberWithInt:-2] forKey:@"vcomment_id"];
                [_tableView reloadData];
            }
        }else{
            [waitingComment setValue:[NSNumber numberWithInt:-2] forKey:@"vcomment_id"];
            [_tableView reloadData];
        }
    }];
}


- (IBAction)publishComment:(id)sender {
    NSString *comment = self.inputTextView.text;
    if ([[comment stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]) {
        self.inputTextView.text = @"";
        return;
    }
    [self.inputTextView resignFirstResponder];
    if (_isEmotionOpen) [self button_Emotionpress:nil];
    self.inputTextView.text = @"";
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self textViewDidChange:nil];
        self.inputTextView.text = @"";
    });
    NSLog(comment,nil);
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    if (_repliedId && [_repliedId intValue]!=[[MTUser sharedInstance].userid intValue]){
        [dictionary setValue:_repliedId forKey:@"replied"];
        comment = [[NSString stringWithFormat:@"回复 %@ : ",_herName] stringByAppendingString:comment];
    }
    [dictionary setValue:[MTUser sharedInstance].userid forKey:@"id"];
    [dictionary setValue:self.videoId forKey:@"video_id"];
    [dictionary setValue:self.eventId forKey:@"event_id"];
    [dictionary setValue:comment forKey:@"content"];
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSString*time = [dateFormatter stringFromDate:[NSDate date]];
    NSMutableDictionary* newComment = [[NSMutableDictionary alloc]init];
    [newComment setValue:[NSNumber numberWithInt:0] forKey:@"good"];
    [newComment setValue:_videoId forKey:@"video_id"];
    [newComment setValue:[MTUser sharedInstance].name forKey:@"author"];
    [newComment setValue:[NSNumber numberWithInt:-1] forKey:@"vcomment_id"];
    [newComment setValue:comment forKey:@"content"];
    [newComment setValue:time forKey:@"time"];
    [newComment setValue:[MTUser sharedInstance].userid forKey:@"author_id"];
    [newComment setValue:[NSNumber numberWithInt:0] forKey:@"isZan"];
    [newComment setValue:[dictionary valueForKey:@"replied"] forKey:@"replied"];

    if ([_vcomment_list isKindOfClass:[NSArray class]]) {
        _vcomment_list = [[NSMutableArray alloc]initWithArray:_vcomment_list];
    }
    [_vcomment_list insertObject:newComment atIndex:0];
    
    [_tableView reloadData];
    self.inputTextView.text = @"";
    [self.inputTextView resignFirstResponder];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if(newComment && [[newComment valueForKey:@"vcomment_id"] intValue]== -1){
            [newComment setValue:[NSNumber numberWithInt:-2] forKey:@"vcomment_id"];
            [_tableView reloadData];
            
        }
    });
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    NSLog(@"%@",[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding]);
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:ADD_VCOMMENT finshedBlock:^(NSData *rData) {
        if (rData) {
            NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
            NSNumber *cmd = [response1 valueForKey:@"cmd"];
            if ([cmd intValue] == NORMAL_REPLY && [response1 valueForKey:@"vcomment_id"]) {
                {
                    [newComment setValue:[response1 valueForKey:@"vcomment_id"] forKey:@"vcomment_id"];
                    [newComment setValue:[response1 valueForKey:@"time"] forKey:@"time"];
                    [_vcomment_list removeObject:newComment];
                    [_vcomment_list insertObject:newComment atIndex:0];
                    [_tableView reloadData];
                }
            }else{
                [newComment setValue:[NSNumber numberWithInt:-2] forKey:@"vcomment_id"];
                [_tableView reloadData];
            }
        }else{
            [newComment setValue:[NSNumber numberWithInt:-2] forKey:@"vcomment_id"];
            [_tableView reloadData];
        }
        
    }];
}



-(void)closeRJ
{
    //    if (_Headeropen) {
    //        _Headeropen = NO;
    //        [_header endRefreshing];
    //    }
    if (_Footeropen) {
        _Footeropen = NO;
        [_footer endRefreshing];
    }
    [self.tableView reloadData];
}

- (void)deleteVideoInfoFromDB
{
    NSString * path = [NSString stringWithFormat:@"%@/db",[MTUser sharedInstance].userid];
    MySqlite *sql = [[MySqlite alloc]init];
    [sql openMyDB:path];
    NSDictionary *wheres = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%@",_videoId],@"video_id", nil];
    [sql deleteTurpleFromTable:@"eventVideo" withWhere:wheres];
    [sql closeMyDB];
}


- (void)pushToFriendView:(id)sender {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone"
															 bundle: nil];
    if ([[self.videoInfo valueForKey:@"author_id"] intValue] == [[MTUser sharedInstance].userid intValue]) {
        UserInfoViewController* userInfoView = [mainStoryboard instantiateViewControllerWithIdentifier: @"UserInfoViewController"];
        userInfoView.needPopBack = YES;
        [self.navigationController pushViewController:userInfoView animated:YES];
        
    }else{
        FriendInfoViewController *friendView = [mainStoryboard instantiateViewControllerWithIdentifier: @"FriendInfoViewController"];
        friendView.fid = [self.videoInfo valueForKey:@"author_id"];
        [self.navigationController pushViewController:friendView animated:YES];
    }
	
}


#pragma mark - HttpSenderDelegate

-(void)finishWithReceivedData:(NSData *)rData
{
    NSString* temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
    NSLog(@"received Data: %@",temp);
    NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
    NSNumber *cmd = [response1 valueForKey:@"cmd"];
    switch ([cmd intValue]) {
        case NORMAL_REPLY:
        {
            if ([response1 valueForKey:@"vcomment_list"]) {
                NSMutableArray *newComments = [[NSMutableArray alloc]initWithArray:[response1 valueForKey:@"vcomment_list"]];
                if ([_sequence intValue] == 0) [self.vcomment_list removeAllObjects];
                [self.vcomment_list addObjectsFromArray:newComments] ;
                self.sequence = [response1 valueForKey:@"sequence"];
                [self closeRJ];
                //
            }
        }
            break;
        default:
        {
            [CommonUtils showSimpleAlertViewWithTitle:@"信息" WithMessage:@"网络异常" WithDelegate:self WithCancelTitle:@"确定"];
            
        }
    }
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger comment_num = 0;
    if (self.vcomment_list) {
        comment_num = [self.vcomment_list count];
    }
    return 1 + comment_num;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.row == 0) {
        float height = self.video_thumb.size.height *320.0/self.video_thumb.size.width;
        cell = [[UITableViewCell alloc]initWithFrame:CGRectMake(0, 0, 320, self.specificationHeight)];
        UIButton* video = [UIButton buttonWithType:UIButtonTypeCustom];
        [video setFrame:CGRectMake(0, 0, 320,height)];
        [video addTarget:self action:@selector(play:) forControlEvents:UIControlEventTouchUpInside];
        
        UIImageView* videoIc = [[UIImageView alloc]initWithFrame:CGRectMake((320-75)/2, (height-75)/2, 75,75)];
        [videoIc setUserInteractionEnabled:NO];
        videoIc.image = [UIImage imageNamed:@"视频按钮"];
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, height, 320, 3)];
        [label setBackgroundColor:[UIColor colorWithRed:252/255.0 green:109/255.0 blue:67/255.0 alpha:1.0]];
        [video setImage:self.video_thumb forState:UIControlStateNormal];
        [cell addSubview:video];
        [cell addSubview:videoIc];
        [cell addSubview:label];
        
        UILabel* author = [[UILabel alloc]initWithFrame:CGRectMake(50, height+13, 200, 12)];
        [author setFont:[UIFont systemFontOfSize:14]];
        [author setTextColor:[UIColor colorWithRed:0/255.0 green:133/255.0 blue:186/255.0 alpha:1.0]];
        [author setBackgroundColor:[UIColor clearColor]];
        author.text = [self.videoInfo valueForKey:@"author"];
        [cell addSubview:author];
        
        UILabel* date = [[UILabel alloc]initWithFrame:CGRectMake(50, height+28, 150, 13)];
        [date setFont:[UIFont systemFontOfSize:11]];
        [date setTextColor:[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0]];
        date.text = [self.videoInfo valueForKey:@"time"];
        [date setBackgroundColor:[UIColor clearColor]];
        [cell addSubview:date];
        
        //NSLog(@"%f",self.specificationHeight);
        UILabel* specification = [[UILabel alloc]initWithFrame:CGRectMake(50, height+38, 260, self.specificationHeight+15)];
        [specification setFont:[UIFont systemFontOfSize:12]];
        [specification setNumberOfLines:0];
        specification.text = [self.videoInfo valueForKey:@"title"];
        [specification setBackgroundColor:[UIColor clearColor]];
        [cell addSubview:specification];
        
        if ([[self.videoInfo valueForKey:@"author_id"] intValue] == [[MTUser sharedInstance].userid intValue]) {
            self.delete_button = [UIButton buttonWithType:UIButtonTypeCustom];
            [self.delete_button setFrame:CGRectMake(275, height+53+self.specificationHeight, 35, 20)];
            [self.delete_button setTitle:@" 删除" forState:UIControlStateNormal];
            [self.delete_button.titleLabel setFont:[UIFont systemFontOfSize:12]];
            [self.delete_button setTitleColor:[UIColor colorWithRed:0/255.0 green:133/255.0 blue:186/255.0 alpha:1.0] forState:UIControlStateNormal];
            [self.delete_button setTitleColor:[UIColor colorWithRed:0/255.0 green:133/255.0 blue:186/255.0 alpha:0.5] forState:UIControlStateHighlighted];
            [self.delete_button addTarget:self action:@selector(deleteVideo:) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:self.delete_button];
        }
        
        UIImageView* avatar = [[UIImageView alloc]initWithFrame:CGRectMake(10, height+13, 30, 30)];
        PhotoGetter *getter = [[PhotoGetter alloc]initWithData:avatar authorId:[self.videoInfo valueForKey:@"author_id"]];
        [getter getAvatar];
        [cell addSubview:avatar];
        
        UIButton* avatarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [avatarBtn setFrame:CGRectMake(0, height+13, 50, 50)];
        [avatarBtn setBackgroundColor:[UIColor clearColor]];
        [avatarBtn addTarget:self action:@selector(pushToFriendView:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:avatarBtn];
        
        
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell setBackgroundColor:[UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0]];
        return cell;
        
        
    }else{
        //cell = [[UITableViewCell alloc]init];
        static NSString *CellIdentifier = @"vCommentCell";
        BOOL nibsRegistered = NO;
        if (!nibsRegistered) {
            UINib *nib = [UINib nibWithNibName:NSStringFromClass([VcommentTableViewCell class]) bundle:nil];
            [tableView registerNib:nib forCellReuseIdentifier:CellIdentifier];
            nibsRegistered = YES;
        }
        cell = (VcommentTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        NSDictionary* Vcomment = self.vcomment_list[indexPath.row - 1];
        NSString* commentText = [Vcomment valueForKey:@"content"];
        
        ((VcommentTableViewCell *)cell).author.text = [Vcomment valueForKey:@"author"];
        ((VcommentTableViewCell *)cell).authorName = [Vcomment valueForKey:@"author"];
        ((VcommentTableViewCell *)cell).authorId = [Vcomment valueForKey:@"author_id"];
        ((VcommentTableViewCell *)cell).origincomment = [Vcomment valueForKey:@"content"];
        ((VcommentTableViewCell *)cell).controller = self;
        ((VcommentTableViewCell *)cell).date.text = [[Vcomment valueForKey:@"time"] substringWithRange:NSMakeRange(5, 11)];
        float commentWidth = 0;
        ((VcommentTableViewCell *)cell).vcomment_id = [Vcomment valueForKey:@"vcomment_id"];
        if ([[Vcomment valueForKey:@"vcomment_id"] intValue] == -1 ) {
            commentWidth = 230;
            [((VcommentTableViewCell *)cell).waitView startAnimating];
            [((VcommentTableViewCell *)cell).resend_Button setHidden:YES];
        }else if([[Vcomment valueForKey:@"vcomment_id"] intValue] == -2 ){
            [((VcommentTableViewCell *)cell).waitView stopAnimating];
            commentWidth = 230;
            [((VcommentTableViewCell *)cell).resend_Button setHidden:NO];
            [((VcommentTableViewCell *)cell).resend_Button addTarget:self action:@selector(resendComment:) forControlEvents:UIControlEventTouchUpInside];
        }else{
            commentWidth = 255;
            [((VcommentTableViewCell *)cell).waitView stopAnimating];
            [((VcommentTableViewCell *)cell).resend_Button setHidden:YES];
        }
        
        PhotoGetter *getter = [[PhotoGetter alloc]initWithData:((VcommentTableViewCell *)cell).avatar authorId:[Vcomment valueForKey:@"author_id"]];
        [getter getAvatar];
        
        
        int height = [CommonUtils calculateTextHeight:commentText width:255.0 fontSize:12.0 isEmotion:YES];
        
        MLEmojiLabel* comment =((VcommentTableViewCell *)cell).comment;
        if (!comment){
            comment = [[MLEmojiLabel alloc]initWithFrame:CGRectMake(50, 24, 255, height)];
            ((VcommentTableViewCell *)cell).comment = comment;
        }
        else [comment setFrame:CGRectMake(50, 24, commentWidth, height)];
        [comment setDisableThreeCommon:YES];
        comment.numberOfLines = 0;
        comment.font = [UIFont systemFontOfSize:12.0f];
        comment.backgroundColor = [UIColor clearColor];
        comment.lineBreakMode = NSLineBreakByCharWrapping;
        
        
        comment.emojiText = [Vcomment valueForKey:@"content"];
        //[comment.layer setBackgroundColor:[UIColor clearColor].CGColor];
        [comment setBackgroundColor:[UIColor clearColor]];
        [cell setFrame:CGRectMake(0, 0, 320, 32 + height)];
        
        UIView* backguand = ((VcommentTableViewCell *)cell).background;
        if (!backguand){
            backguand = [[UIView alloc]initWithFrame:CGRectMake(10, 0, 300, 32+height)];
            ((VcommentTableViewCell *)cell).background = backguand;
        }
        else [backguand setFrame:CGRectMake(10, 0, 300, 32+height)];
        [backguand setBackgroundColor:[UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1.0]];
        [cell setBackgroundColor:[UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0]];
        [cell addSubview:backguand];
        [cell sendSubviewToBack:backguand];
        [cell addSubview:comment];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell setUserInteractionEnabled:YES];
        return cell;
        
    }
    
}

#pragma mark - Table view delegate


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    float height = 0;
    if (indexPath.row == 0) {
        self.specificationHeight = [CommonUtils calculateTextHeight:[self.videoInfo valueForKey:@"title"] width:260.0 fontSize:12.0 isEmotion:NO];
        height = self.video_thumb.size.height *320.0/self.video_thumb.size.width;
        height += 3;
        height += 50;
        height += 30;//delete button
        height += self.specificationHeight;
        
    }else{
        NSDictionary* Vcomment = self.vcomment_list[indexPath.row - 1];
        float commentWidth = 0;
        NSString* commentText = [Vcomment valueForKey:@"content"];
        if ([[Vcomment valueForKey:@"vcomment_id"] intValue] > 0) {
            commentWidth = 255;
        }else commentWidth = 230;
        
        height = [CommonUtils calculateTextHeight:commentText width:commentWidth fontSize:12.0 isEmotion:YES];
        height += 32;
    }
    return height;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isKeyBoard) {
        [self.inputTextView resignFirstResponder];
        return;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        //[self.navigationController popToViewController:self.photoDisplayController animated:YES];
    }else{
        VcommentTableViewCell *cell = (VcommentTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
        [cell.background setAlpha:0.5];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [cell.background setAlpha:1.0];
        });
        if ([cell.vcomment_id intValue] < 0){
            [self resendComment: cell.resend_Button];
            return;
        }
        self.herName = cell.authorName;
        if ([cell.authorId intValue] != [[MTUser sharedInstance].userid intValue]) {
            self.inputTextView.placeHolder = [NSString stringWithFormat:@"回复%@:",_herName];
        }else self.inputTextView.placeHolder = @"说点什么吧";
        [self.inputTextView becomeFirstResponder];
        self.repliedId = cell.authorId;
    }
}

#pragma mark 代理方法-进入刷新状态就会调用
- (void)refreshViewBeginRefreshing:(MJRefreshBaseView *)refreshView
{
    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == 0) {
        NSLog(@"没有网络");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [refreshView endRefreshing];
        });
        return;
    }
    [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(closeRJ) userInfo:nil repeats:NO];
    _Footeropen = YES;
    [self pullMainCommentFromAir];
}
#pragma mark - keyboard observer method
//Code from Brett Schumann
-(void) keyboardWillShow:(NSNotification *)note{
    self.isKeyBoard = YES;
    if (self.isEmotionOpen) {
        [self button_Emotionpress:nil];
    }
    // get keyboard size and loctaion
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
    // get a rect for the textView frame
    CGRect containerFrame = self.commentView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - (keyboardBounds.size.height + containerFrame.size.height);
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    // set views with new info
    self.commentView.frame = containerFrame;
    
    
    // commit animations
    [UIView commitAnimations];
}

-(void) keyboardWillHide:(NSNotification *)note{
    self.isKeyBoard = NO;
    //self.inputField.text = @"";
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // get a rect for the textView frame
    CGRect containerFrame = self.commentView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - containerFrame.size.height;
    
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    // set views with new info
    self.commentView.frame = containerFrame;
    
    // commit animations
    [UIView commitAnimations];
}

#pragma mark - UITextView Delegate
-(void)textViewDidChange:(UITextView *)textView
{
    CGRect frame = _inputTextView.frame;
    float change = _inputTextView.contentSize.height - frame.size.height;
    if (change != 0 && _inputTextView.contentSize.height < 120) {
        frame.size.height = _inputTextView.contentSize.height;
        [_inputTextView setFrame:frame];
        frame = _commentView.frame;
        frame.origin.y -= change;
        frame.size.height += change;
        [_commentView setFrame:frame];
    }
}


#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case 100:{
            NSInteger cancelBtnIndex = alertView.cancelButtonIndex;
            NSInteger okBtnIndex = alertView.firstOtherButtonIndex;
            if (buttonIndex == cancelBtnIndex) {
                ;
            }
            else if (buttonIndex == okBtnIndex)
            {
                NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
                [dictionary setValue:[MTUser sharedInstance].userid forKey:@"id"];
                [dictionary setValue:self.eventId forKey:@"event_id"];
                [dictionary setValue:@"delete" forKey:@"cmd"];
                [dictionary setValue:self.videoId forKey:@"video_id"];
                NSLog(@"%@",dictionary);
                HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
                [httpSender sendVideoMessage:dictionary withOperationCode: VIDEOSERVER finshedBlock:^(NSData *rData) {
                    if (rData) {
                        NSString* temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
                        NSLog(@"received Data: %@",temp);
                        NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
                        NSNumber *cmd = [response1 valueForKey:@"cmd"];
                        switch ([cmd intValue]) {
                            case NORMAL_REPLY:
                            {
                                //百度云 删除
                                CloudOperation * cloudOP = [[CloudOperation alloc]initWithDelegate:nil];
                                [cloudOP deletePhoto:[NSString stringWithFormat:@"/video/%@.thumb",[self.videoInfo valueForKey:@"video_name"]]];
                                CloudOperation * cloudOP1 = [[CloudOperation alloc]initWithDelegate:self];
                                [cloudOP1 deletePhoto:[NSString stringWithFormat:@"/video/%@",[self.videoInfo valueForKey:@"video_name"]]];
                                //数据库 删除
                                [self deleteVideoInfoFromDB];
                                
                                
                            }
                                break;
                            default:
                            {
                                [self deleteVideoInfoFromDB];
                                [self.delete_button setEnabled:YES];
                                UIAlertView *alert = [CommonUtils showSimpleAlertViewWithTitle:@"信息" WithMessage:@"视频删除成功" WithDelegate:self WithCancelTitle:@"确定"];
                                [alert setTag:1];
                            }
                        }
                        
                    }else{
                        [self.delete_button setEnabled:YES];
                        [CommonUtils showSimpleAlertViewWithTitle:@"信息" WithMessage:@"网络异常，请重试" WithDelegate:nil WithCancelTitle:@"确定"];
                    }
                    
                }];
            }
            
        }
            break;
        case 1:{
            int index = self.navigationController.viewControllers.count - 2;
            VideoWallViewController* controller = (VideoWallViewController*)self.navigationController.viewControllers[index];
            controller.shouldReload = YES;
            [self.navigationController popViewControllerAnimated:YES];
        }
        default:
            break;
    }
}

#pragma mark - CloudOperationDelegate
-(void)finishwithOperationStatus:(BOOL)status type:(int)type data:(NSData *)mdata path:(NSString *)path
{
    if (status){
        UIAlertView *alert = [CommonUtils showSimpleAlertViewWithTitle:@"提示" WithMessage:@"视频删除成功" WithDelegate:self WithCancelTitle:@"确定"];
        [alert setTag:1];
        [self.delete_button setEnabled:YES];
    }else{
        [self.delete_button setEnabled:YES];
        [CommonUtils showSimpleAlertViewWithTitle:@"信息" WithMessage:@"网络异常，请重试" WithDelegate:nil WithCancelTitle:@"确定"];
    }
}
#pragma mark - MPlayer Delegate
-(void)movieFinishedCallback:(NSNotification*)notify{
    
    // 视频播放完或者在presentMoviePlayerViewControllerAnimated下的Done按钮被点击响应的通知。
    
    MTMPMoviePlayerViewController* theMovie = [notify object];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self
     
                                                   name:MPMoviePlayerPlaybackDidFinishNotification
     
                                                 object:theMovie];
    
    [self dismissMoviePlayerViewControllerAnimated];
    
    NSString *CacheDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *webPath = [CacheDirectory stringByAppendingPathComponent:@"VideoTemp"];
    NSString *filePath = [webPath stringByAppendingPathComponent:[_videoInfo valueForKey:@"video_name"]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath]) {
        [fileManager removeItemAtPath:filePath error:nil];
    }
}

#pragma mark - TextView view delegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [self publishComment:nil];
        return NO;
    }
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //这里我很谨慎的对sender和目标视图控制器作了判断
    if ([sender isKindOfClass:[VideoDetailViewController class]]) {
        if ([segue.destinationViewController isKindOfClass:[ReportViewController class]]) {
            ReportViewController *nextViewController = segue.destinationViewController;
            nextViewController.eventId = _eventId;
            nextViewController.videoId = _videoId;
            nextViewController.event = self.eventName;
            nextViewController.type = 5;
        }
    }
}

@end
