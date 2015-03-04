

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
#import "../../Source/SVProgressHUD/SVProgressHUD.h"
#import "NotificationController.h"
#import "BOAlertController.h"


@interface VideoWallViewController ()
@property(nonatomic,strong) NSMutableArray* videoInfos;
@property(nonatomic,strong) NSMutableArray* videoInfos_all;
@property(nonatomic,strong) NSNumber* sequence;
@property(nonatomic,strong) NSString* urlFormat;
@property(nonatomic,strong) UIImage* preViewImage;
@property (strong,nonatomic) MJRefreshHeaderView *header;
@property (strong,nonatomic) MJRefreshFooterView *footer;
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
    [NotificationController visitVideoWall:_eventId needClear:YES];
    _loadingVideo = [[NSMutableSet alloc]init];
    //init tableView
    self.view.autoresizesSubviews = YES;
//    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(10, 0, self.view.frame.size.width - 20, self.view.frame.size.height)];
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
    _videoInfos_all = [[NSMutableArray alloc]init];
    [self pullVideosInfosFromDB];
    _sequence = [NSNumber numberWithInt:-1];
    _shouldFlash = NO;
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(reShouldFlash) userInfo:nil repeats:NO];
    [_tableView reloadData];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"initLVideo"
                                                            object:nil
                                                          userInfo:nil];
    });
    
    

}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [SVProgressHUD dismiss];
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
    if (_Footeropen||_Headeropen) {
        [refreshView endRefreshing];
        return;
    }
    if (refreshView == _header) {
        _Headeropen = YES;
        self.sequence = [NSNumber numberWithInt:0];
        [self getVideolist];
    }else{
        _Footeropen = YES;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSInteger rest = [_videoInfos_all count] - [_videoInfos count];
            if (rest > 0) {
                [_videoInfos addObjectsFromArray:[_videoInfos_all subarrayWithRange:NSMakeRange(_videoInfos.count, rest > 10? 10:rest)]];
                _shouldFlash = NO;
                [_timer invalidate];
                _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(reShouldFlash) userInfo:nil repeats:NO];
                [self closeRJ];
                [_tableView reloadData];
                
            }else{
                [self closeRJ];
                [_tableView reloadData];
                
            }
        });
        
        
        
        
    }
    
}

-(void)refreshvideoInfoFromDB:(NSMutableArray*)videoInfos
{
    if (_eventId) {
        [self deleteAllVideoInfoFromDB:_eventId];
        [VideoWallViewController updateVideoInfoToDB:videoInfos eventId:_eventId];
    }
    
}

-(void)deleteAllVideoInfoFromDB:(NSNumber*) eventId
{
    if (!eventId) {
        return;
    }
    NSString * path = [NSString stringWithFormat:@"%@/db",[MTUser sharedInstance].userid];
    MySqlite *sql = [[MySqlite alloc]init];
    [sql openMyDB:path];
    NSDictionary *wheres = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%@", eventId],@"event_id", nil];
    [sql deleteTurpleFromTable:@"eventVideo" withWhere:wheres];
    [sql closeMyDB];
}

+ (void)updateVideoInfoToDB:(NSMutableArray*)videoInfos eventId:(NSNumber*)eventId
{
    NSString * path = [NSString stringWithFormat:@"%@/db",[MTUser sharedInstance].userid];
    MySqlite* sql = [[MySqlite alloc]init];
    [sql openMyDB:path];
    for (int i = 0; i < videoInfos.count; i++) {
        NSDictionary* videoInfo = [videoInfos objectAtIndex:i];
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
    for (int i = 0; i < result.count; i++) {
        NSDictionary* temp = [result objectAtIndex:i];
        NSString *tmpa = [temp valueForKey:@"videoInfo"];
        tmpa = [tmpa stringByReplacingOccurrencesOfString:@"''" withString:@"'"];
        NSData *tmpb = [tmpa dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *videoInfo =  [NSJSONSerialization JSONObjectWithData:tmpb options:NSJSONReadingMutableContainers error:nil];
        [self.videoInfos addObject:videoInfo];
        [self.videoInfos_all addObject:videoInfo];
    }
    
    [sql closeMyDB];
    
//    [self initAVPlayers];
}

-(void)initAVPlayers
{
    return;
    if (!_AVPlayers) _AVPlayers = [[NSMutableDictionary alloc]init];
    if (!_AVPlayerLayers) _AVPlayerLayers = [[NSMutableDictionary alloc]init];
    if (!_AVPlayerItems) _AVPlayerItems = [[NSMutableDictionary alloc]init];
    for (int i = 0; i < _videoInfos.count; i++) {
        NSDictionary* info = [_videoInfos objectAtIndex:i];
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
                    
                    if ([_sequence intValue] == 0){
                        [_videoInfos_all removeAllObjects];
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_global_queue(0, 0), ^{
                            [self deleteAllVideoInfoFromDB:_eventId];
                            if (_eventId) {
                                [VideoWallViewController updateVideoInfoToDB:newvideo_list eventId:_eventId];
                            }
                        });
                        
                    }else{
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_global_queue(0, 0), ^{
                            if (_eventId) {
                                [VideoWallViewController updateVideoInfoToDB:newvideo_list eventId:_eventId];
                            }
                        });
                    }
                    
                    
                    _sequence = [response1 valueForKey:@"sequence"];
                    if ([_sequence integerValue] != -1) {
                        [_videoInfos_all addObjectsFromArray:newvideo_list];
                        [self getVideolist];
                        return ;
                    }
                    
                    
                    NSInteger rest = [_videoInfos_all count];

                    _videoInfos = [NSMutableArray arrayWithArray:[_videoInfos_all subarrayWithRange:NSMakeRange(0, rest > 10? 10:rest)]];

                    _shouldFlash = NO;
                    [_timer invalidate];
                    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(reShouldFlash) userInfo:nil repeats:NO];
                    [NotificationController visitVideoWall:_eventId needClear:YES];
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
            [self closeRJ];
        }
    }];
    
    
}

- (IBAction)uploadVideo:(id)sender {
    
    BOAlertController *actionSheet = [[BOAlertController alloc] initWithTitle:@"选择视频" message:nil viewController:self];
    
    RIButtonItem *cancelItem = [RIButtonItem itemWithLabel:@"取消" action:^{
        NSLog(@"cancel");
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"shouldIgnoreTurnToNotifiPage"];
    }];
    [actionSheet addButton:cancelItem type:RIButtonItemType_Cancel];
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        RIButtonItem *takeItem = [RIButtonItem itemWithLabel:@"录像" action:^{
            UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
            imagePickerController.delegate = self;
            imagePickerController.allowsEditing = NO;
            imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            
            imagePickerController.videoQuality = UIImagePickerControllerQualityType640x480;
            NSArray* availableMedia = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
            imagePickerController.mediaTypes = [NSArray arrayWithObject:availableMedia[1]];
            imagePickerController.videoMaximumDuration = 20;
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"shouldIgnoreTurnToNotifiPage"];
            [self presentViewController:imagePickerController animated:YES completion:^{}];
        }];
        [actionSheet addButton:takeItem type:RIButtonItemType_Other];
    }
    
    RIButtonItem *seleteItem = [RIButtonItem itemWithLabel:@"从相册选择" action:^{
        // 跳转到相机或相册页面
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = self;
        imagePickerController.allowsEditing = NO;
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
            imagePickerController.sourceType =UIImagePickerControllerSourceTypePhotoLibrary;
        }else imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        imagePickerController.videoQuality = UIImagePickerControllerQualityType640x480;
        NSArray* availableMedia = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
        imagePickerController.mediaTypes = [NSArray arrayWithObject:availableMedia[1]];
        imagePickerController.videoMaximumDuration = 20;
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"shouldIgnoreTurnToNotifiPage"];
        [self presentViewController:imagePickerController animated:YES completion:^{}];
    }];
    [actionSheet addButton:seleteItem type:RIButtonItemType_Other];
    
    [actionSheet showInView:self.view];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"shouldIgnoreTurnToNotifiPage"];
    
}

#pragma scrollview Delegate
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"pauseVideo" object:nil userInfo:nil];
    NSLog(@"%f   %f   %f",scrollView.frame.size.height,self.view.frame.size.height,self.navigationController.view.frame.size.height);
    
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
    NSInteger add = 0;
    if(([_sequence integerValue] == -1 || [_videoInfos count] == 0) && _videoInfos.count == _videoInfos_all.count){
        add = 1;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            _footer.scrollView = nil;
            _footer.hidden = YES;
        });
        
    }else{
        _footer.scrollView = _tableView;
        _footer.hidden = NO;
    }
    
    
    if (_videoInfos) {
        return [_videoInfos count] + add;
    }else return add;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row >= [_videoInfos count]) {
        UITableViewCell* cell = [[UITableViewCell alloc]init];
        float width = 300;
        float height = 60;
        UILabel* label = [[UILabel alloc]initWithFrame:CGRectMake(width/6, height-45, width*4/6, 30)];
        label.text = [_videoInfos count] > 0? @"没有更多了哦，去上传吧~":@"还没有视频哦，快去上传吧";
        label.font = [UIFont systemFontOfSize:15];
        label.textColor = [UIColor colorWithWhite:147.0/255.0 alpha:1.0f];
        label.textAlignment = NSTextAlignmentCenter;
        label.backgroundColor = [UIColor clearColor];
        cell.backgroundColor = [UIColor clearColor];
        cell.userInteractionEnabled = NO;
        [cell addSubview:label];
        return cell;
    }

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
    if(indexPath.row >= _videoInfos.count) return 60;
    
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
            nextViewController.index = [_tableView indexPathForCell:_SeleVcell];
            nextViewController.controller = self;
            nextViewController.eventId = self.eventId;
            nextViewController.eventName = self.eventName;
            nextViewController.videoInfo = self.seleted_videoInfo;
            nextViewController.video_thumb = self.seleted_videoThumb;
        }
    }
}



#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSURL* videoURL = info[UIImagePickerControllerMediaURL];
    //[self save:[videoURL path]];
    NSInteger fileSize_N = [self getFileSize:[[videoURL absoluteString] substringFromIndex:16]];
    NSInteger videoLen_N = [self getVideoDuration:videoURL];
    NSString* fileSize = [NSString stringWithFormat:@"%ld kb",(long)fileSize_N];
    NSString* videoLen = [NSString stringWithFormat:@"%.0ld s", (long)videoLen_N];
    NSLog(@"%@   %@",fileSize,videoLen);
    if (videoLen_N > 20*60) {
        //视频超过20分钟，不能上传
        [picker dismissViewControllerAnimated:YES completion:^{
            [CommonUtils showSimpleAlertViewWithTitle:@"提示" WithMessage:@"视频文件过大，无法上传" WithDelegate:nil WithCancelTitle:@"确定"];
        }];
        return;
    }

    VideoPreviewViewController* controller = [[VideoPreviewViewController alloc]init];
    controller.videoURL = videoURL;
    controller.eventId = _eventId;
    [self.navigationController pushViewController:controller animated:YES];
    
    [picker dismissViewControllerAnimated:YES completion:^{
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"shouldIgnoreTurnToNotifiPage"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        //[self openEditor:nil];
    }];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"shouldIgnoreTurnToNotifiPage"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }];
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
