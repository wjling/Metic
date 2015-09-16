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
    static UIImage *defaultImg;
    static UIImage *defaultFailImg;
    if (!defaultImg) {
        defaultImg = [UIImage imageNamed:@"活动图片的默认图片"];
    }
    if (!defaultFailImg) {
        defaultFailImg = [UIImage imageNamed:@"加载失败"];
    }
    self.imageView.downloadName = self.imageName;
    self.imageView.image = defaultImg;
    [self.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [[MTOperation sharedInstance]getUrlFromServer:self.path success:^(NSString *url) {
        if (![self.imageView.downloadName isEqualToString:self.imageName])
            return ;
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:defaultImg cloudPath:self.path completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (completedBlock) {
                completedBlock(image,error,cacheType,imageURL);
            }else {
                if (image) {
                    [self.imageView setContentMode:UIViewContentModeScaleAspectFill];
                }else{
                    self.imageView.image = defaultFailImg;
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
