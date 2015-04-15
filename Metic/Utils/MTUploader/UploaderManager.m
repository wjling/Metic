//
//  UploaderManager.m
//  WeShare
//
//  Created by ligang6 on 15-3-7.
//  Copyright (c) 2015年 WeShare. All rights reserved.
//

#import "UploaderManager.h"
#import "uploaderOperation.h"
#import "photoProcesser.h"
#import "CommonUtils.h"
#import "MTUser.h"
#import "BOAlertController.h"
#import "SlideNavigationController.h"

@interface UploaderManager ()


@end

@implementation UploaderManager


+ (id)sharedManager {
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [self new];
    });
    return instance;
}

- (id)init {
    if ((self = [super init])) {
        _uploadQueue = [[NSOperationQueue alloc]init];
        _taskswithPhotoName = [[NSMutableDictionary alloc]init];
        [_uploadQueue setMaxConcurrentOperationCount:1];
//        [_uploadQueue setQualityOfService:NSQualityOfServiceBackground];
    }
    return self;
}

- (void)checkUnfinishedTasks
{
    NSString * path = [NSString stringWithFormat:@"%@/db",[MTUser sharedInstance].userid];
    MySqlite* sql = [[MySqlite alloc]init];
//    [sql openMyDB:path];

    NSArray *seletes = [[NSArray alloc]initWithObjects:@"event_id",@"imgName",@"alasset", nil];
    NSDictionary *wheres = [[NSDictionary alloc] initWithObjectsAndKeys:@"1 order by id ",@"1", nil];
        
//    NSMutableArray *result = [sql queryTable:@"uploadIMGtasks" withSelect:seletes andWhere:wheres];
//    [sql closeMyDB];
    [sql database:path queryTable:@"uploadIMGtasks" withSelect:seletes andWhere:wheres completion:^(NSMutableArray *resultsArray) {
        if (resultsArray.count == 0) return;
        
        NSString* message = [NSString stringWithFormat:@"发现您有 %lu 张图片未上传成功",(unsigned long)resultsArray.count];
        
        BOAlertController *alertView = [[BOAlertController alloc] initWithTitle:@"系统消息" message:message viewController:[SlideNavigationController sharedInstance]];
        
        RIButtonItem *cancelItem = [RIButtonItem itemWithLabel:@"放弃上传" action:^{
            [self removeAlluploadTaskInDB];
        }];
        [alertView addButton:cancelItem type:RIButtonItemType_Cancel];
        
        RIButtonItem *okItem = [RIButtonItem itemWithLabel:@"马上上传" action:^{
            NSLog(@"%@",resultsArray);
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                for (int i = 0; i < resultsArray.count; i++) {
                    NSDictionary *task = resultsArray[i];
                    NSString* alassetStr = [task valueForKey:@"alasset"];
                    NSString* eventId = [task valueForKey:@"event_id"];
                    NSString* imgName = [task valueForKey:@"imgName"];
                    [self uploadImageStr:alassetStr eventId:[CommonUtils NSNumberWithNSString:eventId] imageName:imgName];
                }
            });
            
        }];
        [alertView addButton:okItem type:RIButtonItemType_Other];
        [alertView show];
    }];
    
}

- (void)removeAlluploadTaskInDB
{
    NSString * path = [NSString stringWithFormat:@"%@/db",[MTUser sharedInstance].userid];
    MySqlite* sql = [[MySqlite alloc]init];
//    [sql openMyDB:path];
    NSDictionary *wheres = [[NSDictionary alloc] initWithObjectsAndKeys:@"1",@"1", nil];
    [sql database:path deleteTurpleFromTable:@"uploadIMGtasks" withWhere:wheres completion:nil];
//    [sql deleteTurpleFromTable:@"uploadIMGtasks" withWhere:wheres];
//    [sql closeMyDB];
}

- (void)uploadImage:(ALAsset *)imgAsset eventId:(NSNumber*)eventId
{
    NSString* imageName = [photoProcesser generateImageName];
    uploaderOperation* newUploadTask = [[uploaderOperation alloc]initWithimgAsset:imgAsset eventId:eventId imageName:imageName];
    [_taskswithPhotoName setValue:newUploadTask forKey:imageName];
    [_uploadQueue addOperation:newUploadTask];

}

- (void)uploadImageStr:(NSString *)imgAssetStr eventId:(NSNumber*)eventId imageName:(NSString*)imageName
{
    uploaderOperation* newUploadTask = [[uploaderOperation alloc]initWithimgAssetStr:imgAssetStr eventId:eventId imageName:imageName];
    [_taskswithPhotoName setValue:newUploadTask forKey:imageName];
    [_uploadQueue addOperation:newUploadTask];
    
    
}

- (void)uploadALAssets:(NSArray *)uploadALAssets eventId:(NSNumber*)eventId
{
    if (uploadALAssets.count == 0 || !eventId) {
        return;
    }
    [uploadALAssets enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        ALAsset *representation = obj;
        [self uploadImage:representation eventId:eventId];
    }];
}

- (NSInteger)uploadTaskCountWithEventId:(NSNumber*)eventId
{
    if (!eventId || [eventId integerValue] == 0) return 0;
    NSInteger count = 0;
    for (int i = 0; i < _uploadQueue.operations.count; i++) {
        uploaderOperation* task = _uploadQueue.operations[i];
        if ([task.eventId integerValue] == [eventId integerValue]) count ++;
    }
    return count;
}

@end



