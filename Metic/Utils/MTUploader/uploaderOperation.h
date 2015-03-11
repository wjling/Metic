//
//  uploaderOperation.h
//  WeShare
//
//  Created by ligang6 on 15-3-7.
//  Copyright (c) 2015年 WeShare. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface uploaderOperation : NSOperation
- (id)initWithimgAsset:(ALAsset *)imgAsset eventId:(NSNumber*)eventId;
@end
