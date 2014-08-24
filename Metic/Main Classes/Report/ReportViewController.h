//
//  ReportViewController.h
//  WeShare
//
//  Created by ligang6 on 14-8-24.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import <UIKit/UIKit.h>
//type  case 1:举报活动  case 2:举报图片  case 3:举报活动评论
@interface ReportViewController : UIViewController
@property (nonatomic,strong) NSString* event;
@property (nonatomic,strong) NSNumber* authorId;
@property (nonatomic,strong) NSNumber* eventId;
@property (nonatomic,strong) NSNumber* commentId;
@property (nonatomic,strong) NSNumber* photoId;
@property (nonatomic,strong) NSString* commentAuthor;
@property (nonatomic,strong) NSString* comment;
@property (strong, nonatomic) IBOutlet UITextField *titleTextField;
@property (strong, nonatomic) IBOutlet UITextView *textView;
@property NSInteger type;
@end
