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
#import "../Utils/HttpSender.h"
#import "AppConstants.h"

@interface PictureWallViewController ()
@property int leftHeight;
@property int rightHeight;
@property int leftRows;
@property int rightRows;
@property int seletedPhotoIndex;

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
    self.sequence = [[NSNumber alloc]initWithInt:0];
    self.photo_list = [[NSMutableArray alloc]init];
    self.photoPath_list = [[NSMutableArray alloc]init];
    [self getPhotolist];
    // Do any additional setup after loading the view.
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
    for(NSDictionary* dict in self.photo_list)
    {
        NSString* path = [NSString stringWithFormat:@"/images/%@",[dict valueForKey:@"photo_name"]];
        [self.photoPath_list addObject:path];
    }
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
    int rows = 0;
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
    if (self.photo_list.count) {
        NSDictionary *a = self.photo_list[indexPath.row*2+addition];
        cell1.author.text = [a valueForKey:@"author"];
        cell1.publish_date.text = [a valueForKey:@"time"];
        
        
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
    if (self.tableView1.contentSize.height > self.tableView2.contentSize.height) {
        [self.tableView2 setContentSize:self.tableView1.contentSize];
    }else [self.tableView1 setContentSize:self.tableView2.contentSize];
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
            NSArray* newphoto_list = [response1 valueForKey:@"photo_list"];
            self.sequence = [response1 valueForKey:@"sequence"];
            [self.photo_list addObjectsFromArray:newphoto_list];
            [self getPhotoPathlist];
            [self.tableView1 reloadData];
            [self.tableView2 reloadData];
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
        }
    }
}
- (IBAction)toUploadPhoto:(id)sender {
    [self performSegueWithIdentifier:@"toUploadPhoto" sender:self];
}
@end
