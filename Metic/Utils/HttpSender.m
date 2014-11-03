//
//  HttpSender.m
//  Metis
//
//  Created by mac on 14-5-19.
//  Copyright (c) 2014年 mac. All rights reserved.
//

#import "HttpSender.h"
#import "AppConstants.h"

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
    
//    URL_mainServer = @"http://42.96.203.86:10087/";//阿里云//测试服
//    URL_mainServer = @"http://whatsact.gz.1251096186.clb.myqcloud.com:10087/";//腾讯//正式服
    URL_mainServer = @[@"http://42.96.203.86:10087/",@"http://whatsact.gz.1251096186.clb.myqcloud.com:10087/"][Server];
    
//    PHOTO_mainServer = @"http://42.96.203.86:20000/";//测试服
//    PHOTO_mainServer = @"http://whatsact.gz.1251096186.clb.myqcloud.com:20000/";//正式服
    PHOTO_mainServer = @[@"http://42.96.203.86:20000/",@"http://whatsact.gz.1251096186.clb.myqcloud.com:20000/"][Server];
    
//    VIDEO_mainServer = @"http://42.96.203.86:20001/";//测试服
//    VIDEO_mainServer = @"http://whatsact.gz.1251096186.clb.myqcloud.com:20001/";//正式服
    VIDEO_mainServer = @[@"http://42.96.203.86:20001/",@"http://whatsact.gz.1251096186.clb.myqcloud.com:20001/"][Server];
    
    feedBack_mainServer = @"http://42.96.203.86:10089/";//测试服
//    feedBack_mainServer = @"http://whatsact.gz.1251096186.clb.myqcloud.com:10089/";//正式服
    feedBack_mainServer = @[@"http://42.96.203.86:10089/",@"http://whatsact.gz.1251096186.clb.myqcloud.com:10089/"][Server];
    
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
    if (self.finishBlock) {
        self.finishBlock(nil);
    }
}
-(void)connection:(NSURLConnection*)connection didReceiveData:(NSData *)data
{
//    NSLog(@"didReceiveData");
    [responseData appendData:data];
}


-(void)connectionDidFinishLoading:(NSURLConnection*)connection
{
//    NSLog(@"connectionDidFinishLoading");
    if (self.finishBlock) {
        self.finishBlock(responseData);
    }else [self.mDelegate finishWithReceivedData:responseData];
}


-(NSString*)parseOperationCode:(int)operationCode
{
    NSString* resultCode;
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
        case 11:
            resultCode = @"invite_friends";
            break;
        case 12:
            resultCode = @"search_event";
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
        case 18:
            resultCode = @"change_settings";
            break;
        case 19:
            resultCode = @"change_pw";
            break;
        case 20:
            resultCode = @"add_pcomment";
            break;
        case 21:
            resultCode = @"get_pcomments";
            break;
        case 23:
            resultCode = @"get_photo_list";
            break;
        case 24:
            resultCode = @"get_event_participants";
            break;
        case 25:
            resultCode = @"get_avatar_updatetime";
            break;
        case 26:
            resultCode = @"get_video_list";
            break;
        case 27:
            resultCode = @"add_vcomment";
            break;
        case 28:
            resultCode = @"get_vcomments";
            break;
        case 29:
            resultCode = @"delete_vcomment";
            break;
        case 30:
            resultCode = @"get_event_recommend";
            break;
        case 33:
            resultCode = @"get_nearby_friends";
            break;
        case 34:
            resultCode = @"kankan";
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
        case 38:
            resultCode = @"kick_out";
            break;
        case 39:
            resultCode = @"quit_event";
            break;
        case 40:
            resultCode = @"avatar";
            break;
        case 41:
            resultCode = @"complain";
            break;
        case 42:
            resultCode = @"get_good_photos";
            break;
        case 43:
            resultCode = @"get_welcome_page";
            break;
        case 44:
            resultCode = @"get_poster";
            break;
        case 45:
            resultCode = @"alias";
            break;
        case 46:
            resultCode = @"set_event_banner";
            break;
        default:
            resultCode = @"json";
            break;
    }
    return resultCode;
}

-(void)sendPhotoMessage:(NSDictionary *)dictionary withOperationCode:(int)operation_Code finshedBlock:(FinishBlock)block
{
    self.finishBlock = block;
    NSString* parsingOperationCode = [self parseOperationCode: operation_Code];
    httpURL = [NSString stringWithFormat:@"%@%@",PHOTO_mainServer,parsingOperationCode];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:httpURL]];
    //[request setValue:@"text/html" forHTTPHeaderField:@"Content-Type"];
    NSLog(@"%@",httpURL);
    [request setHTTPMethod:@"POST"];
    NSString *body=@"";
    body = [body stringByAppendingString:[NSString stringWithFormat:@"%@=%@&",@"id",[dictionary valueForKey:@"id"]]];
    body = [body stringByAppendingString:[NSString stringWithFormat:@"%@=%@&",@"event_id",[dictionary valueForKey:@"event_id"]]];
    body = [body stringByAppendingString:[NSString stringWithFormat:@"%@=%@&",@"cmd",[dictionary valueForKey:@"cmd"]]];
    //upload
    if ([dictionary valueForKey:@"width"])
        body = [body stringByAppendingString:[NSString stringWithFormat:@"%@=%@&",@"width",[dictionary valueForKey:@"width"]]];
    if ([dictionary valueForKey:@"height"])
        body = [body stringByAppendingString:[NSString stringWithFormat:@"%@=%@&",@"height",[dictionary valueForKey:@"height"]]];
    if ([dictionary valueForKey:@"photos"])
        body = [body stringByAppendingString:[NSString stringWithFormat:@"%@=%@&",@"photos",[dictionary valueForKey:@"photos"]]];
    if ([dictionary valueForKey:@"specification"])
        body = [body stringByAppendingString:[NSString stringWithFormat:@"%@=%@",@"specification",[dictionary valueForKey:@"specification"]]];
    //delete
    if ([dictionary valueForKey:@"photo_id"])
        body = [body stringByAppendingString:[NSString stringWithFormat:@"%@=%@",@"photo_id",[dictionary valueForKey:@"photo_id"]]];
    
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    NSData *postData = [body dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%d",[postData length]];
    [request setHTTPBody:postData];
    
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];

    myConnection = [[NSURLConnection alloc]initWithRequest:request delegate:self];

    
}

-(void)sendVideoMessage:(NSDictionary *)dictionary withOperationCode:(int)operation_Code finshedBlock:(FinishBlock)block
{
    self.finishBlock = block;
    NSString* parsingOperationCode = [self parseOperationCode: operation_Code];
    httpURL = [NSString stringWithFormat:@"%@%@",VIDEO_mainServer,parsingOperationCode];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:httpURL]];
    //[request setValue:@"text/html" forHTTPHeaderField:@"Content-Type"];
    NSLog(@"%@",httpURL);
    [request setHTTPMethod:@"POST"];
    NSString *body=@"";
    body = [body stringByAppendingString:[NSString stringWithFormat:@"%@=%@&",@"id",[dictionary valueForKey:@"id"]]];
    body = [body stringByAppendingString:[NSString stringWithFormat:@"%@=%@&",@"event_id",[dictionary valueForKey:@"event_id"]]];
    body = [body stringByAppendingString:[NSString stringWithFormat:@"%@=%@&",@"cmd",[dictionary valueForKey:@"cmd"]]];
    //delete
    if ([dictionary valueForKey:@"video_id"])
        body = [body stringByAppendingString:[NSString stringWithFormat:@"%@=%@",@"video_id",[dictionary valueForKey:@"video_id"]]];
    //upload
    if ([dictionary valueForKey:@"video_name"])
        body = [body stringByAppendingString:[NSString stringWithFormat:@"%@=%@&",@"video_name",[dictionary valueForKey:@"video_name"]]];
    if ([dictionary valueForKey:@"title"])
        body = [body stringByAppendingString:[NSString stringWithFormat:@"%@=%@",@"title",[dictionary valueForKey:@"title"]]];
    
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    NSData *postData = [body dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%d",[postData length]];
    [request setHTTPBody:postData];
    
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    myConnection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
    
    
}

-(void)sendMessage:(NSData *)jsonData withOperationCode:(int)operation_Code
{
    NSString* parsingOperationCode = [self parseOperationCode: operation_Code];
    httpURL = [NSString stringWithFormat:@"%@%@",URL_mainServer,parsingOperationCode];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:httpURL]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:jsonData];
    [request setTimeoutInterval:5];
    myConnection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
    //NSLog(@"request sent");
    
}

-(void)sendMessage:(NSData *)jsonData withOperationCode:(int)operation_Code finshedBlock:(FinishBlock)block
{
    self.finishBlock = block;
    NSString* parsingOperationCode = [self parseOperationCode: operation_Code];
    httpURL = [NSString stringWithFormat:@"%@%@",URL_mainServer,parsingOperationCode];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:httpURL]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:jsonData];
    [request setTimeoutInterval:5];
    myConnection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
    NSLog(@"URL: %@ ",httpURL);
    
}

-(void)sendFeedBackMessage:(NSDictionary *)json
{
    httpURL = [NSString stringWithFormat:@"%@%@",feedBack_mainServer,@"user_feedback"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:httpURL]];
    
    NSString *body=@"";
    body = [body stringByAppendingString:[NSString stringWithFormat:@"%@=%@&",@"id",[json valueForKey:@"id"]]];
    body = [body stringByAppendingString:[NSString stringWithFormat:@"%@=%@",@"content",[json valueForKey:@"content"]]];
    NSData* jsonData = [body dataUsingEncoding:NSUTF8StringEncoding];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:jsonData];
    NSString *postLength = [NSString stringWithFormat:@"%d",[jsonData length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    myConnection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
}

-(void)sendGetPosterMessage:(int)operation_Code finshedBlock:(FinishBlock)block
{
    self.finishBlock = block;
    NSString* parsingOperationCode = [self parseOperationCode: operation_Code];
    httpURL = [NSString stringWithFormat:@"%@%@",feedBack_mainServer,parsingOperationCode];
    NSLog(@"%@",httpURL);
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:httpURL]];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];

    myConnection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
}

@end
