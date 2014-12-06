//
//  PictureWall2.h
//  WeShare
//
//  Created by ligang6 on 14-12-2.
//  Copyright (c) 2014年 WeShare. All rights reserved.
//

#import "TMQuiltViewController.h"
#import "MJRefreshHeaderView.h"

@interface PictureWall2 : TMQuiltViewController<MJRefreshBaseViewDelegate>
@property(nonatomic,strong)NSNumber *eventId;
@property(nonatomic,strong)NSString* eventName;
@property(nonatomic,strong)NSNumber *sequence;

@property(nonatomic,strong)NSMutableArray *photo_list;//部分
@property(nonatomic,strong)NSMutableArray *photo_list_all;//总
@property (strong,nonatomic) MJRefreshHeaderView *header;

@property BOOL shouldReloadPhoto;
//@property (strong,nonatomic) MJRefreshFooterView *footer;

- (IBAction)toBestPhotos:(id)sender;
@end