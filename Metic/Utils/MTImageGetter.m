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

-(void)getImage
{
    [self getImageComplete:NULL];
}

-(void)getImageComplete:(MTImageGetterCompletionBlock)completedBlock
{
    [self.imageView sd_cancelCurrentAnimationImagesLoad];
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
            placeHolder = defaultAvatarImg;
            placeHolderFail = defaultAvatarFailImg;
            break;
        case MTImageGetterTypeVideoThumb:
            placeHolder = defaultVideoThumbImg;
            placeHolderFail = defaultVideoThumbFailImg;
            break;
            
        default:
            break;
    }
    self.imageView.downloadName = self.imageName;
    self.imageView.image = placeHolder;
    [self.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [[MTOperation sharedInstance]getUrlFromServer:self.path success:^(NSString *url) {
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
        NSLog(@"%@",message);
    }];
}

@end
