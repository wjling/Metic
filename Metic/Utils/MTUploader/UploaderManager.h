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
@property (strong, nonatomic) NSDictionary* taskswithPhotoName;
@property (strong, nonatomic) NSOperationQueue *uploadQueue;
+ (UploaderManager *)sharedManager;
- (void)checkUnfinishedTasks;
- (void)postUploadNotification:(NSArray*)resultsArray message:(NSString*)message;
- (void)uploadALAssets:(NSArray *)uploadALAssets eventId:(NSNumber*)eventId imageDescription:(NSString *)imageDescription;
- (void)uploadImage:(ALAsset *)imgAsset eventId:(NSNumber*)eventId imageDescription:(NSString *)imageDescription;
- (void)uploadImageStr:(NSString *)imgAssetStr eventId:(NSNumber*)eventId imageName:(NSString*)imageName imageDescription:(NSString *)imageDescription;
- (NSInteger)uploadTaskCountWithEventId:(NSNumber*)eventId;

@end
