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
    

    NSString*url = [self getLocalUrl];
    if (url) {
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"默认用户头像"]];
    }else{
        CloudOperation * cloudOP = [[CloudOperation alloc]initWithDelegate:self];
        [cloudOP CloudToDo:DOWNLOAD path:_path uploadPath:nil container:self.imageView authorId:self.avatarId];
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
    if (imageData.length > 800000) {
        CGSize imagesize=CGSizeMake(640.0, compressedImage.size.height * 640.0/compressedImage.size.width);
        compressedImage = [compressedImage imageByScalingToSize:imagesize];
        imageData = UIImageJPEGRepresentation(compressedImage, 1.0);
    }
    float para = 0.75;
    while (imageData.length > 100000) {
        imageData = UIImageJPEGRepresentation(compressedImage, para*0.5);
        compressedImage = [UIImage imageWithData:imageData];
    }

    
    
    NSDateFormatter * formatter = [[NSDateFormatter alloc ] init];
    [formatter setDateFormat:[NSString stringWithFormat:@"%@YYYYMMddhhmmssSSSSS",[MTUser sharedInstance].userid]];
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

-(NSString*)getLocalUrl
{
    NSString* url;
    url = [[MTUser sharedInstance].avatarURL valueForKey:[NSString stringWithFormat:@"%@",self.avatarId]];
    return url;
}

@end

