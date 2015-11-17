//
//  myInputView.h
//  WeShare
//
//  Created by ligang_mac4 on 14-10-24.
//  Copyright (c) 2014年 WeShare. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface myInputView : UIView
@property (strong, nonatomic) UITextField *textField;
@property (strong, nonatomic) UILabel *prefix_label;  //通过这个label设置输入框的前缀说明
@property (strong, nonatomic) UIImageView *bgImgView;

@end
