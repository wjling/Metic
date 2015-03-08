//
//  UploaderManager.h
//  WeShare
//
//  Created by ligang6 on 15-3-7.
//  Copyright (c) 2015年 WeShare. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UploaderManager : NSObject
+ (UploaderManager *)sharedManager;
- (void)uploadImage:(UIImage *)img eventId:(NSNumber*)eventId;;
@end
