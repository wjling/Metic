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
        [_uploadQueue setMaxConcurrentOperationCount:3];
    }
    return self;
}

- (void)uploadImage:(ALAsset *)imgAsset eventId:(NSNumber*)eventId;
{
    uploaderOperation* newUploadTask = [[uploaderOperation alloc]initWithimgAsset:imgAsset eventId:eventId];
    [_uploadQueue addOperation:newUploadTask];

    
    return;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        UIImage *img = [UIImage imageWithCGImage:imgAsset.defaultRepresentation.fullScreenImage
                                           scale:imgAsset.defaultRepresentation.scale
                                     orientation:(UIImageOrientation)imgAsset.defaultRepresentation.orientation];
        NSData* compressedData = [photoProcesser compressPhoto:img maxSize:100];
        NSString* imgName = [photoProcesser generateImageName];
        [photoProcesser saveImage:compressedData fileName:imgName];
        
        
        uploaderOperation* newUploadTask = [[uploaderOperation alloc]initWithimgAsset:imgAsset eventId:eventId];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [_uploadQueue addOperation:newUploadTask];
        });
    });
}

- (void)uploadALAssets:(NSArray *)uploadALAssets eventId:(NSNumber*)eventId;
{
    if (uploadALAssets.count == 0 || !eventId) {
        return;
    }
    [uploadALAssets enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        ALAsset *representation = obj;
        [self uploadImage:representation eventId:eventId];
    }];
}

@end



