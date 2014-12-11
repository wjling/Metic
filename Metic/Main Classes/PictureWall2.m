//
//  PictureWall2.m
//  WeShare
//
//  Created by ligang6 on 14-12-2.
//  Copyright (c) 2014年 WeShare. All rights reserved.
//

#import "PictureWall2.h"
#import "../Utils/MySqlite.h"
#import "MTUser.h"
#import "TMQuiltView.h"
#import "MobClick.h"
#import "../Utils/Reachability.h"
#import "NSString+JSON.h"
#import "../Cell/PhotoTableViewCell.h"
#import "PhotoDisplayViewController.h"
#import "photoRankingViewController.h"
#import "PhotoUploadViewController.h"
#import "../Source/SVProgressHUD/SVProgressHUD.h"

@interface PictureWall2 ()
@property (nonatomic,strong) UIButton* add;
@property float h1;
@property BOOL nibsRegistered;
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
    [_header free];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initUI
{
    self.view.backgroundColor = [UIColor colorWithWhite:242.0/255.0 alpha:1.0f];
    [CommonUtils addLeftButton:self isFirstPage:NO];
    
    _add = [UIButton buttonWithType:UIButtonTypeCustom];
    [_add setBackgroundImage:[CommonUtils createImageWithColor:[UIColor colorWithRed:85/255.0 green:203/255.0 blue:171/255.0 alpha:1.0]] forState:UIControlStateNormal];
    [_add setBackgroundImage:[CommonUtils createImageWithColor:[UIColor colorWithRed:85/255.0 green:170/255.0 blue:166/255.0 alpha:1.0]] forState:UIControlStateHighlighted];
    _add.layer.masksToBounds = YES;
    _add.layer.cornerRadius = CGRectGetWidth(self.view.frame)*0.1;
    [_add addTarget:self action:@selector(toUploadPhoto:) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel* addLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    [addLabel setTag:12];
    [addLabel setBackgroundColor:[UIColor clearColor]];
    [addLabel setFont:[UIFont systemFontOfSize:50]];
    [addLabel setTextAlignment:NSTextAlignmentCenter];
    [addLabel setText:@"+"];
    [addLabel setTextColor:[UIColor whiteColor]];
    [_add addSubview:addLabel];
    
    //初始化下拉刷新功能
    _header = [[MJRefreshHeaderView alloc]init];
    _header.delegate = self;
    _header.scrollView = (UIScrollView*)self.view;
    
}

- (void)initData
{
    _nibsRegistered = NO;
    _shouldReloadPhoto = NO;
    _h1 = 0;
    self.sequence = [[NSNumber alloc]initWithInt:-1];
    self.photo_list = [[NSMutableArray alloc]init];
    self.photo_list_all= [[NSMutableArray alloc]init];
    [self pullPhotoInfosFromDB];
    if ([_photo_list_all count] == 0 &&[[Reachability reachabilityForInternetConnection] currentReachabilityStatus]!= 0) {
        self.sequence = [[NSNumber alloc]initWithInt:0];
        [_header beginRefreshing];
    
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [SVProgressHUD dismiss];
    [MobClick beginLogPageView:@"图片墙"];
    CGRect frame = self.navigationController.view.window.frame;
    [_add setFrame:CGRectMake(CGRectGetWidth(frame)*0.7, CGRectGetHeight(frame) - CGRectGetWidth(frame)*0.3 , CGRectGetWidth(frame)*0.2, CGRectGetWidth(frame)*0.2)];
    [[_add viewWithTag:12] setFrame:CGRectMake(0, 0, CGRectGetWidth(frame)*0.2, CGRectGetWidth(frame)*0.17)];
    _add.layer.cornerRadius = CGRectGetWidth(_add.frame)/2;
    _add.layer.masksToBounds = YES;
    [self.navigationController.view.window addSubview:_add];
    
    if (_shouldReloadPhoto && [[Reachability reachabilityForInternetConnection] currentReachabilityStatus]!= 0) {
        _shouldReloadPhoto = NO;
        [_header beginRefreshing];

    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_add removeFromSuperview];
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

- (void)updatePhotoInfoToDB:(NSMutableArray*)photoInfos
{
    NSString * path = [NSString stringWithFormat:@"%@/db",[MTUser sharedInstance].userid];
    MySqlite* sql = [[MySqlite alloc]init];
    [sql openMyDB:path];
    for (NSDictionary *photoInfo in photoInfos) {
        NSString *photoData = [NSString jsonStringWithDictionary:photoInfo];
        photoData = [photoData stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        NSArray *columns = [[NSArray alloc]initWithObjects:@"'photo_id'",@"'event_id'",@"'photoInfo'", nil];
        NSArray *values = [[NSArray alloc]initWithObjects:[NSString stringWithFormat:@"%@",[photoInfo valueForKey:@"photo_id"]],[NSString stringWithFormat:@"%@",_eventId],[NSString stringWithFormat:@"'%@'",photoData], nil];
        
        [sql insertToTable:@"eventPhotos" withColumns:columns andValues:values];
    }
    [sql closeMyDB];
}

- (void)pullPhotoInfosFromDB
{
    NSString * path = [NSString stringWithFormat:@"%@/db",[MTUser sharedInstance].userid];
    MySqlite* sql = [[MySqlite alloc]init];
    [sql openMyDB:path];
    
    //self.events = [[NSMutableArray alloc]init];
    NSArray *seletes = [[NSArray alloc]initWithObjects:@"photoInfo", nil];
    NSDictionary *wheres = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%@ order by photo_id desc",_eventId],@"event_id", nil];
    NSMutableArray *result = [sql queryTable:@"eventPhotos" withSelect:seletes andWhere:wheres];
    for (NSDictionary *temp in result) {
        NSString *tmpa = [temp valueForKey:@"photoInfo"];
        tmpa = [tmpa stringByReplacingOccurrencesOfString:@"''" withString:@"'"];
        NSData *tmpb = [tmpa dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *photoInfo =  [NSJSONSerialization JSONObjectWithData:tmpb options:NSJSONReadingMutableContainers error:nil];
        if ([photoInfo valueForKey:@"width"] && [photoInfo valueForKey:@"height"]) {
            if ([[photoInfo valueForKey:@"width"] floatValue] == 0 || [[photoInfo valueForKey:@"height"] floatValue] == 0) {
                continue;
            }
            [self.photo_list_all addObject:photoInfo];
            [self.photo_list addObject:photoInfo];
        }
        
    }
    [sql closeMyDB];
    [self calculateLRH];
    [self.quiltView reloadData];
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
                    [self updatePhotoInfoToDB:newphoto_list];
                    self.sequence = [response1 valueForKey:@"sequence"];
                    
                    [self.photo_list_all addObjectsFromArray:newphoto_list];
                    
                    if ([_sequence intValue] != -1) {
                        [self getPhotolist];
                        return;
                    }else{
                        [self.photo_list removeAllObjects];
                        [self.photo_list addObjectsFromArray:_photo_list_all];
                        [self calculateLRH];
                        [self.quiltView reloadData];
                        if(_header.refreshing) [_header endRefreshing];
                    }
                    
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
    }];
}

-(void)calculateLRH
{
    float lH = 0, rH = 0;
    for (NSDictionary* dict in _photo_list) {
        float width = [[dict valueForKey:@"width"] floatValue];
        float height = [[dict valueForKey:@"height"] floatValue];
        float RealHeight = height * 150.0f / width + 43;
        if (lH <= rH) {
            lH += RealHeight;
        }else{
            rH += RealHeight;
        }
    }
    NSLog(@"lH: %f , rH: %f",lH,rH);
    _h1 = lH - rH;
}


#pragma mark - TMQuiltViewDelegate
- (NSInteger)quiltViewNumberOfCells:(TMQuiltView *)TMQuiltView {
    return [_photo_list count]+2;
}


- (TMQuiltViewCell *)quiltView:(TMQuiltView *)quiltView cellAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= _photo_list.count) {
        TMQuiltViewCell* cell = [[TMQuiltViewCell alloc]init];
        if ((_h1 > 0 && indexPath.row == _photo_list.count + 1) || (_h1 <= 0 && indexPath.row == _photo_list.count)) {
            float width = 300;
            float height = (_h1 > 0)? 50 : abs(_h1) + 50;
            UILabel* label = [[UILabel alloc]initWithFrame:CGRectMake(width/6, height-40, width*4/6, 40)];
            label.text = @"没有更多了哦，去上传吧~";
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
    
    NSMutableDictionary *a = _photo_list[indexPath.row];
    
    //显示备注名
    NSString* alias = [[MTUser sharedInstance].alias_dic objectForKey:[NSString stringWithFormat:@"%@",[a valueForKey:@"author_id"]]];
    if (alias == nil || [alias isEqual:[NSNull null]]) {
        alias = [a valueForKey:@"author"];
    }
    cell.author.text = alias;
    cell.publish_date.text = [[a valueForKey:@"time"] substringToIndex:10];
    
    cell.avatar.layer.masksToBounds = YES;
    [cell.avatar.layer setCornerRadius:5];
    cell.photoInfo = a;
    cell.PhotoWall = self;
    cell.photo_id = [a valueForKey:@"photo_id"];
    
    PhotoGetter* avatarGetter = [[PhotoGetter alloc]initWithData:cell.avatar authorId:[a valueForKey:@"author_id"]];
    [avatarGetter getAvatar];
    UIImageView* photo = cell.imgView;
//    [cell.infoView removeFromSuperview];
    
    NSString* url = [a valueForKey:@"url"];
    
    [photo setContentMode:UIViewContentModeScaleAspectFit];
    [photo setBackgroundColor:[UIColor colorWithWhite:204.0/255 alpha:1.0f]];
    [photo sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"活动图片的默认图片"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (image) {
            [photo setContentMode:UIViewContentModeScaleToFill];
        }
    }];
    
    int width = [[a valueForKey:@"width"] intValue];
    int height = [[a valueForKey:@"height"] intValue];
    float RealHeight = height * 150.0f / width;
    
    [photo setFrame:CGRectMake(0, 0, 145, RealHeight)];
    [cell.infoView setFrame:CGRectMake(0, RealHeight, 145, 33)];

    return cell;
}


- (NSInteger)quiltViewNumberOfColumns:(TMQuiltView *)quiltView {
    return 2;
    
}

- (CGFloat)quiltView:(TMQuiltView *)quiltView heightForCellAtIndexPath:(NSIndexPath *)indexPath {
//    NSLog(@"heightForCellAtIndexPath %d",indexPath.row);
    if (indexPath.row == _photo_list.count) {
        return abs(_h1) + 50;
    }else if(indexPath.row == _photo_list.count + 1) return 50;
    
    NSDictionary *a = _photo_list[indexPath.row];
    
    float width = [[a valueForKey:@"width"] floatValue];
    float height = [[a valueForKey:@"height"] floatValue];
    float RealHeight = height * 150.0f / width;
    
    return RealHeight + 33;
}

- (void)quiltView:(TMQuiltView *)quiltView didSelectCellAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row >= _photo_list.count) {
        return;
    }
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone"
                                                             bundle: nil];
    PhotoDisplayViewController* photoDisplay = [mainStoryboard instantiateViewControllerWithIdentifier: @"PhotoDisplayViewController"];

    photoDisplay.photo_list = self.photo_list;
    photoDisplay.photoIndex = indexPath.row;
    photoDisplay.eventId = self.eventId;
    photoDisplay.eventName = self.eventName;
    photoDisplay.controller = self;
    
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
        }
    }
}

#pragma mark 代理方法-进入刷新状态就会调用
- (void)refreshViewBeginRefreshing:(MJRefreshBaseView *)refreshView
{
   
    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == 0) {
        NSLog(@"没有网络");
        [refreshView endRefreshing];
        return;
    }
    self.sequence = [[NSNumber alloc]initWithInt:0];
    [_photo_list_all removeAllObjects];
    [self getPhotolist];
    
    
    
}


@end
