//
//  PhotoDetailViewController.h
//  Metic
//
//  Created by ligang6 on 14-7-4.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoGetter.h"

@interface PhotoDetailViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,PhotoGetterDelegate>
@property(nonatomic,strong) UIImage* photo;
@property (nonatomic,strong)NSNumber* photoId;
@property (nonatomic,strong) NSDictionary * photoInfo;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UIViewController* photoDisplayController;

@end
