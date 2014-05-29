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
    URL_mainServer = @"http://222.200.182.183:10087/";
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
            resultCode = @"synchronize_friend";
            break;

            
        default:
            resultCode = @"json";
            break;
    }
    return resultCode;
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
