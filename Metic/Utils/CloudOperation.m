//
//  HttpSender.m
//  Metis
//
//  Created by mac on 14-5-19.
//  Copyright (c) 2014年 mac. All rights reserved.
//

#import "CloudOperation.h"
#import "HttpSender.h"
#import "UIImageView+MTWebCache.h"

#import "../Main Classes/MTUser.h"
@interface CloudOperation()
@property BOOL shouldExit;
@property (nonatomic,strong) NSNumber* authorId;

@end

@implementation CloudOperation

@synthesize myConnection;
@synthesize mDelegate;
@synthesize responseData;


-(id)initWithDelegate:(id)delegate
{
    self = [super init];
    httpURL = @"";
    COtype = 0;
    responseData = [[NSMutableData alloc]init];
    mDelegate = delegate;
    _shouldExit = NO;
    return self;
}

-(NSString*)parseOperationCode:(int)operationCode
{
    NSString* resultCode;
    switch (operationCode) {
        case 1:
            resultCode = @"GET";
            break;
        case 2:
            resultCode = @"POST";
            break;
        case 3:
            resultCode = @"DELETE";
            break;
        default:
            resultCode = @"";
            break;
    }
    return resultCode;
}


-(void)CloudToDo:(int)type path:(NSString*)path uploadPath:(NSString*)uploadpath container:(UIImageView*)container authorId:(NSNumber *)authorId
{
    COtype = type;
    mpath = path;
    img = container;
    uploadFilePath = uploadpath;
    _authorId = authorId;
    
    
    
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:[self parseOperationCode:type] forKey:@"method"];
    [dictionary setValue:path forKey:@"object"];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    NSLog(@"%@",[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding]);
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode: GET_FILE_URL finshedBlock:^(NSData *rData) {
        if (rData) {
            _shouldExit = YES;
            NSString* temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
            NSLog(@"received Data: %@",temp);
            NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
            NSNumber *cmd = [response1 valueForKey:@"cmd"];
            switch ([cmd intValue]) {
                case NORMAL_REPLY:
                {
                    httpURL = (NSString*)[response1 valueForKey:@"url"];
                    switch (COtype) {
                        case 1:
                            break;
                        case 2:
                            [self uploadfile:httpURL path:uploadFilePath];
                            break;
                        case 3:
                            [self deletefile:httpURL];
                            break;
                            
                        default:
                            break;
                    }
                }
                    break;
                default:
                    if(COtype == 2){
                        [self.mDelegate finishwithOperationStatus:NO type:2 data:nil path:mpath];
                    }
                    break;
                    
            }

        }else if(COtype == 2){
            [self.mDelegate finishwithOperationStatus:NO type:2 data:nil path:mpath];
        }
       
    }];
    //[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:1]];


}









-(void)uploadfile:(NSString*)url path:(NSString*)path;
{
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:@""]];
    NSData *fileData = [NSData dataWithContentsOfFile:path];
    NSRange range = [path rangeOfString:@"/" options:NSBackwardsSearch];
    NSString *fileName = [path substringFromIndex:range.location+1];
    AFHTTPRequestOperation *op = [manager POST:url parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        [formData appendPartWithFileData:fileData name:@"file" fileName:fileName mimeType:_mineType];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self.mDelegate finishwithOperationStatus:YES type:2 data:fileData path:mpath];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self.mDelegate finishwithOperationStatus:NO type:2 data:nil path:mpath];
    }];
    [op setUploadProgressBlock:^(NSUInteger __unused bytesWritten,
                                        long long totalBytesWritten,
                                        long long totalBytesExpectedToWrite) {
        if (_shouldRecordProgress) {
            float progress = ((float)totalBytesWritten)/totalBytesExpectedToWrite;
            NSDictionary* dictionary = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:progress],@"progress",[NSNumber numberWithFloat:0.6],@"weight",[NSNumber numberWithFloat:0.2],@"finished",nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"uploadFile"
                                                                object:nil
                                                              userInfo:dictionary];
        }
        
    }];
    [op start];
}

-(void)deletefile:(NSString*)url
{
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:@""]];
    AFHTTPRequestOperation *op = [manager DELETE:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self.mDelegate finishwithOperationStatus:YES type:3 data:nil path:mpath];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self.mDelegate finishwithOperationStatus:NO type:3 data:nil path:mpath];
    }];
    [op start];
}

-(void)deletePhoto:(NSString*)path
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:@"DELETE" forKey:@"method"];
    [dictionary setValue:path forKey:@"object"];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    NSLog(@"%@",[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding]);
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode: GET_FILE_URL finshedBlock:^(NSData *rData) {
        if (rData) {
            NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
            NSNumber *cmd = [response1 valueForKey:@"cmd"];
            switch ([cmd intValue]) {
                case NORMAL_REPLY:
                {
                    httpURL = (NSString*)[response1 valueForKey:@"url"];
                    NSLog(@"Delete url: %@",httpURL);
                    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:@""]];
                    AFHTTPRequestOperation *op = [manager DELETE:httpURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                        [self.mDelegate finishwithOperationStatus:YES type:3 data:nil path:mpath];
                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                        [self.mDelegate finishwithOperationStatus:NO type:3 data:nil path:mpath];
                    }];
                    [op start];
                }
                    break;
                default:{
                    [self.mDelegate finishwithOperationStatus:NO type:3 data:nil path:mpath];
                }
            }
        }else{
            [self.mDelegate finishwithOperationStatus:NO type:3 data:nil path:mpath];
        }
    }];
}

#pragma mark - HttpSenderDelegate

-(void)finishWithReceivedData:(NSData *)rData
{
    
    _shouldExit = YES;
    NSString* temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
    NSLog(@"received Data: %@",temp);
    NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
    NSNumber *cmd = [response1 valueForKey:@"cmd"];
    switch ([cmd intValue]) {
        case NORMAL_REPLY:
        {
            httpURL = (NSString*)[response1 valueForKey:@"url"];
            switch (COtype) {
                case 1:
                    break;
                case 2:
                    [self uploadfile:httpURL path:uploadFilePath];
                    break;
                case 3:
                    [self deletefile:httpURL];
                    break;
                    
                default:
                    break;
            }
        }
            break;
    }
}


@end
