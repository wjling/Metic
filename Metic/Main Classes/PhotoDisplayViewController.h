//
//  PhotoDisplayViewController.h
//  Metic
//
//  Created by ligang6 on 14-7-2.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HttpSender.h"
#import "PhotoGetter.h"
#import "UIImageView+MTWebCache.h"
#import "PictureWall2.h"

@interface PhotoDisplayViewController : UIViewController<UIScrollViewDelegate,HttpSenderDelegate>
@property(nonatomic,strong)UIScrollView *scrollView;
//@property(nonatomic,strong)NSMutableDictionary *photoscache;//存放图片uiimage
//@property(nonatomic,strong)NSMutableArray *photoPath_list;//存放图片路径
@property(nonatomic,strong)NSMutableDictionary *photos;//存放图片父uiscrollview
@property(nonatomic,strong)NSMutableArray *photo_list;//存放图片信息数据
@property(nonatomic,strong)NSNumber* photoId;
@property(nonatomic,strong)NSNumber* eventId;
@property(nonatomic,strong)NSNumber* eventLauncherId;
@property(nonatomic,strong)NSString* eventName;
@property (strong, nonatomic) PictureWall2* controller;
@property long photoIndex;
@property BOOL canManage;

@property (strong, nonatomic) IBOutlet UIView *InfoView;

@property (strong, nonatomic) IBOutlet UILabel *pictureDescription;
@property (strong, nonatomic) IBOutlet UIImageView *avatar;
@property (strong, nonatomic) IBOutlet UILabel *pictureAuthor;
@property (strong, nonatomic) IBOutlet UILabel *publishTime;
@property (strong, nonatomic) IBOutlet UILabel *zan_num;
@property (strong, nonatomic) IBOutlet UILabel *comment_num;
@property (strong, nonatomic) IBOutlet UIImageView *commentImg;
@property (strong, nonatomic) IBOutlet UIImageView *goodImg;
@property (strong, nonatomic) IBOutlet UIButton *goodButton;



- (IBAction)appreciate:(id)sender;
- (IBAction)comment:(id)sender;
- (IBAction)comment_buttonDown:(id)sender;

@end
