//
//  showParticipatorsViewController.h
//  Metic
//
//  Created by ligang_mac4 on 14-7-18.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "../Utils/HttpSender.h"

@interface showParticipatorsViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate,HttpSenderDelegate>
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSMutableArray* fids;
@property (strong, nonatomic) NSNumber* eventId;
@property BOOL visibility;
@end
