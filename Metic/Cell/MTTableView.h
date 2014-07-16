//
//  MTTableView.h
//  Metic
//
//  Created by ligang_mac4 on 14-6-26.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "../Main Classes/HomeViewController.h"
#import "SlideNavigationController.h"
#import "../Utils/PhotoGetter.h"
#import "MTUser.h"

@interface MTTableView : UITableView<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,strong)HomeViewController* homeController;
@property(nonatomic,strong)MTUser *user;
@property(nonatomic,strong)NSMutableArray *eventsSource;
@property (nonatomic,strong) NSOperationQueue *queue;
@end




