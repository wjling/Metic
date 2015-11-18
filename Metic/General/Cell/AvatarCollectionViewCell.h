//
//  AvatarCollectionViewCell.h
//  WeShare
//
//  Created by 俊健 on 15/8/29.
//  Copyright (c) 2015年 WeShare. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AvatarCollectionViewCell : UICollectionViewCell
@property (nonatomic,strong) IBOutlet UILabel *name;
@property (nonatomic,strong) IBOutlet UIImageView *avatar;
@property (nonatomic,strong) IBOutlet UIImageView *deleteIcon;
@property (nonatomic,strong) IBOutlet UIImageView *mask;
@end
