//
//  MTVideoPlayerViewController.h
//  WeShare
//
//  Created by ligang6 on 14-11-23.
//  Copyright (c) 2014年 WeShare. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "VideoWallViewController.h"
#import "VideoWallTableViewCell.h"

@interface MTVideoPlayerViewController : UIViewController

@property (strong,nonatomic) NSString* videoName;
@property (weak, nonatomic) VideoWallViewController* wall;
@property (weak, nonatomic) VideoWallTableViewCell* cell;
@end
