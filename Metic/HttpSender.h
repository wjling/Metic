//
//  HttpSender.h
//  Metis
//
//  Created by mac on 14-5-19.
//  Copyright (c) 2014年 mac. All rights reserved.
//

@protocol HttpSenderDelegate

@optional
-(void)finishWithReceivedData:(NSData*) rData;

@end


@interface HttpSender: NSObject <NSURLConnectionDataDelegate>
{
    NSString *serverURL;
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

-(void)sendMessage:(NSData*)jsonData withOperationCode:(int)operationCode;

@end
