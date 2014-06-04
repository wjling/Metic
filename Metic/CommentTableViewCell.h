//
//  CommentTableViewCell.h
//  Metic
//
//  Created by ligang6 on 14-5-31.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommentTableViewCell : UITableViewCell
{
    IBOutlet UILabel *comment;
    IBOutlet UILabel *publisher;
}

@property(nonatomic,retain) UILabel *comment;
@property(nonatomic,retain) UILabel *publisher;
@end
