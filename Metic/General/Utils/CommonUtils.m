//
//  CommonUtils.m
//  Metis
//
//  Created by ligang5 on 14-5-27.
//  Copyright (c) 2014年 ligang5. All rights reserved.
//

#import "CommonUtils.h"
#import "AppConstants.h"
#import <CoreLocation/CLLocation.h>
#import "TTTAttributedLabel.h"

UIAlertView* toast; //用在showToastWithTitle:withMessage:withDuaration

@interface CommonUtils ()
{
    
}
@end

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
    if (email == nil || [email length]== 0)
        return NO;
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

+ (BOOL)isPhoneNumberVaild:(NSString *)phoneNumber
{
    if (phoneNumber == nil || [phoneNumber length]== 0)
        return NO;
    NSString *rule = @"^1(3|5|7|8|4)\\d{9}";
    NSPredicate* pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",rule];
    BOOL isMatch = [pred evaluateWithObject:phoneNumber];
    return isMatch;
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
    MTLOG(@"MD5: %@",md5_str);
    return md5_str;

}

+(UIAlertView*)showSimpleAlertViewWithTitle:(NSString *)title WithMessage:(NSString *)message WithDelegate:(id)delegate WithCancelTitle:(NSString *)cancelTitle
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:delegate cancelButtonTitle:cancelTitle otherButtonTitles:nil, nil];
    [alert show];
    return alert;

}

/////////////////////////////////////////
+(UIAlertView*)showToastWithTitle:(NSString*)title withMessage:(NSString*)message withDelegate:(id)delegate withDuaration:(double)duaration
{
    toast = [[UIAlertView alloc]initWithTitle:title message:message delegate:delegate cancelButtonTitle:nil otherButtonTitles:nil, nil];
    [toast show];
    
    [NSTimer scheduledTimerWithTimeInterval:duaration target:self selector:@selector(dismissToast:) userInfo:nil repeats:NO];
    return toast;
}
+(void)dismissToast:(NSTimer*)timer
{
    if (toast) {
        [toast dismissWithClickedButtonIndex:0 animated:YES];
        toast = nil;
    }
    else
    {
        MTLOG(@"toast不存在");
    }
}
//////////////////////////////////////

+ (NSNumber*)NSNumberWithNSString:(NSString *)string
{
    id result = string;
    if (result == nil || [result isEqual:[NSNull null]] || [result isKindOfClass:[NSNumber class]]) {
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
    if (!string || [string isEqual:[NSNull null]]) {
        return nil;
    }
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
//        MTLOG(@"char %d: %@",i,mainPinyinStrOfChar);
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
        MTLOG(@"Success: %@ ***** %@", operation.responseString, responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        MTLOG(@"Error: %@ ***** %@", operation.responseString, error);
    }];
    [op start];
}

+(void)deletefile:(NSString*)url
{
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:@""]];
    AFHTTPRequestOperation *op = [manager DELETE:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        MTLOG(@"Success: %@ ***** %@", operation.responseString, responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        MTLOG(@"Error: %@ ***** %@", operation.responseString, error);
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

//+ (NSString*)getUrl:(NSString*) path
//{
//    NSString* content = @[[NSString stringWithFormat:@"MBO\nMethod=GET\nBucket=metis201415\nObject=%@\n",path],[NSString stringWithFormat:@"MBO\nMethod=GET\nBucket=whatsact\nObject=%@\n",path]][Server];
//    NSString* key = @"VWWE6aPlh4uUAhhrXytxvIXUCR27OShi";
//    NSString* sign = [self hmac_sha1:key text:content];
//    NSString* signencoded = [self URLEncodedString:sign];
//
//    NSString* url = @[[NSString stringWithFormat:@"http://bcs.duapp.com/metis201415%@?sign=MBO:V7M9qLLWzuCYRFRQgaHvOn3f:%@",path,signencoded],[NSString stringWithFormat:@"http://bcs.duapp.com/whatsact%@?sign=MBO:V7M9qLLWzuCYRFRQgaHvOn3f:%@",path,signencoded]][Server];
//    return url;
//}


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

+ (void)generateEventContinuedInfoLabel:(TTTAttributedLabel *)label beginTime:(NSString*)beginTime endTime:(NSString*)endTime {
    NSString* timeInfo = @"";
    static NSDateFormatter* dateFormatter;
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
        [dateFormatter setLocale:[NSLocale currentLocale]];
    }
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];

    
    NSDate *begin = [dateFormatter dateFromString:beginTime];
    NSDate *end = [dateFormatter dateFromString:endTime];
    NSDate *now = [NSDate date];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSInteger unitFlags = NSYearCalendarUnit;
    
    NSDateComponents *compsBegin  = [calendar components:unitFlags fromDate:begin];
    NSDateComponents *compsNow  = [calendar components:unitFlags fromDate:now];

    if ([compsBegin year] != [compsNow year]) {
        [dateFormatter setDateFormat:@"YYYY年MM月dd日"];
    } else {
        [dateFormatter setDateFormat:@"MM月dd日 HH:mm"];
    }
    
    NSString *beginStr = [dateFormatter stringFromDate:begin];
    NSString *endStr = [dateFormatter stringFromDate:end];

    timeInfo = [NSString stringWithFormat:@"%@ － %@", beginStr, endStr];
    
    [label setText:timeInfo afterInheritingLabelAttributesAndConfiguringWithBlock:^(NSMutableAttributedString *mutableAttributedString) {
        NSRange date1 = NSMakeRange(0, beginStr.length - ([compsBegin year] != [compsNow year]? 0:5));
        NSRange time1 = NSMakeRange(date1.length, ([compsBegin year] != [compsNow year])? 0:5);
        NSRange seperate = NSMakeRange(beginStr.length, 3);
        NSRange date2 = NSMakeRange(seperate.location + seperate.length, endStr.length - ([compsBegin year] != [compsNow year]? 0:5));
        NSRange time2 = NSMakeRange(date2.location + date2.length, ([compsBegin year] != [compsNow year])? 0:5);

        UIFont *dateFont = [UIFont systemFontOfSize:13];
        UIFont *timeFont = [UIFont systemFontOfSize:12];
        UIFont *seperateFont = [UIFont systemFontOfSize:15];
        
        if (date1.location != NSNotFound) {

            CTFontRef italicFont = CTFontCreateWithName((__bridge CFStringRef)dateFont.fontName, dateFont.pointSize, NULL);
            [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)italicFont range:date1];
            CFRelease(italicFont);
        }
        
        if (date2.location != NSNotFound) {

            CTFontRef italicFont = CTFontCreateWithName((__bridge CFStringRef)dateFont.fontName, dateFont.pointSize, NULL);
            [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)italicFont range:date2];
            CFRelease(italicFont);
        }
        if (time1.location != NSNotFound) {

            CTFontRef italicFont = CTFontCreateWithName((__bridge CFStringRef)timeFont.fontName, timeFont.pointSize, NULL);
            [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)italicFont range:time1];
            CFRelease(italicFont);
        }
        
        if (time2.location != NSNotFound) {

            CTFontRef italicFont = CTFontCreateWithName((__bridge CFStringRef)timeFont.fontName, timeFont.pointSize, NULL);
            [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)italicFont range:time2];
            CFRelease(italicFont);
        }
        
        if (seperate.location != NSNotFound) {

            CTFontRef italicFont = CTFontCreateWithName((__bridge CFStringRef)seperateFont.fontName, seperateFont.pointSize, NULL);
            [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)italicFont range:seperate];
            CFRelease(italicFont);
        }
        
        return mutableAttributedString;
    }];
}

+ (NSString*)calculateTimeInfo:(NSString*)beginTime endTime:(NSString*)endTime launchTime:(NSString*)launchTime
{
    NSString* timeInfo = @"";
    static NSDateFormatter* dateFormatter;
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
        [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
        [dateFormatter setLocale:[NSLocale currentLocale]];
    }
    
    NSDate* begin = [dateFormatter dateFromString:beginTime];
    NSDate* end = [dateFormatter dateFromString:endTime];
    NSTimeInterval begins = [begin timeIntervalSince1970];
    NSTimeInterval ends = [end timeIntervalSince1970];
    NSString* launchInfo = [NSString stringWithFormat:@"创建于 %@",[self calculateTimeStr:launchTime shortVersion:NO]];
    int dis = ends-begins;
    if (dis > 0) {
        NSString* duration = @"";
        if (dis >= 31536000) {
            duration = [NSString stringWithFormat:@"%d年",dis/31536000];
        }else if (dis >= 2592000) {
            duration = [NSString stringWithFormat:@"%d月",dis/2592000];
        }else if (dis >= 86400) {
            duration = [NSString stringWithFormat:@"%d日",dis/86400];
        }else if (dis >= 3600) {
            duration = [NSString stringWithFormat:@"%d小时",dis/3600];
        }else if (dis >= 60) {
            duration = [NSString stringWithFormat:@"%d分钟",dis/60];
        }else{
            duration = [NSString stringWithFormat:@"%d秒",dis];
        }
        
        timeInfo = [NSString stringWithFormat:@"活动持续时间: %@",duration];
        while (timeInfo.length < 15) {
            timeInfo = [timeInfo stringByAppendingString:@" "];
        }
        timeInfo = [timeInfo stringByAppendingString:launchInfo];
    }else timeInfo = launchInfo;
    return timeInfo;
}

//根据时间生成活动时间信息简述
+(NSString*)calculateTimeStr:(NSString*)time shortVersion:(BOOL)isShortVersion
{
    static NSDateFormatter* dateFormatter;
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
        [dateFormatter setLocale:[NSLocale currentLocale]];
    }
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSDate* dateTime = [dateFormatter dateFromString:time];
    NSDate* now = [NSDate date];
    NSTimeInterval dateTimeInterval = [dateTime timeIntervalSince1970];
    NSTimeInterval nowInterval = [now timeIntervalSince1970];
    
    if (isShortVersion) {
        [dateFormatter setDateFormat:@"MM-dd"];
    } else {
        [dateFormatter setDateFormat:@"YYYY年MM月dd日"];
    }
    NSString* timeInfo = [dateFormatter stringFromDate:dateTime];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSInteger unitFlags = NSYearCalendarUnit;
    
    NSDateComponents *compsDate  = [calendar components:unitFlags fromDate:dateTime];
    NSDateComponents *compsNow  = [calendar components:unitFlags fromDate:now];
    
    int dis = nowInterval - dateTimeInterval;
    if (dis >= - 60) {
        if (compsDate.year != compsNow.year) {
            if (isShortVersion) {
                [dateFormatter setDateFormat:@"MM-dd"];
            } else {
                [dateFormatter setDateFormat:@"YYYY年MM月dd日"];
            }
        } else if (dis >= 86400*7) {
            if (isShortVersion) {
                [dateFormatter setDateFormat:@"MM-dd"];
            } else {
                [dateFormatter setDateFormat:@"MM月dd日"];
            }
            timeInfo = [dateFormatter stringFromDate:dateTime];
        }else if (dis >= 86400*2) {
            timeInfo = [NSString stringWithFormat:@"%d天前",dis/86400];
        }else if (dis >= 86400) {
            timeInfo = [NSString stringWithFormat:@"昨天"];
        }else if (dis >= 60*9) {
            [dateFormatter setDateFormat:@"HH:mm"];
            timeInfo = [dateFormatter stringFromDate:dateTime];
        }else if (dis >= 60*1) {
            timeInfo = [NSString stringWithFormat:@"%d分钟前",dis/60];
        }else{
            timeInfo = [NSString stringWithFormat:@"刚刚"];
        }
    }
    return timeInfo;
}


+(double)GetDistance:(double)lat1 lng1:(double)lng1 lat2:(double)lat2 lng2:(double)lng2
{
    CLLocation *orig=[[CLLocation alloc] initWithLatitude:lat1  longitude:lng1];
    CLLocation* dist=[[CLLocation alloc] initWithLatitude:lat2  longitude:lng2];
    
    CLLocationDistance meters=[orig distanceFromLocation:dist];    return meters;
}

+ (void)addLeftButton:(UIViewController*)controller isFirstPage:(BOOL)isFirstPage
{
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)){

        UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
        temporaryBarButtonItem.title = @" ";
        temporaryBarButtonItem.target = controller;
        controller.navigationItem.backBarButtonItem = temporaryBarButtonItem;

    }
}

//从文件中提取Dictionary
+ (NSDictionary *)dictionaryFromFile:(NSString*)fileName {
    NSDictionary *dictionary = nil;

    NSString *dictionaryFilePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:fileName];
    dictionary = [[NSDictionary alloc] initWithContentsOfFile:dictionaryFilePath];

	return dictionary;
}

//从文件中提取Array
+ (NSArray *)arrayFromFile:(NSString*)fileName {
    NSArray *array = nil;
    
    NSString *arrayFilePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:fileName];
    array = [[NSArray alloc] initWithContentsOfFile:arrayFilePath];
    
	return array;
}

+(NSString*)TextFromInt:(int)num
{
    if (num < 1000) {
        NSString* text = [NSString stringWithFormat:@"%d",num];
        while (text.length <3) {
            text = [@" " stringByAppendingString:text];
        }
        return text;
    }else if(num < 10000){
        return [NSString stringWithFormat:@"%dk+",num%1000];
    }else{
        return [NSString stringWithFormat:@"%dw+",num%10000];
    }
}

//计算label动态高度
+ (float)calculateTextHeight:(NSString*)text width:(float)width fontSize:(float)fsize isEmotion:(BOOL)isEmotion
{
    float height = 0;
    UIFont *font = [UIFont systemFontOfSize:fsize];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
    {
        CGSize size = CGSizeMake(width,2000);
        CGRect labelRect = [text boundingRectWithSize:size options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)  attributes:[NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName] context:nil];
        height = ceil(labelRect.size.height);
        if (isEmotion) height*=1.25;
    }else{
        CGSize size = [text sizeWithFont:font constrainedToSize:CGSizeMake(width, 1000.0f) lineBreakMode:NSLineBreakByCharWrapping];
        height = ceil(size.height);
        if (isEmotion) height*=1.6;
    }
    return height;
}

+(int)compareVersion1:(NSString*)version1 andVersion2:(NSString*)version2
{
    int isCountEqual = 0;
    NSArray* version1_arr = [version1 componentsSeparatedByString:@"."];
    NSArray* version2_arr = [version2 componentsSeparatedByString:@"."];
    MTLOG(@"version1 parts arr: %@",version1_arr);
    MTLOG(@"version2 parts arr: %@",version2_arr);
    int count;
    if (version1_arr.count < version2_arr.count) {
        count = version1_arr.count;
        isCountEqual = 2;
    }
    else if (version1_arr.count > version2_arr.count)
    {
        count = version2_arr.count;
        isCountEqual = 1;
    }
    else
    {
        count = version1_arr.count;
    }
    
    for (int i = 0; i < count; i++) {
        NSNumber* ver1 = [CommonUtils NSNumberWithNSString:version1_arr[i]];
        NSNumber* ver2 = [CommonUtils NSNumberWithNSString:version2_arr[i]];
        int rs = [ver1 compare:ver2];
        if (rs == -1) {
            MTLOG(@"version1 小于 version2");
            return -1;
        }
        else if (rs == 1)
        {
            MTLOG(@"version1 大于 version2");
            return 1;
        }
    }
    if (isCountEqual == 0) {
        MTLOG(@"version1 等于 version2");
        return 0;
    }
    else if (isCountEqual == 1)
    {
        MTLOG(@"version1 大于 version2");
        return 1;
    }
    else
    {
        MTLOG(@"version1 小于 version2");
        return -1;
    }
}

+(NSString*)arrayStyleStringfromNummerArray:(id)numbers
{
    NSString *arrayString = @"[";
    BOOL flag = YES;
    for (NSNumber* number in numbers) {
        arrayString = [arrayString stringByAppendingString: flag? @"%@":@",%@"];
        if (flag) flag = NO;
        arrayString = [NSString stringWithFormat:arrayString,number];
    }
    arrayString = [arrayString stringByAppendingString:@"]"];
    return arrayString;
}

+ (NSDictionary *)parameterSignature:(NSDictionary *)dict
{
    NSMutableDictionary *parameterSign = [dict mutableCopy];
    NSDate *date = [NSDate date];
    long timestamp = [date timeIntervalSince1970];
    [parameterSign setValue:@(timestamp) forKey:@"timestamp"];
    
    
    NSArray *keys = [parameterSign allKeys];
    keys = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString *str1 = obj1;
        NSString *str2 = obj2;
        return [str1 compare:str2];
    }];
    
    NSString *sign = @"";
    
    for (NSString *key in keys) {
        id value = [parameterSign valueForKey:key];
        
        if([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSNumber class]]){
            NSString *valueStr = value? [NSString stringWithFormat:@"%@",value]:nil;
            if (valueStr) {
                sign = [sign stringByAppendingString:valueStr];
            }
        }
    }
    
//    NSLog(@"MD5 原串：%@",sign);

    NSString *signature = [sign stringByAppendingString:MTPortCheckKey];
    
    signature = [CommonUtils MD5EncryptionWithString:signature];
    
//    [parameterSign setValue:[sign stringByAppendingString:MTPortCheckKey] forKey:@"unsign"];
    [parameterSign setValue:signature forKey:@"signature"];
    
    return [parameterSign copy];
}
@end
