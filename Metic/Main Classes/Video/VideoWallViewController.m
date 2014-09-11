

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



@interface VideoWallViewController ()
@property(nonatomic,strong) NSMutableArray* videoInfos;
@property(nonatomic,strong) NSMutableDictionary* seleted_videoInfo;
@property(nonatomic,strong) UIImage* seleted_videoThumb;
@property(nonatomic,strong) NSNumber* sequence;
@property(nonatomic,strong) NSString* urlFormat;
@property(nonatomic,strong) UIImage* preViewImage;
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
    [CommonUtils addLeftButton:self isFirstPage:NO];
    
    //init tableView
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(10, 0, self.view.frame.size.width - 20, self.view.frame.size.height)];
    [_tableView setBackgroundColor:[UIColor clearColor]];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
    //    _urlFormat = @"http://bcs.duapp.com/whatsact/video/%@.thumb?sign=%@";//正式服
    _urlFormat = @"http://bcs.duapp.com/metis201415/video/%@.thumb?sign=%@";//测试服
    
    _videoInfos = [[NSMutableArray alloc]init];
    
    _sequence = [NSNumber numberWithInt:0];
    [self getVideolist];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _sequence = [NSNumber numberWithInt:0];
    [self getVideolist];
    [MobClick beginLogPageView:@"视频墙"];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [MobClick endLogPageView:@"视频墙"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//返回上一层
-(void)MTpopViewController{
    [self.navigationController popViewControllerAnimated:YES];
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
                    [_videoInfos removeAllObjects];
                    for (NSDictionary *dictionary in [response1 valueForKey:@"video_list"]) {
                        NSMutableDictionary* Mdictionary = [[NSMutableDictionary alloc]initWithDictionary:dictionary];
                        [_videoInfos addObject:Mdictionary];
                    }
                    [_tableView reloadData];
                }
                    break;
                default:{
                    
                }
            }

        }else{
            [CommonUtils showSimpleAlertViewWithTitle:@"提示" WithMessage:@"网络异常，请重试" WithDelegate:nil WithCancelTitle:@"确定"];
        }
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

-(float)calculateTextHeight:(NSString*)text width:(float)width fontSize:(float)fsize
{
    UIFont *font = [UIFont systemFontOfSize:fsize];
    CGSize size = CGSizeMake(width,2000);
    CGRect labelRect = [text boundingRectWithSize:size options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)  attributes:[NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName] context:nil];
    return ceil(labelRect.size.height);
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
        float height = [self calculateTextHeight:text width:280 fontSize:16.0f];
        cell.height = height;
        [cell refresh];
    }
    
	return cell;

}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dictionary = self.videoInfos[indexPath.row];
    NSString* text = [dictionary valueForKey:@"title"];
    float height = [self calculateTextHeight:text width:280 fontSize:16.0f];
    return 266 + height;
    
}
#pragma tableView Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    VideoWallTableViewCell* cell = (VideoWallTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    NSMutableDictionary *dictionary = self.videoInfos[indexPath.row];
    _seleted_videoInfo = dictionary;
    _seleted_videoThumb = cell.videoThumb;
    [self performSegueWithIdentifier:@"toVideoDetail" sender:self];
}

#pragma mark 用segue跳转时传递参数eventid
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //这里我很谨慎的对sender和目标视图控制器作了判断
    if ([sender isKindOfClass:[VideoWallViewController class]]) {
        if ([segue.destinationViewController isKindOfClass:[VideoDetailViewController class]]) {
            VideoDetailViewController *nextViewController = segue.destinationViewController;
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
    [self.navigationController pushViewController:controller animated:NO];
    
    
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
