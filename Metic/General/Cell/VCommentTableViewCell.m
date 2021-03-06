//
//  VCommentTableViewCell.m
//  WeShare
//
//  Created by ligang6 on 14-9-2.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//


#import "VCommentTableViewCell.h"
#import "ReportViewController.h"
#import "UserInfoViewController.h"
#import "FriendInfoViewController.h"
#import "LCAlertView.h"

@implementation VCommentTableViewCell

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

- (IBAction)resend:(id)sender {
    
}

-(void)showOption:(UIGestureRecognizer*)sender
{
    if ([_vcomment_id intValue]<0) {
        return;
    }
    
    if (sender.state != UIGestureRecognizerStateBegan) return;
    if ([_authorId integerValue] == [[MTUser sharedInstance].userid integerValue]) {
        
        LCAlertView *alert = [[LCAlertView alloc]initWithTitle:@"操作" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"删除",nil];
        alert.alertAction = ^(NSInteger buttonIndex){
            if (buttonIndex == 1) {
                [self deleteComment];
            }
        };
        [alert show];
    }else if ([_controller.eventLauncherId integerValue] == [[MTUser sharedInstance].userid integerValue]){
        LCAlertView *alert = [[LCAlertView alloc]initWithTitle:@"操作" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"删除",@"举报",nil];
        alert.alertAction = ^(NSInteger buttonIndex){
            if (buttonIndex == 1) {
                [self deleteComment];
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

-(void)dismissOption
{
    MTLOG(@"dismissOption");
    if (_controller.optionShadowView) {
        [_controller.optionShadowView removeFromSuperview];
        _controller.optionShadowView = nil;
    }
    if (_controller.commentOptionView) {
        [_controller.commentOptionView removeFromSuperview];
        _controller.commentOptionView = nil;
        
    }
}

-(void)report{
    MTLOG(@"匿名投诉");
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone"
                                                                     bundle: nil];
            ReportViewController *viewcontroller = [mainStoryboard instantiateViewControllerWithIdentifier: @"ReportViewController"]; ;
            viewcontroller.eventId = _controller.eventId;
            viewcontroller.vcommentId = _vcomment_id;
            viewcontroller.comment = _origincomment;
            viewcontroller.commentAuthor = self.authorName;
            viewcontroller.authorId = self.authorId;
            viewcontroller.event = _controller.eventName;
            viewcontroller.type = 6;
            [self.controller.navigationController pushViewController:viewcontroller animated:YES];
    });
}

- (void)deleteComment
{
    MTLOG(@"删除评论");
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:[MTUser sharedInstance].userid forKey:@"id"];
    [dictionary setValue:self.vcomment_id forKey:@"vcomment_id"];
    [dictionary setValue:_controller.eventId forKey:@"event_id"];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    MTLOG(@"%@",[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding]);
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:DELETE_VCOMMENT finshedBlock:^(NSData *rData) {
        if (!rData) {
            [CommonUtils showSimpleAlertViewWithTitle:@"信息" WithMessage:@"网络异常" WithDelegate:nil WithCancelTitle:@"确定"];
            return;
        }
        NSString* temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
        MTLOG(@"received Data: %@",temp);
        NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
        NSNumber *cmd = [response1 valueForKey:@"cmd"];
        switch ([cmd intValue]) {
            case NORMAL_REPLY:
            {
                [_controller.vcomment_list removeObject:_VcommentDict];
                [self.controller.tableView reloadData];
                [self.controller commentNumMinus];
                
            }
                break;
            case SERVER_ERROR:
            {
                
                [CommonUtils showSimpleAlertViewWithTitle:@"信息" WithMessage:@"评论删除失败" WithDelegate:self WithCancelTitle:@"确定"];
                
            }
                break;
            default:{
                [CommonUtils showSimpleAlertViewWithTitle:@"信息" WithMessage:@"网络异常" WithDelegate:self WithCancelTitle:@"确定"];
            }
        }
    }];
}

- (IBAction)pushToFriendView:(id)sender {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone"
															 bundle: nil];

    FriendInfoViewController *friendView = [mainStoryboard instantiateViewControllerWithIdentifier: @"FriendInfoViewController"];
    friendView.fid = self.authorId;
    [_controller.navigationController pushViewController:friendView animated:YES];
	
}

@end
