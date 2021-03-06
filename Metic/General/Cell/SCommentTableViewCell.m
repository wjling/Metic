//
//  SCommentTableViewCell.m
//  Metic
//
//  Created by ligang6 on 14-6-15.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "SCommentTableViewCell.h"
#import "FriendInfoViewController.h"
#import "ReportViewController.h"
#import "UserInfoViewController.h"
#import "LCAlertView.h"

@implementation SCommentTableViewCell

- (void)awakeFromNib
{
    self.comment.emojiDelegate = self;
    //长按手势
    UILongPressGestureRecognizer * longRecognizer = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(showOption:)];
    [self addGestureRecognizer:longRecognizer];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)delete_Comment:(id)sender {
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:[MTUser sharedInstance].userid forKey:@"id"];
    [dictionary setValue:self.commentid forKey:@"comment_id"];
    [dictionary setValue:_controller.eventId forKey:@"event_id"];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    MTLOG(@"%@",[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding]);
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:DELETE_COMMENT finshedBlock:^(NSData *rData) {
        if (!rData) {
            [CommonUtils showSimpleAlertViewWithTitle:@"信息" WithMessage:@"网络异常" WithDelegate:self WithCancelTitle:@"确定"];
        }
        NSString* temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
        MTLOG(@"received Data: %@",temp);
        NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
        NSNumber *cmd = [response1 valueForKey:@"cmd"];
        switch ([cmd intValue]) {
            case NORMAL_REPLY:
            {
                [_McommentArr removeObject:_ScommentDict];
                if (_McommentArr.count) {
                    NSMutableDictionary* Mcomment = _McommentArr[0];
                    int comN = [[Mcomment valueForKey:@"comment_num"]intValue];
                    comN --;
                    if (comN < 0) comN = 0;
                    [Mcomment setValue:[NSNumber numberWithInt:comN] forKey:@"comment_num"];
                }
                
                [self.controller.tableView reloadData];
                
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


- (void)mlEmojiLabel:(MLEmojiLabel*)emojiLabel didSelectLink:(NSString*)link withType:(MLEmojiLabelLinkType)type
{
    switch(type){
        case MLEmojiLabelLinkTypeURL:
            MTLOG(@"点击了链接%@",link);
            break;
        case MLEmojiLabelLinkTypePhoneNumber:
        {
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone"
                                                                     bundle: nil];

            FriendInfoViewController *friendView = [mainStoryboard instantiateViewControllerWithIdentifier: @"FriendInfoViewController"];
            friendView.fid = _authorid;
            [_controller.navigationController pushViewController:friendView animated:YES];
            

            MTLOG(@"点击了用户%@",link);
        }
            break;
        case MLEmojiLabelLinkTypeEmail:
            MTLOG(@"点击了邮箱%@",link);
            break;
        case MLEmojiLabelLinkTypeAt:
            MTLOG(@"点击了用户%@",link);
            break;
        case MLEmojiLabelLinkTypePoundSign:
            MTLOG(@"点击了话题%@",link);
            break;
        default:
            MTLOG(@"点击了不知道啥%@",link);
            break;
    }
    
}

-(void)showOption:(UIGestureRecognizer*)sender
{
    if ([_commentid intValue]<0) {
        return;
    }
    
    if (sender.state != UIGestureRecognizerStateBegan) return;
    if ([_authorid integerValue] == [[MTUser sharedInstance].userid integerValue]) {

        LCAlertView *alert = [[LCAlertView alloc]initWithTitle:@"操作" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"删除",nil];
        alert.alertAction = ^(NSInteger buttonIndex){
            if (buttonIndex == 1) {
                [self delete_Comment:nil];
            }
        };
        [alert show];
    }else if ([[_controller.event valueForKey:@"launcher_id"]integerValue] == [[MTUser sharedInstance].userid integerValue])
    {
        LCAlertView *alert = [[LCAlertView alloc]initWithTitle:@"操作" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"删除",@"举报",nil];
        alert.alertAction = ^(NSInteger buttonIndex){
            if (buttonIndex == 1) {
                [self delete_Comment:nil];
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
        ReportViewController *viewcontroller = [mainStoryboard instantiateViewControllerWithIdentifier: @"ReportViewController"]; ;
        viewcontroller.eventId = _controller.eventId;
        viewcontroller.commentId = _commentid;
        viewcontroller.comment = _originComment;
        viewcontroller.commentAuthor = self.author;
        viewcontroller.authorId = self.authorid;
        viewcontroller.event = [self.controller.event valueForKey:@"subject"];;
        
        viewcontroller.type = 2;
        [self.controller.navigationController pushViewController:viewcontroller animated:YES];
        
    });
}

- (void)deleteComment
{
    MTLOG(@"删除评论");
}

@end
