//
//  SquareTableView.m
//  WeShare
//
//  Created by 俊健 on 15/5/4.
//  Copyright (c) 2015年 WeShare. All rights reserved.
//

#import "SquareTableView.h"
#import "SquareTableViewCell.h"

@implementation SquareTableView

-(void)layoutSubviews
{
    [super layoutSubviews];
    NSLog(@"SquareTableView layoutSubviews");

    NSArray* cells = [self visibleCells];
    for (UITableViewCell* cell in cells) {
        if ([cell isKindOfClass:[SquareTableViewCell class]]) {
            CGRect frame = cell.frame;
            CGRect bound = cell.contentView.frame;
            float cha1 = CGRectGetMinY(frame) - self.contentOffset.y;
            float cha2 = CGRectGetMaxY(frame) - self.contentOffset.y;
            
            UIView* detail = ((SquareTableViewCell*)cell).detailView;
            detail.layer.borderColor = [UIColor redColor].CGColor;
            detail.layer.borderWidth = 2;
            CGRect detailFrame = detail.frame;
            
            UIImageView* theme = ((SquareTableViewCell*)cell).themePhoto;
            CGRect themeFrame = theme.frame;

            if (cha1 < 215 && cha2 > 0) {
                detailFrame.size.height = (215.0 - cha1)*92.0/123.0;
                themeFrame.size.height = (215.0 - cha1)*92.0/123.0;
                bound.origin.y = (cha1 - 215.0)*92.0/123.0;
//                bound.size.height = 123 + 92 - cha1/2;
                [cell.contentView setFrame:bound];
                [detail setFrame:detailFrame];
//                [theme setFrame:themeFrame];
            }else{
                detailFrame.size.height = 0;
                themeFrame.size.height = 0;
                bound.origin.y = 0;
//                bound.size.height = 123;
                [cell.contentView setFrame:bound];
                [detail setFrame:detailFrame];
//                [theme setFrame:themeFrame];
            }
        }
        
    }
}
@end
