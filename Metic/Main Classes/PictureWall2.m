//
//  PictureWall2.m
//  WeShare
//
//  Created by ligang6 on 14-12-2.
//  Copyright (c) 2014年 WeShare. All rights reserved.
//

#import "PictureWall2.h"
#import "../Utils/MySqlite.h"
#import "MTUser.h"
#import "TMQuiltView.h"
#import "../Cell/PhotoTableViewCell.h"

@interface PictureWall2 ()

@end

@implementation PictureWall2

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    [self initData];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initUI
{
    
}

- (void)initData
{
    self.sequence = [[NSNumber alloc]initWithInt:-1];
    self.photo_list = [[NSMutableArray alloc]init];
    self.photo_list_all= [[NSMutableArray alloc]init];
    [self pullPhotoInfosFromDB];
}

- (void)pullPhotoInfosFromDB
{
    NSString * path = [NSString stringWithFormat:@"%@/db",[MTUser sharedInstance].userid];
    MySqlite* sql = [[MySqlite alloc]init];
    [sql openMyDB:path];
    
    //self.events = [[NSMutableArray alloc]init];
    NSArray *seletes = [[NSArray alloc]initWithObjects:@"photoInfo", nil];
    NSDictionary *wheres = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%@ order by photo_id desc",_eventId],@"event_id", nil];
    NSMutableArray *result = [sql queryTable:@"eventPhotos" withSelect:seletes andWhere:wheres];
    for (NSDictionary *temp in result) {
        NSString *tmpa = [temp valueForKey:@"photoInfo"];
        tmpa = [tmpa stringByReplacingOccurrencesOfString:@"''" withString:@"'"];
        NSData *tmpb = [tmpa dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *photoInfo =  [NSJSONSerialization JSONObjectWithData:tmpb options:NSJSONReadingMutableContainers error:nil];
        [self.photo_list_all addObject:photoInfo];
        //[self.photo_list addObject:photoInfo];
    }
    [sql closeMyDB];
    [self.quiltView reloadData];
}

#pragma mark - TMQuiltViewDelegate
- (NSInteger)quiltViewNumberOfCells:(TMQuiltView *)TMQuiltView {
    return [_photo_list_all count];
}


- (TMQuiltViewCell *)quiltView:(TMQuiltView *)quiltView cellAtIndexPath:(NSIndexPath *)indexPath {
    PhotoTableViewCell *cell = (PhotoTableViewCell *)[quiltView dequeueReusableCellWithReuseIdentifier:@"photocell"];
    if (!cell) {
        cell = [[PhotoTableViewCell alloc] initWithReuseIdentifier:@"photocell"];
    }
    [cell.imgView setFrame:CGRectZero];
    [cell.infoView setFrame:CGRectZero];
    
    NSMutableDictionary *a = _photo_list_all[indexPath.row];
    
    //显示备注名
    NSString* alias = [[MTUser sharedInstance].alias_dic objectForKey:[NSString stringWithFormat:@"%@",[a valueForKey:@"author_id"]]];
    if (alias == nil || [alias isEqual:[NSNull null]]) {
        alias = [a valueForKey:@"author"];
    }
    cell.author.text = alias;
    cell.publish_date.text = [[a valueForKey:@"time"] substringToIndex:10];
    
    cell.avatar.layer.masksToBounds = YES;
    [cell.avatar.layer setCornerRadius:5];
    cell.photoInfo = a;
    cell.PhotoWall = self;
    cell.photo_id = [a valueForKey:@"photo_id"];
    
    PhotoGetter* avatarGetter = [[PhotoGetter alloc]initWithData:cell.avatar authorId:[a valueForKey:@"author_id"]];
    [avatarGetter getAvatar];
    UIImageView* photo = cell.imgView;
    [cell.infoView removeFromSuperview];
    
    NSString* url = [a valueForKey:@"url"];
    
    [photo setContentMode:UIViewContentModeScaleAspectFit];
    [photo setBackgroundColor:[UIColor colorWithWhite:204.0/255 alpha:1.0f]];
    [photo sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"活动图片的默认图片"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (image) {
            [photo setContentMode:UIViewContentModeScaleToFill];
        }
    }];
    
    int width = [[a valueForKey:@"width"] intValue];
    int height = [[a valueForKey:@"height"] intValue];
    float RealHeight = height * 150.0f / width;
    
    [cell setHidden:NO];
    [cell.imgView setHidden:NO];
    [cell.activityIndicator stopAnimating];
    [cell.activityIndicator setHidden:YES];
    [photo setFrame:CGRectMake(0, 0, 145, RealHeight)];
    [cell.infoView setFrame:CGRectMake(0, RealHeight, 145, 33)];
    [cell addSubview:cell.infoView];
    
    [cell animationBegin];
    
    return cell;
}


- (NSInteger)quiltViewNumberOfColumns:(TMQuiltView *)quiltView {
    return 2;
    
}

- (CGFloat)quiltView:(TMQuiltView *)quiltView heightForCellAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *a = _photo_list_all[indexPath.row];
    
    
    int width = [[a valueForKey:@"width"] intValue];
    int height = [[a valueForKey:@"height"] intValue];
    float RealHeight = height * 150.0f / width;
    
    return RealHeight + 43;
}

- (void)quiltView:(TMQuiltView *)quiltView didSelectCellAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"sdfasdfasdf");
}

@end
