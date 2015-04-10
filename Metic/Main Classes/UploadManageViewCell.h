//
//  UploadManageViewCell.h
//  WeShare
//
//  Created by 俊健 on 15/4/10.
//  Copyright (c) 2015年 WeShare. All rights reserved.
//

#import <UIKit/UIKit.h>
@class UploadManageViewController;
@interface UploadManageViewCell : UICollectionViewCell
@property (strong, nonatomic) NSMutableDictionary* photoInfo;
@property (weak, nonatomic) UploadManageViewController* uploadManagerView;
- (void)applyData:(NSMutableDictionary *)photoInfo;
@end
