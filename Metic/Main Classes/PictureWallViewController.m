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

@interface PictureWallViewController ()
@property int leftHeight;
@property int rightHeight;
@property int leftRows;
@property int rightRows;
@property int wait;
@property BOOL isOpen;
@property long seletedPhotoIndex;
@property (nonatomic,strong) UIAlertView *Alert;
@property (nonatomic,strong) NSTimer *timer;

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
    self.leftHeight = self.rightHeight = self.leftRows = self.rightRows = 0;
    self.isOpen = NO;
    self.sequence = [[NSNumber alloc]initWithInt:0];
    self.photo_list = [[NSMutableArray alloc]init];
    self.photo_list_all= [[NSMutableArray alloc]init];
    self.photoPath_list = [[NSMutableArray alloc]init];
    
    //初始化下拉刷新功能
    _footer = [[MJRefreshFooterView alloc]init];
    _footer.delegate = self;
    _footer.scrollView = self.tableView1;
    
    //等待圈圈
    
}

-(void)viewDidAppear:(BOOL)animated
{
    
    self.sequence = [[NSNumber alloc]initWithInt:0];
    [self.photo_list removeAllObjects];
    [self.photo_list_all removeAllObjects];
    self.leftHeight = self.rightHeight = self.leftRows = self.rightRows = self.wait= 0;
    [self getPhotolist];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        NSString* path = [NSString stringWithFormat:@"/images/%@",[dict valueForKey:@"photo_name"]];
        [self.photoPath_list addObject:path];
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

-(void)close_RJ
{
    self.isOpen = NO;
    [_footer endRefreshing];
}

-(void)BGgetPhoto:(id)sender
{
    PhotoGetter* getter = sender;
    [getter getPhoto];
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
    long rows = 0;
    if (!self.photo_list.count) {
        return rows;
    }
    rows = self.photo_list.count/2;

    if (tableView == self.tableView1) {
        rows += self.photo_list.count%2;
    }
    return rows;
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
    PhotoTableViewCell *cell1 = (PhotoTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    UITableViewCell *cell = [[UITableViewCell alloc]init];
    [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    if (self.photo_list.count) {
        NSDictionary *a = self.photo_list[indexPath.row*2+addition];
        cell1.author.text = [a valueForKey:@"author"];
        cell1.publish_date.text = [[a valueForKey:@"time"] substringToIndex:10];
        
        
        cell1.avatar.image = nil;
        PhotoGetter *getter = [[PhotoGetter alloc]initWithData:cell1.avatar path:[NSString stringWithFormat:@"/avatar/%@.jpg",[a valueForKey:@"author_id"]] type:2 cache:[MTUser sharedInstance].avatar];
        [getter setTypeOption2:[a valueForKey:@"author_id"]];
        getter.mDelegate = self;
        [getter getPhoto];
        
        
        
        
        UIImageView *photo = [[UIImageView alloc]init];
        //photo.image = nil;
        NSString* path = [NSString stringWithFormat:@"/images/%@",[a valueForKey:@"photo_name"]];
        UIImage* img = [self.photos valueForKey:path];
        if (img) {
            [cell1 setHidden:NO];
            photo.image = img;
            float imgHeight = 145.0*img.size.height/img.size.width;
            [cell setFrame:CGRectMake(0, 0, 145, imgHeight+33)];
            [cell setBackgroundColor:[UIColor clearColor]];
            [photo setFrame:CGRectMake(0, 0, 145, imgHeight)];
            [cell1 setFrame:CGRectMake(0, imgHeight, 145, 33)];
            [cell addSubview:cell1];
            [cell addSubview:photo];
        }else{
            [cell setHidden:YES];
            PhotoGetter *photoGetter = [[PhotoGetter alloc]initWithData:photo path:[NSString stringWithFormat:@"/images/%@",[a valueForKey:@"photo_name"]] type:3 cache:self.photos];
            [photoGetter setTypeOption3:tableView];
            photoGetter.mDelegate = self;
            //[self performSelectorInBackground:@selector(BGgetPhoto:) withObject:photoGetter];

            [photoGetter getPhoto];
            
        }
     
        
    }
	return cell;
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.tableView1 == scrollView) {
        self.tableView2.contentOffset = self.tableView1.contentOffset;
    }else{
        self.tableView1.contentOffset = self.tableView2.contentOffset;
    }
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    //[self performSelector:@selector(reloadPhoto) withObject:nil afterDelay:1];
    //self.wait = 0;
    if (self.tableView1.contentSize.height > self.tableView2.contentSize.height) {
        [self.tableView2 setContentSize:self.tableView1.contentSize];
    }else [self.tableView1 setContentSize:self.tableView2.contentSize];
    self.footer.scrollView = scrollView;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int addition = 0;
    if (tableView == self.tableView2) {
        addition = 1;
    }
    NSDictionary *a = self.photo_list[indexPath.row*2+addition];
    NSString* path = [NSString stringWithFormat:@"/images/%@",[a valueForKey:@"photo_name"]];
    UIImage* img = [self.photos valueForKey:path];
    if (img) {
        float imgHeight = 145.0*img.size.height/img.size.width;
        return imgHeight + 43;
    }else{
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
            [self.tableView1 reloadData];
            [self.tableView2 reloadData];
            [self performSelector:@selector(reloadPhoto) withObject:nil afterDelay:0.2];
            //self.timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(reloadPhoto) userInfo:nil repeats:NO];
        }
            break;
    }
}
#pragma mark - PhotoGetterDelegate
-(void)finishwithNotification:(UIImageView *)imageView image:(UIImage *)image type:(int)type container:(id)container
{
    imageView.image = image;
    switch (type) {
        case 3:
            [(UITableView*)container reloadData];
            break;
        default:
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
            nextViewController.photoscache = self.photos;
            nextViewController.photoPath_list = self.photoPath_list;
            nextViewController.photo_list = self.photo_list;
            nextViewController.photoIndex = self.seletedPhotoIndex;
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
    if ([self.sequence intValue] == -1) {
        [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(showAlert) userInfo:nil repeats:NO];
        [NSTimer scheduledTimerWithTimeInterval:1.2f target:self selector:@selector(performDismiss) userInfo:nil repeats:NO];
        return;
    }
    int photo_rest_num = self.photo_list_all.count - self.photo_list.count;
    int count = self.photo_list.count;
    if (photo_rest_num >= 5) {//加载剩余的，然后再拉
        for (int i = count; i < count + 5; i++) {
            [self.photo_list addObject:self.photo_list_all[i]];
        }
        [self getPhotoPathlist];
        [self.tableView1 reloadData];
        [self.tableView2 reloadData];
        [_footer endRefreshing];
    }else{
        [self getPhotolist];
    }
    
    
    
    
    
    
    
    
}




@end
