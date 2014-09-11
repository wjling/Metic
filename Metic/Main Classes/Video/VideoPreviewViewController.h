//
//  VideoPreviewViewController.h
//  WeShare
//
//  Created by ligang6 on 14-9-4.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "../../Utils/PhotoGetter.h"

@interface VideoPreviewViewController : UIViewController<UITextViewDelegate,PhotoGetterDelegate>
{
    UIAlertView*                                        _alert;
    NSString*                                           _mp4Path;
}
@property(nonatomic,strong) NSURL* videoURL;
@property(nonatomic,strong) NSNumber* eventId;
@end
