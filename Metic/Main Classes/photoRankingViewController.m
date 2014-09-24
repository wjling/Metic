//
//  photoRankingViewController.m
//  WeShare
//
//  Created by ligang6 on 14-9-22.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "photoRankingViewController.h"
#import "PhotoRankingTableViewCell.h"
#import "MTUser.h"
#import "MobClick.h"
#import "../Utils/Reachability.h"

@interface photoRankingViewController ()
@property(nonatomic,strong) NSMutableArray* photos_all;
@property(nonatomic,strong) NSMutableArray* photos;
@property(nonatomic,strong) MJRefreshFooterView* footer;
@property BOOL Footeropen;
@end
#define photoNum 15

@implementation photoRankingViewController

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
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    CGRect frame = self.view.bounds;
    frame.origin.x = frame.size.width/32;
    frame.size.width = frame.size.width * 15/16;
    [self.tableView setFrame:frame];
    [MobClick beginLogPageView:@"图片排行榜"];
    
    self.shouldFlash = NO;
    [self.tableView reloadData];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.shouldFlash = YES;
    });
    
    
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [MobClick endLogPageView:@"图片排行榜"];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    [_footer free];
}
-(void)initData
{
    _shouldFlash = YES;
    _Footeropen = NO;
    CGRect frame = self.view.bounds;
    frame.origin.x = frame.size.width/32;
    frame.size.width = frame.size.width * 15/16;
    self.tableView = [[UITableView alloc]initWithFrame:frame];
    [self.view addSubview:_tableView];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView reloadData];
    _photos = [[NSMutableArray alloc]init];
    _photos_all = [[NSMutableArray alloc]init];
    
    [self getPhotoList];
}

-(void)initUI
{
    [self.view setBackgroundColor:[UIColor colorWithWhite:242.0/255.0 alpha:1.0]];
    [CommonUtils addLeftButton:self isFirstPage:NO];
    
    //初始化上拉加载更多
    _footer = [[MJRefreshFooterView alloc]init];
    _footer.delegate = self;
    _footer.scrollView = _tableView;
}

//返回上一层
-(void)MTpopViewController{
    [self.navigationController popViewControllerAnimated:YES];
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
}

-(void)getPhotoList
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:[MTUser sharedInstance].userid forKey:@"id"];
    [dictionary setValue:[NSNumber numberWithInt:50] forKey:@"number"];
    [dictionary setValue:self.eventId forKey:@"event_id"];
    NSLog(@"%@",dictionary);
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:GET_GOOD_PHOTOS finshedBlock:^(NSData *rData) {
        if (rData) {
            NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
            NSNumber *cmd = [response1 valueForKey:@"cmd"];
            switch ([cmd intValue]) {
                case NORMAL_REPLY:{
                    NSMutableArray* newphoto_list =[[NSMutableArray alloc]initWithArray:[response1 valueForKey:@"good_photos"]];
                    for (int i = 0; i < newphoto_list.count; i++) {
                        NSMutableDictionary* dictionary = [[NSMutableDictionary alloc]initWithDictionary:newphoto_list[i]];
                        newphoto_list[i] = dictionary;
                    }
                    //[self updateVideoInfoToDB:newvideo_list];
                    
                    _photos_all = newphoto_list;
                    int num = MIN(photoNum, _photos_all.count);
                    if (_photos) {
                        [_photos removeAllObjects];
                        [_photos addObjectsFromArray:[_photos_all subarrayWithRange:NSMakeRange(0, num)]];
                    }else _photos = [[NSMutableArray alloc]initWithArray:[_photos_all subarrayWithRange:NSMakeRange(0, num)]];
                    
                    self.shouldFlash = NO;
                    [self.tableView reloadData];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        self.shouldFlash = YES;
                    });
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self closeRJ];
                    });

                }
                    break;
                default:{
                }
            }
            
        }else{
        }
    }];
    
    
}

-(void)loadMorePhoto{
    int num = MIN(photoNum, _photos_all.count - _photos.count);
    if (num > 0) {
        [_photos addObjectsFromArray:[_photos_all subarrayWithRange:NSMakeRange(_photos.count, num)]];
        self.shouldFlash = NO;
        [self.tableView reloadData];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.shouldFlash = YES;
        });
    }
    [self closeRJ];
}


#pragma UITableView DataSource & Delegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_photos) return _photos.count;
    else return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PhotoRankingTableViewCell";
    BOOL nibsRegistered = NO;
    if (!nibsRegistered) {
        UINib *nib = [UINib nibWithNibName:NSStringFromClass([PhotoRankingTableViewCell class]) bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:CellIdentifier];
        nibsRegistered = YES;
    }
    PhotoRankingTableViewCell *cell = (PhotoRankingTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    
    if (self.photos) {
        NSMutableDictionary *dictionary = self.photos[indexPath.row];
        cell.photoInfo = dictionary;
        cell.eventId = _eventId;
        cell.controller = self;
        [cell refresh];
        [cell animationBegin];
    }
    
	return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 226;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PhotoRankingTableViewCell* cell = (PhotoRankingTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    [cell toPhotoDetail];
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
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self loadMorePhoto];
    });
    
}

@end
