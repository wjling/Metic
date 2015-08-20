 //
//  uploaderOperation.m
//  WeShare
//
//  Created by ligang6 on 15-3-7.
//  Copyright (c) 2015年 WeShare. All rights reserved.
//

#import "uploaderOperation.h"
#import "photoProcesser.h"
#import "CloudOperation.h"
#import "MTUser.h"
#import "SDWebImageManager.h"
#import "NSString+JSON.h"
#import "UIImage+fixOrien.h"
#import "SDImageCache.h"
#import "UzysAssetsPickerController.h"
#import "MTDatabaseHelper.h"
#import "UploaderManager.h"
#import "BOAlertController.h"
#import "SlideNavigationController.h"
#import "UploadManageViewController.h"
#import "PictureWall2.h"
#import "MTOperation.h"
#import "MegUtils.h"

@interface uploaderOperation (){
    BOOL _executing;
    BOOL _finished;
}
@property (nonatomic,strong) NSString* imageName;
@property (nonatomic,strong) NSString* uploadURL;
@property (nonatomic,strong) ALAsset* imageALAsset;
@property (nonatomic,strong) NSString* imageALAssetStr;
@property (nonatomic,strong) NSData* imgData;
@property (nonatomic,strong) NSThread* thread;
@property (nonatomic,strong) NSNumber* width;
@property (nonatomic,strong) NSNumber* height;
@property (assign, nonatomic, getter = isExecuting) BOOL executing;
@property (assign, nonatomic, getter = isFinished) BOOL finished;
@end


@implementation uploaderOperation
@synthesize executing = _executing;
@synthesize finished = _finished;

- (id)initWithimgAsset:(ALAsset *)imgAsset eventId:(NSNumber*)eventId imageName:(NSString*)imageName{
    if ((self = [super init])) {
        _progress = 0;
        _executing = NO;
        _finished = NO;
        _imageALAsset = imgAsset;
        _eventId = eventId;
        _imageName = imageName;
        _wait = YES;
        [self saveToDB:imgAsset imageName:_imageName];
        [self saveThumbnail];
    }
    return self;
}

- (id)initWithimgAssetStr:(NSString *)imgAssetStr eventId:(NSNumber*)eventId imageName:(NSString*)imageName
{
    if ((self = [super init])) {
        _progress = 0;
        _executing = NO;
        _finished = NO;
        _imageALAssetStr = imgAssetStr;
        _eventId = eventId;
        _imageName = imageName;
        _wait = YES;
    }
    return self;
}

- (void)setFinished:(BOOL)finished {
    [self willChangeValueForKey:@"isFinished"];
    _finished = finished;
    [self didChangeValueForKey:@"isFinished"];
}

- (BOOL)isFinished
{
    return _finished;
}

- (void)setExecuting:(BOOL)executing {
    [self willChangeValueForKey:@"isExecuting"];
    _executing = executing;
    [self didChangeValueForKey:@"isExecuting"];
}

- (BOOL)isExecuting
{
    return _executing;
}

- (void)saveThumbnail
{
    if (_imageALAsset && _imageName) {
        UIImage* thumbnail = [UIImage imageWithCGImage:_imageALAsset.aspectRatioThumbnail];
        [[SDImageCache sharedImageCache] storeImage:thumbnail forKey:_imageName];
    }
}

- (void)saveToDB:(ALAsset*)alasset imageName:(NSString*)imageName
{
    NSURL* aLAssetsURL = [alasset valueForProperty:ALAssetPropertyAssetURL];
    NSString *aLAssetsStr = [aLAssetsURL absoluteString];
    float width = [[alasset defaultRepresentation]dimensions].width;
    float height = [[alasset defaultRepresentation]dimensions].height;;

    NSArray *columns = [[NSArray alloc]initWithObjects:@"'event_id'",@"'imgName'",@"'alasset'",@"'width'",@"'height'", nil];
    NSArray *values = [[NSArray alloc]initWithObjects:[NSString stringWithFormat:@"%@",_eventId],[NSString stringWithFormat:@"'%@'",imageName],[NSString stringWithFormat:@"'%@'",aLAssetsStr],[NSString stringWithFormat:@"%f",width],[NSString stringWithFormat:@"%f",height], nil];
    [[MTDatabaseHelper sharedInstance]insertToTable:@"uploadIMGtasks" withColumns:columns andValues:values];
}

- (void)removeuploadTaskInDB
{
    if (_imageName && _eventId) {
        NSDictionary *wheres = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"'%@'",_imageName],@"imgName",[NSString stringWithFormat:@"%@",_eventId],@"event_id", nil];
        [[MTDatabaseHelper sharedInstance]deleteTurpleFromTable:@"uploadIMGtasks" withWhere:wheres];
    }
}

- (void)insertPhotoInfoToDB:(NSDictionary*)photoInfo eventId:(NSNumber*)eventId
{
    NSString *photoData = [NSString jsonStringWithDictionary:photoInfo];
    photoData = [photoData stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    NSArray *columns = [[NSArray alloc]initWithObjects:@"'photo_id'",@"'event_id'",@"'photoInfo'", nil];
    NSArray *values = [[NSArray alloc]initWithObjects:[NSString stringWithFormat:@"%@",[photoInfo valueForKey:@"photo_id"]],[NSString stringWithFormat:@"%@",eventId],[NSString stringWithFormat:@"'%@'",photoData], nil];
    [[MTDatabaseHelper sharedInstance]insertToTable:@"eventPhotos" withColumns:columns andValues:values];
}

- (void)DBprocessionAfterUpload:(NSDictionary*)photoInfo eventId:(NSNumber*)eventId
{

    NSDictionary *wheres = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"'%@'",_imageName],@"imgName",[NSString stringWithFormat:@"%@",_eventId],@"event_id", nil];
    [[MTDatabaseHelper sharedInstance]deleteTurpleFromTable:@"uploadIMGtasks" withWhere:wheres];

    NSString *photoData = [NSString jsonStringWithDictionary:photoInfo];
    photoData = [photoData stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    NSArray *columns = [[NSArray alloc]initWithObjects:@"'photo_id'",@"'event_id'",@"'photoInfo'", nil];
    NSArray *values = [[NSArray alloc]initWithObjects:[NSString stringWithFormat:@"%@",[photoInfo valueForKey:@"photo_id"]],[NSString stringWithFormat:@"%@",eventId],[NSString stringWithFormat:@"'%@'",photoData], nil];
    [[MTDatabaseHelper sharedInstance]insertToTable:@"eventPhotos" withColumns:columns andValues:values];
}

- (void)start
{
    @autoreleasepool {
        @synchronized (self) {
            if (self.isCancelled) {
                self.finished = YES;
                return;
            }
        }
        self.executing = YES;
        _thread = [NSThread currentThread];
        [self checkEventExisted];
        
        
        _wait = YES;
        while(_wait) {
            
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:2]];
            
        }
        self.executing = NO;
        self.finished = YES;
        if([UploaderManager sharedManager].uploadQueue.operations.count == 0)
        {
            [self postFinishNotification];
        }
    }
    
}

#pragma mark step1:checkEventExisted
-(void)checkEventExisted
{
    NSArray* eventids = @[_eventId];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:eventids forKey:@"sequence"];
    [dictionary setValue:[MTUser sharedInstance].userid forKey:@"id"];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:GET_EVENTS finshedBlock:^(NSData *rData) {
        if (!rData){
            [self stop];
            return ;
        }
        if (rData) {
            NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableContainers error:nil];
            NSNumber *cmd = [response1 valueForKey:@"cmd"];
            BOOL normal_Reply = NO;
            switch ([cmd intValue]) {
                case NORMAL_REPLY:{
                    if (((NSArray*)[response1 valueForKey:@"event_list"]).count > 0) {
                        NSDictionary* dict = [response1 valueForKey:@"event_list"][0];
                        if ([[dict valueForKey:@"isIn"] boolValue]) {
                            normal_Reply = YES;
                            //继续上传图片
                            [self processALAsset];
                        }
                    }
                }
                    break;
                default:
                    break;
            }
            if (!normal_Reply) {
                //此活动不能上传活动
                [self removeuploadTaskInDB];
                [self stop];
            }
            while(_wait) {
                
                [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:2]];
                
            }

        }
        
    }];
}

#pragma mark step2:processALAsset
-(void)processALAsset
{
    if (_imageALAsset) {
        [self beginUpload];
    }else if(_imageALAssetStr){
        
        ALAssetsLibrary *library = [UzysAssetsPickerController defaultAssetsLibrary] ;
        NSURL *imageFileURL = [NSURL URLWithString:_imageALAssetStr];
        [library assetForURL:imageFileURL resultBlock:^(ALAsset *asset) {
            
            if (!asset) {
                NSLog(@"图片已不存在");
                [self removeuploadTaskInDB];
                [self stop];
                return ;
            }
            
            _imageALAsset = asset;
            [self performSelector:@selector(beginUpload) onThread:_thread withObject:nil waitUntilDone:NO];
            
        } failureBlock:^(NSError *error) {
            NSLog(@"error : %@", error);
            [self removeuploadTaskInDB];
            [self stop];
        }];
    }
}
#pragma mark step3:beginUpload
-(void)beginUpload
{
    if (_imageALAsset) {
        NSDictionary* imgData;
        @autoreleasepool {
            UIImage *img = [UIImage imageWithCGImage:_imageALAsset.defaultRepresentation.fullScreenImage
                                               scale:_imageALAsset.defaultRepresentation.scale
                                         orientation:0];
//            img = [UIImage fixOrientation:img];
            imgData = [photoProcesser compressPhoto:img maxWidth:1280 maxSize:360];
            _imageALAsset = nil;
            img = nil;
        }
        NSData* compressedData = [imgData valueForKey:@"imageData"];
        _width = [imgData valueForKey:@"width"];
        _height = [imgData valueForKey:@"height"];
        _imgData = compressedData;
        NSLog(@"开始上传任务： %@  %@",_eventId,_imageName);
        NSString* Subpath = [NSString stringWithFormat:@"/images/%@.png",_imageName];
        [self getCloudFileURL:Subpath];
    }
}

#pragma mark step4:getCloudFileURL
-(void)getCloudFileURL:(NSString*)path
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:@"PUT" forKey:@"method"];
    [dictionary setValue:path forKey:@"object"];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    NSLog(@"%@",[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding]);
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode: GET_FILE_URL finshedBlock:^(NSData *rData) {
        if (!rData){
            [self stop];
            return ;
        }
        if (rData) {
            NSString* temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
            NSLog(@"received Data: %@",temp);
            NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
            NSNumber *cmd = [response1 valueForKey:@"cmd"];
            switch ([cmd intValue]) {
                case NORMAL_REPLY:
                {
                    _uploadURL = (NSString*)[response1 valueForKey:@"url"];
                    NSLog(@"获得上传地址： %@",_uploadURL);
                    [self uploadfile];
                }
                    break;
                default:
                    [self stop];
                    break;
                    
            }
            
        }
        while(_wait) {
            
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:2]];
            
        }
    }];
    
}

#pragma mark step5:uploadfile
-(void)uploadfile
{
    if (!_imgData || !_uploadURL) {
        return;
    }
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:@""]];
    NSString *fileName = [NSString stringWithFormat:@"%@.png",_imageName];
    
    
    NSMutableURLRequest *request = [manager.requestSerializer requestWithMethod:@"PUT" URLString:_uploadURL parameters:@{@"Content-Type":@"image/jpeg",@"Content-Length":@(_imgData.length)}  error:nil];
    [request setHTTPBody:_imgData];
    
    AFHTTPRequestOperation *requestOperation = [manager HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"上传成功");
        [self performSelector:@selector(reportToServer) onThread:_thread withObject:nil waitUntilDone:NO];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"上传失败");
        _imgData = nil;
        _wait = NO;
        [self performSelector:@selector(stop) onThread:_thread withObject:nil waitUntilDone:NO];
    }];
    
    _progress = 0;
    
    [requestOperation setUploadProgressBlock:^(NSUInteger __unused bytesWritten,
                                 long long totalBytesWritten,
                                 long long totalBytesExpectedToWrite) {
        _progress = ((float)totalBytesWritten)/totalBytesExpectedToWrite*0.8f;
        NSLog(@"图片:%@ 进度:%f ",fileName,_progress);
    }];
    [requestOperation start];
}

#pragma mark step6:reportToServer
-(void)reportToServer
{
    NSString* ImgName = [NSString stringWithFormat:@"%@.png",_imageName];
    
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:[MTUser sharedInstance].userid forKey:@"id"];
    [dictionary setValue:self.eventId forKey:@"event_id"];
    [dictionary setValue:@"upload" forKey:@"cmd"];
    [dictionary setValue:ImgName forKey:@"photos"];
    [dictionary setValue:_width  forKey:@"width"];
    [dictionary setValue:_height forKey:@"height"];
    [dictionary setValue:@"" forKey:@"specification"];
    
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendPhotoMessage:dictionary withOperationCode: UPLOADPHOTO finshedBlock:^(NSData *rData) {
        if (!rData) {
            [self stop];
            return ;
        }
        
        NSString* temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
        NSLog(@"received Data: %@",temp);
        NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
        NSNumber *cmd = [response1 valueForKey:@"cmd"];
        switch ([cmd intValue]) {
            case NORMAL_REPLY:
            {
                self.photoInfo = [[NSMutableDictionary alloc]initWithDictionary:response1];
                _progress = 0.9f;
                [self DBprocessionAfterUpload:response1 eventId:_eventId];
                [self savePhotoToCache];

            }
                break;
            case EVENT_NOT_EXIST:
            {
                [self removeuploadTaskInDB];
                [self stop];
            }
            case NOT_IN_EVENT:
            {
                [self removeuploadTaskInDB];
                [self stop];
            }
            default:
            {
                [self removeuploadTaskInDB];
                [self stop];
            }
        }
        
    }];
    while(_wait) {
        
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:2]];
        
    }
}

#pragma mark step7:savePhotoToCache
-(void)savePhotoToCache
{
    NSString *imageName = [NSString stringWithFormat:@"%@.png",_imageName];
    NSString *photoPath = [MegUtils photoImagePathWithImageName:imageName];
    [[SDImageCache sharedImageCache] storeImage:[UIImage imageWithData:_imgData] forKey:photoPath];
    _imgData = nil;
    [[NSNotificationCenter defaultCenter]postNotificationName:@"photoUploadFinished" object:nil userInfo:self.photoInfo];
    [self stop];
    
}

#pragma mark step8:stop
-(void)stop
{
    NSLog(@"清理数据 && 退出线程");
    _thread = nil;
    _uploadURL = nil;
    _imageALAsset = nil;
    _imgData = nil;
    _wait = NO;
    _finished = YES;
}

#pragma mark step9:postFinishNotification
- (void)postFinishNotification
{
    NSArray *seletes = [[NSArray alloc]initWithObjects:@"event_id",@"imgName",@"alasset", nil];
    NSDictionary *wheres = [[NSDictionary alloc] initWithObjectsAndKeys:@"1 order by id ",@"1", nil];
    
    [[MTDatabaseHelper sharedInstance] queryTable:@"uploadIMGtasks" withSelect:seletes andWhere:wheres completion:^(NSMutableArray *resultsArray) {
        if (resultsArray.count == 0) return;
        
        UIApplicationState applicationState = [[UIApplication sharedApplication]applicationState];
        
        switch (applicationState) {
            case UIApplicationStateActive:
            {
                if ([[SlideNavigationController sharedInstance].viewControllers.lastObject isKindOfClass:[UploadManageViewController class]] || [[SlideNavigationController sharedInstance].viewControllers.lastObject isKindOfClass:[PictureWall2 class]]){
                    return;
                }
                NSString* message = [NSString stringWithFormat:@"你有 %lu 张活动图片上传失败 ，是否重新上传",(unsigned long)resultsArray.count];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [[UploaderManager sharedManager] postUploadNotification:resultsArray message:message];
                });
            }
                
                break;
            default:
            {
                NSString* message = [NSString stringWithFormat:@"你有 %lu 张活动图片上传失败 ，是否重新上传",(unsigned long)resultsArray.count];
                UILocalNotification *notification=[[UILocalNotification alloc] init];
                if (notification!=nil) {
                    NSDate *now = [NSDate date];
                    //从现在开始，10秒以后通知
                    notification.fireDate=[now dateByAddingTimeInterval:1];
                    //使用本地时区
                    notification.timeZone=[NSTimeZone defaultTimeZone];
                    notification.alertBody=message;
                    //通知提示音 使用默认的
                    notification.soundName= UILocalNotificationDefaultSoundName;
                    notification.alertAction=NSLocalizedString(@" 马上处理", nil);
                    //这个通知到时间时，你的应用程序右上角显示的数字。
                    notification.applicationIconBadgeNumber = 1;
                    //add key  给这个通知增加key 便于半路取消。nfkey这个key是我自己随便起的。
                    // 假如你的通知不会在还没到时间的时候手动取消 那下面的两行代码你可以不用写了。
                    NSDictionary *dict =[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:resultsArray.count],@"uploadStateNotification",nil];
                    [notification setUserInfo:dict];
                    //启动这个通知
                    [[UIApplication sharedApplication]   scheduleLocalNotification:notification];
                    //这句真的特别特别重要。如果不加这一句，通知到时间了，发现顶部通知栏提示的地方有了，然后你通过通知栏进去，然后你发现通知栏里边还有这个提示
                    //除非你手动清除，这当然不是我们希望的。加上这一句就好了。网上很多代码都没有，就比较郁闷了。
                }
                if ([[SlideNavigationController sharedInstance].viewControllers.lastObject isKindOfClass:[UploadManageViewController class]] || [[SlideNavigationController sharedInstance].viewControllers.lastObject isKindOfClass:[PictureWall2 class]]){
                    return;
                }dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [[UploaderManager sharedManager] postUploadNotification:resultsArray message:message];
                });
                
            }
                break;
        }
    }];
}

@end
