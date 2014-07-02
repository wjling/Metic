//
//  HttpSender.h
//  Metis
//
//  Created by mac on 14-6-22.
//  Copyright (c) 2014年 mac. All rights reserved.
//


//该文件的内容用于操作百度BCS上数据

//用法示例
////test delete
//CloudOperation * cloudOP = [[CloudOperation alloc]initWithDelegate:self];;
//[cloudOP CloudToDo:DELETE path:@"/test.jpg" uploadPath:nil];

////test upload
//CloudOperation * cloudOP = [[CloudOperation alloc]initWithDelegate:self];
//NSString* uploadfilePath = [NSString stringWithFormat:@"%@%@",NSHomeDirectory(),@"/documents/media/test.jpg"];
//[cloudOP CloudToDo:UPLOAD path:@"/test.jpg" uploadPath:uploadfilePath];

////test download
//CloudOperation * cloudOP = [[CloudOperation alloc]initWithDelegate:self];
//cloudOP.mDelegate = self;
//[cloudOP CloudToDo:DOWNLOAD path:@"/testdl.jpg" uploadPath:nil];


#import "AFNetworking.h"
#import "AppConstants.h"

@protocol CloudOperationDelegate

@optional
//当服务器返回数据的时候执行此方法
-(void)finishwithOperationStatus:(BOOL) status type:(int)type data:(NSData*)mdata path:(NSString*)path;

@end


@interface CloudOperation: NSObject <NSURLConnectionDataDelegate,HttpSenderDelegate>
{
    NSString *httpURL;
    NSString *mpath;
    NSString *uploadFilePath;
    int COtype;
    NSData *mData;
}
//@property(nonatomic,strong)UIImageView* imageView;
@property(nonatomic,strong)NSURLConnection* myConnection;
@property(nonatomic,strong)id <CloudOperationDelegate> mDelegate;
@property(nonatomic,strong)NSMutableData* responseData;


-(id)initWithDelegate:(id)delegate;
-(void)CloudToDo:(int)type path:(NSString*)path uploadPath:(NSString*)uploadpath;

//从url下载图片，并保存到document／media下 path 为在media下的相对路径
-(void)downloadfile:(NSString*)url path:(NSString*)path;

//上传图片到url path为完整路径
-(void)uploadfile:(NSString*)url path:(NSString*)path;

//删除云存储上的图片
-(void)deletefile:(NSString*)url;

@end
