//
//  HttpSender.m
//  Metis
//
//  Created by mac on 14-5-19.
//  Copyright (c) 2014年 mac. All rights reserved.
//

#import "CloudOperation.h"
#import "HttpSender.h"
#import "UIImageView+WebCache.h"
#import "MySqlite.h"
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


-(void)CloudToDo:(int)type path:(NSString*)path uploadPath:(NSString*)uploadpath container:(UIImageView*)container authorId:(NSNumber *)authorId
{
    COtype = type;
    mpath = path;
    img = container;
    if(type == 2) uploadFilePath = uploadpath;
    _authorId = authorId;
    
    
    
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:[self parseOperationCode:type] forKey:@"method"];
    [dictionary setValue:path forKey:@"object"];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    NSLog(@"%@",[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding]);
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode: GET_FILE_URL];
    @autoreleasepool{
    while (!_shouldExit) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }}
}








-(void)downloadfile:(NSString*)url path:(NSString*)path
{
//    MySqlite* sql = [[MySqlite alloc]init];
//    NSString * DBpath = [NSString stringWithFormat:@"%@/db",[MTUser sharedInstance].userid];
//    [sql openMyDB:DBpath];
//    NSArray *columns = [[NSArray alloc]initWithObjects:@"'id'",@"'updatetime'",@"'url'", nil];
//    NSArray *values = [[NSArray alloc]initWithObjects:[NSString stringWithFormat:@"%@",self.authorId],[NSString stringWithFormat:@"'%@'",@"unknown"],[NSString stringWithFormat:@"'%@'",url], nil];
//    [sql insertToTable:@"avatar" withColumns:columns andValues:values];
//    [sql closeMyDB];
    [[MTUser sharedInstance].avatarURL setValue:url forKeyPath:[NSString stringWithFormat:@"%@",self.authorId]];
    [img sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"默认用户头像"]];
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
    _shouldExit = YES;
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
