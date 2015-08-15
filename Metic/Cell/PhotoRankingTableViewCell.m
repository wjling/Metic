//
//  PhotoRankingTableViewCell.m
//  WeShare
//
//  Created by ligang6 on 14-9-23.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "PhotoRankingTableViewCell.h"
#import "PhotoDetailViewController.h"
#import "PhotoGetter.h"
#import "UIImageView+MTWebCache.h"
#import "../Main Classes/UserInfo/UserInfoViewController.h"
#import "../Main Classes/Friends/FriendInfoViewController.h"
#import "MegUtils.h"

@implementation PhotoRankingTableViewCell
#define widthspace 10
#define deepspace 4

- (void)awakeFromNib
{
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    [_good_Btn setBackgroundImage:[CommonUtils createImageWithColor:[CommonUtils colorWithValue:0xe0e0e0]] forState:UIControlStateHighlighted];
    [_good_Btn addTarget:self action:@selector(addGood:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)setFrame:(CGRect)frame
{
    //frame.origin.x += widthspace;
    frame.origin.y += deepspace;
    //frame.size.width -= 2 * widthspace;
    frame.size.height -= 2 * deepspace;
    [super setFrame:frame];
    
}

-(void)refresh
{
    //显示备注名
    NSString* alias = [[MTUser sharedInstance].alias_dic objectForKey:[NSString stringWithFormat:@"%@",[_photoInfo valueForKey:@"author_id"]]];
    if (alias == nil || [alias isEqual:[NSNull null]] || [alias isEqualToString:@""]) {
        alias = [_photoInfo valueForKey:@"author"];
    }
    self.author.text = alias;
    self.time.text = [[_photoInfo valueForKey:@"time"] substringToIndex:10];
    self.authorId = [_photoInfo valueForKey:@"author_id"];
    PhotoGetter* avatarGetter = [[PhotoGetter alloc]initWithData:self.avatar authorId:self.authorId];
    [avatarGetter getAvatar];
    
    [self.good_Btn setEnabled:YES];
    [self setISZan:[[_photoInfo valueForKey:@"isZan"] boolValue]];
    [self setGood_buttonNum:[_photoInfo valueForKey:@"good"]];

    NSString *url = [_photoInfo valueForKey:@"url"];
    NSString *imagePath = [MegUtils photoImagePathWithImageName:_photoInfo[@"photo_name"]];
    
    self.photo.contentMode = UIViewContentModeScaleAspectFit;
    [self.photo sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"活动图片的默认图片"] cloudPath:imagePath completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (!image) {
            self.photo.image = [UIImage imageNamed:@"加载失败"];
        }else self.photo.contentMode = UIViewContentModeScaleAspectFill;
    }];
}

-(void)animationBegin
{
    if (!_controller.shouldFlash) {
        return;
    }
    [self setAlpha:0.5];
    [UIView beginAnimations:@"shadowViewDisappear" context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDelegate:self];
    self.alpha = 1;
    [UIView commitAnimations];
}

-(void)setISZan:(BOOL)isZan
{
    self.isZan = isZan;
    if (isZan) {
        [self.good_Img setImage:[UIImage imageNamed:@"活动详情_点赞图按下效果"] ];
    }else{
        [self.good_Img setImage:[UIImage imageNamed:@"活动详情_点赞图"]];
    }
}

-(void)setGood_buttonNum:(NSNumber *)num
{
    [self.good_Num setText:[CommonUtils TextFromInt:[num intValue]]];
}


- (IBAction)addGood:(id)button
{
    if (!_controller.canManage) return;
    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == 0) {
        [CommonUtils showSimpleAlertViewWithTitle:@"信息" WithMessage:@"网络异常" WithDelegate:self WithCancelTitle:@"确定"];
        return;
    }
    
    BOOL isZan = [[_photoInfo valueForKey:@"isZan"] boolValue];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:[MTUser sharedInstance].userid forKey:@"id"];
    [dictionary setValue:[_photoInfo valueForKey:@"photo_id"] forKey:@"photo_id"];
    [dictionary setValue:[NSNumber numberWithInt:isZan? 2:3]  forKey:@"operation"];
    [dictionary setValue:self.eventId forKey:@"event_id"];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    NSLog(@"%@",[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding]);
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:ADD_GOOD finshedBlock:^(NSData *rData) {
        if (rData) {
            NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
            NSNumber *cmd = [response1 valueForKey:@"cmd"];
            if ([cmd intValue] == NORMAL_REPLY) {
                
            }
        }
    }];
    
    [_photoInfo setValue:[NSNumber numberWithBool:!isZan] forKey:@"isZan"];
    int zan_num = [[_photoInfo valueForKey:@"good"] intValue];
    if (isZan) {
        zan_num --;
    }else{
        zan_num ++;
    }
    [_photoInfo setValue:[NSNumber numberWithInt:zan_num] forKey:@"good"];
    _controller.shouldFlash = NO;
    [_controller.tableView reloadData];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _controller.shouldFlash = YES;
    });
    
}

- (IBAction)toUserInfo:(id)sender {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone"
															 bundle: nil];
    if ([_authorId intValue] == [[MTUser sharedInstance].userid intValue]) {
        UserInfoViewController* userInfoView = [mainStoryboard instantiateViewControllerWithIdentifier: @"UserInfoViewController"];
        userInfoView.needPopBack = YES;
        [_controller.navigationController pushViewController:userInfoView animated:YES];
        
    }else{
        FriendInfoViewController *friendView = [mainStoryboard instantiateViewControllerWithIdentifier: @"FriendInfoViewController"];
        friendView.fid = self.authorId;
        [_controller.navigationController pushViewController:friendView animated:YES];
    }
}

- (void)toPhotoDetail
{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone"
															 bundle: nil];
	PhotoDetailViewController *viewcontroller = [mainStoryboard instantiateViewControllerWithIdentifier: @"PhotoDetailViewController"]; ;
    
    viewcontroller.photoId = [self.photoInfo valueForKey:@"photo_id"];
    viewcontroller.photo = self.photo.image;
    viewcontroller.eventId = self.eventId;
    viewcontroller.photoInfo = self.photoInfo;
    viewcontroller.eventName = _controller.eventName;
    viewcontroller.controller = self.controller.pictureWallController;
    viewcontroller.type = 2;
    viewcontroller.canManage = self.controller.canManage;
    [self.controller.navigationController pushViewController:viewcontroller animated:YES];
    
}

@end
