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

@interface PictureWallViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,PhotoGetterDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView1;
@property (strong, nonatomic) IBOutlet UITableView *tableView2;
@property(nonatomic,strong)NSNumber *eventId;
@property(nonatomic,strong)NSNumber *sequence;
@property(nonatomic,strong)NSMutableArray *photo_list;
@property(nonatomic,strong)NSMutableArray *photoPath_list;
@property(nonatomic,strong)NSMutableDictionary *photos;
- (IBAction)toUploadPhoto:(id)sender;


@end
