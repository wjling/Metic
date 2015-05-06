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

            if (cha1 < 215 && cha2 > 0) {
                float detailH = (215.0 - cha1)*92.0/123.0;
                detailFrame.size.height = detailH > 92? 92:detailH;
                bound.origin.y = (cha1 - 215.0)*92.0/123.0;
                [cell.contentView setFrame:bound];
                [detail setFrame:detailFrame];
            }else{
                detailFrame.size.height = 0;
                bound.origin.y = 0;
                [cell.contentView setFrame:bound];
                [detail setFrame:detailFrame];
            }
        }else if ([cell tag] == 110){
            UIView* contentV = [cell viewWithTag:112];
            if (contentV) {
                contentV.layer.borderColor = [UIColor blueColor].CGColor;
                contentV.layer.borderWidth = 2;
                CGRect frame = cell.frame;
                CGRect bound = contentV.frame;
                float cha1 = CGRectGetMaxY(frame) - self.contentOffset.y;
                
                if (cha1 < 215 && cha1 > 0) {
                    bound.origin.y = (cha1 - 215.0)*92.0/123.0;
                    [contentV setFrame:bound];
                }else{
                    bound.origin.y = 0;
                    [contentV setFrame:bound];
                }

            }
        }
    }
}
@end
