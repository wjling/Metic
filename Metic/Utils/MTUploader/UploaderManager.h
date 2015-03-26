//
//  UploaderManager.h
//  WeShare
//
//  Created by ligang6 on 15-3-7.
//  Copyright (c) 2015年 WeShare. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface UploaderManager : NSObject
@property (strong, nonatomic) NSDictionary* taskswithEventId;
+ (UploaderManager *)sharedManager;
- (void)checkUnfinishedTasks;
- (void)uploadImage:(ALAsset *)imgAsset eventId:(NSNumber*)eventId;
- (void)uploadALAssets:(NSArray *)uploadALAssets eventId:(NSNumber*)eventId;
- (void)uploadImageStr:(NSString *)imgAssetStr eventId:(NSNumber*)eventId imageName:imageName;

@end
