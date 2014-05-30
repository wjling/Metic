//
//  NSString+JSON.h
//  Metic
//
//  Created by ligang_mac4 on 14-5-30.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (JSON)

+(NSString *) jsonStringWithDictionary:(NSDictionary *)dictionary;

+(NSString *) jsonStringWithArray:(NSArray *)array;

+(NSString *) jsonStringWithString:(NSString *) string;

+(NSString *) jsonStringWithObject:(id) object;

@end
