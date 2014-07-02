//
//  PhotoDisplayViewController.h
//  Metic
//
//  Created by ligang6 on 14-7-2.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "../Utils/PhotoGetter.h"

@interface PhotoDisplayViewController : UIViewController<PhotoGetterDelegate,UIScrollViewDelegate>
@property(nonatomic,strong)UIScrollView *scrollView;
@property(nonatomic,strong)NSMutableDictionary *photoscache;
@property(nonatomic,strong)NSMutableArray *photoPath_list;
@property(nonatomic,strong)NSMutableDictionary *photos;
@property int photoIndex;
@end
