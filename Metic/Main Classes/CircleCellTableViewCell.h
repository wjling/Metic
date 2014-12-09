//
//  CircleCellTableViewCell.h
//  WeShare
//
//  Created by ligang6 on 14-12-2.
//  Copyright (c) 2014年 WeShare. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EventDetail2.h"
#import "../Source/ASIHTTPRequest2/ASIHTTPRequest.h"

@interface CircleCellTableViewCell : UITableViewCell<ASIHTTPRequestDelegate>{
    ASIHTTPRequest *videoRequest;
    unsigned long long Recordull;
    BOOL isReady;
}
@property(nonatomic,weak) EventDetail2* controller;

@property(nonatomic,strong) UIImageView* avatar;
@property(nonatomic,strong) UILabel* name;
@property(nonatomic,strong) UILabel* textView;
@property(nonatomic,strong) UIView* photosView;
@property(nonatomic,strong) UIView* videoView;
@property(nonatomic,strong) UIView* videoLayerView;

@property(nonatomic,strong) UIView* controlView;
@property(nonatomic,strong) UILabel* publishTime;
@property(nonatomic,strong) UIButton* zanBtn;
@property(nonatomic,strong) UIButton* commentBtn;


@property(nonatomic,strong) NSString* text;
@property int type;//单文字：0  图片：1 视频：2
- (void)drawCell;
- (void)adjustHeight;
@end
