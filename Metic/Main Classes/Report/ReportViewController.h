//
//  ReportViewController.h
//  WeShare
//
//  Created by ligang6 on 14-8-24.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import <UIKit/UIKit.h>
//type case 0:举报用户 case 1:举报活动  case 2:举报活动评论  case 3:举报图片  case 4:举报活动图片评论 case 5:举报视频 case 6:举报视频评论
@interface ReportViewController : UIViewController<UIAlertViewDelegate>
@property (nonatomic,strong) NSString* event;
@property (nonatomic,strong) NSNumber* authorId;
//举报id
@property (nonatomic,strong) NSNumber* userId;
@property (nonatomic,strong) NSNumber* eventId;
@property (nonatomic,strong) NSNumber* commentId;
@property (nonatomic,strong) NSNumber* photoId;
@property (nonatomic,strong) NSNumber* pcommentId;
@property (nonatomic,strong) NSNumber* videoId;
@property (nonatomic,strong) NSNumber* vcommentId;

@property (nonatomic,strong) NSString* commentAuthor;
@property (nonatomic,strong) NSString* comment;
@property (strong, nonatomic) IBOutlet UITextField *titleTextField;
@property (strong, nonatomic) IBOutlet UITextView *textView;
@property NSInteger type;
@property (strong, nonatomic) IBOutlet UIButton *confirm_Button;
- (IBAction)confirm:(id)sender;
@end
