//
//  PictureWall2.h
//  WeShare
//
//  Created by ligang6 on 14-12-2.
//  Copyright (c) 2014年 WeShare. All rights reserved.
//

#import "TMQuiltViewController.h"
#import "MJRefreshHeaderView.h"

@interface PictureWall2 : UIViewController<MJRefreshBaseViewDelegate>
@property(nonatomic,strong)TMQuiltView* quiltView;
@property(nonatomic,strong)NSNumber *eventId;
@property(nonatomic,strong)NSString* eventName;
@property(nonatomic,strong)NSNumber* eventLauncherId;
@property(nonatomic,strong)NSNumber *sequence;

@property NSInteger showPhoNum;
@property NSInteger uploadingTaskCount;
@property(nonatomic,strong)NSMutableArray *photo_list;//部分
@property(nonatomic,strong)NSMutableArray *photo_list_all;//总
@property (strong,nonatomic) MJRefreshHeaderView *header;

@property (nonatomic,strong) NSMutableArray* uploadingPhotos;

@property BOOL shouldReloadPhoto;

//@property (strong,nonatomic) MJRefreshFooterView *footer;
+ (void)updatePhotoInfoToDB:(NSArray*)photoInfos eventId:(NSNumber*)eventId;
- (IBAction)toBestPhotos:(id)sender;
- (IBAction)addPhoto:(id)sender;
-(void)calculateLRH;
- (void)pullPhotoInfosFromDB;
- (void)pullUploadTasksfromDB;
@end
