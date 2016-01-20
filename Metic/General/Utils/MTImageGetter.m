//
//  MTImageGetter.m
//  WeShare
//
//  Created by 俊健 on 15/9/16.
//  Copyright (c) 2015年 WeShare. All rights reserved.
//

#import "MTImageGetter.h"
#import "MegUtils.h"
#import "UIImageView+MTTag.h"
#import "UIImage+UIImageExtras.h"
#import "MTOperation.h"

@interface MTImageGetter ()
@property (nonatomic, weak) UIImageView *imageView;
@property (nonatomic, strong) NSNumber *imageId;
@property (nonatomic, strong) NSString *imageName;
@property (nonatomic, strong) NSString *path;
@property (nonatomic) MTImageGetterType type;
@end

@implementation MTImageGetter

-(instancetype)initWithImageView:(UIImageView*)imageView imageId:(NSNumber *)imageId imageName:(NSString *)imageName type:(MTImageGetterType)type
{
    if (self) {
        self = [super init];
        self.imageView = imageView;
        self.imageId = imageId;
        self.imageName = imageName;
        self.type = type;
        [self setupPath];
    }
    return self;
}

-(void)setupPath
{
    if (self.imageId || self.imageName) {
        switch (self.type) {
            case MTImageGetterTypeAvatar:
                self.path = [MegUtils avatarImagePathWithUserId:self.imageId];
                break;
            case MTImageGetterTypePhoto:
                self.path = [MegUtils photoImagePathWithImageName:self.imageName];
                break;
            case MTImageGetterTypeVideoThumb:
                self.path = [MegUtils videoThummbImagePathWithVideoName:self.imageName];
                break;
                
            default:
                break;
        }
    }
}

-(void)getImage {
    [self getImageFitSize:NO Complete:NULL];
}

-(void)getImageFitSize {
    [self getImageFitSize:YES Complete:NULL];
}

-(void)getImageComplete:(MTImageGetterCompletionBlock)completedBlock {
    [self getImageFitSize:NO Complete:completedBlock];
}

-(void)getImageFitSize:(BOOL)fitSize Complete:(MTImageGetterCompletionBlock)completedBlock
{
    [self.imageView sd_cancelCurrentImageLoad];
    static UIImage *defaultPhotoImg;
    static UIImage *defaultPhotoFailImg;
    static UIImage *defaultAvatarImg;
    static UIImage *defaultAvatarFailImg;
    static UIImage *defaultVideoThumbImg;
    static UIImage *defaultVideoThumbFailImg;
    if (!defaultPhotoImg) {
        defaultPhotoImg = [UIImage imageNamed:@"活动图片的默认图片"];
    }
    if (!defaultPhotoFailImg) {
        defaultPhotoFailImg = [UIImage imageNamed:@"加载失败"];
    }
    
    if (!defaultAvatarImg) {
        defaultAvatarImg = [UIImage imageNamed:@"默认用户头像"];
    }
    if (!defaultAvatarFailImg) {
        defaultAvatarFailImg = [UIImage imageNamed:@"默认用户头像"];
    }
    
    if (!defaultVideoThumbImg) {
        defaultVideoThumbImg = nil;
    }
    if (!defaultVideoThumbFailImg) {
        defaultVideoThumbFailImg = nil;
    }
    
    UIImage *placeHolder = nil;
    UIImage *placeHolderFail = nil;
    switch (self.type) {
        case MTImageGetterTypeAvatar:
            placeHolder = defaultAvatarImg;
            placeHolderFail = defaultAvatarFailImg;
            break;
        case MTImageGetterTypePhoto:
            placeHolder = defaultPhotoImg;
            placeHolderFail = defaultPhotoFailImg;
            break;
        case MTImageGetterTypeVideoThumb:
            placeHolder = defaultVideoThumbImg;
            placeHolderFail = defaultVideoThumbFailImg;
            break;
            
        default:
            break;
    }
    
    if(![self.imageView.downloadName isEqualToString:self.imageName]){
        self.imageView.image = placeHolder;
        self.imageView.downloadName = self.imageName;
        [self.imageView setContentMode:UIViewContentModeScaleAspectFit];
    }else return;
    
    if (fitSize) {
        [[MTOperation sharedInstance] checkPhotoFromServer:self.path size:self.imageView.bounds.size success:^(NSString *scalePath) {
            if (![self.imageView.downloadName isEqualToString:self.imageName])
                return ;
            [self.imageView sd_setImageWithURL:[NSURL URLWithString:scalePath] placeholderImage:placeHolder cloudPath:self.path completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                if (completedBlock) {
                    completedBlock(image,error,cacheType,imageURL);
                }else {
                    if (image) {
                        [self.imageView setContentMode:UIViewContentModeScaleAspectFill];
                    }else{
                        self.imageView.image = placeHolderFail;
                    }
                }
                
            }];
        } failure:^(NSString *savePath, CGSize saveSize) {
            if (!savePath) {
                return ;
            }
            [[MTOperation sharedInstance] getUrlFromServer:self.path success:^(NSString *url) {
                if (![self.imageView.downloadName isEqualToString:self.imageName])
                    return ;
                [self.imageView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:placeHolder cloudPath:self.path completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    if (![self.imageView.downloadName isEqualToString:self.imageName])
                        return ;

                    if (completedBlock) {
                        completedBlock(image,error,cacheType,imageURL);
                    }else {
                        if (image) {
                            [self.imageView setContentMode:UIViewContentModeScaleAspectFill];
                        }else{
                            self.imageView.image = placeHolderFail;
                        }
                    }

                    dispatch_async(dispatch_get_global_queue(0, 0), ^{
                        UIImage *thumbImage = [image imageByScalingToSize:saveSize];
                        [[SDImageCache sharedImageCache] storeImage:thumbImage forKey:savePath];
                    });
                }];
            } failure:^(NSString *message) {
                if (![self.imageView.downloadName isEqualToString:self.imageName])
                    return ;
                MTLOG(@"%@",message);
            }];
        }];
    } else {
        [[MTOperation sharedInstance] getUrlFromServer:self.path success:^(NSString *url) {
            if (![self.imageView.downloadName isEqualToString:self.imageName])
                return ;
            [self.imageView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:placeHolder cloudPath:self.path completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                
                if (completedBlock) {
                    completedBlock(image,error,cacheType,imageURL);
                }else {
                    if (image) {
                        [self.imageView setContentMode:UIViewContentModeScaleAspectFill];
                    }else{
                        self.imageView.image = placeHolderFail;
                    }
                }
                
            }];
        } failure:^(NSString *message) {
            if (![self.imageView.downloadName isEqualToString:self.imageName])
                return ;
            MTLOG(@"%@",message);
        }];
    }
}

- (UIImage *)thumbnailWithImageWithoutScale:(UIImage *)image size:(CGSize)asize

{
    
    UIImage *newimage;
    
    if (nil == image) {
        
        newimage = nil;
        
    }
    
    else{
        
        CGSize oldsize = image.size;
        
        CGRect rect;
        
        if (asize.width/asize.height > oldsize.width/oldsize.height) {
            
            rect.size.width = asize.height*oldsize.width/oldsize.height;
            
            rect.size.height = asize.height;
            
            rect.origin.x = (asize.width - rect.size.width)/2;
            
            rect.origin.y = 0;
            
        }
        
        else{
            
            rect.size.width = asize.width;
            
            rect.size.height = asize.width*oldsize.height/oldsize.width;
            
            rect.origin.x = 0;
            
            rect.origin.y = (asize.height - rect.size.height)/2;
            
        }
        
        NSLog(@"%f %f",asize.width,asize.height);
        
        UIGraphicsBeginImageContext(asize);
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
        
        UIRectFill(CGRectMake(0, 0, asize.width, asize.height));//clear background
        
        [image drawInRect:rect];
        
        newimage = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
    }
    
    return newimage;
    
}

@end
