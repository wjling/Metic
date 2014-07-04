//
//  HttpSender.m
//  Metis
//
//  Created by mac on 14-5-19.
//  Copyright (c) 2014年 mac. All rights reserved.
//

#import "CloudOperation.h"
#import "HttpSender.h"

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
    return self;
}

-(NSString*)parseOperationCode:(int)operationCode
{
    NSString* resultCode = [NSString alloc];
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


-(void)CloudToDo:(int)type path:(NSString*)path uploadPath:(NSString*)uploadpath
{
    COtype = type;
    mpath = path;
    if(type == 2) uploadFilePath = uploadpath;
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:[self parseOperationCode:type] forKey:@"method"];
    [dictionary setValue:path forKey:@"object"];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    NSLog(@"%@",[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding]);
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode: GET_FILE_URL];
}



-(void)downloadfile:(NSString*)url path:(NSString*)path
{
    NSURL *myurl = [NSURL URLWithString:url];
    NSData *imgData = [NSData dataWithContentsOfURL:myurl];
    [self.mDelegate finishwithOperationStatus:YES type:1 data:imgData path:mpath];
    
}

-(void)uploadfile:(NSString*)url path:(NSString*)path;
{
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:@""]];
    NSData *imageData = [NSData dataWithContentsOfFile:path];
    NSRange range = [path rangeOfString:@"/" options:NSBackwardsSearch];
    NSString *fileName = [path substringFromIndex:range.location+1];
    AFHTTPRequestOperation *op = [manager POST:url parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        [formData appendPartWithFileData:imageData name:@"file" fileName:fileName mimeType:@"image/jpeg"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self.mDelegate finishwithOperationStatus:YES type:2 data:nil path:nil];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self.mDelegate finishwithOperationStatus:NO type:2 data:nil path:nil];
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



#pragma mark - HttpSenderDelegate

-(void)finishWithReceivedData:(NSData *)rData
{
    NSString* temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
    rData = [temp dataUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"received Data: %@",temp);
    NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
    NSNumber *cmd = [response1 valueForKey:@"cmd"];
    switch ([cmd intValue]) {
        case NORMAL_REPLY:
        {
            httpURL = (NSString*)[response1 valueForKey:@"url"];
            switch (COtype) {
                case 1:
                    [self downloadfile:httpURL path:mpath];
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
