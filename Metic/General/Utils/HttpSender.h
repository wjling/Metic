//
//  HttpSender.h
//  Metis
//
//  Created by mac on 14-5-19.
//  Copyright (c) 2014年 mac. All rights reserved.
//

//该文件的内容用于向服务器发送数据

@protocol HttpSenderDelegate<NSObject>

@required
//当服务器返回数据的时候执行此方法
-(void)finishWithReceivedData:(NSData*) rData;

@end

typedef void (^FinishBlock)(NSData* rData);
@interface HttpSender: NSObject <NSURLConnectionDataDelegate>
{
    NSString *URL_mainServer;
    NSString *PHOTO_mainServer;
    NSString *VIDEO_mainServer;
    NSString *FeedBack_mainServer;
    NSString *HttpURL;
}
@property(nonatomic,strong)NSURLConnection* myConnection;
@property(nonatomic,strong)id <HttpSenderDelegate> mDelegate;

-(id)initWithDelegate:(id)delegate;

//向服务器传送数据（jsonData）,操作码为operationCode，操作码可从AppConstants.h里面查找
-(void)sendMessage:(NSData*)jsonData withOperationCode:(int)operationCode;
-(void)sendMessage:(NSData *)jsonData withOperationCode:(int)operation_Code finshedBlock:(FinishBlock)block;
-(void)sendMessage:(NSData *)jsonData withOperationCode:(int)operation_Code HttpMethod:(MTHttpMethod)method finshedBlock:(FinishBlock)block;

-(void)sendPhotoMessage:(NSDictionary *)dictionary withOperationCode:(int)operation_Code finshedBlock:(FinishBlock)block;
-(void)sendVideoMessage:(NSDictionary *)dictionary withOperationCode:(int)operation_Code finshedBlock:(FinishBlock)block;

-(void)sendFeedBackMessage:(NSDictionary*)json;
-(void)sendGetPosterMessage:(int)operation_Code finshedBlock:(FinishBlock)block;

@end
