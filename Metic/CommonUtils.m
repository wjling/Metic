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

+(void)LabelAdaptedFrame:(UILabel *)label fontsize:(float)fontsize
{
    CGSize maximumSize =CGSizeMake(280,80);
    NSDictionary *attribute = @{NSFontAttributeName: [UIFont systemFontOfSize:13]};
    CGSize size = [label.text boundingRectWithSize:maximumSize options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
    
    //UIFont*dateFont =[UIFont fontWithName:@"Helvetica" size:14];
    //CGSize size = [label.text sizeWithAttributes: @{NSFontAttributeName: [UIFont fontWithName:@"Helvetica" size:fontsize]}];
//    //CGSize dateStringSize =[label.text size sizeWithFont:dateFont
//                                  constrainedToSize:maximumSize
//                                      lineBreakMode:label.lineBreakMode];
    CGRect frame =CGRectMake(20,231,280, size.height);
    label.frame = frame;
}


+(NSString*)SHA1EncryptionWithString:(NSString *)str
{
    const char *cstr = [str cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:str.length];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, data.length, digest);
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return output;
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

@end
