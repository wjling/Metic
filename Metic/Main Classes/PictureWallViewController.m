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
#import "../Cell/PhotoTableViewCell.h"
#import "../Utils/CommonUtils.h"
#import "../Utils/HttpSender.h"
#import "AppConstants.h"
#import "UIImageView+WebCache.h"



@interface PictureWallViewController ()
@property BOOL isOpen;
@property long seletedPhotoIndex;
@property (nonatomic,strong) UIAlertView *Alert;
@property BOOL shouldStopTimer;
@property (nonatomic,strong) NSTimer *timer;
@property (nonatomic,strong) NSMutableDictionary *cellHeight;
@property (nonatomic,strong)SDWebImageManager *manager;
@property int currentPhotoNum;
@property (nonatomic,strong) NSString* urlFormat;

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
    self.photos = [[NSMutableDictionary alloc]init];
    [self.tableView1 setDelegate:self];
    [self.tableView1 setDataSource:self];
    [self.tableView2 setDelegate:self];
    [self.tableView2 setDataSource:self];
    self.seletedPhotoIndex = 0;
    self.isOpen = NO;
    self.sequence = [[NSNumber alloc]initWithInt:0];
    self.photo_list = [[NSMutableArray alloc]init];
    self.photo_list_all= [[NSMutableArray alloc]init];
    self.photoPath_list = [[NSMutableArray alloc]init];
    self.cellHeight = [[NSMutableDictionary alloc]init];
    _urlFormat = @"http://bcs.duapp.com/metis201415/images/%@?sign=%@";
    _manager = [SDWebImageManager sharedManager];
    
    //初始化下拉刷新功能
    _footer = [[MJRefreshFooterView alloc]init];
    _footer.delegate = self;
    _footer.scrollView = self.tableView1;
    //[_footer beginRefreshing];
    
    //等待圈圈
    
}

-(void)viewDidAppear:(BOOL)animated
{
    _shouldStopTimer = YES;
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(reloadPhoto) userInfo:nil repeats:YES];
    [self getPhotolist];
}


-(void)viewDidDisappear:(BOOL)animated
{
    if (_shouldStopTimer){
        _shouldStopTimer = NO;
        [_timer invalidate];
        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell removeFromSuperview];
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
        NSString *url = [NSString stringWithFormat:_urlFormat,[dict valueForKey:@"photo_name"] ,[dict valueForKey:@"url"]];
        [self.photoPath_list addObject:url];
    }
}


-(void)reloadPhoto
{
    if (self.isOpen) {
        self.isOpen = NO;
        [_footer endRefreshing];
    }
    [self.tableView1 reloadData];
    [self.tableView2 reloadData];
}

- (IBAction)toUploadPhoto:(id)sender {
    [self performSegueWithIdentifier:@"toUploadPhoto" sender:self];
}

-(void)showAlert
{
    _Alert = [[UIAlertView alloc] initWithTitle:@"" message:@"没有更多了" delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
    [_Alert show];
    self.isOpen = NO;
    [_footer endRefreshing];
}
-(void)performDismiss
{
    [_Alert dismissWithClickedButtonIndex:0 animated:NO];
}

#pragma mark 代理方法-UIScrollView
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == _tableView1) {
        [_tableView2 setContentOffset:_tableView1.contentOffset];
    }else [_tableView1 setContentOffset:_tableView2.contentOffset];
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (_shouldStopTimer){
        _shouldStopTimer = NO;
        [_timer invalidate];
    
    }
    _footer.scrollView = scrollView;
    if (_tableView1.contentSize.height > _tableView2.contentSize.height) {
        [_tableView2 setContentSize:_tableView1.contentSize];
    }else [_tableView1 setContentSize:_tableView2.contentSize];
}

#pragma mark 代理方法-UITableView
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.seletedPhotoIndex = indexPath.row*2;
    if (tableView == self.tableView2) {
        self.seletedPhotoIndex +=1;
    }
    [self performSegueWithIdentifier:@"photosShow" sender:self];
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    long max = 0;
    if (!self.photo_list.count) {
        return 0;
    }
    max = self.photo_list.count/2;
    
    if (tableView == self.tableView1) {
        max += self.photo_list.count%2;
    }
    return max;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int addition = 0;
    if (tableView == self.tableView2) {
        addition = 1;
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
    NSDictionary *a = self.photo_list[indexPath.row*2+addition];
    cell.author.text = [a valueForKey:@"author"];
    cell.publish_date.text = [[a valueForKey:@"time"] substringToIndex:10];
    
    cell.avatar.layer.masksToBounds = YES;
    [cell.avatar.layer setCornerRadius:5];
    
    PhotoGetter* avatarGetter = [[PhotoGetter alloc]initWithData:cell.avatar authorId:[a valueForKey:@"author_id"]];
    [avatarGetter getPhoto];
    
        
    NSString *url = [NSString stringWithFormat:_urlFormat,[a valueForKey:@"photo_name"] ,[a valueForKey:@"url"]];
    UIImageView* photo = cell.imgView;
    [cell.infoView removeFromSuperview];
    [photo sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"活动图片的默认图片"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
    }];
    //[photo sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"活动图片的默认图片"]];
    NSNumber* Cellheight = [_cellHeight valueForKey:url];
    if (Cellheight) {
        float height = [Cellheight floatValue];
        if (height == 0) {
            [cell setHidden:YES];
        }else{
            [cell setHidden:NO];
            [photo setFrame:CGRectMake(0, 0, 145, height)];
            [cell.infoView setFrame:CGRectMake(0, height, 145, 33)];
            [cell setFrame:CGRectMake(0, 0, 145, height+43)];
            [cell addSubview:cell.infoView];
        }

    }else [cell setHidden:YES];
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int addition = 0;
    if (tableView == self.tableView2) {
        addition = 1;
    }
    NSDictionary *a = self.photo_list[indexPath.row*2+addition];
    NSString *url = [NSString stringWithFormat:_urlFormat,[a valueForKey:@"photo_name"] ,[a valueForKey:@"url"]];
    UIImage * img = [[_manager imageCache] imageFromDiskCacheForKey:url];
    float height = 0;
    if(img){
        height = img.size.height *145.0/img.size.width;
        [_cellHeight setValue:[NSNumber numberWithFloat:height] forKey:url];
        return height+43;
    }else{
        [_cellHeight setValue:[NSNumber numberWithFloat:0] forKey:url];
        return 0;
    }

    
}
#pragma mark - HttpSenderDelegate

-(void)finishWithReceivedData:(NSData *)rData
{
    NSString* temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
    rData = [temp dataUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"received Data: %@",temp);
    NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
    NSNumber *cmd = [response1 valueForKey:@"cmd"];
    switch ([cmd intValue]) {
        case NORMAL_REPLY:
        {
            NSMutableArray* newphoto_list =[[NSMutableArray alloc]initWithArray:[response1 valueForKey:@"photo_list"]];
            self.sequence = [response1 valueForKey:@"sequence"];
            [self.photo_list_all addObjectsFromArray:newphoto_list];
            int count = self.photo_list.count;
            for (int i = count; i < count + 5 && i < self.photo_list_all.count; i++) {
                [self.photo_list addObject:self.photo_list_all[i]];
            }
            [self getPhotoPathlist];
            [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(reloadPhoto) userInfo:nil repeats:NO];
            
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
            nextViewController.photoPath_list = self.photoPath_list;
            nextViewController.photo_list = self.photo_list;
            nextViewController.photoIndex = self.seletedPhotoIndex;
            nextViewController.eventId = self.eventId;
        }
        if ([segue.destinationViewController isKindOfClass:[PhotoUploadViewController class]]) {
            PhotoUploadViewController *nextViewController = segue.destinationViewController;
            nextViewController.eventId = self.eventId;
            nextViewController.photoWallController = self;
        }
    }
}

#pragma mark 代理方法-进入刷新状态就会调用
- (void)refreshViewBeginRefreshing:(MJRefreshBaseView *)refreshView
{
    self.isOpen = YES;
    int photo_rest_num = self.photo_list_all.count - self.photo_list.count;
    if ([self.sequence intValue] == -1 && photo_rest_num == 0) {
        [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(showAlert) userInfo:nil repeats:NO];
        [NSTimer scheduledTimerWithTimeInterval:1.2f target:self selector:@selector(performDismiss) userInfo:nil repeats:NO];
        return;
    }
    
    int count = self.photo_list.count;
    if (photo_rest_num >= 5 || [_sequence intValue] == -1) {//加载剩余的，然后再拉
        for (int i = count; i < count + 5 && i < _photo_list_all.count; i++) {
            [self.photo_list addObject:self.photo_list_all[i]];
        }
        [self getPhotoPathlist];
        [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(reloadPhoto) userInfo:nil repeats:NO];
    }else{
        [self getPhotolist];
    }

}

-(void)dealloc
{
    [_footer free];
}



@end
