//
//  EventPhotosTableViewCell.h
//  WeShare
//
//  Created by ligang6 on 14-10-7.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventPhotosTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIView *imagesView;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *images;
@property (strong, nonatomic) IBOutlet UIView *info;

@end
