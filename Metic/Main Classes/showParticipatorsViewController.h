//
//  showParticipatorsViewController.h
//  Metic
//
//  Created by ligang_mac4 on 14-7-18.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface showParticipatorsViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate>
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSMutableArray* fids;
@end
