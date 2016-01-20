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

@interface PhotoTableViewCell ()
@property (nonatomic,strong) UIView* progressView;
@property (nonatomic,weak) uploaderOperation *uploadTask;
@property (nonatomic,strong) NSTimer* timer;

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
    
    UIView* line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 145, 3)];
    [line setBackgroundColor:[UIColor colorWithRed:246.0/255.0 green:92.0/255.0 blue:35.0/255.0 alpha:1.0]];
    [_infoView addSubview:line];
    
    _avatar = [[UIImageView alloc]initWithFrame:CGRectMake(5, 8, 20, 20)];
    [_infoView addSubview:_avatar];
    
    _author = [[UILabel alloc]initWithFrame:CGRectMake(30, 5, 110, 15)];
    _author.font = [UIFont systemFontOfSize:12];
    _author.textColor = [UIColor colorWithWhite:51.0/255.0 alpha:1.0f];
    [_infoView addSubview:_author];
    
    _publish_date = [[UILabel alloc]initWithFrame:CGRectMake(30, 20, 110, 10)];
    _publish_date.font = [UIFont systemFontOfSize:11];
    _publish_date.textColor = [UIColor colorWithWhite:145.0/255.0 alpha:1.0f];
    [_infoView addSubview:_publish_date];
    
    UITapGestureRecognizer* tapRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(button_DetailPressed:)];
    [self.infoView addGestureRecognizer:tapRecognizer];
    
    [self.imgView setBackgroundColor:[UIColor colorWithWhite:204.0/255 alpha:1.0f]];
    
    return self;
}

- (void)button_DetailPressed:(id)sender {
    MTLOG(@"pressed");
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone"
															 bundle: nil];
	PhotoDetailViewController *viewcontroller = [mainStoryboard instantiateViewControllerWithIdentifier: @"PhotoDetailViewController"];
    
    viewcontroller.photoId = self.photo_id;
    viewcontroller.eventId = self.PhotoWall.eventId;
    viewcontroller.eventLauncherId = _PhotoWall.eventLauncherId;
    viewcontroller.photoInfo = self.photoInfo;
    viewcontroller.eventName = _PhotoWall.eventName;
    viewcontroller.controller = self.PhotoWall;
    viewcontroller.type = 2;
    viewcontroller.canManage = [[_PhotoWall.eventInfo valueForKey:@"isIn"]boolValue];
    [self.PhotoWall.navigationController pushViewController:viewcontroller animated:YES];

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
    NSString* alias = [[MTUser sharedInstance].alias_dic objectForKey:[NSString stringWithFormat:@"%@",[data valueForKey:@"author_id"]]];
    if (alias == nil || [alias isEqual:[NSNull null]] || [alias isEqualToString:@""]) {
        alias = [data valueForKey:@"author"];
    }
    self.author.text = alias;
    self.publish_date.text = [[data valueForKey:@"time"] substringToIndex:10];
    
    self.avatar.layer.masksToBounds = YES;
    [self.avatar.layer setCornerRadius:5];
    self.photo_id = [data valueForKey:@"photo_id"];
    
    PhotoGetter* avatarGetter = [[PhotoGetter alloc]initWithData:self.avatar authorId:[data valueForKey:@"author_id"]];
    [avatarGetter getAvatar];

    MTImageGetter *imageGetter = [[MTImageGetter alloc]initWithImageView:self.imgView imageId:nil imageName:data[@"photo_name"] type:MTImageGetterTypePhoto];
//    [imageGetter getImage];
    if (CGSizeEqualToSize(self.imgView.bounds.size, CGSizeZero)) {
        [imageGetter getImage];
    }else {
        [imageGetter getImageFitSize];
    }

    int width = [[data valueForKey:@"width"] intValue];
    int height = [[data valueForKey:@"height"] intValue];
    float RealHeight = height * 145.0f / width;
    
    [self.imgView setFrame:CGRectMake(0, 0, 145, RealHeight)];
    [self.infoView setFrame:CGRectMake(0, RealHeight, 145, 33)];
}

@end
