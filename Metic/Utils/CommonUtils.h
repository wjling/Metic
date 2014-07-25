//
//  CommonUtils.h
//  Metis
//
//  Created by ligang5 on 14-5-27.
//  Copyright (c) 2014年 ligang5. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCrypto.h>
#import "PinYin4Objc.h"
#import "AFNetworking.h"
#import "GTMBase64.h"

@interface CommonUtils : NSObject

//打包一个dictionary.传入参数格式: value,key,value,key...
+(NSMutableDictionary*)packParamsInDictionary:(id) params,...;

//验证邮箱格式是不是正确
+(BOOL)isEmailValid:(NSString*) email;

//生成随机字符串，包括数字和大小写的字母
+(NSString*)randomStringWithLength:(int)length;

//对str字符串进行md5加密
+(NSMutableString*)MD5EncryptionWithString:(NSString*)str;

//生成简单alertView
+(void)showSimpleAlertViewWithTitle:(NSString*)title WithMessage:(NSString*)message WithDelegate:(id)delegate WithCancelTitle:(NSString*)cancelTitle;

//NSString转换成NSNumber
+ (NSNumber*)NSNumberWithNSString:(NSString*)string;

//NSNumber转换成NSString
+ (NSString*)NSStringWithNSNumber:(NSNumber*)number;

//NSString转换成NSDictionary (通常用在将数据库中的json字符串取出后，将json字符串转换成字典)
+ (NSDictionary*)NSDictionaryWithNSString:(NSString*)string;

//中文转成拼音（如果是英文还是转成英文）
+ (NSString*)pinyinFromNSString:(NSString*)str;

//从url下载图片，并保存到document／media下 path 为在media下的相对路径
+(UIImage*)downloadfile:(NSString*)url path:(NSString*)path;

//上传图片到url path为完整路径
+(void)uploadfile:(NSString*)url path:(NSString*)path;

//删除云存储上的图片 
+(void)deletefile:(NSString*)url;

//hmacSha1 加密
+ (NSString *)hmac_sha1:(NSString *)key text:(NSString *)text;

//urlencode
+ (NSString *)URLEncodedString:(NSString*) originUrl;

//计算头像url
+ (NSString*)getUrl:(NSString*) path;

//将图片裁剪成圆形
+(UIImage*) circleImage:(UIImage*) image withParam:(CGFloat) inset  borderColor:(UIColor*)color borderWidth:(CGFloat)width ;

//UIColor 转UIImage
+ (UIImage*) createImageWithColor: (UIColor*) color;

//base64加密
+ (NSString *)base64StringFromText:(NSString *)text;

//base64解密
+ (NSString *)TextFrombase64String:(NSString *)text;

//翻转字符串
+ (NSString *)stringByReversed:(NSString*) text;

//将uiview转换成uiimage
+(UIImage*)convertViewToImage:(UIView*)view;
@end
