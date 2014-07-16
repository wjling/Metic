//
//  FriendInfoEventsTableViewCell.h
//  Metic
//
//  Created by mac on 14-7-4.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FriendInfoEventsTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *subject_label;
@property (strong, nonatomic) IBOutlet UILabel *time_label;
@property (strong, nonatomic) IBOutlet UILabel *location_label;
@property (strong, nonatomic) IBOutlet UILabel *launcher_label;
@property (strong, nonatomic) IBOutlet UITextView *remark_textView;
@property (strong, nonatomic) IBOutlet UIButton *add_button;
@property (strong, nonatomic) IBOutlet UILabel *numOfMember_label;
@property (strong, nonatomic,readonly) IBOutlet UIView *contentView;
@property (strong, nonatomic) NSMutableArray* avatars;
@property (strong, nonatomic) UIButton *stretch_button;
@property (readwrite,nonatomic) BOOL isExpanded;


//- (IBAction)stretch_btn_clicked:(id)sender;

@end
