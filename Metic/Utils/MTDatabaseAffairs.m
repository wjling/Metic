//
//  MTDatabaseAffairs.m
//  WeShare
//
//  Created by 俊健 on 15/5/26.
//  Copyright (c) 2015年 WeShare. All rights reserved.
//

#import "MTDatabaseAffairs.h"
#import "MTDatabaseHelper.h"
#import "NSString+JSON.h"

@implementation MTDatabaseAffairs

+ (MTDatabaseAffairs *)sharedInstance {
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


-(void)saveEventToDB:(NSDictionary*)event
{
    NSString *eventData = [NSString jsonStringWithDictionary:event];
    eventData = [eventData stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    NSString *beginTime = [event valueForKey:@"time"];
    NSString *joinTime = [event valueForKey:@"jointime"];
    NSNumber *islike = [event valueForKey:@"islike"];
    NSString* updateTime_sql = [NSString stringWithFormat:@"(SELECT updateTime FROM event WHERE event_id = %@)",[event valueForKey:@"event_id"]];
    NSString* likeTime_sql = [event valueForKey:@"likeTime"];
    if(!likeTime_sql) likeTime_sql = [NSString stringWithFormat:@"(SELECT likeTime FROM event WHERE event_id = %@)",[event valueForKey:@"event_id"]];
    else likeTime_sql = [NSString stringWithFormat:@"'%@'",likeTime_sql];
    
    
    NSArray *columns = [[NSArray alloc]initWithObjects:@"'event_id'",@"'beginTime'",@"'joinTime'",@"'updateTime'",@"'likeTime'",@"'islike'",@"'event_info'", nil];
    NSArray *values = [[NSArray alloc]initWithObjects:[NSString stringWithFormat:@"%@",[event valueForKey:@"event_id"]],[NSString stringWithFormat:@"'%@'",beginTime],[NSString stringWithFormat:@"'%@'",joinTime],updateTime_sql,likeTime_sql,[NSString stringWithFormat:@"'%@'",islike],[NSString stringWithFormat:@"'%@'",eventData], nil];
    [[MTDatabaseHelper sharedInstance]insertToTable:@"event" withColumns:columns andValues:values];
}

@end
