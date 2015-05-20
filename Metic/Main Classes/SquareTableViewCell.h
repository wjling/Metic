//
//  SquareTableViewCell.h
//  WeShare
//
//  Created by 俊健 on 15/5/4.
//  Copyright (c) 2015年 WeShare. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SquareTableViewCell : UITableViewCell
@property (nonatomic,strong) IBOutlet UIImageView *themePhoto;
@property (nonatomic,strong) IBOutlet UIImageView *avatar;
@property (nonatomic,strong) IBOutlet UILabel *subject;
@property (strong, nonatomic) IBOutlet UILabel *viewcount;


@property (nonatomic,strong) NSDictionary *eventInfo;
- (void)applyData:(NSDictionary*)data;
@end
