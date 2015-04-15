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
    NSString * path = [NSString stringWithFormat:@"%@/db",[MTUser sharedInstance].userid];
    MySqlite* sql = [[MySqlite alloc]init];
//    [sql openMyDB:path];
    NSURL* aLAssetsURL = [alasset valueForProperty:ALAssetPropertyAssetURL];
    NSString *aLAssetsStr = [aLAssetsURL absoluteString];
    float width = [[alasset defaultRepresentation]dimensions].width;
    float height = [[alasset defaultRepresentation]dimensions].height;;

    NSArray *columns = [[NSArray alloc]initWithObjects:@"'event_id'",@"'imgName'",@"'alasset'",@"'width'",@"'height'", nil];
    NSArray *values = [[NSArray alloc]initWithObjects:[NSString stringWithFormat:@"%@",_eventId],[NSString stringWithFormat:@"'%@'",imageName],[NSString stringWithFormat:@"'%@'",aLAssetsStr],[NSString stringWithFormat:@"%f",width],[NSString stringWithFormat:@"%f",height], nil];
    
    [sql database:path insertToTable:@"uploadIMGtasks" withColumns:columns andValues:values completion:nil];
//    [sql insertToTable:@"uploadIMGtasks" withColumns:columns andValues:values];
//    [sql closeMyDB];
}

- (void)removeuploadTaskInDB
{
    if (_imageName && _eventId) {
        NSString * path = [NSString stringWithFormat:@"%@/db",[MTUser sharedInstance].userid];
        MySqlite* sql = [[MySqlite alloc]init];
//        [sql openMyDB:path];
        NSDictionary *wheres = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"'%@'",_imageName],@"imgName",[NSString stringWithFormat:@"%@",_eventId],@"event_id", nil];
        [sql database:path deleteTurpleFromTable:@"uploadIMGtasks" withWhere:wheres completion:nil];
//        [sql deleteTurpleFromTable:@"uploadIMGtasks" withWhere:wheres];
//        [sql closeMyDB];
    }
}

- (void)insertPhotoInfoToDB:(NSDictionary*)photoInfo eventId:(NSNumber*)eventId
{
    NSString * path = [NSString stringWithFormat:@"%@/db",[MTUser sharedInstance].userid];
    MySqlite* sql = [[MySqlite alloc]init];
//    [sql openMyDB:path];

    NSString *photoData = [NSString jsonStringWithDictionary:photoInfo];
    photoData = [photoData stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    NSArray *columns = [[NSArray alloc]initWithObjects:@"'photo_id'",@"'event_id'",@"'photoInfo'", nil];
    NSArray *values = [[NSArray alloc]initWithObjects:[NSString stringWithFormat:@"%@",[photoInfo valueForKey:@"photo_id"]],[NSString stringWithFormat:@"%@",eventId],[NSString stringWithFormat:@"'%@'",photoData], nil];
    [sql database:path insertToTable:@"eventPhotos" withColumns:columns andValues:values completion:nil];
//    [sql insertToTable:@"eventPhotos" withColumns:columns andValues:values];
    
//    [sql closeMyDB];
}

- (void)DBprocessionAfterUpload:(NSDictionary*)photoInfo eventId:(NSNumber*)eventId
{
    NSString * path = [NSString stringWithFormat:@"%@/db",[MTUser sharedInstance].userid];
    MySqlite* sql = [[MySqlite alloc]init];
//    [sql openMyDB:path];
    NSDictionary *wheres = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"'%@'",_imageName],@"imgName",[NSString stringWithFormat:@"%@",_eventId],@"event_id", nil];
//    [sql deleteTurpleFromTable:@"uploadIMGtasks" withWhere:wheres];
    [sql database:path deleteTurpleFromTable:@"uploadIMGtasks" withWhere:wheres completion:nil];
    
    NSString *photoData = [NSString jsonStringWithDictionary:photoInfo];
    photoData = [photoData stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    NSArray *columns = [[NSArray alloc]initWithObjects:@"'photo_id'",@"'event_id'",@"'photoInfo'", nil];
    NSArray *values = [[NSArray alloc]initWithObjects:[NSString stringWithFormat:@"%@",[photoInfo valueForKey:@"photo_id"]],[NSString stringWithFormat:@"%@",eventId],[NSString stringWithFormat:@"'%@'",photoData], nil];
    
//    [sql insertToTable:@"eventPhotos" withColumns:columns andValues:values];
    [sql database:path insertToTable:@"eventPhotos" withColumns:columns andValues:values completion:nil];
//    [sql closeMyDB];
}

- (void)start
{
    @synchronized (self) {
        if (self.isCancelled) {
            self.finished = YES;
//            [self reset];
            return;
        }
    }
    self.executing = YES;
    _thread = [NSThread currentThread];
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
    _wait = YES;
    while(_wait) {
        
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:2]];
        
    }
    self.executing = NO;
    self.finished = YES;
}

-(void)beginUpload
{
    if (_imageALAsset) {
        NSDictionary* imgData;
        @autoreleasepool {
            UIImage *img = [UIImage imageWithCGImage:_imageALAsset.defaultRepresentation.fullResolutionImage
                                               scale:_imageALAsset.defaultRepresentation.scale
                                         orientation:(UIImageOrientation)_imageALAsset.defaultRepresentation.orientation];
            //        img = [UIImage fixOrientation:img];
            imgData = [photoProcesser compressPhoto:img maxSize:100];
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

-(void)getCloudFileURL:(NSString*)path
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:@"POST" forKey:@"method"];
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

-(void)uploadfile
{
    if (!_imgData || !_uploadURL) {
        return;
    }
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:@""]];
    NSString *fileName = [NSString stringWithFormat:@"%@.png",_imageName];
    
    AFHTTPRequestOperation *op = [manager POST:_uploadURL parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:_imgData name:@"file" fileName:fileName mimeType:@"image/jpeg"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"上传成功");
//        _imgData = nil;
        [self performSelector:@selector(reportToServer) onThread:_thread withObject:nil waitUntilDone:NO];

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"上传失败");
        _imgData = nil;
        _wait = NO;
        [self performSelector:@selector(stop) onThread:_thread withObject:nil waitUntilDone:NO];
    }];
    _progress = 0;
    
    [op setUploadProgressBlock:^(NSUInteger __unused bytesWritten,
                                 long long totalBytesWritten,
                                 long long totalBytesExpectedToWrite) {
        _progress = ((float)totalBytesWritten)/totalBytesExpectedToWrite*0.8f;
        NSLog(@"图片:%@ 进度:%f ",fileName,_progress);
    }];
    [op start];
}

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
                NSString *url = [CommonUtils getUrl:[NSString stringWithFormat:@"/images/%@",[response1 valueForKey:@"photo_name"]]];
                [[SDImageCache sharedImageCache] storeImageDataToDisk:_imgData forKey:url];
                _imgData = nil;
                [[NSNotificationCenter defaultCenter]postNotificationName:@"photoUploadFinished" object:nil userInfo:self.photoInfo];
                [self stop];
            }
                break;
            default:
            {
                [self stop];
            }
        }
        
    }];
    while(_wait) {
        
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:2]];
        
    }
}

@end
