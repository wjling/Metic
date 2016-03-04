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
+ (BOOL)isEmailValid:(NSString*) email;

//验证电话号码是不是正确
+ (BOOL)isPhoneNumberVaild:(NSString *)phoneNumber;

//生成随机字符串，包括数字和大小写的字母
+(NSString*)randomStringWithLength:(int)length;

//对str字符串进行md5加密
+(NSMutableString*)MD5EncryptionWithString:(NSString*)str;

//生成简单alertView
+(UIAlertView*)showSimpleAlertViewWithTitle:(NSString*)title WithMessage:(NSString*)message WithDelegate:(id)delegate WithCancelTitle:(NSString*)cancelTitle;

//生成简单的类似android的toast的消息
+(UIAlertView*)showToastWithTitle:(NSString*)title withMessage:(NSString*)message withDelegate:(id)delegate withDuaration:(double)duaration;

//NSString转换成NSNumber
+ (NSNumber*)NSNumberWithNSString:(NSString*)string;

//NSNumber转换成NSString
+ (NSString*)NSStringWithNSNumber:(NSNumber*)number;

//NSString转换成NSDictionary (通常用在将数据库中的json字符串取出后，将json字符串转换成字典)
+ (NSMutableDictionary*)NSDictionaryWithNSString:(NSString*)string;

//中文转成拼音（如果是英文还是转成英文）
+ (NSString*)pinyinFromNSString:(NSString*)str;
//中文转换为拼音首字母，英文还是英文
+ (NSString*)pinyinHeadFromNSString:(NSString *)str;
//判断字符串中是否有中文
+ (BOOL)isIncludeChineseInString:(NSString*)str;

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

////计算头像url
//+ (NSString*)getUrl:(NSString*) path;

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

//将颜色值转换成UIColor
+(UIColor*)colorWithValue:(NSInteger)rgbValue;

//根据开始时间 结束时间 生成活动时间信息简述
+(NSString*)calculateTimeInfo:(NSString*)beginTime endTime:(NSString*)endTime launchTime:(NSString*)launchTime;

//根据时间生成活动时间信息简述
+(NSString*)calculateTimeStr:(NSString*)time shortVersion:(BOOL)isShortVersion;

//计算两经纬度间距离
+(double)GetDistance:(double)lat1 lng1:(double)lng1 lat2:(double)lat2 lng2:(double)lng2;

//添加返回上一层按钮
+(void)addLeftButton:(UIViewController*)controller isFirstPage:(BOOL)isFirstPage;

//从文件中提取Dictionary
+ (NSDictionary *)dictionaryFromFile:(NSString*)fileName;

//从文件中提取Array
+ (NSArray *)arrayFromFile:(NSString*)fileName;

//简化数字表述
+(NSString*)TextFromInt:(int)num;

//计算label动态高度
+(float)calculateTextHeight:(NSString*)text width:(float)width fontSize:(float)fsize isEmotion:(BOOL)isEmotion;

//比较app版本号大小，
//返回－1， version1 小于 version2
//返回0， version1 等于 version2
//返回1， version1 大于 version2
//version 形如："0.1.21","12.21.14"等
+(int)compareVersion1:(NSString*)version1 andVersion2:(NSString*)version2;

//将数字序列转换成数组样式的字符串
+(NSString*)arrayStyleStringfromNummerArray:(id)numbers;

//请求参数加签名字段
+ (NSDictionary *)parameterSignature:(NSDictionary *)dict;
@end
