//
//  VideoPreviewViewController.h
//  WeShare
//
//  Created by ligang6 on 14-9-4.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface VideoPreviewViewController : UIViewController<UITextViewDelegate>
@property(nonatomic,strong) NSURL* videoURL;
@end
