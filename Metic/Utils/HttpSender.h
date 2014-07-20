//
//  HttpSender.h
//  Metis
//
//  Created by mac on 14-5-19.
//  Copyright (c) 2014年 mac. All rights reserved.
//


//该文件的内容用于向服务器发送数据

@protocol HttpSenderDelegate

@required
//当服务器返回数据的时候执行此方法
-(void)finishWithReceivedData:(NSData*) rData;

@end


@interface HttpSender: NSObject <NSURLConnectionDataDelegate>
{
    NSString *URL_mainServer;
    NSString *PHOTO_mainServer;
    NSString* feedBack_mainServer;
    NSString *httpURL;
}
@property(nonatomic,strong)NSURLConnection* myConnection;
@property(nonatomic,strong)id <HttpSenderDelegate> mDelegate;
@property(nonatomic,strong)NSMutableData* responseData;

//@property(nonatomic,strong)NSMutableSet* myDelegates;
//@property(nonatomic,strong)NSMutableDictionary* delegate_method;

//-(id)init;

-(id)initWithDelegate:(id)delegate;

//-(void)addDelegate:(id)myDelegate whithDelegateName:(NSString*)myDelegateName withCallbackMethodName:(NSString*)methodName;
//-(void)removeDelegate:(id)myDelegate withDelegateName:(NSString*)myDelegateName;

-(NSString*)parseOperationCode:(int) operationCode;

//向服务器传送数据（jsonData）,操作码为operationCode，操作码可从AppConstants.h里面查找
-(void)sendMessage:(NSData*)jsonData withOperationCode:(int)operationCode;

-(void)sendPhotoMessage:(NSDictionary *)dictionary withOperationCode:(int)operation_Code;

-(void)sendFeedBackMessage:(NSDictionary*)json;

@end
