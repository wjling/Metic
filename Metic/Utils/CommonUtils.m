//
//  CommonUtils.m
//  Metis
//
//  Created by ligang5 on 14-5-27.
//  Copyright (c) 2014年 ligang5. All rights reserved.
//

#import "CommonUtils.h"

@implementation CommonUtils

//传入参数格式: number of value_key,value,key,value,key...
+(NSMutableDictionary*)packParamsInDictionary:(id)params, ...
{
    NSMutableDictionary* myDic = [[NSMutableDictionary alloc]init];
//    NSNumber* num = (NSNumber*)params;
    id value;
    NSString* key = [[NSString alloc]init];
    va_list dicList;
//
//    if (params) {
//        
//        va_start(dicList, params);
//        for (int i = 0; i<[num intValue]; i++) {
//            value = va_arg(dicList, id);
//            key = va_arg(dicList, id);
//            [myDic setValue:value forKey:key];
//        }
//        va_end(dicList);
//        
//    }
    
    
    value = params;
    if (value) {
        va_start(dicList, params);
        while (value) {
            key = va_arg(dicList, id);
            [myDic setValue:value forKey:key];
            value = va_arg(dicList, id);
        }
        va_end(dicList);
    }
    
    return myDic;
}


+(BOOL)isEmailValid:(NSString *)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
    
}


+(NSString*)randomStringWithLength:(int)length
{
    NSString* result =[[NSString alloc ]init];
    for (int i = 0; i < length; i++) {
        int temp1 = arc4random()%2;
        int temp2 = arc4random()%36;
        if (temp2>9) {
            if (temp1 <1) {
                char c = 'A'+temp2-10;
                NSString* temp3 = [[NSString alloc]initWithFormat:@"%c",c];
                result = [result stringByAppendingString:temp3];
            }
            else
            {
                char c = 'a'+temp2-10;
                NSString* temp3 = [[NSString alloc]initWithFormat:@"%c",c];
                result = [result stringByAppendingString:temp3];
            }
        }
        else
        {
            char c = '0'+temp2;
            NSString* temp3 = [[NSString alloc]initWithFormat:@"%c",c];
            result = [result stringByAppendingString:temp3];
        }

    }
    return result;
}

+(NSMutableString*)MD5EncryptionWithString:(NSString *)str
{
    const char *cstr = [str UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cstr, strlen(cstr), result);
    NSMutableString *md5_str = [NSMutableString string];
    for (int i = 0; i < 16; i++)
        [md5_str appendFormat:@"%02x", result[i]];
    NSLog(@"MD5: %@",md5_str);
    return md5_str;

}

+(UIAlertView*)showSimpleAlertViewWithTitle:(NSString *)title WithMessage:(NSString *)message WithDelegate:(id)delegate WithCancelTitle:(NSString *)cancelTitle
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:delegate cancelButtonTitle:cancelTitle otherButtonTitles:nil, nil];
    [alert show];
    return alert;

}

+ (NSNumber*)NSNumberWithNSString:(NSString *)string
{
    id result = string;
    if ([result isKindOfClass:[NSNumber class]]) {
        return result;
    }
    NSNumberFormatter* format = [[NSNumberFormatter alloc]init];
    result = [format numberFromString:string];
//    if (!result) {
//        result = nil;
//    }
    return result;
}

+ (NSString*)NSStringWithNSNumber:(NSNumber *)number
{
    NSNumberFormatter* format = [[NSNumberFormatter alloc]init];
    return [format stringFromNumber:number];
}

+ (NSMutableDictionary*)NSDictionaryWithNSString:(NSString *)string
{
    NSData* temp1 = [string dataUsingEncoding:NSUTF8StringEncoding];
    return [NSMutableDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:temp1 options:NSJSONReadingMutableLeaves error:nil]];
}


//中文转拼音
+ (NSString*)pinyinFromNSString:(NSString *)str
{
    HanyuPinyinOutputFormat* outputFormat = [[HanyuPinyinOutputFormat alloc]init];
    [outputFormat setToneType:ToneTypeWithoutTone];
    [outputFormat setVCharType:VCharTypeWithV];
    [outputFormat setCaseType:CaseTypeUppercase];
    return [PinyinHelper toHanyuPinyinStringWithNSString:str withHanyuPinyinOutputFormat:outputFormat withNSString:@""];
}

+ (NSString*)pinyinHeadFromNSString:(NSString *)str {
    HanyuPinyinOutputFormat *outputFormat = [[HanyuPinyinOutputFormat alloc] init];
    [outputFormat setToneType:ToneTypeWithoutTone];
    [outputFormat setVCharType:VCharTypeWithV];
    [outputFormat setCaseType:CaseTypeLowercase];
    NSMutableString *outputPinyin = [[NSMutableString alloc] init];
    for (int i=0;i <str.length;i++) {
        NSString *mainPinyinStrOfChar = [PinyinHelper toHanyuPinyinStringWithNSString:[str substringWithRange:NSMakeRange(i,1)] withHanyuPinyinOutputFormat:outputFormat withNSString:@""];
//        NSLog(@"char %d: %@",i,mainPinyinStrOfChar);
        if (nil!=mainPinyinStrOfChar) {
            [outputPinyin appendString:[mainPinyinStrOfChar substringToIndex:1]];
        } else {
            break;
        }
    }
    return outputPinyin;
}

+ (BOOL)isIncludeChineseInString:(NSString*)str {
    for (int i=0; i<str.length; i++) {
        unichar ch = [str characterAtIndex:i];
        if (0x4e00 < ch  && ch < 0x9fff) {
            return true;
        }
    }
    return false;
}



+(UIImage*)downloadfile:(NSString*)url path:(NSString*)path
{
    NSURL *myurl = [NSURL URLWithString:url];
    NSData *imgData = [NSData dataWithContentsOfURL:myurl];
    NSString *filePath = [NSString stringWithFormat:@"%@/Documents/media%@", NSHomeDirectory(),path];
    [imgData writeToFile: filePath atomically: NO];
    UIImage *img = [[UIImage alloc]initWithData:imgData];
    return img;
}

+(void)uploadfile:(NSString*)url path:(NSString*)path;
{
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:@""]];
    NSData *imageData = [NSData dataWithContentsOfFile:path];
    NSRange range = [path rangeOfString:@"/" options:NSBackwardsSearch];
    NSString *fileName = [path substringFromIndex:range.location+1];
    AFHTTPRequestOperation *op = [manager POST:url parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        [formData appendPartWithFileData:imageData name:@"file" fileName:fileName mimeType:@"image/jpeg"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Success: %@ ***** %@", operation.responseString, responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@ ***** %@", operation.responseString, error);
    }];
    [op start];
}

+(void)deletefile:(NSString*)url
{
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:@""]];
    AFHTTPRequestOperation *op = [manager DELETE:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Success: %@ ***** %@", operation.responseString, responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@ ***** %@", operation.responseString, error);
    }];
    [op start];
}


+ (NSString *)hmac_sha1:(NSString *)key text:(NSString *)text{
    
    const char *cKey  = [key cStringUsingEncoding:NSUTF8StringEncoding];
    const char *cData = [text cStringUsingEncoding:NSUTF8StringEncoding];
    char cHMAC[CC_SHA1_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);//hmac_sha1
    NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC length:CC_SHA1_DIGEST_LENGTH];
    NSString *hash = [GTMBase64 stringByEncodingData:HMAC];//base64 编码。
    
    
    //hash = [[hash substringWithRange:NSMakeRange(0,27)] stringByAppendingString:@"%%3D"];
    return hash;

}

+ (NSString *)base64StringFromText:(NSString *)text
{
    NSData *Data=[text dataUsingEncoding:NSUTF8StringEncoding];
    //进行编码
    Data =[GTMBase64 encodeData:Data];
    NSString *codestr=[[NSString alloc] initWithData:Data encoding:NSUTF8StringEncoding];
    return codestr;
}

+ (NSString *)TextFrombase64String:(NSString *)text
{
    NSData *Data=[text dataUsingEncoding:NSUTF8StringEncoding];
    //进行编码
    Data =[GTMBase64 decodeData:Data];
    NSString *codestr=[[NSString alloc] initWithData:Data encoding:NSUTF8StringEncoding];
    return codestr;
}

+ (NSString*)getUrl:(NSString*) path
{
    NSString* content = [NSString stringWithFormat:@"MBO\nMethod=GET\nBucket=metis201415\nObject=%@\n",path];
    NSString* key = @"VWWE6aPlh4uUAhhrXytxvIXUCR27OShi";
    NSString* sign = [self hmac_sha1:key text:content];
    NSString* signencoded = [self URLEncodedString:sign];
    NSString* url = [NSString stringWithFormat:@"http://bcs.duapp.com/metis201415%@?sign=MBO:V7M9qLLWzuCYRFRQgaHvOn3f:%@",path,signencoded];
    return url;
}


+(UIImage*) circleImage:(UIImage*) image withParam:(CGFloat) inset borderColor:(UIColor*)color borderWidth:(CGFloat)width{
    UIGraphicsBeginImageContext(image.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, width);
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    CGRect rect = CGRectMake(inset, inset, image.size.width - inset * 2.0f, image.size.height - inset * 2.0f);
    CGContextAddEllipseInRect(context, rect);
    CGContextClip(context);
    
    [image drawInRect:rect];
    CGContextAddEllipseInRect(context, rect);
    CGContextStrokePath(context);
    UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newimg;
}

//UIColor 转UIImage
+ (UIImage*) createImageWithColor: (UIColor*) color
{
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage* theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

+ (NSString *)URLEncodedString:(NSString*) originUrl
{
    NSString *encodedValue = (NSString*)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(nil,
                                                                                (CFStringRef)originUrl, nil,
                                                                                (CFStringRef)@"!*'();:@&=+$,?%#[]", kCFStringEncodingUTF8));
    return encodedValue;
}

+ (NSString *)stringByReversed:(NSString*) text
{
    NSMutableString *s = [NSMutableString string];
    for (NSUInteger i=text.length; i>0; i--) {
        [s appendString:[text substringWithRange:NSMakeRange(i-1, 1)]];
    }
    return s;
}

+(UIImage*)convertViewToImage:(UIView*)view{
    UIGraphicsBeginImageContext(view.bounds.size);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage*image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+(UIColor*)colorWithValue:(NSInteger)rgbValue
{
    return [UIColor
            colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0
            green:((float)((rgbValue & 0xFF00) >> 8))/255.0
            blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0];
}
@end
