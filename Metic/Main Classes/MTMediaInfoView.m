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

    // Configure the view for the selected state
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
    NSString* alias = [[MTUser sharedInstance].alias_dic objectForKey:[NSString stringWithFormat:@"%@",[self.mediaInfo valueForKey:@"author_id"]]];
    if (alias == nil || [alias isEqual:[NSNull null]] || [alias isEqualToString:@""]) {
        alias = [self.mediaInfo valueForKey:@"author"];
    }
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
    
    
    
    
    
    
    
    
//    
//    
//    
//    
//    
//    
//    
//    cell = [[UITableViewCell alloc]initWithFrame:CGRectMake(0, 0, 320, self.specificationHeight)];
//    if (!self.video_button) {
//        self.video_button = [UIButton buttonWithType:UIButtonTypeCustom];
//    }
//    [self.video_button setFrame:CGRectMake(0, 0, CGRectGetWidth(tableView.bounds),height)];
//    [self.video_button addTarget:self action:@selector(play:) forControlEvents:UIControlEventTouchUpInside];
//    if (!_video_thumb) {
//        [self.video_button setBackgroundImage:[CommonUtils createImageWithColor:[UIColor lightGrayColor]] forState:UIControlStateNormal];
//        [self.video_button setBackgroundImage:[CommonUtils createImageWithColor:[CommonUtils colorWithValue:0x909090]] forState:UIControlStateHighlighted];
//        
//    }
//    
//    //长按手势
//    //        UILongPressGestureRecognizer * longRecognizer = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(showOption:)];
//    //        [video addGestureRecognizer:longRecognizer];
//    
//    MTImageGetter *imageGetter = [[MTImageGetter alloc]initWithImageView:self.video_button.imageView imageId:nil imageName:_videoInfo[@"video_name"] type:MTImageGetterTypeVideoThumb];
//    [imageGetter getImageComplete:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//        if (image) {
//            _video_thumb = image;
//            [self.video_button setImage:image forState:UIControlStateNormal];
//            self.video_button.imageView.contentMode = UIViewContentModeScaleAspectFill;
//        }
//    }];
//    
//    UIImageView* videoIc = [[UIImageView alloc]initWithFrame:CGRectMake((320-75)/2, (height-75)/2, 75,75)];
//    [videoIc setUserInteractionEnabled:NO];
//    videoIc.image = [UIImage imageNamed:@"视频按钮"];
//    _videoPlayImg = videoIc;
//    
//    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, height, 320, 3)];
//    [label setBackgroundColor:[UIColor colorWithRed:252/255.0 green:109/255.0 blue:67/255.0 alpha:1.0]];
//    
//    [cell addSubview:self.video_button];
//    [cell addSubview:videoIc];
//    [cell addSubview:label];
//    //显示备注名
//    NSString* alias = [[MTUser sharedInstance].alias_dic objectForKey:[NSString stringWithFormat:@"%@",[_videoInfo valueForKey:@"author_id"]]];
//    if (alias == nil || [alias isEqual:[NSNull null]] || [alias isEqualToString:@""]) {
//        alias = [_videoInfo valueForKey:@"author"];
//    }
//    
//    UILabel* author = [[UILabel alloc]initWithFrame:CGRectMake(50, height+11, 200, 17)];
//    [author setFont:[UIFont systemFontOfSize:14]];
//    [author setTextColor:[UIColor colorWithRed:0/255.0 green:133/255.0 blue:186/255.0 alpha:1.0]];
//    [author setBackgroundColor:[UIColor clearColor]];
//    author.text = alias;
//    [cell addSubview:author];
//    
//    UILabel* date = [[UILabel alloc]initWithFrame:CGRectMake(50, height+28, 150, 13)];
//    [date setFont:[UIFont systemFontOfSize:11]];
//    [date setTextColor:[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0]];
//    date.text = [self.videoInfo valueForKey:@"time"];
//    [date setBackgroundColor:[UIColor clearColor]];
//    [cell addSubview:date];
//    
//    CGFloat specificationWidth = CGRectGetWidth(self.view.frame) - 10 - 50;
//    if (!self.specification) {
//        UILabel* specification = [[UILabel alloc]initWithFrame:CGRectMake(50, CGRectGetMaxY(date.frame)+1, specificationWidth, self.specificationHeight+15)];
//        [specification setFont:[UIFont systemFontOfSize:12]];
//        [specification setNumberOfLines:0];
//        [specification setBackgroundColor:[UIColor clearColor]];
//        self.specification = specification;
//    }
//    self.specification.frame = CGRectMake(50, CGRectGetMaxY(date.frame)+1, specificationWidth, self.specificationHeight+15);
//    self.specification.text = [self.videoInfo valueForKey:@"title"];
//    [cell addSubview:self.specification];
//    
//    
//    //shareBtn
//    if (!self.shareButton) {
//        self.shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        [self.shareButton setImage:[UIImage imageNamed:@"icon_detail_share"] forState:UIControlStateNormal];
//        [self.shareButton setImageEdgeInsets:UIEdgeInsetsMake(10, 12, 10, 8)];
//        [self.shareButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
//        [self.shareButton setTitleColor:[UIColor colorWithRed:0/255.0 green:133/255.0 blue:186/255.0 alpha:1.0] forState:UIControlStateNormal];
//        [self.shareButton setTitleColor:[UIColor colorWithRed:0/255.0 green:133/255.0 blue:186/255.0 alpha:0.5] forState:UIControlStateHighlighted];
//        [self.shareButton addTarget:self action:@selector(shareVideo) forControlEvents:UIControlEventTouchUpInside];
//    }
//    [self.shareButton setFrame:CGRectMake(CGRectGetWidth(self.view.frame) - 40 - 40, height + 3 + 2, 40, 40)];
//    [cell addSubview:self.shareButton];
//    
//    //good button
//    if (!self.good_button) {
//        self.good_button = [UIButton buttonWithType:UIButtonTypeCustom];
//        [self.good_button setImageEdgeInsets:UIEdgeInsetsMake(10, 8, 10, 12)];
//        [self.good_button addTarget:self action:@selector(good:) forControlEvents:UIControlEventTouchUpInside];
//    }
//    [self.good_button setFrame:CGRectMake(CGRectGetWidth(self.view.frame) - 40 , height + 3 + 2, 40, 40)];
//    [cell addSubview:self.good_button];
//    [self setGoodButton];
//    
//    if (!self.avatarView) {
//        self.avatarView = [[UIImageView alloc] initWithFrame:CGRectZero];
//    }
//    [self.avatarView setFrame:CGRectMake(10, height+13, 30, 30)];
//    [cell addSubview:self.avatarView];
//    
//    PhotoGetter *getter = [[PhotoGetter alloc]initWithData:self.avatarView authorId:[self.videoInfo valueForKey:@"author_id"]];
//    [getter getAvatar];
//    
//    UIButton* avatarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [avatarBtn setFrame:CGRectMake(0, height+13, 50, 50)];
//    [avatarBtn setBackgroundColor:[UIColor clearColor]];
//    [avatarBtn addTarget:self action:@selector(pushToFriendView:) forControlEvents:UIControlEventTouchUpInside];
//    [cell addSubview:avatarBtn];
//    
//    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
//    [cell setBackgroundColor:[UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0]];
//    return cell;
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
    
    height += 45 + 30 + 20;
    
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
