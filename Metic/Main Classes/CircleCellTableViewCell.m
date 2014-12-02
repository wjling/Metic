//
//  CircleCellTableViewCell.m
//  WeShare
//
//  Created by ligang6 on 14-12-2.
//  Copyright (c) 2014年 WeShare. All rights reserved.
//

#import "CircleCellTableViewCell.h"
#import "../Source/SDWebImage/UIImageView+WebCache.h"
#import "../Utils/CommonUtils.h"

@implementation CircleCellTableViewCell

- (void)awakeFromNib {
    _avatar = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 32, 32)];
    [_avatar sd_setImageWithURL:nil placeholderImage:[UIImage imageNamed:@"默认用户头像"]];
    [self addSubview:_avatar];
    
    _name = [[UILabel alloc]initWithFrame:CGRectMake(52, 10, 200, 16)];
    _name.font = [UIFont systemFontOfSize:13];
    _name.textColor = [UIColor colorWithRed:52.0/255.0 green:171.0/255.0 blue:139.0/255.0 alpha:1.0f];
    [self addSubview:_name];
    
    _textView = [[UILabel alloc]initWithFrame:CGRectMake(52, 26, 258, 16)];
    _textView.lineBreakMode = NSLineBreakByTruncatingTail;
    _textView.numberOfLines = 0;
    _textView.font = [UIFont systemFontOfSize:14];
    _textView.textColor = [UIColor colorWithWhite:53.0/255.0 alpha:1.0];
    [self addSubview:_textView];
    
    _controlView = [[UIView alloc]initWithFrame:CGRectMake(52, 42, 258, 34)];
    [self addSubview:_controlView];
    
    _publishTime = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 120, 34)];
    _publishTime.textColor = [UIColor colorWithWhite:147.0/255.0 alpha:1.0f];
    _publishTime.font = [UIFont systemFontOfSize:9];
    [_controlView addSubview:_publishTime];
    
    _zanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _zanBtn.frame = CGRectMake(150, 4, 50, 26);
    [_zanBtn setTitle:@"点赞" forState:UIControlStateNormal];
    _zanBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [_zanBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [_zanBtn setBackgroundColor:[UIColor colorWithWhite:238.0/255.0 alpha:1.0f]];
    [_controlView addSubview:_zanBtn];
    
    _commentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _commentBtn.frame = CGRectMake(210, 4, 50, 26);
    [_commentBtn setTitle:@"评论" forState:UIControlStateNormal];
    _commentBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [_commentBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [_commentBtn setBackgroundColor:[UIColor colorWithWhite:238.0/255.0 alpha:1.0f]];
    [_controlView addSubview:_commentBtn];
    
    
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)drawCell
{
    _name.text = @"我是海贼王";
    _publishTime.text = @"两小时前发布";
    _text = @"冬日的天，带着些许凄凉往返于街道两旁，吹冷了谁孤寂的心，我在这里等你。你有在哪里呢......";
    _textView.text = _text;
    
    [self adjustHeight];
}
- (void)adjustHeight
{
    float textHeight = [CommonUtils calculateTextHeight:_text width:258 fontSize:14 isEmotion:NO];
    
    CGRect frame = _textView.frame;
    frame.size.height = textHeight;
    _textView.frame = frame;
    
    frame = _controlView.frame;
    frame.origin.y = CGRectGetMaxY(_textView.frame);
    _controlView.frame = frame;
}

@end
