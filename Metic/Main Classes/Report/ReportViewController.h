//
//  ReportViewController.h
//  WeShare
//
//  Created by ligang6 on 14-8-24.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReportViewController : UIViewController
@property (nonatomic,strong) NSString* event;
@property (nonatomic,strong) NSNumber* eventId;
@property (nonatomic,strong) NSNumber* commentId;
@property (nonatomic,strong) NSNumber* photoId;
@property (strong, nonatomic) IBOutlet UITextField *titleTextField;
@property (strong, nonatomic) IBOutlet UITextView *textView;
@property (nonatomic,strong) NSNumber* type;
@end
