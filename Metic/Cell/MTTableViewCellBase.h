//
//  MTTableViewCellBase.h
//  WeShare
//
//  Created by 俊健 on 15/4/27.
//  Copyright (c) 2015年 WeShare. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MTTableViewCellBase : UITableViewCell
@property(nonatomic,weak) UIViewController* controller;
- (void)applyData:(NSDictionary*)data;
@end
