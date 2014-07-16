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

@interface PhotoGetter ()
@property(nonatomic,strong) UIImage* uploadImage;
@property(nonatomic,strong) NSString* imgName;
@property BOOL isUpload;

@end


@implementation PhotoGetter


- (instancetype)initWithData:(UIImageView*)animageView authorId:(NSNumber*)authorId //type:(int)type cache:(NSMutableDictionary*)cache
{
    if (self) {
        self = [super init];
        self.user = [MTUser sharedInstance];
        self.imageView = animageView;
        self.avatarId = authorId;
        self.path = [NSString stringWithFormat:@"/avatar/%@.jpg",authorId];
        self.isUpload = NO;
    }
    return self;
}

- (instancetype)initUploadMethod:(UIImage*)aImage type:(int)type
{
    if (self) {
        self = [super init];
        self.user = [MTUser sharedInstance];
        self.uploadImage = aImage;
        self.type = type;
    }
    return self;
}



-(void)getPhoto
{
//    UIImage *image = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:_path];
//    if (!image) {
//        image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:_path];
//    }
//    if (image) {
//        self.imageView.image = image;
//    }
    NSString*url = [self getLocalAvatarUrl];
    if (url) {
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"默认用户头像"]];
    }
    else{
        CloudOperation * cloudOP = [[CloudOperation alloc]initWithDelegate:self];
        [cloudOP CloudToDo:DOWNLOAD path:_path uploadPath:nil container:self.imageView authorId:self.avatarId];
    }

}


-(void)getBanner
{
//    self.path = [self.path stringByReplacingOccurrencesOfString:@"avatar" withString:@"banner"];
//    UIImage *image = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:_path];
//    if (!image) {
//        image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:_path];
//    }
//    if (image) {
//        self.imageView.image = image;
//    }
    self.path = [self.path stringByReplacingOccurrencesOfString:@"avatar" withString:@"banner"];
    NSString*url = [self getLocalBannerUrl];
    if (url) {
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"event.png"]];
    }
    else{
        CloudOperation * cloudOP = [[CloudOperation alloc]initWithDelegate:self];
        [cloudOP CloudToDo:DOWNLOAD path:_path uploadPath:@"" container:self.imageView authorId:self.avatarId];
    }
    
}



-(void)updatePhoto
{
    CloudOperation * cloudOP = [[CloudOperation alloc]initWithDelegate:self];
    [cloudOP CloudToDo:DOWNLOAD path:_path uploadPath:nil container:self.imageView authorId:nil];
}

-(void)uploadPhoto
{
    self.isUpload = YES;
    UIImage* compressedImage = self.uploadImage;
    NSData* imageData = UIImageJPEGRepresentation(compressedImage, 1.0);
    if (compressedImage.size.width> 640) {
        CGSize imagesize=CGSizeMake(640.0, compressedImage.size.height * 640.0/compressedImage.size.width);
        compressedImage = [compressedImage imageByScalingToSize:imagesize];
        imageData = UIImageJPEGRepresentation(compressedImage, 1.0);
    }
    float para = 1.0;
    int restOp = 5;
    while (imageData.length > 100000) {
        imageData = UIImageJPEGRepresentation(compressedImage, para*0.5);
        compressedImage = [UIImage imageWithData:imageData];
        if (!restOp--) {
            [CommonUtils showSimpleAlertViewWithTitle:@"消息" WithMessage:@"文件太大，不能处理" WithDelegate:nil WithCancelTitle:@"确定"];
            return;
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
    NSString* uploadfilePath = filePath;
    [cloudOP CloudToDo:UPLOAD path:self.path uploadPath:uploadfilePath container:nil authorId:nil];
    
}

//-(NSString*)getLocalUrl
//{
//    MySqlite* sql = [[MySqlite alloc]init];
//    NSString* url;
//    NSString * path = [NSString stringWithFormat:@"%@/db",[MTUser sharedInstance].userid];
//    [sql openMyDB:path];
//
//    NSArray *seletes = [[NSArray alloc]initWithObjects:@"url", nil];
//    NSDictionary *wheres = [[NSDictionary alloc] initWithObjectsAndKeys:self.avatarId,@"id", nil];
//    NSMutableArray *results = [self.sql queryTable:@"avatar" withSelect:seletes andWhere:wheres];
//    if (!results.count) {
//        url = nil;
//    }else{
//        NSDictionary* result = results[0];
//        url = [result valueForKey:@"url"];
//    }
//    
//    [self.sql closeMyDB];
//    return url;
//
//}

-(NSString*)getLocalAvatarUrl
{
    NSString* url;
    url = [[MTUser sharedInstance].avatarURL valueForKey:[NSString stringWithFormat:@"%@",self.avatarId]];
    return url;
}

-(NSString*)getLocalBannerUrl
{
    NSString* url;
    url = [[MTUser sharedInstance].bannerURL valueForKey:[NSString stringWithFormat:@"%@",self.avatarId]];
    return url;
}


-(void)finishwithOperationStatus:(BOOL)status type:(int)type data:(NSData *)mdata path:(NSString *)path
{
    if (self.isUpload) {
        if (status){
            [self.mDelegate finishwithNotification:nil image:nil type:100 container:self.imgName];
        }else{
            [self.mDelegate finishwithNotification:nil image:nil type:106 container:self.imgName];
        }
        return;
    }
}
@end

