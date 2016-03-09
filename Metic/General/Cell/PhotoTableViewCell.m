//
//  PhotoTableViewCell.m
//  Metic
//
//  Created by ligang6 on 14-6-30.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "PhotoTableViewCell.h"
#import "PhotoDetailViewController.h"
#import "UploaderManager.h"
#import "uploaderOperation.h"
#import "TMQuiltView.h"
#import "UploaderManager.h"
#import "MegUtils.h"
#import "UIImageView+MTWebCache.h"
#import "MTImageGetter.h"
#import "FriendInfoViewController.h"
#import "MTOperation.h"
#import "Reachability.h"
#import "MTDatabaseAffairs.h"

static CGFloat INFO_VIEW_HEIGHT = 30;
static CGFloat DETAIL_VIEW_HEIGHT = 17;

@interface PhotoTableViewCell ()
//@property (nonatomic,strong) UIView* progressView;
//@property (nonatomic,weak) uploaderOperation *uploadTask;
//@property (nonatomic,strong) NSTimer* timer;

@property (nonatomic, strong) PhotoDetailView *detailView;
@property (nonatomic, strong) UIButton *zanBtn;

@end

@implementation PhotoTableViewCell


- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    _imgView = [[UIImageView alloc]initWithFrame:CGRectZero];
    _imgView.clipsToBounds = YES;
    [self addSubview:_imgView];
    
    _infoView = [[UIView alloc]initWithFrame:CGRectZero];
    [_infoView setBackgroundColor:[UIColor whiteColor]];
    [self addSubview:_infoView];
    
    self.avatar = [[UIImageView alloc]initWithFrame:CGRectMake(5, 4, 22, 22)];
    self.avatar.layer.masksToBounds = YES;
    [self.avatar.layer setCornerRadius:3];
    [_infoView addSubview:_avatar];
    
    _author = [[UILabel alloc]initWithFrame:CGRectMake(30, 2, 110, 15)];
    _author.font = [UIFont systemFontOfSize:11];
    _author.textColor = [UIColor colorWithWhite:51.0/255.0 alpha:1.0f];
    [_infoView addSubview:_author];
    
    _publish_date = [[UILabel alloc]initWithFrame:CGRectMake(30, 17, 110, 10)];
    _publish_date.font = [UIFont systemFontOfSize:9];
    _publish_date.textColor = [UIColor colorWithWhite:145.0/255.0 alpha:1.0f];
    [_infoView addSubview:_publish_date];
    
    UIButton *avatarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    avatarBtn.backgroundColor = [UIColor clearColor];
    avatarBtn.frame = CGRectMake(0, 0, 100, INFO_VIEW_HEIGHT);
    [avatarBtn addTarget:self action:@selector(button_AvatarPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.infoView addSubview:avatarBtn];
    
//    UITapGestureRecognizer* tapRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(button_DetailPressed:)];
//    [self.infoView addGestureRecognizer:tapRecognizer];
    
    [self.imgView setBackgroundColor:[UIColor colorWithWhite:204.0/255 alpha:1.0f]];
    
    self.detailView = [[PhotoDetailView alloc] init];
    [self.detailView setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.4f]];
    [self addSubview:self.detailView];
    
    self.zanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.zanBtn.backgroundColor = [UIColor clearColor];
    self.zanBtn.frame = CGRectMake(0, 0, 100, DETAIL_VIEW_HEIGHT * 2.f);
    [self.zanBtn addTarget:self action:@selector(good) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.zanBtn];
    
    return self;
}

# pragma mark get Mathod
- (NSNumber *)photoId {
    return [self.photoInfo valueForKey:@"photo_id"];
}

- (NSNumber *)authorId {
    return [self.photoInfo valueForKey:@"author_id"];
}

- (NSString *)photoName {
    return [self.photoInfo valueForKey:@"photo_name"];
}

- (NSInteger)commentNum {
    return [[self.photoInfo valueForKey:@"comment_num"] integerValue];
}

- (NSInteger)zanNum {
    return [[self.photoInfo valueForKey:@"good"] integerValue];
}

- (BOOL)isZan {
    return [[self.photoInfo valueForKey:@"isZan"] boolValue];
}

- (void)button_DetailPressed:(id)sender {

    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone"
															 bundle: nil];
	PhotoDetailViewController *viewcontroller = [mainStoryboard instantiateViewControllerWithIdentifier: @"PhotoDetailViewController"];
    
    viewcontroller.photoId = self.photoId;
    viewcontroller.eventId = self.PhotoWall.eventId;
    viewcontroller.eventLauncherId = _PhotoWall.eventLauncherId;
    viewcontroller.photoInfo = self.photoInfo;
    viewcontroller.eventName = _PhotoWall.eventName;
    viewcontroller.canManage = [[_PhotoWall.eventInfo valueForKey:@"isIn"]boolValue];
    [self.PhotoWall.navigationController pushViewController:viewcontroller animated:YES];

}

- (void)button_AvatarPressed:(id)sender {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone"
                                                             bundle: nil];

    FriendInfoViewController *friendView = [mainStoryboard instantiateViewControllerWithIdentifier: @"FriendInfoViewController"];
    friendView.fid = self.authorId;
    [self.PhotoWall.navigationController pushViewController:friendView animated:YES];
    
}

-(void)animationBegin
{
    if (_isloading) return;
    [self setAlpha:0.5];
    [UIView beginAnimations:@"shadowViewDisappear" context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDelegate:self];
    self.alpha = 1;
    [UIView commitAnimations];
}

//加载数据
- (void)applyData:(NSMutableDictionary *)data
{
    self.photoInfo = data;
    //显示备注名
    NSString *alias = [MTOperation getAliasWithUserId:data[@"author_id"] userName:data[@"author"]];

    self.author.text = alias;
    self.publish_date.text = [[data valueForKey:@"time"] substringToIndex:10];

    int width = [[data valueForKey:@"width"] intValue];
    int height = [[data valueForKey:@"height"] intValue];
    float RealHeight = height * 145.0f / width;
    
    [self.imgView setFrame:CGRectMake(0, INFO_VIEW_HEIGHT, 145, RealHeight)];
    [self.infoView setFrame:CGRectMake(0, 0, 145, INFO_VIEW_HEIGHT)];
    [self.detailView setFrame:CGRectMake(0, INFO_VIEW_HEIGHT + RealHeight - DETAIL_VIEW_HEIGHT, 145, DETAIL_VIEW_HEIGHT)];
    [self.detailView setupUIWithIsZan:self.isZan zanNum:self.zanNum commentNum:self.commentNum];
    [self.zanBtn setFrame:CGRectMake(145.f / 2.f, INFO_VIEW_HEIGHT + RealHeight - DETAIL_VIEW_HEIGHT * 2.f, 145.f / 2.f, DETAIL_VIEW_HEIGHT * 2.f)];
    
    PhotoGetter* avatarGetter = [[PhotoGetter alloc]initWithData:self.avatar authorId:[data valueForKey:@"author_id"]];
    [avatarGetter getAvatar];
    
    MTImageGetter *imageGetter = [[MTImageGetter alloc]initWithImageView:self.imgView imageId:nil imageName:data[@"photo_name"] type:MTImageGetterTypePhoto];
    //    [imageGetter getImage];
    if (CGSizeEqualToSize(self.imgView.bounds.size, CGSizeZero)) {
        [imageGetter getImage];
    }else {
        [imageGetter getImageFitSize];
    }
}

//刷新detailview
- (void)reloadDetailView {
    if (self.detailView) {
     [self.detailView setupUIWithIsZan:self.isZan zanNum:self.zanNum commentNum:self.commentNum];
    }
}

#pragma mark 点赞
- (void)good {
    if (![[self.PhotoWall.eventInfo valueForKey:@"isIn"]boolValue]) {
        [CommonUtils showSimpleAlertViewWithTitle:@"温馨提示" WithMessage:@"您尚未加入该活动中，无法点赞" WithDelegate:nil WithCancelTitle:@"确定"];
        return;
    }
    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == 0)
    {
        [CommonUtils showSimpleAlertViewWithTitle:@"信息" WithMessage:@"网络异常" WithDelegate:nil WithCancelTitle:@"确定"];
        return;
    }
    
    [[MTOperation sharedInstance] likeOperationWithType:MTMediaTypePhoto mediaId:self.photoId eventId:self.PhotoWall.eventId like:!self.isZan finishBlock:NULL];
    
    BOOL isZan = self.isZan;
    NSInteger good = self.zanNum;
    if (isZan) {
        good --;
    }else good ++;
    [self.photoInfo setValue:[NSNumber numberWithBool:!isZan] forKey:@"isZan"];
    [self.photoInfo setValue:[NSNumber numberWithInteger:good] forKey:@"good"];
    [MTDatabaseAffairs updatePhotoInfoToDB:@[_photoInfo] eventId:self.PhotoWall.eventId];
    [self.detailView setupUIWithIsZan:self.isZan zanNum:self.zanNum commentNum:self.commentNum];
    
}

+ (CGFloat)photoCellHeightForPhotoInfo:(NSDictionary *)photoInfo {
    float width = [[photoInfo valueForKey:@"width"] floatValue];
    float height = [[photoInfo valueForKey:@"height"] floatValue];
    float RealHeight = height * 145.0f / width;
    
    return RealHeight + INFO_VIEW_HEIGHT;
}

@end


@interface PhotoDetailView ()

@property (nonatomic, strong) UIImageView *commentImageView;
@property (nonatomic, strong) UILabel *commentLabelView;

@property (nonatomic, strong) UIImageView *zanImageView;
@property (nonatomic, strong) UILabel *zanLabelView;

@property (nonatomic) BOOL isZan;
@property (nonatomic) NSInteger zanNum;
@property (nonatomic) NSInteger commentNum;


@end

@implementation PhotoDetailView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupData];
        [self setupUI];
    }
    return self;
}

- (void)setupData {
    self.isZan = NO;
    self.zanNum = 0;
}

- (void)setupUI {
    
    self.frame = CGRectMake(0, 0, 145, DETAIL_VIEW_HEIGHT);
    
    self.zanLabelView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 20, DETAIL_VIEW_HEIGHT)];
    self.zanLabelView.font = [UIFont systemFontOfSize:11];
    self.zanLabelView.textColor = [UIColor whiteColor];
    [self addSubview:self.zanLabelView];
    
    self.zanImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, DETAIL_VIEW_HEIGHT)];
    self.zanImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:self.zanImageView];
    
    self.commentLabelView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 20, DETAIL_VIEW_HEIGHT)];
    self.commentLabelView.font = [UIFont systemFontOfSize:11];
    self.commentLabelView.textColor = [UIColor whiteColor];
    [self addSubview:self.commentLabelView];
    
    self.commentImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, DETAIL_VIEW_HEIGHT)];
    self.commentImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:self.commentImageView];

}

- (void)setupUIWithIsZan:(BOOL)isZan zanNum:(NSInteger)zanNum commentNum:(NSInteger)commentNum {
    _isZan = isZan;
    _zanNum = zanNum;
    _commentNum = commentNum;
    
    double width = CGRectGetWidth(self.frame);
    
    NSString *zanLabelText = [NSString stringWithFormat:@"%ld",(long)_zanNum];
    CGFloat zanTextWidth = zanLabelText.length * 8;
    self.zanLabelView.text = zanLabelText;
    self.zanLabelView.frame = CGRectMake(width - zanTextWidth - 4, 0, zanTextWidth, DETAIL_VIEW_HEIGHT);
    
    self.zanImageView.frame = CGRectMake(CGRectGetMinX(self.zanLabelView.frame) - DETAIL_VIEW_HEIGHT, 0, DETAIL_VIEW_HEIGHT-3, DETAIL_VIEW_HEIGHT);
    [self.zanImageView setImage:isZan? [UIImage imageNamed:@"icon_like_yes"]:[UIImage imageNamed:@"icon_like_no"]];
    
    
    NSString *commentLabelText = [NSString stringWithFormat:@"%ld",(long)_commentNum];
    CGFloat commentTextWidth = commentLabelText.length * 8;
    self.commentLabelView.text = commentLabelText;
    self.commentLabelView.frame = CGRectMake(CGRectGetMinX(self.zanImageView.frame) - commentTextWidth - 7, 0, commentTextWidth, DETAIL_VIEW_HEIGHT);
    
    self.commentImageView.frame = CGRectMake(CGRectGetMinX(self.commentLabelView.frame) - DETAIL_VIEW_HEIGHT, 0, DETAIL_VIEW_HEIGHT-3, DETAIL_VIEW_HEIGHT);
    [self.commentImageView setImage:[UIImage imageNamed:@"icon_comment_yes"]];

}

@end