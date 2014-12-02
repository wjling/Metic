//
//  PictureWall2.h
//  WeShare
//
//  Created by ligang6 on 14-12-2.
//  Copyright (c) 2014年 WeShare. All rights reserved.
//

#import "TMQuiltViewController.h"

@interface PictureWall2 : TMQuiltViewController
@property (strong, nonatomic) UIView *indicatorView;
@property(nonatomic,strong)NSNumber *eventId;
@property(nonatomic,strong)NSString* eventName;
@property(nonatomic,strong)NSNumber *sequence;
@property (nonatomic,strong) NSMutableArray* lefPhotos;
@property (nonatomic,strong) NSMutableArray* rigPhotos;
@property double leftH;
@property double rightH;
@property(nonatomic,strong)NSMutableArray *photo_list;//部分
@property(nonatomic,strong)NSMutableArray *photo_list_all;//总
@property(nonatomic,strong)NSMutableArray *photoPath_list;
@property(nonatomic,strong)NSMutableDictionary *photos;

//@property (strong,nonatomic) MJRefreshFooterView *footer;
@property BOOL shouldReloadPhoto;
@end
