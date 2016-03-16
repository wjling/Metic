//
//  MTEvent.h
//  Metic
//
//  Created by ligang_mac4 on 14-5-27.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MTEvent : NSObject

+ (MTEvent *)sharedInstance;

- (BOOL)analyzePasteboard;

- (NSString *)getValidPasteString;

- (void)clearPasteBoard;

@end
