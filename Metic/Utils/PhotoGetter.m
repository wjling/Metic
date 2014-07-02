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


- (instancetype)initWithData:(UIImageView*)animageView path:(NSString*)path type:(int)type cache:(NSMutableDictionary*)cache isCircle:(BOOL)isCircle borderColor:(UIColor*)borderColor borderWidth:(CGFloat) borderWidth
{
    if (self) {
        self = [super init];
        self.user = [MTUser sharedInstance];
        self.imageView = animageView;
        self.path = path;
        self.filePath = [NSString stringWithFormat:@"%@/Documents/media%@", NSHomeDirectory(),_path];
        self.type = type;
        switch (type) {
            case 1://头像
                self.phothCache = _user.avatar;
                break;
            case 2://照片
                self.phothCache = cache;
                break;
            default:
                break;
        }
        self.isCircle = isCircle;
        self.borderColor = borderColor;
        self.borderWidth = borderWidth;
        
    }
    return self;
}

-(void)getPhoto
{
    //缓存
    UIImage *cacheAvatar = [_phothCache valueForKey:_path];
    if (cacheAvatar) {
        if (self.isCircle) {
            cacheAvatar = [CommonUtils circleImage:cacheAvatar withParam:0 borderColor:_borderColor borderWidth:_borderWidth];
        }else{
            _imageView.layer.cornerRadius = 3;
            _imageView.layer.masksToBounds = YES;
        }
        _imageView.image = cacheAvatar;
        if (self.type == 2) {
            [self.mDelegate finishwithNotification:self.tableView indexPath:self.index];
        }
    }else{
        //NSString *filePath = [NSString stringWithFormat:@"%@/Documents/media%@", NSHomeDirectory(),_path];
        if ([[NSFileManager defaultManager] fileExistsAtPath:_filePath]) {
            //本地内存
            UIImage *memoryAvatar = [UIImage imageWithContentsOfFile:_filePath];
            if (memoryAvatar) {
                [_phothCache setValue:memoryAvatar forKey:_path];
                if (self.isCircle) {
                    memoryAvatar = [CommonUtils circleImage:memoryAvatar withParam:0 borderColor:_borderColor borderWidth:_borderWidth];
                }else{
                    _imageView.layer.cornerRadius = 3;
                    _imageView.layer.masksToBounds = YES;
                }
                _imageView.image = memoryAvatar;
                
            }
            
            if (self.type == 2) {
                [self.mDelegate finishwithNotification:self.tableView indexPath:self.index];
            }
        }else{
            _imageView.image = [UIImage imageNamed:@"default_avatar.jpg"];
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
        
        UIImage *netAvatar = [UIImage imageWithData:mdata];
        //UIImage *netAvatar = [UIImage imageWithContentsOfFile:_filePath];
        if (netAvatar) {
            [_phothCache setValue:netAvatar forKey:_path];
            if (self.isCircle) {
                netAvatar = [CommonUtils circleImage:netAvatar withParam:0 borderColor:_borderColor borderWidth:_borderWidth];
            }else{
                _imageView.layer.cornerRadius = 3;
                _imageView.layer.masksToBounds = YES;
            }
            _imageView.image = netAvatar;
            
        }
        if (self.type == 2) {
            [self.mDelegate finishwithNotification:self.tableView indexPath:self.index];
        }
    }
    else{
        UIImage *defaultAvatar = [UIImage imageNamed:@"default_avatar.jpg"];
        if (defaultAvatar) {
            [_phothCache setValue:defaultAvatar forKey:_path];
            if (self.isCircle) {
                defaultAvatar = [CommonUtils circleImage:defaultAvatar withParam:0 borderColor:_borderColor borderWidth:_borderWidth];
            }else{
                _imageView.layer.cornerRadius = 3;
                _imageView.layer.masksToBounds = YES;
            }
            _imageView.image = defaultAvatar;
            
        }
        if (self.type == 2) {
            [self.mDelegate finishwithNotification:self.tableView indexPath:self.index];
        }

    }
}


@end

