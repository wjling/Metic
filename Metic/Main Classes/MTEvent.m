//
//  MTEvent.m
//  Metic
//
//  Created by ligang_mac4 on 14-5-27.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "MTEvent.h"

@interface MTEvent ()

@property (nonatomic, strong) NSString *validPasteString;

@end

@implementation MTEvent
@synthesize validPasteString;

+ (MTEvent *)sharedInstance {
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [self new];
    });
    return instance;
}

- (id)init {
    if ((self = [super init])) {
    }
    return self;
}

- (BOOL)analyzePasteboard {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    
    if ([pasteboard containsPasteboardTypes:UIPasteboardTypeListString]) {
        NSString *str = pasteboard.string;
        BOOL isValid = [self checkValid:str];
        if (isValid) {
            NSString *validStr = [str substringWithRange:NSMakeRange(3, 7)];
            self.validPasteString = validStr;
            pasteboard.string = @"";
            return YES;
        }
    }
    return NO;
}

- (BOOL)checkValid:(NSString *)pasteStr {
    if (!pasteStr || ![pasteStr isKindOfClass:[NSString class]] || pasteStr.length < 10 ) {
        return NO;
    }
    
    const char *pasteArray =[pasteStr UTF8String];
    
    char h = pasteArray[0];
    char d = pasteArray[1];
    char b = pasteArray[2];
    
    char c1 = pasteArray[3];
    char c2 = pasteArray[4];
    char c3 = pasteArray[5];

    int result = 0;
    
    NSError *error = nil;
    
    if (result == 0 && !error) {
        result = [self changeValueFromChar:c1 error:&error] + [self changeValueFromChar:'H' error:&error] - [self changeValueFromChar:h error:&error];
        result %= 36;
    } else {
        return NO;
    }
    
    if (result == 0 && !error) {
        result = [self changeValueFromChar:c2 error:&error] + [self changeValueFromChar:'D' error:&error] - [self changeValueFromChar:d error:&error];
        result %= 36;
    } else {
        return NO;
    }
    
    if (result == 0 && !error) {
        result = [self changeValueFromChar:c3 error:&error] + [self changeValueFromChar:'B' error:&error] - [self changeValueFromChar:b error:&error];
        result %= 36;
    } else {
        return NO;
    }

    return YES;
}

- (int)changeValueFromChar:(char)c error:(NSError **)error{
    if (c >= 'A' && c <= 'Z') {
        return c - 'A' + 10;
    } else if (c >= '0' && c <= '9') {
        return c - '0';
    } else {
        if (!error) {
            *error = [NSError errorWithDomain:@"com.weshare.error.mtevent.changeValueFromChar" code:-1000 userInfo:nil];
        }
    }return -1;
}

- (void)clearPasteBoard {
    
    validPasteString = nil;
    
}

- (NSString *)getValidPasteString {
    return validPasteString;
}

@end
