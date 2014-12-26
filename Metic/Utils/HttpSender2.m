//
//  HttpSender2.m
//  WeShare
//
//  Created by ligang6 on 14-12-26.
//  Copyright (c) 2014年 WeShare. All rights reserved.
//

#import "HttpSender2.h"
#import "AppConstants.h"

@implementation HttpSender2

@synthesize myConnection;
@synthesize mDelegate;
@synthesize responseData;



-(id)initWithDelegate:(id)delegate
{
    self = [super init];
    URL_mainServer = @"http://182.254.176.64:8001/";

    
    httpURL = @"";
    responseData = [[NSMutableData alloc]init];
    mDelegate = delegate;
    return self;
}

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
    }else
    {
        if ([(UIViewController*)self.mDelegate respondsToSelector:@selector(finishWithReceivedData:)])
        {
            [self.mDelegate finishWithReceivedData:responseData];
        }
        
    }
}


-(NSArray*)parseOperationCode:(int)operationCode
{
    NSArray* resultCode;
    switch (operationCode) {
        case 0:
            resultCode = @[@"register"];
            break;
        case 1:
            resultCode = @[@"login"];
            break;
        case 2:
            resultCode = @[@"get_user_info"];
            break;
        case 3:
            resultCode = @[@"get_my_events"];
            break;
        case 4:
            resultCode = @[@"event/",@"user_id",@"event_id",@"detail"];
            break;
        case 5:
            resultCode = @[@"add_friend"];
            break;
        case 6:
            resultCode = @[@"upload_phonebook"];
            break;
        case 7:
            resultCode = @[@"search_friend"];
            break;
        case 8:
            resultCode = @[@"synchronize_friends"];
            break;
        case 9:
            resultCode = @[@"launch_event"];
            break;
        case 10:
            resultCode = @[@"participate_event"];
            break;
        case 11:
            resultCode = @[@"invite_friends"];
            break;
        case 12:
            resultCode = @[@"search_event"];
            break;
        case 14:
            resultCode = @[@"add_comment"];
            break;
        case 15:
            resultCode = @[@"delete_comment"];
            break;
        case 16:
            resultCode = @[@"get_comments"];
            break;
        case 17:
            resultCode = @[@"add_good"];
            break;
        case 18:
            resultCode = @[@"change_settings"];
            break;
        case 19:
            resultCode = @[@"change_pw"];
            break;
        case 20:
            resultCode = @[@"add_pcomment"];
            break;
        case 21:
            resultCode = @[@"get_pcomments"];
            break;
        case 23:
            resultCode = @[@"get_photo_list"];
            break;
        case 24:
            resultCode = @[@"get_event_participants"];
            break;
        case 25:
            resultCode = @[@"get_avatar_updatetime"];
            break;
        case 26:
            resultCode = @[@"get_video_list"];
            break;
        case 27:
            resultCode = @[@"add_vcomment"];
            break;
        case 28:
            resultCode = @[@"get_vcomments"];
            break;
        case 29:
            resultCode = @[@"delete_vcomment"];
            break;
        case 30:
            resultCode = @[@"get_event_recommend"];
            break;
        case 33:
            resultCode = @[@"get_nearby_friends"];
            break;
        case 34:
            resultCode = @[@"kankan"];
            break;
        case 35:
            resultCode = @[@"uploadphoto"];
            break;
        case 36:
            resultCode = @[@"get_file_url"];
            break;
        case 37:
            resultCode = @[@"videoserver"];
            break;
        case 38:
            resultCode = @[@"kick_out"];
            break;
        case 39:
            resultCode = @[@"quit_event"];
            break;
        case 40:
            resultCode = @[@"avatar"];
            break;
        case 41:
            resultCode = @[@"complain"];
            break;
        case 42:
            resultCode = @[@"get_good_photos"];
            break;
        case 43:
            resultCode = @[@"get_welcome_page"];
            break;
        case 44:
            resultCode = @[@"get_poster"];
            break;
        case 45:
            resultCode = @[@"alias"];
            break;
        case 46:
            resultCode = @[@"set_event_banner"];
            break;
        default:
            resultCode = @[@"json"];
            break;
    }
    return resultCode;
}






-(void)sendMessage_GET:(NSDictionary *)dictionary withOperationCode:(int)operation_Code finshedBlock:(FinishBlock)block
{
    self.finishBlock = block;
    NSMutableArray* parsingOperationCode = [[NSMutableArray alloc]initWithArray:[self parseOperationCode: operation_Code]];
    
    httpURL = [NSString stringWithFormat:@"%@%@",URL_mainServer,parsingOperationCode[0],nil];
    for (int i = 1; i < parsingOperationCode.count; i++) {
        httpURL = [httpURL stringByAppendingString:[NSString stringWithFormat:@"%@/",[dictionary valueForKey:parsingOperationCode[i]]]];
    }
    
    NSLog(httpURL,nil);

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:httpURL]];

    [request setHTTPMethod:@"GET"];

    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setTimeoutInterval:12];
    myConnection = [[NSURLConnection alloc]initWithRequest:request delegate:self];

    
}

@end
