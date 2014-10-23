//
//  PictureWallViewController.m
//  Metic
//
//  Created by ligang6 on 14-6-29.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "PictureWallViewController.h"
#import "PhotoDisplayViewController.h"
#import "PhotoUploadViewController.h"
#import "photoRankingViewController.h"
#import "../Cell/PhotoTableViewCell.h"
#import "../Utils/CommonUtils.h"
#import "../Utils/HttpSender.h"
#import "AppConstants.h"
#import "UIImageView+WebCache.h"
#import "MobClick.h"
#import "NSString+JSON.h"
#import "../Utils/Reachability.h"

#define PhotoNum 20


@interface PictureWallViewController ()
@property(nonatomic,strong)MySqlite *sql;
@property BOOL isHeaderOpen;
@property BOOL isFooterOpen;
@property long seletedPhotoIndex;
@property (nonatomic,strong) UIAlertView *Alert;
@property (nonatomic,strong) NSMutableDictionary *cellHeight;
@property (nonatomic,strong)SDWebImageManager *manager;
@property int currentPhotoNum;
@property (nonatomic,strong) NSString* urlFormat;
@property (nonatomic,strong) UIButton* add;
@property (nonatomic,strong) UILabel* addLabel;

@property BOOL isLoading;
@property BOOL shouldStop;
@property NSString* outSVState;


@end

@implementation PictureWallViewController

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
    
    [[SDImageCache sharedImageCache]setMaxCacheSize:1024*1024*100];
    
    [_promt setHidden:YES];
    [CommonUtils addLeftButton:self isFirstPage:NO];
    self.photos = [[NSMutableDictionary alloc]init];
    
    _isLoading = NO;
    _shouldStop = NO;
    _leftH = _rightH = 0;
    _lefPhotos = [[NSMutableArray alloc]init];
    _rigPhotos = [[NSMutableArray alloc]init];
    
    [self.tableView1 setDelegate:self];
    [self.tableView1 setDataSource:self];
    [self.tableView2 setDelegate:self];
    [self.tableView2 setDataSource:self];
//    [_scrollView setDelegate:self];
    self.seletedPhotoIndex = 0;
    self.isFooterOpen = NO;
    self.isHeaderOpen = NO;
    self.shouldReloadPhoto = YES;
    self.sequence = [[NSNumber alloc]initWithInt:0];
    self.photo_list = [[NSMutableArray alloc]init];
    self.photo_list_all= [[NSMutableArray alloc]init];
    self.photoPath_list = [[NSMutableArray alloc]init];
    self.cellHeight = [[NSMutableDictionary alloc]init];
    self.sql = [[MySqlite alloc]init];
    
    [self initUI];
    
//    _urlFormat = @"http://bcs.duapp.com/metis201415/images/%@?sign=%@";//测试服
//    _urlFormat = @"http://bcs.duapp.com/whatsact/images/%@?sign=%@";//正式服
    _urlFormat = @[@"http://bcs.duapp.com/metis201415/images/%@?sign=%@",@"http://bcs.duapp.com/whatsact/images/%@?sign=%@"][Server];
    _manager = [SDWebImageManager sharedManager];
    [self initIndicator];
    

    //初始化下拉刷新功能
    _footer = [[MJRefreshFooterView alloc]init];
    _footer.delegate = self;
    _footer.isPhotoWall = YES;
    _footer.isRight = NO;
    _footer.SscrollView = self.tableView2;
    _footer.scrollView = self.tableView1;
    
    //初始化下拉刷新功能
    _header = [[MJRefreshHeaderView alloc]init];
    _header.delegate = self;
    _header.isPhotoWall = YES;
    _header.isRight = NO;
    _header.SscrollView = self.tableView2;
    _header.scrollView = self.tableView1;
    
    //等待圈圈
    
    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == 0) {
        NSLog(@"没有网络");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [self pullPhotoInfosFromDB];
        });
        
    }
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (_shouldReloadPhoto) {
        if (![[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == 0)
            [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(indicatorAppear) userInfo:nil repeats:NO];
        self.sequence = [[NSNumber alloc]initWithInt:0];
        [self getPhotolist];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [MobClick beginLogPageView:@"图片墙"];
    [self adjustUI];
}


-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [MobClick endLogPageView:@"图片墙"];
    if (_isLoading) {
        _isLoading = NO;
        _shouldStop = YES;
        [self indicatorDisappear];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    if (_isLoading) {
        _isLoading = NO;
        _shouldStop = YES;
    }
    
    // Dispose of any resources that can be recreated.
}
//-(void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    [cell removeFromSuperview];
//}

//返回上一层
-(void)MTpopViewController{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)initUI
{
    _add = [UIButton buttonWithType:UIButtonTypeCustom];
    [_add setBackgroundImage:[CommonUtils createImageWithColor:[UIColor colorWithRed:85/255.0 green:203/255.0 blue:171/255.0 alpha:1.0]] forState:UIControlStateNormal];
    [_add setBackgroundImage:[CommonUtils createImageWithColor:[UIColor colorWithRed:85/255.0 green:170/255.0 blue:166/255.0 alpha:1.0]] forState:UIControlStateHighlighted];
    _add.layer.masksToBounds = YES;
    _add.layer.cornerRadius = CGRectGetWidth(self.view.frame)*0.1;
    [_add addTarget:self action:@selector(toUploadPhoto:) forControlEvents:UIControlEventTouchUpInside];
    _addLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    [_addLabel setBackgroundColor:[UIColor clearColor]];
    [_addLabel setFont:[UIFont systemFontOfSize:50]];
    [_addLabel setTextAlignment:NSTextAlignmentCenter];
    [_addLabel setText:@"+"];
    [_addLabel setTextColor:[UIColor whiteColor]];
    [_add addSubview:_addLabel];
    [_add setFrame:CGRectZero];
    [self.view addSubview:_add];
}

-(void)adjustUI
{
    CGRect frame = self.view.frame;
    NSLog(@"%f  %f",CGRectGetWidth(frame),CGRectGetHeight(frame));
    [_add setFrame:CGRectMake(CGRectGetWidth(frame)*0.7, CGRectGetHeight(frame) - CGRectGetWidth(frame)*0.3 , CGRectGetWidth(frame)*0.2, CGRectGetWidth(frame)*0.2)];
    [_addLabel setFrame:CGRectMake(0, 0, CGRectGetWidth(frame)*0.2, CGRectGetWidth(frame)*0.17)];
}


-(void)getPhotolist
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:[MTUser sharedInstance].userid forKey:@"id"];
    [dictionary setValue:self.sequence forKey:@"sequence"];
    [dictionary setValue:self.eventId forKey:@"event_id"];
    NSLog(@"%@",dictionary);
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:GET_PHOTO_LIST];
    
    
}

-(void)getPhotoPathlist
{
    [self.photoPath_list removeAllObjects];
    for(NSDictionary* dict in self.photo_list)
    {
        //NSString *url = [NSString stringWithFormat:_urlFormat,[dict valueForKey:@"photo_name"] ,[dict valueForKey:@"url"]];
        NSString *url = [CommonUtils getUrl:[NSString stringWithFormat:@"/images/%@",[dict valueForKey:@"photo_name"]]];
        [self.photoPath_list addObject:url];
    }
    
//    [self.photoPath_list removeAllObjects];
//    for(int i = 0; i < self.photo_list.count ; i++ )
//    {
//        NSDictionary* dict = self.photo_list[i];
//        [self.photoPath_list addObject:@""];
//        __block NSString* url = [[MTUser sharedInstance].photoURL valueForKey:[NSString stringWithFormat:@"%@",[dict valueForKey:@"photo_id"]]];
//        if (!url) {
//            NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
//            [dictionary setValue:@"GET" forKey:@"method"];
//            [dictionary setValue:[NSString stringWithFormat:@"/images/%@",[dict valueForKey:@"photo_name"]] forKey:@"object"];
//            
//            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
//            NSLog(@"%@",[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding]);
//            HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
//            [httpSender sendMessage:jsonData withOperationCode: GET_FILE_URL finshedBlock:^(NSData *rData) {
//                NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
//                NSNumber *cmd = [response1 valueForKey:@"cmd"];
//                switch ([cmd intValue]) {
//                    case NORMAL_REPLY:
//                    {
//                        url = (NSString*)[response1 valueForKey:@"url"];
//                        NSLog(@"%@",url);
//                        [[MTUser sharedInstance].photoURL setValue:url forKey:[NSString stringWithFormat:@"%@",[dict valueForKey:@"photo_id"]]];
//                        self.photoPath_list[i] = url;
//                        break;
//                    }
//                }
//            }];
//        }else self.photoPath_list[i] = url;
//
//    }
}


-(void)reloadPhoto
{
    if (self.isHeaderOpen) {
        self.isHeaderOpen = NO;
        [_header endRefreshing];
    }
    if (self.isFooterOpen) {
        self.isFooterOpen = NO;
        [_footer endRefreshing];
    }
    [self.tableView1 reloadData];
    [self.tableView2 reloadData];

    
}

- (void)toUploadPhoto:(id)sender {
    [self performSegueWithIdentifier:@"toUploadPhoto" sender:self];
}
- (IBAction)toBestPhotos:(id)sender{
    [self performSegueWithIdentifier:@"toPhotoRanking" sender:self];
}

-(void)showAlert
{
    _Alert = [[UIAlertView alloc] initWithTitle:@"" message:@"没有更多了" delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
    [_Alert show];
    self.isFooterOpen = NO;
    [_footer endRefreshing];
}
-(void)performDismiss
{
    [_Alert dismissWithClickedButtonIndex:0 animated:NO];
}


-(void)initIndicator
{
    _indicatorView = [[UIView alloc]initWithFrame:CGRectMake(60, -50, 200, 50)];
    [self.view addSubview:_indicatorView];
    [_indicatorView.layer setCornerRadius:10];
    [_indicatorView setBackgroundColor:[UIColor whiteColor]];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(40, 10, 100, 30)];
    label.text = @"正在加载图片";
    [label setFont:[UIFont systemFontOfSize:16]];
    [_indicatorView addSubview:label];
    UIActivityIndicatorView* indicator = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(140, 15, 20, 20)];
    indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [indicator startAnimating];
    [_indicatorView addSubview:indicator];
}


-(void)indicatorAppear
{
    [UIView beginAnimations:@"indicatorAppear" context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelegate:self];
    //[UIView setAnimationTransition:UIViewAnimationTransitionNone forView:_indicatorView cache:YES];
    _indicatorView.frame = CGRectMake(60, 10, 200, 50);
    [UIView commitAnimations];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(20 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self indicatorDisappear];
    });
}

-(void)indicatorDisappear
{
    [UIView beginAnimations:@"indicatorDisappear" context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDelegate:self];
    _indicatorView.frame = CGRectMake(60, -50, 200, 50);
    [UIView commitAnimations];
    if (!_photo_list_all || _photo_list_all.count == 0) {
        [_promt setHidden:NO];
    }else {
        [_promt setHidden:YES];
    }
}

- (void)updatePhotoInfoToDB:(NSMutableArray*)photoInfos
{
    NSString * path = [NSString stringWithFormat:@"%@/db",[MTUser sharedInstance].userid];
    [self.sql openMyDB:path];
    for (NSDictionary *photoInfo in photoInfos) {
        NSString *photoData = [NSString jsonStringWithDictionary:photoInfo];
        photoData = [photoData stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        NSArray *columns = [[NSArray alloc]initWithObjects:@"'photo_id'",@"'event_id'",@"'photoInfo'", nil];
        NSArray *values = [[NSArray alloc]initWithObjects:[NSString stringWithFormat:@"%@",[photoInfo valueForKey:@"photo_id"]],[NSString stringWithFormat:@"%@",_eventId],[NSString stringWithFormat:@"'%@'",photoData], nil];
        
        [self.sql insertToTable:@"eventPhotos" withColumns:columns andValues:values];
    }
    [self.sql closeMyDB];
}

- (void)pullPhotoInfosFromDB
{
    NSString * path = [NSString stringWithFormat:@"%@/db",[MTUser sharedInstance].userid];
    [self.sql openMyDB:path];
    
    //self.events = [[NSMutableArray alloc]init];
    NSArray *seletes = [[NSArray alloc]initWithObjects:@"photoInfo", nil];
    NSDictionary *wheres = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%@ order by photo_id desc",_eventId],@"event_id", nil];
    NSMutableArray *result = [self.sql queryTable:@"eventPhotos" withSelect:seletes andWhere:wheres];
    for (NSDictionary *temp in result) {
        NSString *tmpa = [temp valueForKey:@"photoInfo"];
        tmpa = [tmpa stringByReplacingOccurrencesOfString:@"''" withString:@"'"];
        NSData *tmpb = [tmpa dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *photoInfo =  [NSJSONSerialization JSONObjectWithData:tmpb options:NSJSONReadingMutableContainers error:nil];
        [self.photo_list_all addObject:photoInfo];
        //[self.photo_list addObject:photoInfo];
    }
    [self.sql closeMyDB];
    int count = MIN(PhotoNum, _photo_list_all.count);
    [self performSelectorInBackground:@selector(classifyPhotos:) withObject:[_photo_list_all subarrayWithRange:NSMakeRange(0, count)]];
}

-(void)classifyPhotos:(NSArray*)photos
{
    [self classifyPhotos:photos index:0];
}

-(void)classifyPhotos:(NSArray*)photos index:(int)index
{
    if (_shouldStop) {
        _shouldStop = NO;
        return;
    }
    _isLoading = YES;
    if (index < photos.count) {
        NSDictionary* photo = photos[index];
        NSString *url = [CommonUtils getUrl:[NSString stringWithFormat:@"/images/%@",[photo valueForKey:@"photo_name"]]];
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        [manager downloadImageWithURL:[NSURL URLWithString:url] options:SDWebImageRetryFailed progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            if (cacheType == SDImageCacheTypeNone) {
                NSLog(@"from air %d",index);
            }else{
                NSLog(@"from local %d",index);
            }
            if(image){
                float H = image.size.height * 145.0 / image.size.width;
                [_cellHeight setValue:[NSNumber numberWithFloat:H] forKey:url];
                [_photo_list addObject:photo];
                if (_leftH <= _rightH) {
                    [_lefPhotos addObject:photo];
                    _leftH += (H + 43);
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [_tableView1 reloadData];
                    });
                }else{
                    [_rigPhotos addObject:photo];
                    _rightH += (H + 43);
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [_tableView2 reloadData];
                    });
                }
            }else{
                [_photo_list removeObject:photo];
                [_photo_list_all removeObject:photo];
            }
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_global_queue(0, 0), ^{
                [self classifyPhotos:photos index:index+1];
            });

        }];
 
        return;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self indicatorDisappear];
    });
    _isLoading = NO;
}


#pragma mark 代理方法-UIScrollView
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == _tableView1) {
        [_tableView2 setContentOffset:_tableView1.contentOffset];
    }else if(scrollView == _tableView2)
        [_tableView1 setContentOffset:_tableView2.contentOffset];
    

    
    if (_tableView1.contentSize.height > _tableView2.contentSize.height) {
        CGSize size = _tableView2.contentSize;
        size.height = _tableView1.contentSize.height;
        [_tableView2 setContentSize:size];
    }else if(_tableView1.contentSize.height < _tableView2.contentSize.height){
        CGSize size = _tableView1.contentSize;
        size.height = _tableView2.contentSize.height;
        [_tableView1 setContentSize:size];
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSLog(@"ready auto loading");
    if (!self.isLoading && !_isFooterOpen && (scrollView.contentSize.height - scrollView.contentOffset.y) < (100.0f + scrollView.frame.size.height) && !([_sequence intValue] == -1 && _photo_list_all.count == _photo_list.count) ) {
        NSLog(@"ready auto loading");
        [_footer beginRefreshing];
    }
}

//-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
//{
//    if (scrollView == _tableView1) {
//        if (!self.isLoading && !_isFooterOpen && (scrollView.contentSize.height - scrollView.contentOffset.y) < 100.0f && !([_sequence intValue] == -1 && _photo_list_all.count == _photo_list.count) ) {
//            [_footer beginRefreshing];
//        }
//    }
//}



-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (scrollView == _tableView1) {
        _footer.isRight = NO;
        _footer.scrollView = _tableView1;
        _header.isRight = NO;
        _header.scrollView = _tableView1;
        
    }else if (scrollView == _tableView2){
        _footer.isRight = YES;
        _footer.scrollView = _tableView2;
        _header.isRight = YES;
        _header.scrollView = _tableView2;
        
    }
}

#pragma mark 代理方法-UITableView
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary* dictionary;
    if (tableView == _tableView1) {
        dictionary = _lefPhotos[indexPath.row];
    }else dictionary = _rigPhotos[indexPath.row];
    
    self.seletedPhotoIndex = [_photo_list indexOfObject:dictionary];
    [self performSegueWithIdentifier:@"photosShow" sender:self];
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    long max = 0;
    if (tableView == self.tableView1) {
        max = _lefPhotos.count;
    }else max = _rigPhotos.count;
    return max;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"photocell";
    BOOL nibsRegistered = NO;
    if (!nibsRegistered) {
        UINib *nib = [UINib nibWithNibName:NSStringFromClass([PhotoTableViewCell class]) bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:CellIdentifier];
        nibsRegistered = YES;
    }
    PhotoTableViewCell *cell = (PhotoTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[PhotoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
    }
    [cell.imgView setFrame:CGRectZero];
    [cell.infoView setFrame:CGRectZero];
    
    NSDictionary *a;
    if (tableView == _tableView1) {
        a = _lefPhotos[indexPath.row];
    }else a = _rigPhotos[indexPath.row];
    cell.author.text = [a valueForKey:@"author"];
    cell.publish_date.text = [[a valueForKey:@"time"] substringToIndex:10];
    
    cell.avatar.layer.masksToBounds = YES;
    [cell.avatar.layer setCornerRadius:5];
    cell.photoInfo = a;
    cell.PhotoWall = self;
    cell.photo_id = [a valueForKey:@"photo_id"];
    
    PhotoGetter* avatarGetter = [[PhotoGetter alloc]initWithData:cell.avatar authorId:[a valueForKey:@"author_id"]];
    [avatarGetter getAvatar];
    UIImageView* photo = cell.imgView;
    [cell.infoView removeFromSuperview];
        
    //NSString *url = [NSString stringWithFormat:_urlFormat,[a valueForKey:@"photo_name"] ,[a valueForKey:@"url"]];
    NSString *url = [CommonUtils getUrl:[NSString stringWithFormat:@"/images/%@",[a valueForKey:@"photo_name"]]];
    //NSLog(@"%@",url);
    [photo sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"活动图片的默认图片"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
    }];
    //服务器获取url准备
//    __block NSString* url = [[MTUser sharedInstance].photoURL valueForKey:[NSString stringWithFormat:@"%@",[a valueForKey:@"photo_id"]]];
//    if (!url) {
//        [photo setImage:[UIImage imageNamed:@"活动图片的默认图片"]];
//        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
//        [dictionary setValue:@"GET" forKey:@"method"];
//        [dictionary setValue:[NSString stringWithFormat:@"/images/%@",[a valueForKey:@"photo_name"]] forKey:@"object"];
//        
//        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
//        NSLog(@"%@",[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding]);
//        HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
//        [httpSender sendMessage:jsonData withOperationCode: GET_FILE_URL finshedBlock:^(NSData *rData) {
//            NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
//            NSNumber *cmd = [response1 valueForKey:@"cmd"];
//            switch ([cmd intValue]) {
//                case NORMAL_REPLY:
//                {
//                    url = (NSString*)[response1 valueForKey:@"url"];
//                    NSLog(@"%@",url);
//                    [[MTUser sharedInstance].photoURL setValue:url forKey:[NSString stringWithFormat:@"%@",[a valueForKey:@"photo_id"]]];
//                    [photo sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"活动图片的默认图片"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//                        if (self && image && cacheType == SDImageCacheTypeNone) {
//                            [tableView reloadData];
//                            NSLog(@"reloadData %@",imageURL);
//                        }
//                    }];
//                }
//                    break;
//            }
//        }];
//    }else{
//        [photo sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"活动图片的默认图片"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//            if (self && image && cacheType == SDImageCacheTypeNone) {
//                [tableView reloadData];
//                NSLog(@"reloadData %@",imageURL);
//            }
//        }];
//    }
    
    
    
    //[photo sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"活动图片的默认图片"]];
    NSNumber* Cellheight = [_cellHeight valueForKey:url];
    if (Cellheight) {
        float height = [Cellheight floatValue];
        if (height == 0) {
            [cell.activityIndicator startAnimating];
            [cell.activityIndicator setHidden:NO];
            [cell.imageView setHidden:YES];
        }else{
            [cell setHidden:NO];
            [cell.imageView setHidden:NO];
            [cell.activityIndicator stopAnimating];
            [cell.activityIndicator setHidden:YES];
            [photo setFrame:CGRectMake(0, 0, 145, height)];
            [cell.infoView setFrame:CGRectMake(0, height, 145, 33)];
            if (tableView == _tableView1) [cell setFrame:CGRectMake(0, 0, 155, height+43)];
            else [cell setFrame:CGRectMake(0, 0, 145, height+43)];
            [cell addSubview:cell.infoView];
        }

    }else [cell setHidden:YES];
    cell.isloading = _isLoading;
    [cell animationBegin];
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *a;
    if (tableView == _tableView1) {
        a = _lefPhotos[indexPath.row];
    }else a = _rigPhotos[indexPath.row];
    
//    NSString *url = [NSString stringWithFormat:_urlFormat,[a valueForKey:@"photo_name"] ,[a valueForKey:@"url"]];
    NSString *url = [CommonUtils getUrl:[NSString stringWithFormat:@"/images/%@",[a valueForKey:@"photo_name"]]];
    float height = 0;
    NSNumber *H = [_cellHeight valueForKey:url];
    if (H) {
        height = [H floatValue];
        return height + 43;
    }else{
        UIImage * img = [[_manager imageCache] imageFromMemoryCacheForKey:url];
        if (!img) img = [[_manager imageCache] imageFromDiskCacheForKey:url];
        
        if(img){
            height = img.size.height *145.0/img.size.width;
            [_cellHeight setValue:[NSNumber numberWithFloat:height] forKey:url];
            return height+43;
        }else{
            [_cellHeight setValue:[NSNumber numberWithFloat:0] forKey:url];
            return 178;
        }

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
            NSMutableArray* newphoto_list =[[NSMutableArray alloc]initWithArray:[response1 valueForKey:@"photo_list"]];
            for (int i = 0; i < newphoto_list.count; i++) {
                NSMutableDictionary* dictionary = [[NSMutableDictionary alloc]initWithDictionary:newphoto_list[i]];
                newphoto_list[i] = dictionary;
            }
            [self updatePhotoInfoToDB:newphoto_list];
            self.sequence = [response1 valueForKey:@"sequence"];
            if (_shouldReloadPhoto) {
                [self.photo_list_all removeAllObjects];
                [self.photo_list removeAllObjects];
                [_lefPhotos removeAllObjects];
                [_rigPhotos removeAllObjects];
                _leftH = 0;
                _rightH = 0;
                _shouldReloadPhoto = NO;
                [_tableView1 reloadData];
                [_tableView2 reloadData];
            }
            [self.photo_list_all addObjectsFromArray:newphoto_list];
            int count = self.photo_list.count;
            int num = MIN(PhotoNum, _photo_list_all.count - count);
            
            NSArray* addPhotos = [_photo_list_all subarrayWithRange:NSMakeRange(count, num)];
            
            
            //分图
            [self performSelectorInBackground:@selector(classifyPhotos:) withObject:addPhotos];
            
            
            
            
            //[NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(reloadPhoto) userInfo:nil repeats:NO];
            //[NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(indicatorDisappear) userInfo:nil repeats:NO];
            if (!_photo_list_all || _photo_list_all.count == 0) {
                [_promt setHidden:NO];
            }else [_promt setHidden:YES];
            if ([_sequence intValue] == -1 && self.isFooterOpen == YES && _photo_list_all.count == _photo_list.count) {
                [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(showAlert) userInfo:nil repeats:NO];
                [NSTimer scheduledTimerWithTimeInterval:1.2f target:self selector:@selector(performDismiss) userInfo:nil repeats:NO];
            }else [self reloadPhoto];

        }
            break;
    }
}



#pragma mark 用segue跳转时传递参数eventid
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //这里我很谨慎的对sender和目标视图控制器作了判断
    if ([sender isKindOfClass:[PictureWallViewController class]]) {
        if ([segue.destinationViewController isKindOfClass:[PhotoDisplayViewController class]]) {
            PhotoDisplayViewController *nextViewController = segue.destinationViewController;
            [self getPhotoPathlist];
            nextViewController.photoPath_list = self.photoPath_list;
            nextViewController.photo_list = self.photo_list;
            nextViewController.photoIndex = self.seletedPhotoIndex;
            nextViewController.eventId = self.eventId;
            nextViewController.eventName = self.eventName;
            nextViewController.controller = self;
        }
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
        }
    }
}

#pragma mark 代理方法-进入刷新状态就会调用
- (void)refreshViewBeginRefreshing:(MJRefreshBaseView *)refreshView
{
    if (_isLoading) {
        [refreshView endRefreshing];
        return;
    }
    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == 0) {
        NSLog(@"没有网络");
        [refreshView endRefreshing];
        return;
    }
    if (_isHeaderOpen || _isFooterOpen) {
        [refreshView endRefreshing];
        return;
    }
    
    if (refreshView == _footer) {
        self.isFooterOpen = YES;
        int photo_rest_num = self.photo_list_all.count - self.photo_list.count;
        if ([self.sequence intValue] == -1 && photo_rest_num == 0) {
            [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(showAlert) userInfo:nil repeats:NO];
            [NSTimer scheduledTimerWithTimeInterval:1.2f target:self selector:@selector(performDismiss) userInfo:nil repeats:NO];
            return;
        }
        
        int count = self.photo_list.count;
        if (photo_rest_num >= PhotoNum || [_sequence intValue] == -1) {//加载剩余的，然后再拉
            int num = MIN(PhotoNum, _photo_list_all.count - count);
            //        for (int i = count; i < count + num; i++) {
            //            [self.photo_list addObject:self.photo_list_all[i]];
            //        }
            [refreshView endRefreshing];
            self.isFooterOpen = NO;
            [self performSelectorInBackground:@selector(classifyPhotos:) withObject:[_photo_list_all subarrayWithRange:NSMakeRange(count, num)]];
            //[NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(reloadPhoto) userInfo:nil repeats:NO];
        }else{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (self.isFooterOpen) {
                    self.isFooterOpen = NO;
                    [refreshView endRefreshing];
                }
            });
            [self getPhotolist];
        }

    }else if (refreshView == _header){
        _isHeaderOpen = YES;
        _shouldReloadPhoto = YES;
        self.sequence = [[NSNumber alloc]initWithInt:0];
        [self getPhotolist];
    }
    
    
}



-(void)dealloc
{
    [_footer free];
}



@end










