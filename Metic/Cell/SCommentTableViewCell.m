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

- (IBAction)delete_Comment:(id)sender {
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:[MTUser sharedInstance].userid forKey:@"id"];
    [dictionary setValue:self.commentid forKey:@"comment_id"];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    NSLog(@"%@",[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding]);
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:DELETE_COMMENT];
}





#pragma mark - HttpSenderDelegate

-(void)finishWithReceivedData:(NSData *)rData
{
    NSString* temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
    NSLog(@"received Data: %@",temp);
    NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
    NSNumber *cmd = [response1 valueForKey:@"cmd"];
    switch ([cmd intValue]) {
        case NORMAL_REPLY:
        {
            
            [CommonUtils showSimpleAlertViewWithTitle:@"信息" WithMessage:@"评论删除成功" WithDelegate:self WithCancelTitle:@"确定"];
            [self.controller pullMainCommentFromAir];
            
        }
            break;
        case SERVER_ERROR:
        {
            
            [CommonUtils showSimpleAlertViewWithTitle:@"信息" WithMessage:@"评论删除失败" WithDelegate:self WithCancelTitle:@"确定"];
            
        }
            break;
    }
}

- (void)mlEmojiLabel:(MLEmojiLabel*)emojiLabel didSelectLink:(NSString*)link withType:(MLEmojiLabelLinkType)type
{
    switch(type){
        case MLEmojiLabelLinkTypeURL:
            NSLog(@"点击了链接%@",link);
            break;
        case MLEmojiLabelLinkTypePhoneNumber:
        {
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone"
                                                                     bundle: nil];
            if ([_authorid intValue] == [[MTUser sharedInstance].userid intValue]) {
                UserInfoViewController* userInfoView = [mainStoryboard instantiateViewControllerWithIdentifier: @"UserInfoViewController"];
                userInfoView.needPopBack = YES;
                [_controller.navigationController pushViewController:userInfoView animated:YES];
                
            }else{
                FriendInfoViewController *friendView = [mainStoryboard instantiateViewControllerWithIdentifier: @"FriendInfoViewController"];
                friendView.fid = _authorid;
                [_controller.navigationController pushViewController:friendView animated:YES];
            }

            NSLog(@"点击了用户%@",link);
        }
            break;
        case MLEmojiLabelLinkTypeEmail:
            NSLog(@"点击了邮箱%@",link);
            break;
        case MLEmojiLabelLinkTypeAt:
            NSLog(@"点击了用户%@",link);
            break;
        case MLEmojiLabelLinkTypePoundSign:
            NSLog(@"点击了话题%@",link);
            break;
        default:
            NSLog(@"点击了不知道啥%@",link);
            break;
    }
    
}

-(void)showOption:(UIGestureRecognizer*)sender
{
    if ([_commentid intValue]<0) {
        return;
    }
    if (_controller.isKeyBoard || _controller.isEmotionOpen) {
        return;
    }
    if (sender.state == UIGestureRecognizerStateBegan) {
        NSLog(@"showOption");
        if (!_controller.optionShadowView) {
            CGRect frame = _controller.view.frame;
            frame.origin = CGPointMake(0, 0);
            _controller.optionShadowView = [[UIView alloc]initWithFrame:frame];
            [_controller.optionShadowView setBackgroundColor:[UIColor blackColor]];
            [_controller.optionShadowView setAlpha:0.4];
            //单击手势
            UITapGestureRecognizer * singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissOption)];
            [_controller.optionShadowView addGestureRecognizer:singleRecognizer];
            
            UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
            _controller.commentOptionView = button;
            frame.origin = CGPointMake(40, (frame.size.height - 40)/2);
            frame.size = CGSizeMake(frame.size.width-80, 40);
            [button setFrame:frame];
            [button setTitle:@"匿名举报" forState:UIControlStateNormal];
            [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
            [button addTarget:self action:@selector(report) forControlEvents:UIControlEventTouchUpInside];
            [button setUserInteractionEnabled:YES];
            [_controller.view addSubview:_controller.optionShadowView];
            [_controller.view addSubview:_controller.commentOptionView];
            [button setBackgroundColor:[UIColor whiteColor]];
            [button.layer setBorderColor:[UIColor darkGrayColor].CGColor];
            [button.layer setBorderWidth:2];
            button.layer.masksToBounds = YES;
            [button.layer setCornerRadius:5];
            [button setAlpha:1.0];
        }
        
    }
}

-(void)dismissOption
{
    NSLog(@"dismissOption");
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
    NSLog(@"匿名投诉");
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (_controller.optionShadowView) {
            [self dismissOption];
            
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
        }
        
    });
}



@end
