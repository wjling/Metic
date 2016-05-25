//
//  MCommentTableViewCell.m
//  Metic
//
//  Created by ligang6 on 14-6-15.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "MCommentTableViewCell.h"
#import "FriendInfoViewController.h"
#import "ReportViewController.h"
#import "UserInfoViewController.h"
#import "LCAlertView.h"

@interface MCommentTableViewCell ()

@end

@implementation MCommentTableViewCell

- (void)awakeFromNib
{
    // Initialization code
    //长按手势
    UILongPressGestureRecognizer * longRecognizer = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(showOption:)];
    [self addGestureRecognizer:longRecognizer];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)delete_Comment:(id)sender {
    [_controller delete_Comment:sender];
}


- (IBAction)appreciate:(id)sender {
    [_controller appreciate:sender];
}

- (IBAction)pushToFriendView:(id)sender {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone"
															 bundle: nil];

    FriendInfoViewController *friendView = [mainStoryboard instantiateViewControllerWithIdentifier: @"FriendInfoViewController"];
    friendView.fid = self.authorId;
    [_controller.navigationController pushViewController:friendView animated:YES];

}

-(void)showOption:(UIGestureRecognizer*)sender
{
    if ([_commentid intValue]<0) {
        return;
    }
    
    if (sender.state != UIGestureRecognizerStateBegan) return;
    if ([_authorId integerValue] == [[MTUser sharedInstance].userid integerValue]) {
        
        LCAlertView *alert = [[LCAlertView alloc]initWithTitle:@"操作" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"删除",nil];
        alert.alertAction = ^(NSInteger buttonIndex){
            if (buttonIndex == 1) {
                [self delete_Comment:self];
            }
        };
        [alert show];
    }else if ([[_controller.event valueForKey:@"launcher_id"]integerValue] == [[MTUser sharedInstance].userid integerValue])
    {
        LCAlertView *alert = [[LCAlertView alloc]initWithTitle:@"操作" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"删除",@"举报",nil];
        alert.alertAction = ^(NSInteger buttonIndex){
            if (buttonIndex == 1) {
                [self delete_Comment:self];
            }else if (buttonIndex == 2){
                [self report];
            }
        };
        [alert show];
    }else{
        LCAlertView *alert = [[LCAlertView alloc]initWithTitle:@"操作" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"举报",nil];
        alert.alertAction = ^(NSInteger buttonIndex){
            if (buttonIndex == 1) {
                [self report];
            }
            
        };
        [alert show];
    }
}

-(void)report{
    MTLOG(@"匿名投诉");
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone"
                                                                 bundle: nil];
        ReportViewController *viewcontroller = [mainStoryboard instantiateViewControllerWithIdentifier: @"ReportViewController"];
        viewcontroller.eventId = _controller.eventId;
        viewcontroller.commentId = _commentid;
        viewcontroller.comment = _origincomment;
        viewcontroller.commentAuthor = self.author;
        viewcontroller.authorId = self.authorId;
        viewcontroller.event = [self.controller.event valueForKey:@"subject"];
        
        viewcontroller.type = 2;
        [self.controller.navigationController pushViewController:viewcontroller animated:YES];

    });
}

- (void)deleteComment
{
    MTLOG(@"删除评论");
}

@end
