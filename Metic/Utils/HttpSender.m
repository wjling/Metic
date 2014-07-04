//
//  HttpSender.m
//  Metis
//
//  Created by mac on 14-5-19.
//  Copyright (c) 2014年 mac. All rights reserved.
//

#import "HttpSender.h"

@implementation HttpSender

@synthesize myConnection;
@synthesize mDelegate;
@synthesize responseData;
//@synthesize myDelegates;
//@synthesize delegate_method;

//
//-(id)init
//{
//    serverURL = @"http://222.200.182.183:10087/";
//    httpURL = @"";
//    responseData = [[NSMutableData alloc]init];
//    myDelegates = [[NSMutableSet alloc]init];
//    delegate_method = [[NSMutableDictionary alloc]init];
//    return self;
//}

-(id)initWithDelegate:(id)delegate
{
    self = [super init];
//    URL_mainServer = @"http://222.200.182.183:10087/";
//    URL_mainServer = @"http://115.29.103.9:10087/";
//    URL_mainServer = @"http://42.96.203.86:10087/";//阿里云

    URL_mainServer = @"http://203.195.174.128:10087/";//腾讯
    PHOTO_mainServer = @"http://203.195.174.128:20000/";
    httpURL = @"";
    responseData = [[NSMutableData alloc]init];
    mDelegate = delegate;
    return self;
}

//-(void)addDelegate:(id)myDelegate whithDelegateName:(NSString*)myDelegateName withCallbackMethodName:(NSString*)methodName
//{
//    [myDelegates addObject:myDelegate];
//    [delegate_method setValue:methodName forKey:myDelegateName];
//}
//
//-(void)removeDelegate:(id)myDelegate withDelegateName:(NSString*)myDelegateName
//{
//    [myDelegates removeObject:myDelegate];
//    [delegate_method removeObjectForKey:myDelegateName];
//}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"error");
}
-(void)connection:(NSURLConnection*)connection didReceiveData:(NSData *)data
{
//    NSLog(@"didReceiveData");
    [responseData appendData:data];
}


-(void)connectionDidFinishLoading:(NSURLConnection*)connection
{
//    NSLog(@"connectionDidFinishLoading");

    [self.mDelegate finishWithReceivedData:responseData];
}


-(NSString*)parseOperationCode:(int)operationCode
{
    NSString* resultCode = [NSString alloc];
    switch (operationCode) {
        case 0:
            resultCode = @"register";
            break;
        case 1:
            resultCode = @"login";
            break;
        case 2:
            resultCode = @"get_user_info";
            break;
        case 3:
            resultCode = @"get_my_events";
            break;
        case 4:
            resultCode = @"get_events";
            break;
        case 5:
            resultCode = @"add_friend";
            break;
        case 6:
            resultCode = @"upload_phonebook";
            break;
        case 7:
            resultCode = @"search_friend";
            break;
        case 8:
            resultCode = @"synchronize_friends";
            break;
        case 9:
            resultCode = @"launch_event";
            break;
        case 10:
            resultCode = @"participate_event";
            break;
        case 14:
            resultCode = @"add_comment";
            break;
        case 15:
            resultCode = @"delete_comment";
            break;
        case 16:
            resultCode = @"get_comments";
            break;
        case 17:
            resultCode = @"add_good";
            break;
        case 23:
            resultCode = @"get_photo_list";
            break;
        case 25:
            resultCode = @"get_avatar_updatetime";
            break;
        case 35:
            resultCode = @"uploadphoto";
            break;
        case 36:
            resultCode = @"get_file_url";
            break;
        case 37:
            resultCode = @"videoserver";
            break;
        default:
            resultCode = @"json";
            break;
    }
    return resultCode;
}

-(void)sendPhotoMessage:(NSDictionary *)dictionary withOperationCode:(int)operation_Code
{
    NSString* parsingOperationCode = [self parseOperationCode: operation_Code];
    httpURL = [NSString stringWithFormat:@"%@%@",PHOTO_mainServer,parsingOperationCode];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:httpURL]];
    //[request setValue:@"text/html" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    NSString *body=@"";
    body = [body stringByAppendingString:[NSString stringWithFormat:@"%@=%@&",@"id",[dictionary valueForKey:@"id"]]];
    body = [body stringByAppendingString:[NSString stringWithFormat:@"%@=%@&",@"event_id",[dictionary valueForKey:@"event_id"]]];
    body = [body stringByAppendingString:[NSString stringWithFormat:@"%@=%@&",@"cmd",[dictionary valueForKey:@"cmd"]]];
    body = [body stringByAppendingString:[NSString stringWithFormat:@"%@=%@&",@"photos",[dictionary valueForKey:@"photos"]]];
    body = [body stringByAppendingString:[NSString stringWithFormat:@"%@=%@",@"specification",[dictionary valueForKey:@"specification"]]];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    NSData *postData = [body dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%d",[postData length]];
    [request setHTTPBody:postData];
    
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    //NSHTTPURLResponse* urlResponse = nil;
   // NSError *error = [[NSError alloc] init];
    //同步提交:POST提交并等待返回值（同步），返回值是NSData类型。
    //NSData *responseData1 = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error];
    //将NSData类型的返回值转换成NSString类型
    //NSString *result = [[NSString alloc] initWithData:responseData1 encoding:NSUTF8StringEncoding];
    //NSLog(@"user login check result:%@",result);
    
    //NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    //[NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:handler];
    //NSLog(@"before connection");
    myConnection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
    //NSLog(@"request sent");
    
}




-(void)sendMessage:(NSData *)jsonData withOperationCode:(int)operation_Code
{
    NSString* parsingOperationCode = [self parseOperationCode: operation_Code];
    httpURL = [NSString stringWithFormat:@"%@%@",URL_mainServer,parsingOperationCode];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:httpURL]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:jsonData];
    
    //NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    //[NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:handler];
    //NSLog(@"before connection");
    myConnection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
    //NSLog(@"request sent");
    
}

@end
