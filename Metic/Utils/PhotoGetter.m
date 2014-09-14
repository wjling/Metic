//
//  PhotoGetter.m
//  Metic
//
//  Created by ligang_mac4 on 14-6-26.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "PhotoGetter.h"
#import "CommonUtils.h"
#import "UIImage+UIImageExtras.h"
#import "UIImageView+WebCache.h"
#import "UserInfoViewController.h"
#import "FillinInfoViewController.h"

@interface PhotoGetter ()
{
    UIViewController* updateAvatarViewController;
    BOOL updateAvatarFlag;
}
@property(nonatomic,strong) UIImage* uploadImage;
@property(nonatomic,strong) NSString* imgName;
@property(nonatomic,strong) NSString* videoName;
@property(nonatomic,strong) NSString* videoFilePath;
@property BOOL isUpload;

@end


@implementation PhotoGetter


- (instancetype)initWithData:(UIImageView*)animageView authorId:(NSNumber*)authorId //type:(int)type cache:(NSMutableDictionary*)cache
{
    if (self) {
        self = [super init];
        self.imageView = animageView;
        if ([authorId isKindOfClass:[NSString class]]) {
            self.avatarId = [CommonUtils NSNumberWithNSString:authorId];
        }else self.avatarId = authorId;
        
        self.path = [NSString stringWithFormat:@"/avatar/%@.jpg",authorId];
        self.isUpload = NO;
    }
    return self;
}

- (instancetype)initUploadMethod:(UIImage*)aImage type:(int)type
{
    if (self) {
        self = [super init];
        self.uploadImage = aImage;
        self.type = type;
    }
    return self;
}

- (instancetype)initUploadAvatarMethod:(UIImage*)aImage type:(int)type viewController:(UIViewController*)vc
{
    if (self) {
        self = [super init];
        self.uploadImage = aImage;
        self.type = type;
        updateAvatarViewController = vc;
    }
    return self;
}

-(void)getAvatar
{
    
    NSString *url = [self getLocalAvatarUrl];
    if ([[MTUser sharedInstance].friendsIdSet containsObject:self.avatarId]) {
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"默认用户头像"] options:SDWebImageRetryFailed];
    }else{
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"默认用户头像"] options:SDWebImageCacheMemoryOnly];
    }
}

//-(void)getAvatar
//{
//    __block NSString* url = [[MTUser sharedInstance].avatarURL valueForKey:[NSString stringWithFormat:@"%@",self.avatarId]];
//    if (!url) {
//        [self.imageView setImage:[UIImage imageNamed:@"默认用户头像"]];
//        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
//        [dictionary setValue:@"GET" forKey:@"method"];
//        [dictionary setValue:[NSString stringWithFormat:@"/avatar/%@.jpg",self.avatarId] forKey:@"object"];
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
//                    [[MTUser sharedInstance].avatarURL setValue:url forKey:[NSString stringWithFormat:@"%@",self.avatarId]];
//                    [self.imageView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"默认用户头像"]];
//                }
//                    break;
//            }
//        }];
//
//        
//    }else{
//        [self.imageView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"默认用户头像"]];
//    }
//    
//}


-(void)getBanner:(NSNumber*)code
{
    switch ([code intValue]) {
        case 0:
        {
            NSString *url = [self getLocalBannerUrl];
            [self.imageView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"1星空.jpg"]];
        }
            break;
//        case 0:
//        {
//            __block NSString* url = [[MTUser sharedInstance].bannerURL valueForKey:[NSString stringWithFormat:@"%@",self.avatarId]];
//            if (!url) {
//                [self.imageView setImage:[UIImage imageNamed:@"1星空.jpg"]];
//                NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
//                [dictionary setValue:@"GET" forKey:@"method"];
//                [dictionary setValue:[NSString stringWithFormat:@"/banner/%@.jpg",self.avatarId] forKey:@"object"];
//                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
//                NSLog(@"%@",[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding]);
//                HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
//                [httpSender sendMessage:jsonData withOperationCode: GET_FILE_URL finshedBlock:^(NSData *rData) {
//                    NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
//                    NSNumber *cmd = [response1 valueForKey:@"cmd"];
//                    switch ([cmd intValue]) {
//                        case NORMAL_REPLY:
//                        {
//                            url = (NSString*)[response1 valueForKey:@"url"];
//                            NSLog(@"%@",url);
//                            [[MTUser sharedInstance].bannerURL setValue:url forKey:[NSString stringWithFormat:@"%@",self.avatarId]];
//                            [self.imageView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"1星空.jpg"]];
//                        }
//                            break;
//                    }
//                }];   
//            }else{
//                [self.imageView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"1星空.jpg"]];
//            }
//        }
//            break;
        case 1:
        {
            [self.imageView setImage:[UIImage imageNamed:@"1星空.jpg"]];
        }
            break;
        case 2:
        {
            [self.imageView setImage:[UIImage imageNamed:@"2聚餐.jpg"]];
        }
            break;
        case 3:
        {
            [self.imageView setImage:[UIImage imageNamed:@"3兜风.jpg"]];
        }
            break;
        case 4:
        {
            [self.imageView setImage:[UIImage imageNamed:@"4喝酒.jpg"]];
        }
            break;
        case 5:
        {
            [self.imageView setImage:[UIImage imageNamed:@"5健身.jpg"]];
        }
            break;
        case 6:
        {
            [self.imageView setImage:[UIImage imageNamed:@"6听课.jpg"]];
        }
            break;
        case 7:
        {
            [self.imageView setImage:[UIImage imageNamed:@"7夜店.jpg"]];
        }
            break;
        default:
            [self.imageView setImage:[UIImage imageNamed:@"1星空.jpg"]];
            break;
        }
  
}



-(void)updatePhoto
{
    CloudOperation * cloudOP = [[CloudOperation alloc]initWithDelegate:self];
    cloudOP.mineType = @"image/jpeg";
    [cloudOP CloudToDo:DOWNLOAD path:_path uploadPath:nil container:self.imageView authorId:nil];
}

-(void)uploadPhoto
{
    self.isUpload = YES;
    UIImage* compressedImage = self.uploadImage;
    NSData* imageData = UIImageJPEGRepresentation(compressedImage, 1.0);
    BOOL flag = YES;
    float adjustWidth = 640.0;
    while (flag) {
        if (compressedImage.size.width> adjustWidth) {
            CGSize imagesize=CGSizeMake(adjustWidth, compressedImage.size.height * adjustWidth/compressedImage.size.width);
            compressedImage = [compressedImage imageByScalingToSize:imagesize];
            imageData = UIImageJPEGRepresentation(compressedImage, 1.0);
        }
        float para = 1.0;
        int restOp = 5;
        while (imageData.length > 100000) {
            imageData = UIImageJPEGRepresentation(compressedImage, para*0.5);
            compressedImage = [UIImage imageWithData:imageData];
            if (!restOp--) {
                adjustWidth *= 2/3;
                break;
            }
        }
        if (imageData.length < 100000) {
            flag = NO;
        }
    }
    

    
    
    NSDateFormatter * formatter = [[NSDateFormatter alloc ] init];
    [formatter setDateFormat:[NSString stringWithFormat:@"%@YYYYMMddHHmmssSSSSS",[MTUser sharedInstance].userid]];
    NSString *date =  [formatter stringFromDate:[NSDate date]];
    NSString *timeLocal = [[NSString alloc] initWithFormat:@"%@", date];
    
    self.path = [NSString stringWithFormat:@"/images/%@.png",timeLocal];
    self.imgName =[NSString stringWithFormat:@"%@.png",timeLocal];
    NSString *filePath = [NSString stringWithFormat:@"%@/Documents/media%@", NSHomeDirectory(),_path];
    [imageData writeToFile:filePath atomically:YES];

    CloudOperation * cloudOP = [[CloudOperation alloc]initWithDelegate:self];
    cloudOP.mineType = @"image/jpeg";
    cloudOP.shouldRecordProgress = YES;
    NSString* uploadfilePath = filePath;
    dispatch_async(dispatch_get_main_queue(), ^{
        [cloudOP CloudToDo:UPLOAD path:self.path uploadPath:uploadfilePath container:nil authorId:nil];
    });
    
    
}

-(void)uploadAvatar  //type 21
{
    self.isUpload = YES;
    UIImage* compressedImage1 = self.uploadImage;
    UIImage* compressedImage2 = self.uploadImage;
    
    NSData* imageData1 = UIImageJPEGRepresentation(compressedImage1, 1.0);
//    NSData* imageData2 = [[NSData alloc]initWithData:imageData1];
    NSData* imageData2 = UIImageJPEGRepresentation(compressedImage2, 1.0);
    
    if (compressedImage1.size.width> 640) {
        CGSize imagesize=CGSizeMake(640.0, compressedImage1.size.height * 640.0/compressedImage1.size.width);
        compressedImage1 = [compressedImage1 imageByScalingToSize:imagesize];
        imageData1 = UIImageJPEGRepresentation(compressedImage1, 1.0);
    }
    
    if (compressedImage2.size.width> 300) {
        CGSize imagesize=CGSizeMake(300.0, compressedImage2.size.height * 300.0/compressedImage2.size.width);
        compressedImage2 = [compressedImage2 imageByScalingToSize:imagesize];
        imageData2 = UIImageJPEGRepresentation(compressedImage2, 1.0);
    }
    
    float para = 1.0;
    int restOp = 5;
    
//    NSData* imageData_compressed1 = [[NSData alloc]initWithData:imageData1];
//    NSData* imageData_compressed2 = [[NSData alloc]initWithData:imageData2];
    
    while (imageData1.length > 300000) {
        imageData1 = UIImageJPEGRepresentation(compressedImage1, para*0.5);
        compressedImage1 = [UIImage imageWithData:imageData1];
        if (!restOp--) {
            [CommonUtils showSimpleAlertViewWithTitle:@"消息" WithMessage:@"文件太大，不能处理" WithDelegate:nil WithCancelTitle:@"确定"];
            return;
        }
    }
    
    while (imageData2.length > 30000) {
        imageData2 = UIImageJPEGRepresentation(compressedImage2, para*0.5);
        compressedImage2 = [UIImage imageWithData:imageData2];
        if (!restOp--) {
            [CommonUtils showSimpleAlertViewWithTitle:@"消息" WithMessage:@"文件太大，不能处理" WithDelegate:nil WithCancelTitle:@"确定"];
            return;
        }
    }
    
    
    
//    NSDateFormatter * formatter = [[NSDateFormatter alloc ] init];
//    [formatter setDateFormat:[NSString stringWithFormat:@"%@YYYYMMddHHmmssSSSSS",[MTUser sharedInstance].userid]];
//    NSString *date =  [formatter stringFromDate:[NSDate date]];
    NSString *avatarName1 = [[NSString alloc] initWithFormat:@"%@_2", [MTUser sharedInstance].userid];
    NSString* avatarName2 = [NSString stringWithFormat:@"%@",[MTUser sharedInstance].userid];
    NSString* uploadfilePath;
    CloudOperation *cloudOP1 = [[CloudOperation alloc]initWithDelegate:self];
    cloudOP1.mineType = @"image/jpeg";
    CloudOperation* cloudOP2 = [[CloudOperation alloc]initWithDelegate:self];
    cloudOP2.mineType = @"image/jpeg";
    
    self.path = [NSString stringWithFormat:@"/avatar/%@.jpg",avatarName1];
    self.imgName =[NSString stringWithFormat:@"%@.jpg",avatarName1];
    uploadfilePath = [NSString stringWithFormat:@"%@/Documents/media%@", NSHomeDirectory(),_path];
    [imageData1 writeToFile:uploadfilePath atomically:YES];
    
    [cloudOP1 CloudToDo:UPLOAD path:self.path uploadPath:uploadfilePath container:nil authorId:nil];
    
    self.path = [NSString stringWithFormat:@"/avatar/%@.jpg",avatarName2];
    self.imgName =[NSString stringWithFormat:@"%@.jpg",avatarName2];
    uploadfilePath = [NSString stringWithFormat:@"%@/Documents/media%@", NSHomeDirectory(),_path];
    [imageData2 writeToFile:uploadfilePath atomically:YES];
    
    [cloudOP2 CloudToDo:UPLOAD path:self.path uploadPath:uploadfilePath container:nil authorId:nil];
    
   
}




-(void)uploadBanner:(NSNumber*)eventId
{
    self.isUpload = YES;
    UIImage* compressedImage = self.uploadImage;
    NSData* imageData = UIImageJPEGRepresentation(compressedImage, 1.0);
    BOOL flag = YES;
    float adjustWidth = 640.0;
    while (flag) {
        if (compressedImage.size.width> adjustWidth) {
            CGSize imagesize=CGSizeMake(adjustWidth, compressedImage.size.height * adjustWidth/compressedImage.size.width);
            compressedImage = [compressedImage imageByScalingToSize:imagesize];
            imageData = UIImageJPEGRepresentation(compressedImage, 1.0);
        }
        float para = 0.8;
        int restOp = 5;
        while (imageData.length > 50000) {
            imageData = UIImageJPEGRepresentation(compressedImage, para*0.5);
            compressedImage = [UIImage imageWithData:imageData];
            if (!restOp--) {
                adjustWidth *= 2/3;
                break;
            }
        }
        if (imageData.length < 100000) {
            flag = NO;
        }
    }

    
    
    
    
    self.path = [NSString stringWithFormat:@"/banner/%@.jpg",eventId];
    self.imgName =[NSString stringWithFormat:@"%@.jpg",eventId];
    NSString *filePath = [NSString stringWithFormat:@"%@/Documents/media%@", NSHomeDirectory(),_path];
    [imageData writeToFile:filePath atomically:YES];
    
    CloudOperation * cloudOP = [[CloudOperation alloc]initWithDelegate:self];
    cloudOP.mineType = @"image/jpeg";
    NSString* uploadfilePath = filePath;
    [cloudOP CloudToDo:UPLOAD path:self.path uploadPath:uploadfilePath container:nil authorId:nil];
    
}

-(void)uploadVideoThumb
{
    self.isUpload = YES;
    NSDateFormatter * formatter = [[NSDateFormatter alloc ] init];
    [formatter setDateFormat:[NSString stringWithFormat:@"YYYYMMddHHmmssSSSSS%@",[MTUser sharedInstance].userid]];
    NSString *date =  [formatter stringFromDate:[NSDate date]];
    //NSString *timeLocal = [[NSString alloc] initWithFormat:@"%@", date];
    
    self.path = [NSString stringWithFormat:@"/video/%@.mp4.thumb",date];
    self.imgName = nil;
    self.videoName =[NSString stringWithFormat:@"%@.mp4",date];
    NSString* docFolder = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString* filePath = [docFolder stringByAppendingPathComponent:@"tmp.mp4"];
    _videoFilePath = [NSString stringWithString:filePath];
    filePath = [filePath stringByAppendingString:@".thumb"];
    NSData* imageData = UIImageJPEGRepresentation(_uploadImage, 0.5);
    [imageData writeToFile:filePath atomically:YES];
    CloudOperation * cloudOP = [[CloudOperation alloc]initWithDelegate:self];
    cloudOP.mineType = @"image/jpeg";
    NSString* uploadfilePath = filePath;
    [cloudOP CloudToDo:UPLOAD path:self.path uploadPath:uploadfilePath container:nil authorId:nil];
}

-(void)uploadVideo
{
    self.isUpload = YES;
    self.path = [NSString stringWithFormat:@"/video/%@",_videoName];
    self.imgName = _videoName;
    CloudOperation * cloudOP = [[CloudOperation alloc]initWithDelegate:self];
    cloudOP.mineType = @"video/mp4";
    cloudOP.shouldRecordProgress = YES;
    [cloudOP CloudToDo:UPLOAD path:self.path uploadPath:_videoFilePath container:nil authorId:nil];
}

-(NSString*)getLocalAvatarUrl
{
    NSString* url = [[MTUser sharedInstance].avatarURL valueForKey:[NSString stringWithFormat:@"%@",self.avatarId]];
    if (!url) {
        url = [CommonUtils getUrl:[NSString stringWithFormat:@"/avatar/%@.jpg",self.avatarId]];
        [[MTUser sharedInstance].avatarURL setValue:url forKey:[NSString stringWithFormat:@"%@",self.avatarId]];
    }
    return url;
}

-(NSString*)getLocalBannerUrl
{
    NSString* url = [[MTUser sharedInstance].bannerURL valueForKey:[NSString stringWithFormat:@"%@",self.avatarId]];
    if (!url) {
        url = [CommonUtils getUrl:[NSString stringWithFormat:@"/banner/%@.jpg",self.avatarId]];
        [[MTUser sharedInstance].bannerURL setValue:url forKey:[NSString stringWithFormat:@"%@",self.avatarId]];
    }
    return url;
}


-(void)finishwithOperationStatus:(BOOL)status type:(int)type data:(NSData *)mdata path:(NSString *)path
{
    if (self.isUpload) {
        if (status){
            if (self.type == 21) { //上传头像
//                SDImageCache* cache = [SDImageCache sharedImageCache];
//                [cache removeImageForKey:path];
                NSLog(@"removed image path: %@",path);
                
                NSString* avatarUrl =[CommonUtils getUrl:path];
                [[SDImageCache sharedImageCache] removeImageForKey:avatarUrl withCompletition:^{
                    NSLog(@"removed image url: %@",avatarUrl);
                }];
                
                NSMutableDictionary* json_dic = [CommonUtils packParamsInDictionary:
                                                 [MTUser sharedInstance].userid, @"id",
                                                 [NSNumber numberWithInteger:1], @"operation", nil];
                NSData* json_data = [NSJSONSerialization dataWithJSONObject:json_dic options:NSJSONWritingPrettyPrinted error:nil];
                HttpSender* http = [[HttpSender alloc]initWithDelegate:self];
                [http sendMessage:json_data withOperationCode:UPDATE_AVATAR finshedBlock:^(NSData *rData) {
                    
                    NSString* temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
                    NSLog(@"Received Data: %@",temp);
                    NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
                    NSNumber *cmd = [response1 valueForKey:@"cmd"];
                    if ([cmd integerValue] == NORMAL_REPLY) {
                        if (updateAvatarFlag) {
                            
                            if (updateAvatarViewController && [updateAvatarViewController isKindOfClass:[UserInfoViewController class]]) {
                                [(UserInfoViewController*)updateAvatarViewController refresh];
                                
                            }
                            [(MenuViewController*)([SlideNavigationController sharedInstance].leftMenu) refresh];
                            NSLog(@"上传头像后刷新");
                            
                            UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"头像上传成功" delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
                            [alertView show];
                            [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(alertViewDismiss:) userInfo:alertView repeats:YES];
                        }
                        updateAvatarFlag = !updateAvatarFlag;
                    }
                }];

            }
            else if (self.type == 22)
            {
                NSLog(@"removed image path: %@",path);
                
                NSString* avatarUrl =[CommonUtils getUrl:path];
                [[SDImageCache sharedImageCache] removeImageForKey:avatarUrl withCompletition:^{
                    NSLog(@"removed image url: %@",avatarUrl);
                }];
                
                NSMutableDictionary* json_dic = [CommonUtils packParamsInDictionary:
                                                 [MTUser sharedInstance].userid, @"id",
                                                 [NSNumber numberWithInteger:1], @"operation", nil];
                NSData* json_data = [NSJSONSerialization dataWithJSONObject:json_dic options:NSJSONWritingPrettyPrinted error:nil];
                HttpSender* http = [[HttpSender alloc]initWithDelegate:self];
                [http sendMessage:json_data withOperationCode:UPDATE_AVATAR finshedBlock:^(NSData *rData) {
                    
                    NSString* temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
                    NSLog(@"Received Data: %@",temp);
                    NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
                    NSNumber *cmd = [response1 valueForKey:@"cmd"];
                    if ([cmd integerValue] == NORMAL_REPLY) {
                        if (updateAvatarFlag) {
                            
                            if (updateAvatarViewController && [updateAvatarViewController isKindOfClass:[FillinInfoViewController class]]) {
//                                [(UserInfoViewController*)updateAvatarViewController refresh];
                                [[(FillinInfoViewController*)updateAvatarViewController info_tableview] reloadData];
                                
                            }
                            [(MenuViewController*)([SlideNavigationController sharedInstance].leftMenu) refresh];
                            NSLog(@"上传头像后刷新");
                            
                            UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"头像上传成功" delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
                            [alertView show];
                            [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(alertViewDismiss:) userInfo:alertView repeats:YES];
                        }
                        updateAvatarFlag = !updateAvatarFlag;
                    }
                }];

            }
            if (!_imgName) {
                [self uploadVideo];
            }else [self.mDelegate finishwithNotification:nil image:nil type:100 container:self.imgName];
        }else{
            [self.mDelegate finishwithNotification:nil image:nil type:106 container:self.imgName];
        }
        return;
    }
}

-(void)alertViewDismiss:(NSTimer*)timer
{
    [[timer userInfo] dismissWithClickedButtonIndex:0 animated:YES];
}
@end

