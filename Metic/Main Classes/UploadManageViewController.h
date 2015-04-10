//
//  UploadManageViewController.h
//  WeShare
//
//  Created by 俊健 on 15/4/10.
//  Copyright (c) 2015年 WeShare. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UploadManageViewController : UIViewController
@property(nonatomic,strong) NSNumber* eventId;
@property(nonatomic,strong)UICollectionView* collelctionView;
@property(nonatomic,strong)NSMutableArray* uploadingPhotos;
@end
