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
@property (strong, nonatomic) IBOutlet UIButton *manage_Button;
- (IBAction)manage:(id)sender;
@property (strong, nonatomic) NSMutableArray* fids;
@property (strong, nonatomic) NSNumber* eventId;
@property BOOL canManage;  //必填
@property BOOL visibility; //canManage的情况下 必填
@property BOOL isMine;     //canManage的情况下 必填

@end
