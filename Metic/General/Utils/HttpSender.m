//
//  HttpSender.m
//  Metis
//
//  Created by mac on 14-5-19.
//  Copyright (c) 2014年 mac. All rights reserved.
//

#import "HttpSender.h"
#import "AppConstants.h"
#import "AFHTTPRequestOperationManager.h"

@implementation HttpSender

@synthesize myConnection;
@synthesize mDelegate;

-(id)initWithDelegate:(id)delegate
{
    self = [super init];
    URL_mainServer = @[@"http://203.195.243.84:10087/",@"http://app.whatsact.com:10087/"][Server];
    PHOTO_mainServer = @[@"http://203.195.243.84:20000/",@"http://app.whatsact.com:20000/"][Server];
    VIDEO_mainServer = @[@"http://203.195.243.84:20001/",@"http://app.whatsact.com:20001/"][Server];
    FeedBack_mainServer = @[@"http://203.195.243.84:10089/",@"http://app.whatsact.com:10089/"][Server];
    HttpURL = @"";
    mDelegate = delegate;
    return self;
}

-(NSString*)parseMethodCode:(MTHttpMethod)methodCode
{
    NSString* resultCode;
    switch (methodCode) {
        case HTTP_GET:
            resultCode = @"GET";
            break;
        case HTTP_POST:
            resultCode = @"POST";
            break;
        case HTTP_PUT:
            resultCode = @"PUT";
            break;
        case HTTP_DELETE:
            resultCode = @"DELETE";
            break;
        default:
            resultCode = @"";
            break;
    }
    return resultCode;
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
        case 22:
            resultCode = @"delete_pcomment";
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
        case 31:
            resultCode = @"get_version_info";
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
        case 47:
            resultCode = @"push_message";
            break;
        case 48:
            resultCode = @"get_object_info";
            break;
        case 49:
            resultCode = @"find_back_password";
            break;
        case 50:
            resultCode = @"qrcode_invite";
            break;
        case 51:
            resultCode = @"delete_friend";
            break;
        case 52:
            resultCode = @"view_event";
            break;
        case 53:
            resultCode = @"change_event_info";
            break;
        case 54:
            resultCode = @"add_friend_batch";
            break;
        case 55:
            resultCode = @"get_like_event";
            break;
        case 56:
            resultCode = @"like_event";
            break;
        case 57:
            resultCode = @"token";
            break;
        default:
            resultCode = @"json";
            break;
    }
    return resultCode;
}

#pragma mark - Send Message To Server
-(void)sendPhotoMessage:(NSDictionary *)parameter withOperationCode:(int)operation_Code finshedBlock:(FinishBlock)block
{
    NSString* parsingOperationCode = [self parseOperationCode:operation_Code];
    NSString* parsingMethodCode = [self parseMethodCode:HTTP_POST];
    HttpURL = [NSString stringWithFormat:@"%@%@",PHOTO_mainServer,parsingOperationCode];
    
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:@""]];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer.timeoutInterval = MTREQUEST_TIMEOUT ;
    
    NSMutableURLRequest *request = [manager.requestSerializer requestWithMethod:parsingMethodCode URLString:HttpURL parameters:parameter error:nil];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    AFHTTPRequestOperation *requestOperation = [manager HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (block) {
            block(responseObject);
        }else if ([self.mDelegate respondsToSelector:@selector(finishWithReceivedData:)]) {
            [self.mDelegate finishWithReceivedData:responseObject];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            block(nil);
        }
    }];
    [requestOperation start];
}

-(void)sendVideoMessage:(NSDictionary *)parameter withOperationCode:(int)operation_Code finshedBlock:(FinishBlock)block
{
    NSString* parsingOperationCode = [self parseOperationCode:operation_Code];
    NSString* parsingMethodCode = [self parseMethodCode:HTTP_POST];
    HttpURL = [NSString stringWithFormat:@"%@%@",VIDEO_mainServer,parsingOperationCode];
    
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:@""]];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer.timeoutInterval = MTREQUEST_TIMEOUT ;
    
    NSMutableURLRequest *request = [manager.requestSerializer requestWithMethod:parsingMethodCode URLString:HttpURL parameters:parameter error:nil];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    AFHTTPRequestOperation *requestOperation = [manager HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (block) {
            block(responseObject);
        }else if ([self.mDelegate respondsToSelector:@selector(finishWithReceivedData:)]) {
            [self.mDelegate finishWithReceivedData:responseObject];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            block(nil);
        }
    }];
    [requestOperation start];
}

-(void)sendMessage:(NSData *)jsonData withOperationCode:(int)operation_Code
{
    [self sendMessage:jsonData withOperationCode:operation_Code HttpMethod:HTTP_POST finshedBlock:nil];
}

-(void)sendMessage:(NSData *)jsonData withOperationCode:(int)operation_Code finshedBlock:(FinishBlock)block
{
    [self sendMessage:jsonData withOperationCode:operation_Code HttpMethod:HTTP_POST finshedBlock:block];
}

-(void)sendMessage:(NSData *)jsonData withOperationCode:(int)operation_Code HttpMethod:(MTHttpMethod)method finshedBlock:(FinishBlock)block
{
    NSString* parsingOperationCode = [self parseOperationCode:operation_Code];
    NSString* parsingMethodCode = [self parseMethodCode:method];
    HttpURL = [NSString stringWithFormat:@"%@%@",URL_mainServer,parsingOperationCode];
    NSDictionary *parameter = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:nil];
    
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:@""]];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer.timeoutInterval = MTREQUEST_TIMEOUT ;
    
     NSMutableURLRequest *request = [manager.requestSerializer requestWithMethod:parsingMethodCode URLString:HttpURL parameters:parameter error:nil];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
     AFHTTPRequestOperation *requestOperation = [manager HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (block) {
            block(responseObject);
        }else if ([self.mDelegate respondsToSelector:@selector(finishWithReceivedData:)]) {
            [self.mDelegate finishWithReceivedData:responseObject];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            block(nil);
        }
    }];
    [requestOperation start];
}


-(void)sendFeedBackMessage:(NSDictionary *)json
{
    NSString* parsingMethodCode = [self parseMethodCode:HTTP_POST];
    HttpURL = [NSString stringWithFormat:@"%@%@",FeedBack_mainServer,@"user_feedback"];
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:@""]];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer.timeoutInterval = MTREQUEST_TIMEOUT ;
    
    NSMutableURLRequest *request = [manager.requestSerializer requestWithMethod:parsingMethodCode URLString:HttpURL parameters:json error:nil];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    AFHTTPRequestOperation *requestOperation = [manager HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([self.mDelegate respondsToSelector:@selector(finishWithReceivedData:)]) {
            [self.mDelegate finishWithReceivedData:responseObject];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
    [requestOperation start];
}

-(void)sendGetPosterMessage:(int)operation_Code finshedBlock:(FinishBlock)block
{
    NSString* parsingOperationCode = [self parseOperationCode: operation_Code];
    NSString* parsingMethodCode = [self parseMethodCode:HTTP_POST];
    HttpURL = [NSString stringWithFormat:@"%@%@",FeedBack_mainServer,parsingOperationCode];
    
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:@""]];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer.timeoutInterval = MTREQUEST_TIMEOUT ;
    
    NSMutableURLRequest *request = [manager.requestSerializer requestWithMethod:parsingMethodCode URLString:HttpURL parameters:nil error:nil];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    AFHTTPRequestOperation *requestOperation = [manager HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (block) {
            block(responseObject);
        }else if ([self.mDelegate respondsToSelector:@selector(finishWithReceivedData:)]) {
            [self.mDelegate finishWithReceivedData:responseObject];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            block(nil);
        }
    }];
    [requestOperation start];
}

@end
