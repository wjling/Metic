//
//  PhotoBrowserViewController.h
//  WeShare
//
//  Created by 俊健 on 16/2/21.
//  Copyright © 2016年 WeShare. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoBrowserViewController : UIViewController

- (instancetype)initWithEventInfo:(NSDictionary *)eventInfo PhotoDists:(NSArray *)photos showPhotoIndex:(NSInteger)index;
- (void)showPhotoInIndex:(NSInteger)index;
- (void)setTableViewScrollEnabled:(BOOL)scrollEnabled;
- (void)showPhotos;

@end
