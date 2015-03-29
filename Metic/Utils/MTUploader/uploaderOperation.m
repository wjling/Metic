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

@interface uploaderOperation (){
    BOOL _executing;
    BOOL _finished;
}
@property (nonatomic,strong) NSString* imageName;
@property (nonatomic,strong) NSString* uploadURL;
@property (nonatomic,strong) ALAsset* imageALAsset;
@property (nonatomic,strong) NSString* imageALAssetStr;
@property (nonatomic,strong) NSData* imgData;
@property (nonatomic,strong) NSNumber* eventId;
@property (nonatomic,strong) NSThread* thread;
@property (nonatomic,strong) NSNumber* width;
@property (nonatomic,strong) NSNumber* height;
@property BOOL wait;
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
        [self saveToDB:imgAsset imageName:_imageName];
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

- (void)saveToDB:(ALAsset*)alasset imageName:(NSString*)imageName
{
    NSString * path = [NSString stringWithFormat:@"%@/db",[MTUser sharedInstance].userid];
    MySqlite* sql = [[MySqlite alloc]init];
    [sql openMyDB:path];
    NSURL* aLAssetsURL = [alasset valueForProperty:ALAssetPropertyAssetURL];
    NSString *aLAssetsStr = [aLAssetsURL absoluteString];
    float width = [[alasset defaultRepresentation]dimensions].width;
    float height = [[alasset defaultRepresentation]dimensions].height;;

    NSArray *columns = [[NSArray alloc]initWithObjects:@"'event_id'",@"'imgName'",@"'alasset'",@"'width'",@"'height'", nil];
    NSArray *values = [[NSArray alloc]initWithObjects:[NSString stringWithFormat:@"%@",_eventId],[NSString stringWithFormat:@"'%@'",imageName],[NSString stringWithFormat:@"'%@'",aLAssetsStr],[NSString stringWithFormat:@"%f",width],[NSString stringWithFormat:@"%f",height], nil];
    
    [sql insertToTable:@"uploadIMGtasks" withColumns:columns andValues:values];
    [sql closeMyDB];
}

- (void)removeuploadTaskInDB
{
    NSString * path = [NSString stringWithFormat:@"%@/db",[MTUser sharedInstance].userid];
    MySqlite* sql = [[MySqlite alloc]init];
    [sql openMyDB:path];
    NSDictionary *wheres = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"'%@'",_imageName],@"imgName",[NSString stringWithFormat:@"%@",_eventId],@"event_id", nil];
    [sql deleteTurpleFromTable:@"uploadIMGtasks" withWhere:wheres];
    [sql closeMyDB];
}

- (void)insertPhotoInfoToDB:(NSDictionary*)photoInfo eventId:(NSNumber*)eventId
{
    NSString * path = [NSString stringWithFormat:@"%@/db",[MTUser sharedInstance].userid];
    MySqlite* sql = [[MySqlite alloc]init];
    [sql openMyDB:path];

    NSString *photoData = [NSString jsonStringWithDictionary:photoInfo];
    photoData = [photoData stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    NSArray *columns = [[NSArray alloc]initWithObjects:@"'photo_id'",@"'event_id'",@"'photoInfo'", nil];
    NSArray *values = [[NSArray alloc]initWithObjects:[NSString stringWithFormat:@"%@",[photoInfo valueForKey:@"photo_id"]],[NSString stringWithFormat:@"%@",eventId],[NSString stringWithFormat:@"'%@'",photoData], nil];
    
    [sql insertToTable:@"eventPhotos" withColumns:columns andValues:values];
    
    [sql closeMyDB];
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
    
    if (_imageALAsset) {
        UIImage *img = [UIImage imageWithCGImage:_imageALAsset.defaultRepresentation.fullResolutionImage
                                           scale:_imageALAsset.defaultRepresentation.scale
                                     orientation:(UIImageOrientation)_imageALAsset.defaultRepresentation.orientation];
//        img = [UIImage fixOrientation:img];
        NSDictionary* imgData = [photoProcesser compressPhoto:img maxSize:100];
        
        NSData* compressedData = [imgData valueForKey:@"imageData"];
        _width = [imgData valueForKey:@"width"];
        _height = [imgData valueForKey:@"height"];
        _imgData = compressedData;
        NSLog(@"开始上传任务： %@  %@",_eventId,_imageName);
        NSString* Subpath = [NSString stringWithFormat:@"/images/%@.png",_imageName];
        [self getCloudFileURL:Subpath];
        _wait = YES;
        _thread = [NSThread currentThread];
    }else if(_imageALAssetStr){

        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        NSURL *imageFileURL = [NSURL URLWithString:_imageALAssetStr];
        [library assetForURL:imageFileURL resultBlock:^(ALAsset *asset) {
            
            if (!asset) {
                NSLog(@"图片已不存在");
                [self removeuploadTaskInDB];
                [self stop];
                return ;
            }
            
            UIImage *img = [UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage
                                               scale:asset.defaultRepresentation.scale
                                         orientation:(UIImageOrientation)asset.defaultRepresentation.orientation];
            NSDictionary* imgData = [photoProcesser compressPhoto:img maxSize:100];
            
            NSData* compressedData = [imgData valueForKey:@"imageData"];
            _width = [imgData valueForKey:@"width"];
            _height = [imgData valueForKey:@"height"];
            _imgData = compressedData;
            NSLog(@"开始上传任务： %@  %@",_eventId,_imageName);
            NSString* Subpath = [NSString stringWithFormat:@"/images/%@.png",_imageName];
            [self getCloudFileURL:Subpath];
            _wait = YES;
            _thread = [NSThread currentThread];
            while(_wait) {
                
                [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
                
            }

        } failureBlock:^(NSError *error) {
            NSLog(@"error : %@", error);
            [self removeuploadTaskInDB];
            [self stop];
        }];
    }
    _wait = YES;
    while(_wait) {
        
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        
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
            
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
            
        }
    }];
    
}

-(void)stop
{
    NSLog(@"清理数据 && 退出线程");
    _thread = nil;
    _imageName = nil;
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
        [self performSelector:@selector(reportToServer) onThread:_thread withObject:nil waitUntilDone:NO];

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"上传失败");
        _wait = NO;
        [self performSelector:@selector(stop) onThread:_thread withObject:nil waitUntilDone:NO];
    }];
    _progress = 0;
    
    [op setUploadProgressBlock:^(NSUInteger __unused bytesWritten,
                                 long long totalBytesWritten,
                                 long long totalBytesExpectedToWrite) {
        _progress = ((float)totalBytesWritten)/totalBytesExpectedToWrite;
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
                [self removeuploadTaskInDB];
                [self insertPhotoInfoToDB:response1 eventId:_eventId];
                NSString *url = [CommonUtils getUrl:[NSString stringWithFormat:@"/images/%@",[response1 valueForKey:@"photo_name"]]];
                [[SDImageCache sharedImageCache] storeImageDataToDisk:_imgData forKey:url];
                self.photoInfo = [[NSMutableDictionary alloc]initWithDictionary:response1];
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
        
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        
    }
}

@end
