//
//  PictureWall2.m
//  WeShare
//
//  Created by ligang6 on 14-12-2.
//  Copyright (c) 2014年 WeShare. All rights reserved.
//

#import "PictureWall2.h"
#import "MySqlite.h"
#import "MTUser.h"
#import "TMQuiltView.h"
#import "MobClick.h"
#import "Reachability.h"
#import "NSString+JSON.h"
#import "PhotoTableViewCell.h"
#import "PhotoDisplayViewController.h"
#import "photoRankingViewController.h"
#import "PhotoUploadViewController.h"
#import "SVProgressHUD.h"
#import "NotificationController.h"
#import "MTAutoHideButton.h"
#import "UploaderManager.h"
#import "UploadManageViewController.h"
#import "MTDatabaseHelper.h"

#define photoNumPP 60
#define photoNumToGet 100

@interface PictureWall2 ()<TMQuiltViewDataSource,TMQuiltViewDelegate>
{
    dispatch_queue_t sync_queue;
}

@property (nonatomic,strong) MTAutoHideButton* add;
@property (nonatomic,strong) UIButton* uploadManageBtn;
@property (nonatomic,strong) NSTimer* uploadStatusTimer;
@property float h1;
@property BOOL nibsRegistered;
@property BOOL shouldLoadPhoto;
@property BOOL haveLoadedPhoto;
@property BOOL isLoading;
@property BOOL isFirstIn;
@property BOOL isFirstPullDB;
@end

@implementation PictureWall2
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    [self initData];
    // Do any additional setup after loading the view from its nib.
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"photoUploadFinished" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"deletePhotoItem" object:nil];
    [_header free];
    [_add free];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initUI
{
    self.title = @"图片墙";
    self.quiltView = [[TMQuiltView alloc] initWithFrame:self.view.bounds];
    self.quiltView.delegate = self;
    self.quiltView.dataSource = self;
    self.quiltView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

    [self.view addSubview:self.quiltView];
    [self.quiltView reloadData];
    
    self.view.backgroundColor = [UIColor colorWithWhite:242.0/255.0 alpha:1.0f];
    [CommonUtils addLeftButton:self isFirstPage:NO];

    _add = [[MTAutoHideButton alloc]initWithScrollView:self.quiltView];
    [_add addTarget:self action:@selector(toUploadPhoto:) forControlEvents:UIControlEventTouchUpInside];
    //初始化下拉刷新功能
    _header = [[MJRefreshHeaderView alloc]init];
    _header.delegate = self;
    _header.scrollView = (UIScrollView*)self.quiltView;
    
}

- (void)initData
{
    _nibsRegistered = NO;
    _shouldReloadPhoto = NO;
    _shouldLoadPhoto = NO;
    _haveLoadedPhoto = NO;
    _isFirstPullDB = YES;
    _uploadingTaskCount = 0;
    _showPhoNum = 0;
    _h1 = 0;
    _isFirstIn = YES;
    sync_queue = dispatch_queue_create("imgWallRefresh_syncueue", NULL);
    self.sequence = @-1;
    self.photo_list = [[NSMutableArray alloc]init];
    self.photo_list_all= [[NSMutableArray alloc]init];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self pullPhotoInfosFromDB];
        [self pullUploadTasksfromDB];
    });
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(photoUploadFinished:) name:@"photoUploadFinished" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deletePhotoItem:) name:@"deletePhotoItem" object:nil];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [MobClick beginLogPageView:@"图片墙"];
    
    if (_eventInfo && [[_eventInfo valueForKey:@"isIn"]boolValue]) {
        [_add appear];
    }
    
    [self UploadStatusTimerStart];
    
    if (_shouldReloadPhoto && [[Reachability reachabilityForInternetConnection] currentReachabilityStatus]!= 0) {
        _shouldReloadPhoto = NO;
        [_header beginRefreshing];
    }
    _isFirstIn = NO;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_add disappear];
    [self UploadStatusTimerEnd];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [MobClick endLogPageView:@"图片墙"];
}

//返回上一层
-(void)MTpopViewController{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)toUploadPhoto:(id)sender {
    [self performSegueWithIdentifier:@"toUploadPhoto" sender:self];
}

- (void)toBestPhotos:(id)sender{
    [self performSegueWithIdentifier:@"toPhotoRanking" sender:self];
}

- (IBAction)addPhoto:(id)sender {
    [self performSegueWithIdentifier:@"toUploadPhoto" sender:self];
}

-(void)refreshPhotoInfoFromDB:(NSMutableArray*)photoInfos
{
    [self deleteAllPhotoInfoFromDB:_eventId];
    [PictureWall2 updatePhotoInfoToDB:photoInfos eventId:_eventId];
}

-(void)deleteAllPhotoInfoFromDB:(NSNumber*) eventId
{
    if (!eventId) {
        return;
    }
    NSDictionary *wheres = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%@", eventId],@"event_id", nil];
    [[MTDatabaseHelper sharedInstance] deleteTurpleFromTable:@"eventPhotos" withWhere:wheres];
}

+ (void)updatePhotoInfoToDB:(NSArray*)photoInfos eventId:(NSNumber*)eventId
{
    for (int i = 0; i < photoInfos.count; i++) {
        NSDictionary* photoInfo = [photoInfos objectAtIndex:i];
        NSString *photoData = [NSString jsonStringWithDictionary:photoInfo];
        photoData = [photoData stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        NSArray *columns = [[NSArray alloc]initWithObjects:@"'photo_id'",@"'event_id'",@"'photoInfo'", nil];
        NSArray *values = [[NSArray alloc]initWithObjects:[NSString stringWithFormat:@"%@",[photoInfo valueForKey:@"photo_id"]],[NSString stringWithFormat:@"%@",eventId],[NSString stringWithFormat:@"'%@'",photoData], nil];
        [[MTDatabaseHelper sharedInstance] insertToTable:@"eventPhotos" withColumns:columns andValues:values];
        
    }
    
}

- (void)pullPhotoInfosFromDB
{
    NSArray *seletes = [[NSArray alloc]initWithObjects:@"photoInfo", nil];
    NSDictionary *wheres = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%@ order by photo_id desc",_eventId],@"event_id", nil];
    
    [[MTDatabaseHelper sharedInstance] queryTable:@"eventPhotos" withSelect:seletes andWhere:wheres completion:^(NSMutableArray *resultsArray) {
        if (_isFirstPullDB) {
            _isFirstPullDB = NO;
            if (resultsArray.count == 0) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0* NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [_header beginRefreshing];
                    if ([NotificationController visitPhotoWall:_eventId needClear:NO] && [[Reachability reachabilityForInternetConnection] currentReachabilityStatus]!= 0) {
                        [_header beginRefreshing];
                    }
                });
                return ;
            }
        }
        NSMutableArray* photo_list_all_Tmp = [[NSMutableArray alloc]init];
        NSMutableArray* photo_list_Tmp = [[NSMutableArray alloc]init];
        for (int i = 0; i < resultsArray.count; i++) {
            NSDictionary* temp = [resultsArray objectAtIndex:i];
            NSString *tmpa = [temp valueForKey:@"photoInfo"];
            tmpa = [tmpa stringByReplacingOccurrencesOfString:@"''" withString:@"'"];
            NSData *tmpb = [tmpa dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *photoInfo =  [NSJSONSerialization JSONObjectWithData:tmpb options:NSJSONReadingMutableContainers error:nil];
            if ([photoInfo valueForKey:@"width"] && [photoInfo valueForKey:@"height"]) {
                if ([[photoInfo valueForKey:@"width"] floatValue] == 0 || [[photoInfo valueForKey:@"height"] floatValue] == 0) {
                    continue;
                }
                [photo_list_all_Tmp addObject:photoInfo];
                [photo_list_Tmp addObject:photoInfo];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            
            _photo_list = photo_list_Tmp;
            _photo_list_all = photo_list_all_Tmp;
            _haveLoadedPhoto = YES;
            [self resetPhoNum];
            [self calculateLRH];
            _uploadingTaskCount = 0;
            [self.quiltView reloadData];
            self.sequence = @-1;
            if(photo_list_Tmp.count) {
                NSDictionary *photoInfo = [_photo_list lastObject];
                self.sequence = photoInfo[@"photo_id"];
            }
            
            if ([NotificationController visitPhotoWall:_eventId needClear:NO] && [[Reachability reachabilityForInternetConnection] currentReachabilityStatus]!= 0) {
                [_header beginRefreshing];
            }
            
        });
    }];
    
}

- (void)pullUploadTasksfromDB
{

}

-(void)resetPhoNum
{
    NSInteger count = _photo_list.count;
    if (count > photoNumPP) {
        _showPhoNum = photoNumPP;
        _shouldLoadPhoto = YES;
    }else{
        _showPhoNum = count;
        _shouldLoadPhoto = NO;
    }
}

-(BOOL)checkPhoNum
{
    NSInteger count = _photo_list.count;
    if (_showPhoNum == count && [_sequence integerValue] == -1) {
        return NO;
    }else{
        return YES;
    }
}

-(void)addPhoNum
{
    if (!_shouldLoadPhoto) {
        return;
    }
    NSInteger count = _photo_list.count;
    if (_showPhoNum + photoNumPP > count) {
        _showPhoNum = count;
        _shouldLoadPhoto = NO;
    }else{
        _showPhoNum += photoNumPP;
        _shouldLoadPhoto = YES;
    }
}

-(void)UploadStatusTimerStart
{
    if (!_uploadStatusTimer) {
        _uploadStatusTimer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(checkUploadStatus) userInfo:nil repeats:YES];
    }
    [_uploadStatusTimer fire];
}

-(void)UploadStatusTimerEnd
{
    if (_uploadStatusTimer) {
        [_uploadStatusTimer invalidate];
        _uploadStatusTimer = nil;
    }
}

-(void)checkUploadStatus
{
    NSArray *seletes = [[NSArray alloc]initWithObjects:@"event_id",@"imgName", nil];
    NSDictionary *wheres = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%@",_eventId],@"event_id", nil];
    [[MTDatabaseHelper sharedInstance] queryTable:@"uploadIMGtasks" withSelect:seletes andWhere:wheres completion:^(NSMutableArray *resultsArray) {
        NSInteger uploadTaskCount = 0;
        uploadTaskCount = resultsArray.count;
        NSInteger uploadingTask = 0;
        uploadingTask = [UploaderManager sharedManager].uploadQueue.operations.count;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (uploadTaskCount == 0 || uploadingTask == 0) [self UploadStatusTimerEnd];
            [self setupUploadBtn:uploadTaskCount uploadingTask:uploadingTask];
        });
        
    }];
    
}

-(void)setupUploadBtn:(NSInteger)uploadTaskCount uploadingTask:(NSInteger)uploadingTask
{
    if (uploadTaskCount > 0) {
        
        if(!_uploadManageBtn){
            _uploadManageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            _uploadManageBtn.frame = CGRectMake(0, 0, 320, 0);
            [_uploadManageBtn setBackgroundColor:[UIColor whiteColor]];
            [_uploadManageBtn setTitle:@"" forState:UIControlStateNormal];
            [_uploadManageBtn setTitleColor:[CommonUtils colorWithValue:0x939393] forState:UIControlStateNormal];
            _uploadManageBtn.titleLabel.font = [UIFont systemFontOfSize:11];
            _uploadManageBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            _uploadManageBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
            [_uploadManageBtn addTarget:self action:@selector(toUploadManage) forControlEvents:UIControlEventTouchUpInside];
            [_uploadManageBtn setAlpha:0];
            _uploadManageBtn.clipsToBounds = YES;
            [self.view addSubview:_uploadManageBtn];
            
            UIActivityIndicatorView* activity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(260, 2.5f, 25, 25)];//指定进度轮的大小
            activity.transform = CGAffineTransformMakeScale(1, 1);
            [activity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];//设置进度轮显示类型
            [activity startAnimating];
            [_uploadManageBtn addSubview:activity];
            
            UIImageView* turn_icon = [[UIImageView alloc]initWithFrame:CGRectMake(292.5, 5, 15, 20)];
            turn_icon.image = [UIImage imageNamed:@"箭头icon"];
            [turn_icon setTransform:CGAffineTransformMakeRotation(-1*M_PI_2)];
            [_uploadManageBtn addSubview:turn_icon];
        }
        if (uploadingTask == 0) {
            [_uploadManageBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            [UIView animateWithDuration:1 animations:^{
                [_uploadManageBtn setAlpha:1.0f];
                _uploadManageBtn.frame = CGRectMake(0, 0, 320, 30);
                [_uploadManageBtn setTitle:[NSString stringWithFormat:@"图片上传完成，有%ld张图片上传失败",(long)uploadTaskCount] forState:UIControlStateNormal];
                CGRect frame = self.quiltView.frame;
                if (CGRectGetMinY(frame) != 30) {
                    frame.size.height -=30;
                    frame.origin.y = 30;
                    [self.quiltView setFrame:frame];
                }
            }];
        }else{
            [_uploadManageBtn setTitleColor:[CommonUtils colorWithValue:0x939393] forState:UIControlStateNormal];
            [UIView animateWithDuration:1 animations:^{
                [_uploadManageBtn setAlpha:1.0f];
                _uploadManageBtn.frame = CGRectMake(0, 0, 320, 30);
                [_uploadManageBtn setTitle:[NSString stringWithFormat:@"有%ld张图片正在上传中...",(long)uploadTaskCount] forState:UIControlStateNormal];
                CGRect frame = self.quiltView.frame;
                if (CGRectGetMinY(frame) != 30) {
                    frame.size.height -=30;
                    frame.origin.y = 30;
                    [self.quiltView setFrame:frame];
                }
            }];
        }
        
        
    }else{
        [_uploadManageBtn setTitleColor:[CommonUtils colorWithValue:0x939393] forState:UIControlStateNormal];
        [UIView animateWithDuration:1 animations:^{
            [_uploadManageBtn setAlpha:0.0f];
            _uploadManageBtn.frame = CGRectMake(0, 0, 320, 0);
            [_uploadManageBtn setTitle:[NSString stringWithFormat:@"图片上传完成"] forState:UIControlStateNormal];
            CGRect frame = self.quiltView.frame;
            if (CGRectGetMinY(frame) != 0) {
                frame.size.height +=30;
                frame.origin.y = 0;
                [self.quiltView setFrame:frame];
            }
        }];
    }
}

-(void)toUploadManage
{
//    MTLOG(@"toUploadManage");
    UploadManageViewController* uploadManager = [[UploadManageViewController alloc]init];
    uploadManager.eventId = self.eventId;
    [self.navigationController pushViewController:uploadManager animated:YES];
    
}

-(void)photoUploadFinished:(id)sender
{
    MTLOG(@"photoUploadFinished receive: %@",sender);
    NSMutableDictionary* newPhotoInfo = (NSMutableDictionary*)[sender userInfo];
    NSNumber *photoEventId = [newPhotoInfo valueForKey:@"eventId"];
    if(![photoEventId isKindOfClass:[NSNumber class]] || ![photoEventId isEqualToNumber:self.eventId]) {
        return;
    }
    if (newPhotoInfo) {
        dispatch_sync(sync_queue, ^{
            [_photo_list insertObject:newPhotoInfo atIndex:0];
            [_photo_list_all insertObject:newPhotoInfo atIndex:0];
            [self resetPhoNum];
            [self calculateLRH];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.quiltView reloadData];
            });
        });
    }
}

-(void)deletePhotoItem:(id)sender
{
    MTLOG(@"deletePhotoItem receive: %@",sender);
    NSMutableDictionary* deleteItem = (NSMutableDictionary*)[sender userInfo];
    NSNumber *photoEventId = [deleteItem valueForKey:@"eventId"];
    if(![photoEventId isKindOfClass:[NSNumber class]] || ![photoEventId isEqualToNumber:self.eventId]) {
        return;
    }
    if (deleteItem) {
        dispatch_sync(sync_queue, ^{
            [_photo_list removeObject:deleteItem];
            [_photo_list_all removeObject:deleteItem];
            _showPhoNum --;
            if (_showPhoNum < 0) {
                _showPhoNum = 0;
            }
            [self calculateLRH];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.quiltView reloadData];
            });
        });
        
    }
}

-(void)getPhotolist
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    NSNumber* sequence = _sequence;
    [dictionary setValue:[MTUser sharedInstance].userid forKey:@"id"];
    [dictionary setValue:sequence forKey:@"sequence"];
    [dictionary setValue:self.eventId forKey:@"event_id"];
    [dictionary setValue:[NSNumber numberWithInt:photoNumToGet] forKey:@"number"];
    MTLOG(@"%@",dictionary);
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    _isLoading = YES;
    static NSInteger operationNum = 0;
    operationNum ++;
    NSInteger operNum = operationNum;
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:GET_PHOTO_LIST finshedBlock:^(NSData *rData) {
        if (operNum != operationNum)
        {
            MTLOG(@"wuwuwuwuwu");
            if(_header.refreshing) [_header endRefreshing];
            return ;
        }
        if (rData) {
            if (!([self.navigationController.viewControllers containsObject:self])) {
                _isLoading = NO;
                return ;
            }
            NSString* temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
            MTLOG(@"received Data: %@",temp);
            NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
            NSNumber *cmd = [response1 valueForKey:@"cmd"];
            switch ([cmd intValue]) {
                case NORMAL_REPLY:
                {
                    
                    NSArray* newphoto_list_origin = [response1 valueForKey:@"photo_list"];
                    NSMutableArray* newphoto_list =[[NSMutableArray alloc]init];
                    for (int i = 0; i < newphoto_list_origin.count; i++) {
                        NSMutableDictionary* dictionary = [[NSMutableDictionary alloc]initWithDictionary:newphoto_list_origin[i]];
                        if ([dictionary valueForKey:@"width"] && [dictionary valueForKey:@"height"]) {
                            if ([[dictionary valueForKey:@"width"] floatValue] == 0 || [[dictionary valueForKey:@"height"] floatValue] == 0) {
                                continue;
                            }
                            [newphoto_list addObject:dictionary];
                        }
                    }
                    
                    
                    [self.photo_list_all addObjectsFromArray:newphoto_list];
                    
                    if([sequence integerValue] == 0){
                        [self deleteAllPhotoInfoFromDB:_eventId];
                    }
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_global_queue(0, 0), ^{
                        [PictureWall2 updatePhotoInfoToDB:newphoto_list eventId:_eventId];
                    });

                    [NotificationController visitPhotoWall:_eventId needClear:YES];
                    [self.photo_list removeAllObjects];
                    [self.photo_list addObjectsFromArray:_photo_list_all];
                    if([sequence integerValue] == 0){
                        dispatch_async(dispatch_get_global_queue(0, 0), ^{
                            [self pullUploadTasksfromDB];
                        });
                        [self resetPhoNum];
                    }
                    
                    [self calculateLRH];
                    if (newphoto_list_origin.count < 20) {
                        self.sequence = @(-1);
                    }else {
                        self.sequence = [response1 valueForKey:@"sequence"];
                    }
                    _haveLoadedPhoto = YES;
                    [self.quiltView reloadData];
                    if(_header.refreshing) [_header endRefreshing];
                    
                }
                    break;
                default:
                    [CommonUtils showSimpleAlertViewWithTitle:@"信息" WithMessage:@"网络异常，请重试" WithDelegate:nil WithCancelTitle:@"确定"];
                    if(_header.refreshing) [_header endRefreshing];
                    
            }
        }else{
            [CommonUtils showSimpleAlertViewWithTitle:@"信息" WithMessage:@"网络异常，请重试" WithDelegate:nil WithCancelTitle:@"确定"];
            if(_header.refreshing) [_header endRefreshing];
        }
        _isLoading = NO;
    }];
}

-(void)calculateLRH
{
    float lH = 0, rH = 0;
    NSArray* tmp = [_photo_list subarrayWithRange:NSMakeRange(0, _showPhoNum)];
    for (int i = 0; i < tmp.count; i++) {
        NSDictionary* dict = [tmp objectAtIndex:i];
        float width = [[dict valueForKey:@"width"] floatValue];
        float height = [[dict valueForKey:@"height"] floatValue];
        float RealHeight = height * 145.0f / width + 43;
        if (lH <= rH) {
            lH += RealHeight;
        }else{
            rH += RealHeight;
        }
    }
    MTLOG(@"lH: %f , rH: %f",lH,rH);
    _h1 = lH - rH;
}


#pragma mark - TMQuiltViewDelegate
- (NSInteger)quiltViewNumberOfCells:(TMQuiltView *)TMQuiltView {
    return _showPhoNum+2;
}


- (TMQuiltViewCell *)quiltView:(TMQuiltView *)quiltView cellAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row >= _showPhoNum) {
        TMQuiltViewCell* cell = [[TMQuiltViewCell alloc]init];
        if(indexPath.row == _showPhoNum + 1){
            TMQuiltViewCell* preCell = [quiltView cellAtIndexPath:[NSIndexPath indexPathForRow:_showPhoNum inSection:0]];
            float preHeight = CGRectGetHeight(preCell.frame);
            float preX = CGRectGetMinX(preCell.frame);
            float width = 300;
            float height = (preHeight != 50)? 50 : fabsf(_h1) + 50;
            UILabel* label = [[UILabel alloc]initWithFrame:CGRectMake((preX == 10)? (width/6 - 155):width/6, height-40, width*4/6, 40)];
            if (!_haveLoadedPhoto) {
                label.text = @"正在加载 ...";
            }else if([self checkPhoNum]){
                NSInteger count = _photo_list.count;
                if (_showPhoNum + photoNumPP > count && [_sequence integerValue]!=-1){
                    label.text = @"正在加载 ...";
                    if (![_header isRefreshing] && !_isLoading) {
                        [self getPhotolist];
                    }
                }else if (_shouldLoadPhoto) {
                    label.text = @"正在加载 ...";
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self addPhoNum];
                        [self calculateLRH];
                        [quiltView reloadData];
                    });
                }else{
                    label.text = _showPhoNum > 0? @"没有更多了哦，去上传吧~":@"还没有图片哦，快去上传吧";
                }
            }else{
                label.text = _showPhoNum > 0? @"没有更多了哦，去上传吧~":@"还没有图片哦，快去上传吧";
            }
            
            label.font = [UIFont systemFontOfSize:15];
            label.textColor = [UIColor colorWithWhite:147.0/255.0 alpha:1.0f];
            label.textAlignment = NSTextAlignmentCenter;
            [cell addSubview:label];
        }
        return cell;
    }
    static NSString *CellIdentifier = @"photocell";

    
    PhotoTableViewCell *cell = (PhotoTableViewCell *)[quiltView dequeueReusableCellWithReuseIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[PhotoTableViewCell alloc] initWithReuseIdentifier:CellIdentifier];
    }
    if(indexPath.row >= _photo_list.count){
        cell.hidden = YES;
        return cell;
    }else{
        cell.hidden = NO;
    }
    NSMutableDictionary *data = _photo_list[indexPath.row];
    cell.PhotoWall = self;
    [cell applyData:data];
    return cell;
}


- (NSInteger)quiltViewNumberOfColumns:(TMQuiltView *)quiltView {
    return 2;
    
}

- (CGFloat)quiltView:(TMQuiltView *)quiltView heightForCellAtIndexPath:(NSIndexPath *)indexPath {
    
    float defaultHeight = _showPhoNum == 0? 200:50;
    if (indexPath.row == _showPhoNum) {
        return fabsf(_h1) + defaultHeight;
    }else if(indexPath.row == _showPhoNum + 1) return defaultHeight;
    
    
    if(indexPath.row >= _photo_list.count) return 0;
    NSDictionary *a = _photo_list[indexPath.row];
    
    float width = [[a valueForKey:@"width"] floatValue];
    float height = [[a valueForKey:@"height"] floatValue];
    float RealHeight = height * 145.0f / width;
    
    return RealHeight + 33;
}

- (void)quiltView:(TMQuiltView *)quiltView didSelectCellAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row >= _showPhoNum) {
        return;
    }
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone"
                                                             bundle: nil];
    PhotoDisplayViewController* photoDisplay = [mainStoryboard instantiateViewControllerWithIdentifier: @"PhotoDisplayViewController"];

    photoDisplay.photo_list = [NSMutableArray arrayWithArray:[self.photo_list subarrayWithRange:NSMakeRange(0, _showPhoNum)]];
    photoDisplay.photoIndex = indexPath.row;
    photoDisplay.eventId = self.eventId;
    photoDisplay.eventLauncherId = self.eventLauncherId;
    photoDisplay.eventName = self.eventName;
    photoDisplay.controller = self;
    photoDisplay.canManage = [[_eventInfo valueForKey:@"isIn"]boolValue];
    
    [self.navigationController pushViewController:photoDisplay animated:YES];
}

#pragma mark 用segue跳转时传递参数eventid
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //这里我很谨慎的对sender和目标视图控制器作了判断
    if ([sender isKindOfClass:[PictureWall2 class]]) {
        if ([segue.destinationViewController isKindOfClass:[PhotoUploadViewController class]]) {
            PhotoUploadViewController *nextViewController = segue.destinationViewController;
            nextViewController.eventId = self.eventId;
            nextViewController.photoWallController = self;
        }
        if ([segue.destinationViewController isKindOfClass:[photoRankingViewController class]]) {
            photoRankingViewController *nextViewController = segue.destinationViewController;
            nextViewController.pictureWallController = self;
            nextViewController.eventName = self.eventName;
            nextViewController.eventId = self.eventId;
            nextViewController.canManage = [[_eventInfo valueForKey:@"isIn"]boolValue];
        }
    }
}

#pragma mark 代理方法-进入刷新状态就会调用
- (void)refreshViewBeginRefreshing:(MJRefreshBaseView *)refreshView
{
   
    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == 0) {
        MTLOG(@"没有网络");
        [refreshView endRefreshing];
        return;
    }
    self.sequence = [[NSNumber alloc]initWithInt:0];
    [_photo_list_all removeAllObjects];
    [self getPhotolist];

}

@end
