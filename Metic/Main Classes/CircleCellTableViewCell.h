//
//  CircleCellTableViewCell.h
//  WeShare
//
//  Created by ligang6 on 14-12-2.
//  Copyright (c) 2014年 WeShare. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CircleCellTableViewCell : UITableViewCell
@property(nonatomic,strong) UIImageView* avatar;
@property(nonatomic,strong) UILabel* name;
@property(nonatomic,strong) UILabel* textView;
@property(nonatomic,strong) UIView* controlView;
@property(nonatomic,strong) UILabel* publishTime;
@property(nonatomic,strong) UIButton* zanBtn;
@property(nonatomic,strong) UIButton* commentBtn;


@property(nonatomic,strong) NSString* text;
- (void)drawCell;
- (void)adjustHeight;
@end
