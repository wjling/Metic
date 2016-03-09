//
//  MTPhotoInfoView.m
//  WeShare
//
//  Created by 俊健 on 16/3/3.
//  Copyright © 2016年 WeShare. All rights reserved.
//

#import "MTMediaInfoView.h"
#import "MTUser.h"
#import "MTImageGetter.h"
#import "PhotoGetter.h"
#import "SocialSnsApi.h"
#import "UMSocial.h"
#import "SlideNavigationController.h"
#import "Reachability.h"

@interface MTMediaInfoView () <UMSocialUIDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (strong, nonatomic) IBOutlet UILabel *authorLabel;
@property (strong, nonatomic) IBOutlet UILabel *publishTimeLabel;

@property (strong, nonatomic) NSMutableDictionary *mediaInfo;

@property (nonatomic) MTMediaType type;

@end

@implementation MTMediaInfoView

- (void)awakeFromNib {
    
    self.avatarImageView.layer.cornerRadius = 4;
    self.avatarImageView.layer.masksToBounds = YES;
    
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    [self setBackgroundColor:[UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0]];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

//加载数据
- (void)applyData:(NSMutableDictionary *)data type:(MTMediaType)type containerWidth:(CGFloat)width {
    
    _mediaInfo = data;
    _type = type;
    
    //avatar
    PhotoGetter *getter = [[PhotoGetter alloc]initWithData:self.avatarImageView authorId:[self.mediaInfo valueForKey:@"author_id"]];
    [getter getAvatar];
    
    //imageView
    MTImageGetter *imageGetter;
    if (type == MTMediaTypePhoto) {
        imageGetter = [[MTImageGetter alloc]initWithImageView:self.photoView imageId:nil imageName:self.mediaInfo[@"photo_name"] type:MTImageGetterTypePhoto];
        self.playIcon.hidden = YES;
    } else {
        imageGetter = [[MTImageGetter alloc]initWithImageView:self.photoView imageId:nil imageName:self.mediaInfo[@"video_name"] type:MTImageGetterTypeVideoThumb];
        self.playIcon.hidden = NO;
    }
    
    [imageGetter getImageComplete:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (image) {
            [self.photoView setContentMode:UIViewContentModeScaleAspectFill];
            if (type == MTMediaTypePhoto) {
                self.photo = image;
            }
        }else{
            if (type == MTMediaTypePhoto) {
                [self.photoView setContentMode:UIViewContentModeScaleAspectFit];
                self.photoView.image = [UIImage imageNamed:@"加载失败"];
            }
        }
    }];
    
    NSArray *constraints = self.photoView.superview.constraints;
    for (NSLayoutConstraint *constraint in constraints) {
        if ([[constraint identifier] isEqualToString:@"photoHeight"]) {
            constraint.constant = [MTMediaInfoView calculatePhotoHeightwithMediaInfo:self.mediaInfo type:type containerWidth:width];

            break;
        }
    }

    //author
    //显示备注名
    NSString* alias = [MTOperation getAliasWithUserId:self.mediaInfo[@"author_id"] userName:self.mediaInfo[@"author"]];
    self.authorLabel.text = alias;
    
    //time
    NSString *time = [self.mediaInfo valueForKey:@"time"];
    if (time.length > 10) {
        time = [time substringToIndex:10];
    }
    self.publishTimeLabel.text = time;
    
    //description
    self.descriptionLabel.text = [MTMediaInfoView mediaDescription:self.mediaInfo type:self.type];
    
    //likeBtn
    [self setupLikeButton];

}

+ (NSString *)mediaDescription:(NSMutableDictionary *)mediaInfo type:(MTMediaType)type {
    //description
    NSString *description;
    if (type == MTMediaTypePhoto) {
        description = [mediaInfo valueForKey:@"specification"];
    } else {
        description = [mediaInfo valueForKey:@"title"];
    }
    if (description.length == 0) {
        description = @"暂无描述";
    }
    return description;
}

- (void)setupLikeButton {
    if (self.mediaInfo && [[self.mediaInfo valueForKey:@"isZan"] boolValue]) {
        [self.likeBtn setImage:[UIImage imageNamed:@"icon_detail_like_yes"] forState:UIControlStateNormal];
    }else [self.likeBtn setImage:[UIImage imageNamed:@"icon_detail_like_no"] forState:UIControlStateNormal];
}

+ (float)calculateCellHeightwithMediaInfo:(NSMutableDictionary *)mediaInfo type:(MTMediaType)type containerWidth:(CGFloat)width {
    CGFloat height = 0;
    NSString *description = [self mediaDescription:mediaInfo type:type];
    CGFloat descriptionHeight = description? [CommonUtils calculateTextHeight:description width:width - 20 fontSize:14.f isEmotion:NO]:0;
    height += descriptionHeight;
    
    CGFloat photoHeight = [self calculatePhotoHeightwithMediaInfo:mediaInfo type:type containerWidth:width];
    height += photoHeight;
    
    height += 45 + 30 + 20 + 5;
    
    return height;
}

+ (float)calculatePhotoHeightwithMediaInfo:(NSMutableDictionary *)mediaInfo type:(MTMediaType)type containerWidth:(CGFloat)width {
    CGFloat photoHeight = 0;
    if (type == MTMediaTypePhoto) {
        photoHeight = mediaInfo? ([[mediaInfo valueForKey:@"height"] longValue] *width/[[mediaInfo valueForKey:@"width"] longValue]):180;
    } else if (type == MTMediaTypeVideo) {
        photoHeight = width / 64.f * 41.f;
    }
    return photoHeight;
}

@end
