

//
//  VideoWallViewController.m
//  WeShare
//
//  Created by ligang6 on 14-8-31.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "VideoWallViewController.h"
#import "VideoDetailViewController.h"
#import "../../Cell/VideoWallTableViewCell.h"
#import "PhotoGetter.h"
#import "UIImageView+WebCache.h"
#import "MobClick.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "VideoPreviewViewController.h"
#import "MTUIImagePickerController.h"
#import "../../Utils/NSString+JSON.h"
#import "../../Utils/Reachability.h"



@interface VideoWallViewController ()
@property(nonatomic,strong) NSMutableArray* videoInfos;
@property(nonatomic,strong) NSNumber* sequence;
@property(nonatomic,strong) NSString* urlFormat;
@property(nonatomic,strong) UIImage* preViewImage;
@property (strong,nonatomic) MJRefreshHeaderView *header;
@property (strong,nonatomic) MJRefreshFooterView *footer;
@property (strong,nonatomic) VideoWallTableViewCell *SeleVcell;
@property(nonatomic,strong) UILabel* promt;
@property BOOL Headeropen;
@property BOOL Footeropen;
@property NSTimer* timer;
@end

@implementation VideoWallViewController

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
    _shouldReload = YES;
    _shouldFlash = YES;
    _canPlay = YES;
    _shouldPlay = NO;
    [CommonUtils addLeftButton:self isFirstPage:NO];
    _loadingVideo = [[NSMutableSet alloc]init];
    //init tableView
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(10, 0, self.view.frame.size.width - 20, self.view.frame.size.height)];
    [_tableView setShowsVerticalScrollIndicator:NO];
    [_tableView setBackgroundColor:[UIColor clearColor]];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];

//    _urlFormat = @"http://bcs.duapp.com/metis201415/video/%@.thumb?sign=%@";//测试服
//    _urlFormat = @"http://bcs.duapp.com/whatsact/video/%@.thumb?sign=%@";//正式服
    _urlFormat = @[@"http://bcs.duapp.com/metis201415/video/%@.thumb?sign=%@",@"http://bcs.duapp.com/whatsact/video/%@.thumb?sign=%@"][Server];
    
    _videoInfos = [[NSMutableArray alloc]init];
    [self pullVideosInfosFromDB];
    _shouldFlash = NO;
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(reShouldFlash) userInfo:nil repeats:NO];
    [_tableView reloadData];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"initLVideo"
                                                            object:nil
                                                          userInfo:nil];
    });
    
    _Headeropen = NO;
    _Footeropen = NO;
    //初始化下拉刷新功能
    _header = [[MJRefreshHeaderView alloc]init];
    _header.delegate = self;
    _header.scrollView = self.tableView;
    
    //初始化上拉加载更多
    _footer = [[MJRefreshFooterView alloc]init];
    _footer.delegate = self;
    _footer.scrollView = _tableView;

}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_tableView setFrame:CGRectMake(10, 0, self.view.frame.size.width - 20, self.view.frame.size.height)];
    if (_shouldReload) {
        _shouldReload = NO;
        [_header beginRefreshing];
    }
    
    [MobClick beginLogPageView:@"视频墙"];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"initLVideo"
                                                            object:nil
                                                          userInfo:nil];
    });
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Playfrompause"
                                                        object:nil
                                                      userInfo:nil];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [MobClick endLogPageView:@"视频墙"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"pauseVideo" object:nil userInfo:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    for (AVPlayer*  player in [_AVPlayers objectEnumerator]) {
        [player replaceCurrentItemWithPlayerItem:nil];
    }
    [_header free];
    [_footer free];
}
//返回上一层
-(void)MTpopViewController{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)reShouldFlash{
    if (self) {
        _shouldFlash = YES;
    }
}

-(void)closeRJ
{
    if (_Headeropen) {
        _Headeropen = NO;
        [_header endRefreshing];
    }
    if (_Footeropen) {
        _Footeropen = NO;
        [_footer endRefreshing];
    }
}

-(void)showPromt
{
    if (_videoInfos.count == 0 && _promt == nil) {
        _promt = [[UILabel alloc]initWithFrame:CGRectMake(50, 20, 200, 21)];
        _promt.text = @"还没有视频哦，快去上传吧";
        _promt.textAlignment= NSTextAlignmentCenter;
        _promt.textColor = [UIColor colorWithWhite:147.0/255.0 alpha:1];
        _promt.font = [UIFont systemFontOfSize:15];
        
        [_tableView addSubview:_promt];
    }
    
    if (_videoInfos.count != 0 && _promt) {
        [_promt removeFromSuperview];
        _promt = nil;
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
    if (_Footeropen||_Headeropen) {
        [refreshView endRefreshing];
        return;
    }
    if (refreshView == _header) {
        _Headeropen = YES;
        self.sequence = [NSNumber numberWithInt:0];
    }else _Footeropen = YES;
    [self getVideolist];
}

+ (void)updateVideoInfoToDB:(NSMutableArray*)videoInfos eventId:(NSNumber*)eventId
{
    NSString * path = [NSString stringWithFormat:@"%@/db",[MTUser sharedInstance].userid];
    MySqlite* sql = [[MySqlite alloc]init];
    [sql openMyDB:path];
    for (NSDictionary *videoInfo in videoInfos) {
        NSString *videoData = [NSString jsonStringWithDictionary:videoInfo];
        videoData = [videoData stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        NSArray *columns = [[NSArray alloc]initWithObjects:@"'video_id'",@"'event_id'",@"'videoInfo'", nil];
        NSArray *values = [[NSArray alloc]initWithObjects:[NSString stringWithFormat:@"%@",[videoInfo valueForKey:@"video_id"]],[NSString stringWithFormat:@"%@",eventId],[NSString stringWithFormat:@"'%@'",videoData], nil];
        
        [sql insertToTable:@"eventVideo" withColumns:columns andValues:values];
    }
    [sql closeMyDB];
}

- (void)pullVideosInfosFromDB
{
    NSString * path = [NSString stringWithFormat:@"%@/db",[MTUser sharedInstance].userid];
    MySqlite* sql = [[MySqlite alloc]init];
    [sql openMyDB:path];
    
    //self.events = [[NSMutableArray alloc]init];
    NSArray *seletes = [[NSArray alloc]initWithObjects:@"videoInfo", nil];
    NSDictionary *wheres = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%@ order by video_id desc",_eventId],@"event_id", nil];
    NSMutableArray *result = [sql queryTable:@"eventVideo" withSelect:seletes andWhere:wheres];
    for (NSDictionary *temp in result) {
        NSString *tmpa = [temp valueForKey:@"videoInfo"];
        tmpa = [tmpa stringByReplacingOccurrencesOfString:@"''" withString:@"'"];
        NSData *tmpb = [tmpa dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *videoInfo =  [NSJSONSerialization JSONObjectWithData:tmpb options:NSJSONReadingMutableContainers error:nil];
        [self.videoInfos addObject:videoInfo];
    }
    
    [sql closeMyDB];
    [self showPromt];
    
//    [self initAVPlayers];
}

-(void)initAVPlayers
{
    return;
    if (!_AVPlayers) _AVPlayers = [[NSMutableDictionary alloc]init];
    if (!_AVPlayerLayers) _AVPlayerLayers = [[NSMutableDictionary alloc]init];
    if (!_AVPlayerItems) _AVPlayerItems = [[NSMutableDictionary alloc]init];
    for (NSDictionary* info in _videoInfos) {
        NSString *videoName = [info valueForKey:@"video_name"];
        if ([_AVPlayers objectForKey:videoName]) continue;
        NSString *CacheDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        NSString *cachePath = [CacheDirectory stringByAppendingPathComponent:@"VideoCache"];
        
        NSFileManager *fileManager=[NSFileManager defaultManager];
        if([fileManager fileExistsAtPath:[cachePath stringByAppendingPathComponent:videoName]])
        {
            NSURL* url = [NSURL fileURLWithPath:[cachePath stringByAppendingPathComponent:videoName]];
            AVPlayerItem *videoItem = [AVPlayerItem playerItemWithURL:url];
            AVPlayer *videoPlayer = [AVPlayer playerWithPlayerItem:videoItem];
            AVPlayerLayer* playerLayer = [AVPlayerLayer playerLayerWithPlayer:videoPlayer];
            [_AVPlayerItems setObject:videoItem forKey:videoName];
            [_AVPlayers setObject:videoPlayer forKey:videoName];
            [_AVPlayerLayers setObject:playerLayer forKey:videoName];
        }
    }
}

-(void)getVideolist
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:[MTUser sharedInstance].userid forKey:@"id"];
    [dictionary setValue:self.sequence forKey:@"sequence"];
    [dictionary setValue:self.eventId forKey:@"event_id"];
    NSLog(@"%@",dictionary);
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:GET_VIDEO_LIST finshedBlock:^(NSData *rData) {
        if (rData) {
            NSString* temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
            NSLog(@"received Data: %@",temp);
            NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
            NSNumber *cmd = [response1 valueForKey:@"cmd"];
            switch ([cmd intValue]) {
                case NORMAL_REPLY:{
                    NSMutableArray* newvideo_list =[[NSMutableArray alloc]initWithArray:[response1 valueForKey:@"video_list"]];
                    for (int i = 0; i < newvideo_list.count; i++) {
                        NSMutableDictionary* dictionary = [[NSMutableDictionary alloc]initWithDictionary:newvideo_list[i]];
                        newvideo_list[i] = dictionary;
                    }
                    [VideoWallViewController updateVideoInfoToDB:newvideo_list eventId:_eventId];
                    if ([_sequence intValue] == 0) [_videoInfos removeAllObjects];
                    _sequence = [response1 valueForKey:@"sequence"];
                    for (NSMutableDictionary *dictionary in newvideo_list) {
                        [_videoInfos addObject:dictionary];
                    }
//                    [self initAVPlayers];
                    _shouldFlash = NO;
                    [_timer invalidate];
                    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(reShouldFlash) userInfo:nil repeats:NO];
                    
                    [self.tableView reloadData];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"initLVideo"
                                                                            object:nil
                                                                          userInfo:nil];
                    });
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self closeRJ];
                    });
                    
                }
                    break;
                default:{
                }
            }

        }else{
        }
        [self showPromt];
    }];
    
    
}

- (IBAction)uploadVideo:(id)sender {
    UIActionSheet *sheet;
    
    // 判断是否支持相机
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        sheet  = [[UIActionSheet alloc] initWithTitle:@"选择视频" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"取消" otherButtonTitles:@"录像", @"从相册选择", nil];
    }
    else {
        sheet = [[UIActionSheet alloc] initWithTitle:@"选择视频" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"取消" otherButtonTitles:@"从相册选择", nil];
    }
    
    sheet.tag = 255;
    
    [sheet showInView:self.view];
}

#pragma scrollview Delegate
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"pauseVideo" object:nil userInfo:nil];
}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"initLVideo"
                                                        object:nil
                                                      userInfo:nil];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    _shouldPlay = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (_shouldPlay == YES) {
            _shouldPlay = NO;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"initLVideo"
                                                                object:nil
                                                              userInfo:nil];
            
        }
        
    });
    
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    _shouldPlay = NO;
}


#pragma tableView DataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_videoInfos) {
        return [_videoInfos count];
    }else return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"VideoTableViewCell";
    BOOL nibsRegistered = NO;
    if (!nibsRegistered) {
        UINib *nib = [UINib nibWithNibName:NSStringFromClass([VideoWallTableViewCell class]) bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:CellIdentifier];
        nibsRegistered = YES;
    }
    VideoWallTableViewCell *cell = (VideoWallTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (self.videoInfos) {
        NSMutableDictionary *dictionary = self.videoInfos[indexPath.row];
        cell.videoInfo = dictionary;
        cell.eventId = _eventId;
        cell.controller = self;

        NSString* text = [dictionary valueForKey:@"title"];
        float height = [CommonUtils calculateTextHeight:text width:280 fontSize:16.0f  isEmotion:NO];
        if ([text isEqualToString:@""]) height = -19;
        cell.height = height;
        [cell refresh];
        [cell animationBegin];
    }
    
	return cell;

}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dictionary = self.videoInfos[indexPath.row];
    NSString* text = [dictionary valueForKey:@"title"];
    float height = [CommonUtils calculateTextHeight:text width:280 fontSize:16.0f isEmotion:NO];
    if ([text isEqualToString:@""]) height = -19;
    return 341 + height;
    
}
#pragma tableView Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    VideoWallTableViewCell* cell = (VideoWallTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    _SeleVcell = cell;
    NSMutableDictionary *dictionary = self.videoInfos[indexPath.row];
    _seleted_videoInfo = dictionary;
    _seleted_videoThumb = cell.videoThumb;
    [cell clearVideoRequest];
    [self performSegueWithIdentifier:@"toVideoDetail" sender:self];
}

#pragma mark 用segue跳转时传递参数eventid
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //这里我很谨慎的对sender和目标视图控制器作了判断
    if ([sender isKindOfClass:[VideoWallViewController class]]) {
        if ([segue.destinationViewController isKindOfClass:[VideoDetailViewController class]]) {
            VideoDetailViewController *nextViewController = segue.destinationViewController;
            nextViewController.SeleVcell = _SeleVcell;
            nextViewController.controller = self;
            nextViewController.eventId = self.eventId;
            nextViewController.eventName = self.eventName;
            nextViewController.videoInfo = self.seleted_videoInfo;
            nextViewController.video_thumb = self.seleted_videoThumb;
        }
    }
}

#pragma mark - action sheet delegte
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 255) {
        // 跳转到相机或相册页面
        UIImagePickerController* pickerView = [[UIImagePickerController alloc] init];
        NSUInteger sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        // 判断是否支持相机
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            switch (buttonIndex) {
                case 0:
                    return;
                case 1: //相机
                    sourceType = UIImagePickerControllerSourceTypeCamera;
                    break;
                case 2: //相册
                    sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                    break;
            }
        }
        else {
            if (buttonIndex == 0) {
                return;
            } else {
                sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            }
        }
        pickerView.sourceType = sourceType;
        pickerView.videoQuality = UIImagePickerControllerQualityType640x480;
        NSArray* availableMedia = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
        pickerView.mediaTypes = [NSArray arrayWithObject:availableMedia[1]];
        [self presentViewController:pickerView animated:YES completion:^{}];
        pickerView.videoMaximumDuration = 20;
        pickerView.delegate = self;
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSURL* videoURL = info[UIImagePickerControllerMediaURL];
    //[self save:[videoURL path]];
    NSString* fileSize = [NSString stringWithFormat:@"%d kb", [self getFileSize:[[videoURL absoluteString] substringFromIndex:16]]];
    NSString* videoLen = [NSString stringWithFormat:@"%.0f s", [self getVideoDuration:videoURL]];
    NSLog(@"%@   %@",fileSize,videoLen);
    [picker dismissViewControllerAnimated:YES completion:^{
        //[self openEditor:nil];
    }];

    VideoPreviewViewController* controller = [[VideoPreviewViewController alloc]init];
    controller.videoURL = videoURL;
    controller.eventId = _eventId;
    [self.navigationController pushViewController:controller animated:YES];
    
    
}


#pragma mark - private Method

- (NSInteger) getFileSize:(NSString*) path
{
    NSFileManager * filemanager = [[NSFileManager alloc]init];
    if([filemanager fileExistsAtPath:path]){
        NSDictionary * attributes = [filemanager attributesOfItemAtPath:path error:nil];
        NSNumber *theFileSize;
        if ( (theFileSize = [attributes objectForKey:NSFileSize]) )
            return  [theFileSize intValue]/1024;
        else
            return -1;
    }
    else
    {
        return -1;
    }
}

- (CGFloat) getVideoDuration:(NSURL*) URL
{
    NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                                                     forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:URL options:opts];
    float second = 0;
    second = urlAsset.duration.value/urlAsset.duration.timescale;
    return second;
}

- (void)save:(NSString*)urlString{
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library writeVideoAtPathToSavedPhotosAlbum:[NSURL fileURLWithPath:urlString]
                                completionBlock:^(NSURL *assetURL, NSError *error) {
                                    if (error) {
                                        NSLog(@"Save video fail:%@",error);
                                    } else {
                                        NSLog(@"Save video succeed.");
                                        
                                    }
                                }];
}


@end
