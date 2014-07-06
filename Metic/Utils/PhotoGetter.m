//
//  PhotoGetter.m
//  Metic
//
//  Created by ligang_mac4 on 14-6-26.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "PhotoGetter.h"
#import "CommonUtils.h"

@interface PhotoGetter ()
@property(nonatomic,strong) UIImage* uploadImage;
@property(nonatomic,strong) NSString* imgName;
@property BOOL isUpload;

@end


@implementation PhotoGetter


- (instancetype)initWithData:(UIImageView*)animageView path:(NSString*)path type:(int)type cache:(NSMutableDictionary*)cache
{
    if (self) {
        self = [super init];
        self.user = [MTUser sharedInstance];
        self.imageView = animageView;
        self.path = path;
        self.filePath = [NSString stringWithFormat:@"%@/Documents/media%@", NSHomeDirectory(),_path];
        self.type = type;
        self.phothCache = cache;
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




-(void)setTypeOption1:(UIColor*)borderColor borderWidth:(CGFloat) borderWidth avatarId:(NSNumber*) avatarId
{
    self.avatarId = avatarId;
    self.borderColor = borderColor;
    self.borderWidth = borderWidth;
}

-(void)setTypeOption2:(NSNumber*) avatarId
{
    self.avatarId = avatarId;
    _imageView.layer.cornerRadius = 3;
    _imageView.layer.masksToBounds = YES;
}

-(void)setTypeOption3:(id)container
{
    self.container = container;
}


-(void)getPhoto
{
    //缓存
    UIImage *imageFromCache = [_phothCache valueForKey:_path];
    if (imageFromCache){
        switch (self.type) {
            case 1:
                imageFromCache = [CommonUtils circleImage:imageFromCache withParam:0 borderColor:_borderColor borderWidth:_borderWidth];
                self.container = nil;
                break;
            case 2:
                self.container = nil;
                break;
            case 3:
                
                break;
                
            default:
                break;
        }
        [self.mDelegate finishwithNotification:self.imageView image:imageFromCache type:self.type container:self.container];
    }else{
        //NSString *filePath = [NSString stringWithFormat:@"%@/Documents/media%@", NSHomeDirectory(),_path];
        if ([[NSFileManager defaultManager] fileExistsAtPath:_filePath]) {
            //本地内存
            UIImage *imageFromMemory = [UIImage imageWithContentsOfFile:_filePath];
            if (imageFromMemory) {
                [_phothCache setValue:imageFromMemory forKey:_path];
                switch (self.type) {
                    case 1:
                        imageFromMemory = [CommonUtils circleImage:imageFromMemory withParam:0 borderColor:_borderColor borderWidth:_borderWidth];
                        self.container = nil;
                        break;
                    case 2:
                        self.container = nil;
                        break;
                    case 3:
                        
                        break;
                        
                    default:
                        break;
                }
                [self.mDelegate finishwithNotification:self.imageView image:imageFromMemory type:self.type container:self.container];
            }
        }else{
            
            //网络下载
            CloudOperation * cloudOP = [[CloudOperation alloc]initWithDelegate:self];
            [cloudOP CloudToDo:DOWNLOAD path:_path uploadPath:nil];
        }
        
    }
}

-(void)updatePhoto
{
    CloudOperation * cloudOP = [[CloudOperation alloc]initWithDelegate:self];
    [cloudOP CloudToDo:DOWNLOAD path:_path uploadPath:nil];
}

-(void)uploadPhoto
{
    self.isUpload = YES;
    UIImage* compressedImage = self.uploadImage;
    NSData* imageData = UIImageJPEGRepresentation(compressedImage, 1.0);
    while (imageData.length > 100000) {
        imageData = UIImageJPEGRepresentation(compressedImage, 0.7);
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
    [cloudOP CloudToDo:UPLOAD path:self.path uploadPath:uploadfilePath];
    
}

-(void)finishwithOperationStatus:(BOOL)status type:(int)type data:(NSData *)mdata path:(NSString *)path
{
    if (self.isUpload) {
        if (status){
            [self.mDelegate finishwithNotification:nil image:nil type:100 container:self.imgName];
        }else{
            [self.mDelegate finishwithNotification:nil image:nil type:106 container:self.imgName];
        }
    }
    if (mdata) {
        NSString *filePath = [NSString stringWithFormat:@"%@/Documents/media%@", NSHomeDirectory(),_path];
        [UIImageJPEGRepresentation([UIImage imageWithData:mdata], 1.0f) writeToFile:filePath atomically:YES];
        
        UIImage *imageFromAir = [UIImage imageWithData:mdata];
        //UIImage *netAvatar = [UIImage imageWithContentsOfFile:_filePath];
        if (imageFromAir) {
            [_phothCache setValue:imageFromAir forKey:_path];
            switch (self.type) {
                case 1:
                    imageFromAir = [CommonUtils circleImage:imageFromAir withParam:0 borderColor:_borderColor borderWidth:_borderWidth];
                    [self.mDelegate finishwithNotification:self.imageView image:imageFromAir type:self.type container:self.container];
                    break;
                case 2:
                    [self.mDelegate finishwithNotification:self.imageView image:imageFromAir type:self.type container:self.container];
                    break;
                case 3:
                    [self.mDelegate finishwithNotification:self.imageView image:imageFromAir type:self.type container:self.container];
                    break;
                default:
                    break;
            }
        }
        
    }else{
        UIImage* tmpAvatar = [UIImage imageNamed:@"默认用户头像"];
        UIImage* tmpPhoto = [UIImage imageNamed:@"活动图片的默认图片"];
        
        switch (self.type) {
            case 1:
                [_phothCache setValue:tmpAvatar forKey:_path];
                tmpAvatar = [CommonUtils circleImage:tmpAvatar withParam:0 borderColor:_borderColor borderWidth:1];
                [self.mDelegate finishwithNotification:self.imageView image:tmpAvatar type:self.type container:nil];
                break;
            case 2:
                [_phothCache setValue:tmpAvatar forKey:_path];
                [self.mDelegate finishwithNotification:self.imageView image:tmpAvatar type:self.type container:nil];
                break;
            case 3:
                [_phothCache setValue:tmpPhoto forKey:_path];
                [self.mDelegate finishwithNotification:self.imageView image:tmpPhoto type:self.type container:self.container];
                break;
                
            default:
                break;
        }

    }
}


@end

