//
//  PhotoGetter.m
//  Metic
//
//  Created by ligang_mac4 on 14-6-26.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "PhotoGetter.h"
#import "CommonUtils.h"



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
        if (type == 2) {
            [self setTypeOption2];
        }
        self.phothCache = cache;
    }
    return self;
}



-(void)setTypeOption1:(UIColor*)borderColor borderWidth:(CGFloat) borderWidth
{
    self.borderColor = borderColor;
    self.borderWidth = borderWidth;
}

-(void)setTypeOption2
{
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
                break;
            case 2:
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
                        break;
                    case 2:
                        break;
                    case 3:
                        
                        break;
                        
                    default:
                        break;
                }
                [self.mDelegate finishwithNotification:self.imageView image:imageFromMemory type:self.type container:self.container];
            }
        }else{
            UIImage* tmpAvatar = [UIImage imageNamed:@"default_avatar.jpg"];
            UIImage* tmpPhoto = [UIImage imageNamed:@"活动图片的默认图片"];
            
            switch (self.type) {
                case 1:
                    tmpAvatar = [CommonUtils circleImage:tmpAvatar withParam:0 borderColor:_borderColor borderWidth:_borderWidth];
                    [self.mDelegate finishwithNotification:self.imageView image:tmpAvatar type:self.type container:self.container];
                    break;
                case 2:
                    [self.mDelegate finishwithNotification:self.imageView image:tmpAvatar type:self.type container:self.container];
                    break;
                case 3:
                    [self.mDelegate finishwithNotification:self.imageView image:tmpPhoto type:self.type container:self.container];
                    break;
                    
                default:
                    break;
            }
            //_imageView.image = [UIImage imageNamed:@"default_avatar.jpg"];
            //网络下载
            CloudOperation * cloudOP = [[CloudOperation alloc]initWithDelegate:self];
            [cloudOP CloudToDo:DOWNLOAD path:_path uploadPath:nil];
        }
        
    }
}
-(void)finishwithOperationStatus:(BOOL)status type:(int)type data:(NSData *)mdata path:(NSString *)path
{
    
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
                    break;
                case 2:
                    break;
                case 3:
                    break;
                default:
                    break;
            }
            [self.mDelegate finishwithNotification:self.imageView image:imageFromAir type:self.type container:self.container];
        }
    }
}


@end

