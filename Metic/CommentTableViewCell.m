//
//  CommentTableViewCell.m
//  Metic
//
//  Created by ligang6 on 14-5-31.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "CommentTableViewCell.h"

@implementation CommentTableViewCell

@synthesize publisher;
@synthesize comment;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        
        // Initialization code
        
        
        
    }
    
    return self;
    
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
