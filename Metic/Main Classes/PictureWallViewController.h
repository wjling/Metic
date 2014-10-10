//
//  PictureWallViewController.h
//  Metic
//
//  Created by ligang6 on 14-6-29.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoGetter.h"
#import "MTUser.h"
#import "MJRefreshFooterView.h"
#import "MJRefreshHeaderView.h"
#import "UIImageView+WebCache.h"

@interface PictureWallViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,MJRefreshBaseViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView1;
@property (strong, nonatomic) IBOutlet UITableView *tableView2;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UILabel *promt;
@property (strong, nonatomic) UIView *indicatorView;
@property(nonatomic,strong)NSNumber *eventId;
@property(nonatomic,strong)NSString* eventName;
@property(nonatomic,strong)NSNumber *sequence;
@property (nonatomic,strong) NSMutableArray* lefPhotos;
@property (nonatomic,strong) NSMutableArray* rigPhotos;
@property int leftH;
@property int rightH;
@property(nonatomic,strong)NSMutableArray *photo_list;//部分
@property(nonatomic,strong)NSMutableArray *photo_list_all;//总
@property(nonatomic,strong)NSMutableArray *photoPath_list;
@property(nonatomic,strong)NSMutableDictionary *photos;
@property(nonatomic,strong)MJRefreshHeaderView *header;
@property (strong,nonatomic) MJRefreshFooterView *footer;
@property BOOL shouldReloadPhoto;
- (IBAction)toBestPhotos:(id)sender;


@end
