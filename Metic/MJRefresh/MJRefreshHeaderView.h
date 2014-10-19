//
//  MJRefreshHeaderView.h
//  MJRefresh
//
//  Created by mj on 13-2-26.
//  Copyright (c) 2013年 itcast. All rights reserved.
//  下拉刷新

#import "MJRefreshBaseView.h"

@interface MJRefreshHeaderView : MJRefreshBaseView
@property BOOL isRight;
@property BOOL isPhotoWall;
+ (instancetype)header;
@end