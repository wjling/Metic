//
//  FriendInfoEventsTableViewCell.m
//  Metic
//
//  Created by mac on 14-7-4.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "FriendInfoEventsTableViewCell.h"

@implementation FriendInfoEventsTableViewCell
@synthesize isExpanded ;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    self.avatars = [[NSMutableArray alloc]init];
    self.stretch_button = [[UIButton alloc]init];
    self.stretch_button.tag = 90;
//    self.stretch_button = [[UIButton alloc]initWithFrame:CGRectMake(155, 90, 10, 10)];
//    [self.stretch_button setBackgroundImage:[UIImage imageNamed:@"箭头icon"] forState:UIControlStateNormal];
//    [self.contentView addSubview:self.stretch_button];
    isExpanded = NO;
    MTLOG(@"init cell");
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
    self.avatars = [[NSMutableArray alloc]init];
//    self.stretch_button = [[UIButton alloc]init];
//    self.stretch_button.tag = 90;
    isExpanded = NO;
    MTLOG(@"awake cell");
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

//- (IBAction)stretch_btn_clicked:(id)sender {
//    if (!isExpanded) {
//        CGRect cellFrame = self.frame;
//        cellFrame.size.height = 215;
//        self.frame = cellFrame;
//        isExpanded = YES;
//        UIView* v = self;
//        while (![v isKindOfClass:[UITableView class]]) {
//            v = [v superview];
//        }
//        if ([v isKindOfClass:[UITableView class]]) {
//            MTLOG(@"cell reload");
//            [(UITableView*)v beginUpdates];
//        }
//        for (UIImageView* imgv in self.avatars) {
//            imgv.hidden = NO;
//            MTLOG(@"set hidden NO");
//        }
//    }
//    else
//    {
//        CGRect cellFrame = self.frame;
//        cellFrame.size.height = 115;
//        self.frame = cellFrame;
//        isExpanded = NO;
//        
//        UIView* v = self;
//        
//        while (![v isKindOfClass:[UITableView class]]) {
//            v = [v superview];
//        }
//        if ([v isKindOfClass:[UITableView class]]) {
//            MTLOG(@"cell reload");
//            [(UITableView*)v beginUpdates];
//        }
//        for (UIImageView* imgv in self.avatars) {
//            imgv.hidden = YES;
//            MTLOG(@"set hidden YES");
//        }
//
//
//    }
//}
@end
