//
//  EventDetail2.h
//  WeShare
//
//  Created by ligang6 on 14-11-13.
//  Copyright (c) 2014年 WeShare. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventDetail2 : UIViewController<UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,strong) NSMutableSet* loadingVideo;
@end
