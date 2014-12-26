//
//  HttpSender2.h
//  WeShare
//
//  Created by ligang6 on 14-12-26.
//  Copyright (c) 2014年 WeShare. All rights reserved.
//

//该文件的内容用于向服务器发送数据

@protocol HttpSenderDelegate

@required
//当服务器返回数据的时候执行此方法
-(void)finishWithReceivedData:(NSData*) rData;

@end

typedef void (^FinishBlock)(NSData* rData);
@interface HttpSender2: NSObject <NSURLConnectionDataDelegate>
{
    NSString *URL_mainServer;
    NSString *PHOTO_mainServer;
    NSString *VIDEO_mainServer;
    NSString *feedBack_mainServer;
    NSString *httpURL;
}
@property(nonatomic,strong)NSURLConnection* myConnection;
@property(nonatomic,strong)id <HttpSenderDelegate> mDelegate;
@property(nonatomic,strong)NSMutableData* responseData;
@property (strong, nonatomic) FinishBlock finishBlock;

-(id)initWithDelegate:(id)delegate;


//向服务器传送数据（jsonData）,操作码为operationCode，操作码可从AppConstants.h里面查找
-(void)sendMessage_GET:(NSDictionary *)dictionary withOperationCode:(int)operation_Code finshedBlock:(FinishBlock)block;

@end
