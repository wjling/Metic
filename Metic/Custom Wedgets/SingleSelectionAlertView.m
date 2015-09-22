//
//  SingleSelectionAlertView.m
//  Metic
//
//  Created by mac on 14-7-17.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "SingleSelectionAlertView.h"

@implementation SingleSelectionAlertView
@synthesize numberOfOptions;
@synthesize optionView;
@synthesize title_label;
@synthesize contentView;
@synthesize selectionItems;
@synthesize options;
@synthesize kDelegate;

- (id)initWithContentSize:(CGSize)size withTitle:(NSString*)title withOptions:(NSArray*)theOptions
{
    self = [[SingleSelectionAlertView alloc]init];
    if (self) {
        // Initialization code
        customAlert = [[CustomIOS7AlertView alloc]init];
        customAlert.delegate = self;
        theTitle = title;
        self.options = theOptions;
        self.kSize = size;
        [self initParams];
    }
    return self;
}


- (void)set_Options:(NSArray *)theOptions
{
    self.options = theOptions;
    [self initParams];
}

- (void) initParams
{
    lastSelected = -1;
    self.numberOfOptions = self.options.count;
    self.selectionItems = [[NSMutableArray alloc]init];

    [customAlert setContainerView:[self createContentView]];
    [customAlert setButtonTitles:[NSMutableArray arrayWithObjects:@"取消", @"确定", nil]];
    [customAlert setUseMotionEffects:YES];

}

- (UIView*)createContentView
{
    CGFloat content_width = self.kSize.width;
    CGFloat content_height = 30+30*numberOfOptions; // <=400
    if (content_height > self.kSize.height) {
        content_height = self.kSize.height;
    }
    if (content_height > 400)
    {
        content_height = 400;
    }
    MTLOG(@"width: %f, height: %f",content_width,content_height);
    contentView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, content_width, content_height)];
    [contentView setBackgroundColor:[UIColor clearColor]];
    
    self.title_label = [[UILabel alloc]initWithFrame:CGRectMake(5, 5, content_width-10, 25)];
//    [self.title_label setBackgroundColor:[UIColor lightGrayColor]];
    self.title_label.text = theTitle;
    self.title_label.textAlignment = NSTextAlignmentCenter;
    [self.title_label setBackgroundColor:[UIColor clearColor]];
    self.optionView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 30, content_width, content_height-30)];
    CGSize content_size = CGSizeMake(content_width, 30*numberOfOptions);
    self.optionView.contentSize = content_size;
//    self.content_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    for (int i = 0; i< numberOfOptions; i++) {
        UIView* itemView = [[UIView alloc]initWithFrame:CGRectMake(0, i*30, content_width, 30)];
        UILabel* option_label = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, content_width-40, 30)];
        UIButton* option_button = [[UIButton alloc]initWithFrame:CGRectMake(0, 5, content_width, 20)];
        option_button.imageEdgeInsets = UIEdgeInsetsMake(0, content_width - 35, 0, 15);
        
        UIColor* color1 = [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1];
        UIColor* color2 = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1];
        if (i%2 == 0) {
            [itemView setBackgroundColor:color1];
        }
        else
        {
            [itemView setBackgroundColor:color2];
        }
        
        
        option_label.text = [self.options objectAtIndex:i];
        [option_label setBackgroundColor:[UIColor clearColor]];
        option_button.tag = i;
        [option_button setImage:[UIImage imageNamed:@"勾选前icon"] forState:UIControlStateNormal];
        [option_button setImage:[UIImage imageNamed:@"勾选后icon"] forState:UIControlStateSelected];
        [option_button setSelected:NO];
       
        [option_button  addTarget:self action:@selector(changeButtonStateAfterClicked:) forControlEvents:UIControlEventTouchUpInside];
//        [itemView addGestureRecognizer:tapRecognizeer];
        [itemView addSubview:option_label];
        [itemView addSubview:option_button];
        [self.selectionItems addObject:itemView];
        [self.optionView addSubview:itemView];
        
    }
    [contentView addSubview:self.title_label];
    [contentView addSubview:self.optionView];
    
    return contentView;
}

- (void)changeButtonStateAfterClicked:(id)sender
{

    if (lastSelected != -1) {
        UIView* last = [selectionItems objectAtIndex:lastSelected];
        for (UIView* v in [last subviews]) {
            if ([v isKindOfClass:[UIButton class]]) {
                [(UIButton*)v setSelected:NO];
                break;
            }
        }
    }
    
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton* temp = (UIButton*)sender;
        BOOL flag = [temp isSelected];
        [(UIButton*)sender setSelected:!flag];
    }
    lastSelected = ((UIButton*)sender).tag;
}

- (NSInteger)getSelectedIndex
{
    return lastSelected;
}

- (void)show
{
    [customAlert show];
}

- (void)close
{
    [customAlert close];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)customIOS7dialogButtonTouchUpInside:(id)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
//    MTLOG(@"click custom ios7 dialog button");
    if ([self.kDelegate respondsToSelector:@selector(SingleSelectionAlertView:clickedButtonAtIndex:)]) {
        [self.kDelegate SingleSelectionAlertView:alertView clickedButtonAtIndex:buttonIndex];
    }
    [self close];
    
}

@end
