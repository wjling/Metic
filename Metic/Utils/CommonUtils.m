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

+(void)showSimpleAlertViewWithTitle:(NSString *)title WithMessage:(NSString *)message WithDelegate:(id)delegate WithCancelTitle:(NSString *)cancelTitle
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:delegate cancelButtonTitle:cancelTitle otherButtonTitles:nil, nil];
    [alert show];

}

+ (NSNumber*)NSNumberWithNSString:(NSString *)string
{
    id result;
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

+ (NSDictionary*)NSDictionaryWithNSString:(NSString *)string
{
    NSData* temp1 = [string dataUsingEncoding:NSUTF8StringEncoding];
    return [NSJSONSerialization JSONObjectWithData:temp1 options:NSJSONReadingMutableLeaves error:nil];
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

@end
