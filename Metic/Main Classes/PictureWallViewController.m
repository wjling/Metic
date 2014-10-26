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

@property BOOL isAutoLoading;
@property BOOL isLoading;
@property BOOL ignoreLeft;
@property BOOL isLeft;
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

    [_promt setHidden:YES];
    [CommonUtils addLeftButton:self isFirstPage:NO];
    self.photos = [[NSMutableDictionary alloc]init];
    
    _isAutoLoading = NO;
    _isLoading = NO;
    _shouldStop = NO;
    _leftH = _rightH = 0;
    _lefPhotos = [[NSMutableArray alloc]init];
    _rigPhotos = [[NSMutableArray alloc]init];
    
    [self.tableView1 setDelegate:self];
    [self.tableView1 setDataSource:self];
    [self.tableView2 setDelegate:self];
    [self.tableView2 setDataSource:self];
    
    _tableView1.layer.borderColor = [UIColor greenColor].CGColor;
    _tableView1.layer.borderWidth = 2;
    
    _tableView2.layer.borderColor = [UIColor greenColor].CGColor;
    _tableView2.layer.borderWidth = 2;
    self.seletedPhotoIndex = 0;
    self.isFooterOpen = NO;
    self.isHeaderOpen = NO;
    self.shouldReloadPhoto = NO;
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
    _header1 = [[MJRefreshHeaderView alloc]init];
    _header1.delegate = self;
    _header1.isPhotoWall = YES;
    _header1.isRight = NO;
    _header1.scrollView = self.tableView1;
    
    //初始化下拉刷新功能
    _header2 = [[MJRefreshHeaderView alloc]init];
    _header2.delegate = self;
    _header2.isPhotoWall = YES;
    _header2.isRight = YES;
    _header2.scrollView = self.tableView2;
    _header2.hidden = YES;
    //等待圈圈
    
    _sequence = [NSNumber numberWithInt:-1];
    [self pullPhotoInfosFromDB];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [MobClick beginLogPageView:@"图片墙"];
    [self adjustUI];
    if (_shouldReloadPhoto) {
        if (![[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == 0){
            [self.header1 beginRefreshing];
        }
    }
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
    [httpSender sendMessage:jsonData withOperationCode:GET_PHOTO_LIST finshedBlock:^(NSData *rData) {
        if (rData) {
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

                    [self.photo_list_all addObjectsFromArray:newphoto_list];
                    
                    if ([_sequence intValue] != -1) {
                        [self getPhotolist];
                        return;
                    }else{
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            int Acount = self.photo_list_all.count;
                            if (Acount == 0) {
//                                [_promt removeFromSuperview];
//                                [_tableView1 addSubview:_promt];
                                [_promt setHidden:NO];
                            }else [_promt setHidden:YES];
                            [self.photo_list removeAllObjects];
                            [_lefPhotos removeAllObjects];
                            [_rigPhotos removeAllObjects];
                            _leftH = 0;
                            _rightH = 0;
                            _shouldReloadPhoto = NO;
                            [_tableView1 reloadData];
                            [_tableView2 reloadData];
                            
                            [self photoDistribution];
                        });
                        
                      
                        
                    }
                    
                }
                    break;
            }
            
        }else{
            [CommonUtils showSimpleAlertViewWithTitle:@"信息" WithMessage:@"网络异常，请重试" WithDelegate:nil WithCancelTitle:@"确定"];
        }
        
    }];
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
}


- (void)toUploadPhoto:(id)sender {
    [self performSegueWithIdentifier:@"toUploadPhoto" sender:self];
}
- (IBAction)toBestPhotos:(id)sender{
    [self performSegueWithIdentifier:@"toPhotoRanking" sender:self];
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
//        [_promt removeFromSuperview];
//        [_tableView1 addSubview:_promt];
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
    if (_photo_list_all && _photo_list_all.count > 0) {
        [self photoDistribution];
    }else [_header2 beginRefreshing];
}


-(void)photoDistribution
{
    if (self.isHeaderOpen) {
        self.isHeaderOpen = NO;
        [_header1 endRefreshing];
        [_header2 endRefreshing];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _leftH = 0;
        _rightH = 0;
        NSArray *tmp = [NSArray arrayWithArray:_photo_list_all];
        for (NSDictionary* photo in tmp) {
            int width = [[photo valueForKey:@"width"] intValue];
            int height = [[photo valueForKey:@"height"] intValue];
            if(width == 0 || height == 0){
                NSLog(@"图片 %@ 宽高不正确",[photo valueForKey:@"photo_name"]);
                [_photo_list_all removeObject:photo];
                continue;
            }
            double RealHeight = height * 150.0f / width;
            
            if (_leftH <= _rightH) {
                _leftH += (RealHeight + 43);
                [_lefPhotos addObject:photo];
            }else{
                _rightH += (RealHeight + 43);
                [_rigPhotos addObject:photo];
            }
            [_photo_list addObject:photo];
        }
        [self.tableView1 reloadData];
        [self.tableView2 reloadData];
    });
    
    
    
    
    
}

#pragma mark 代理方法-UIScrollView
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == _tableView1) {
        [_tableView2 setContentOffset:_tableView1.contentOffset];
        if (!_promt.hidden) {
            CGRect frame = _promt.frame;
            frame.origin.y = -_tableView1.contentOffset.y + 20;
            _promt.frame = frame;
        }
    }else if(scrollView == _tableView2){
        [_tableView1 setContentOffset:_tableView2.contentOffset];
        if (!_promt.hidden) {
            CGRect frame = _promt.frame;
            frame.origin.y = -_tableView2.contentOffset.y + 20;
            _promt.frame = frame;
        }
    }
}



-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (scrollView == _tableView1 && !_header2.refreshing) {
        _header1.hidden = NO;
        _header2.hidden = YES;
    }else if (scrollView == _tableView2 && !_header1.refreshing){
        _header1.hidden = YES;
        _header2.hidden = NO;
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
        if (_leftH < _rightH) max = max + 1;
    }else{
        max = _rigPhotos.count;
        if (_leftH > _rightH) max = max + 1;
    }
    NSLog(@"%ld",max);
    return max;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((tableView == _tableView1 && indexPath.row == _lefPhotos.count) || (tableView == _tableView2 && indexPath.row == _rigPhotos.count)) {
        UITableViewCell *cell = [[UITableViewCell alloc]init];
        cell.backgroundColor = [UIColor clearColor];
        return cell;
    }
    
    
    
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
    
    NSMutableDictionary *a;
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
    
    NSString* url = [a valueForKey:@"url"];

    [photo setContentMode:UIViewContentModeScaleAspectFit];
    [photo sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"活动图片的默认图片"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (image) {
            [photo setContentMode:UIViewContentModeScaleToFill];
        }
    }];

    int width = [[a valueForKey:@"width"] intValue];
    int height = [[a valueForKey:@"height"] intValue];
    float RealHeight = height * 150.0f / width;

    if (height == 0) {
        [cell.activityIndicator startAnimating];
        [cell.activityIndicator setHidden:NO];
        [cell.imageView setHidden:YES];
    }else{
        [cell setHidden:NO];
        [cell.imageView setHidden:NO];
        [cell.activityIndicator stopAnimating];
        [cell.activityIndicator setHidden:YES];
        [photo setFrame:CGRectMake(0, 0, 145, RealHeight)];
        [cell.infoView setFrame:CGRectMake(0, RealHeight, 145, 33)];
        if (tableView == _tableView1) [cell setFrame:CGRectMake(0, 0, 155, RealHeight+43)];
        else [cell setFrame:CGRectMake(0, 0, 145, RealHeight+43)];
        [cell addSubview:cell.infoView];
    }
    cell.isloading = _isLoading;
    [cell animationBegin];
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *a;
    if (tableView == _tableView1) {
        if (indexPath.row >= _lefPhotos.count) {
            return abs(_leftH - _rightH);
        }
        a = _lefPhotos[indexPath.row];
    }else{
        if (indexPath.row >= _rigPhotos.count) {
            return abs(_rightH - _leftH);
        }
        a = _rigPhotos[indexPath.row];
    }
    
    int width = [[a valueForKey:@"width"] intValue];
    int height = [[a valueForKey:@"height"] intValue];
    float RealHeight = height * 150.0f / width;
    
    return RealHeight + 43;
    

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
//    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == 0) {
//        NSLog(@"没有网络");
//        [refreshView endRefreshing];
//        return;
//    }
    if (_header1.refreshing || _header2.refreshing) {
        return;
    }

    _isHeaderOpen = YES;
    _shouldReloadPhoto = YES;
    self.sequence = [[NSNumber alloc]initWithInt:0];
    [_photo_list_all removeAllObjects];
    [self getPhotolist];

    
    
}



-(void)dealloc
{
    [_header1 free];
    [_header2 free];
}

@end











