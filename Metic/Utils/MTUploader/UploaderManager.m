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
@property (strong, nonatomic) NSOperationQueue *uploadQueue;

@end

@implementation UploaderManager


/*
功能：
 1.线程池管理上传队列，最多3个线程同时进行上传
 2.每个线程能够记录上传的进度
 3.控制上传队列全部暂停、继续
 
 
 
 
 
 */




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
        _taskswithEventId = [[NSMutableDictionary alloc]init];
        [_uploadQueue setMaxConcurrentOperationCount:3];
    }
    return self;
}

- (void)checkUnfinishedTasks
{
    NSString * path = [NSString stringWithFormat:@"%@/db",[MTUser sharedInstance].userid];
    MySqlite* sql = [[MySqlite alloc]init];
    [sql openMyDB:path];

    NSArray *seletes = [[NSArray alloc]initWithObjects:@"event_id",@"imgName",@"alasset", nil];
    NSDictionary *wheres = [[NSDictionary alloc] initWithObjectsAndKeys:@"1 order by id ",@"1", nil];
        
    NSMutableArray *result = [sql queryTable:@"uploadIMGtasks" withSelect:seletes andWhere:wheres];
    [sql closeMyDB];
    
    if (result.count == 0) return;
    
    NSString* message = [NSString stringWithFormat:@"发现您有 %lu 张图片未上传成功",(unsigned long)result.count];
    
    BOAlertController *alertView = [[BOAlertController alloc] initWithTitle:@"系统消息" message:message viewController:[SlideNavigationController sharedInstance]];
    
    RIButtonItem *cancelItem = [RIButtonItem itemWithLabel:@"放弃上传" action:^{
        [self removeAlluploadTaskInDB];
    }];
    [alertView addButton:cancelItem type:RIButtonItemType_Cancel];
    
    RIButtonItem *okItem = [RIButtonItem itemWithLabel:@"马上上传" action:^{
        NSLog(@"%@",result);
        for (int i = 0; i < result.count; i++) {
            NSDictionary *task = result[i];
            NSString* alassetStr = [task valueForKey:@"alasset"];
            NSString* eventId = [task valueForKey:@"event_id"];
            NSString* imgName = [task valueForKey:@"imgName"];
            [self uploadImageStr:alassetStr eventId:[CommonUtils NSNumberWithNSString:eventId] imageName:imgName];
        }
    }];
    [alertView addButton:okItem type:RIButtonItemType_Other];
    [alertView show];
}

- (void)removeAlluploadTaskInDB
{
    NSString * path = [NSString stringWithFormat:@"%@/db",[MTUser sharedInstance].userid];
    MySqlite* sql = [[MySqlite alloc]init];
    [sql openMyDB:path];
    NSDictionary *wheres = [[NSDictionary alloc] initWithObjectsAndKeys:@"1",@"1", nil];
    [sql deleteTurpleFromTable:@"uploadIMGtasks" withWhere:wheres];
    [sql closeMyDB];
}

- (void)uploadImage:(ALAsset *)imgAsset eventId:(NSNumber*)eventId
{
    uploaderOperation* newUploadTask = [[uploaderOperation alloc]initWithimgAsset:imgAsset eventId:eventId];
//    NSMutableArray* tasksArraywithEventID = [_taskswithEventId valueForKey:[CommonUtils NSStringWithNSNumber:eventId]];
//    if (!tasksArraywithEventID) {
//        tasksArraywithEventID = [[NSMutableArray alloc]init];
//        [_taskswithEventId setValue:tasksArraywithEventID forKey:[CommonUtils NSStringWithNSNumber:eventId]];
//    }
//    [tasksArraywithEventID addObject:newUploadTask];
    [_uploadQueue addOperation:newUploadTask];

}

- (void)uploadImageStr:(NSString *)imgAssetStr eventId:(NSNumber*)eventId imageName:(NSString*)imageName
{
    uploaderOperation* newUploadTask = [[uploaderOperation alloc]initWithimgAssetStr:imgAssetStr eventId:eventId imageName:imageName];
//    NSMutableArray* tasksArraywithEventID = [_taskswithEventId valueForKey:[CommonUtils NSStringWithNSNumber:eventId]];
//    if (!tasksArraywithEventID) {
//        tasksArraywithEventID = [[NSMutableArray alloc]init];
//        [_taskswithEventId setValue:tasksArraywithEventID forKey:[CommonUtils NSStringWithNSNumber:eventId]];
//    }
//    [tasksArraywithEventID addObject:newUploadTask];
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

//- (void)uploadALAssetsStr:(NSArray *)uploadALAssetsStr eventId:(NSNumber*)eventId
//{
//    if (uploadALAssetsStr.count == 0 || !eventId) {
//        return;
//    }
//    [uploadALAssetsStr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//        ALAsset *aLAsset = obj;
//        NSURL* aLAssetsURL = [aLAsset valueForProperty:ALAssetPropertyAssetURL];
//        NSString *aLAssetsStr = [aLAssetsURL absoluteString];
//        [self uploadImageStr:aLAssetsStr eventId:eventId];
//    }];
//}

@end



