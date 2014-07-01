//
//  MTUser.m
//  Metic
//
//  Created by ligang_mac4 on 14-5-27.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "MTUser.h"
#import "MySqlite.h"

@interface MTUser ()
@end

@implementation MTUser


static MTUser *singletonInstance;

+ (MTUser *)sharedInstance
{
	return singletonInstance;
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        singletonInstance = self;
    }
    return self;
}

- (void)getInfo:(NSNumber *)uid myid:(NSNumber *)myid delegateId:(id) aDelegate
{
    
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:myid forKey:@"myid"];
    [dictionary setValue:uid forKey:@"id"];
    NSLog(@"getInfo:\n%@",dictionary);
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:aDelegate];
    [httpSender sendMessage:jsonData withOperationCode:GET_USER_INFO];
}

- (void)setUserid:(NSNumber *)userid
{
    _userid = userid;
    NSLog(@"set user id");
    [self initUserDir];
}

- (void)initUserDir
{
    if (YES) {
        NSString* mediaDir= [NSString stringWithFormat:@"%@/Documents/media", NSHomeDirectory()];
        NSLog(mediaDir,nil);
        BOOL isDir = NO;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL existed = [fileManager fileExistsAtPath:mediaDir isDirectory:&isDir];
        if (!(isDir == YES && existed == YES)) {
            [fileManager createDirectoryAtPath:mediaDir withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
    NSString* userDir= [NSString stringWithFormat:@"%@/Documents/%@", NSHomeDirectory(), self.userid];
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:userDir isDirectory:&isDir];
    if (!(isDir == YES && existed == YES)) {
        [fileManager createDirectoryAtPath:userDir withIntermediateDirectories:YES attributes:nil error:nil];
//        [self initUserDB];
        NSLog(@"init user DB");
        [self performSelectorOnMainThread:@selector(initUserDB) withObject:nil waitUntilDone:YES];
    }
}

- (void)initUserDB
{
    MySqlite * sql = [[MySqlite alloc]init];
    NSString * path = [NSString stringWithFormat:@"%@/db",self.userid];
    [sql openMyDB:path];
    [sql createTableWithTableName:@"event" andIndexWithProperties:@"event_id INTEGER PRIMARY KEY UNIQUE",@"event_info",nil];
    [sql createTableWithTableName:@"notification" andIndexWithProperties:@"seq INTEGER PRIMARY KEY UNIQUE",@"timestamp",@"msg",nil];
    [sql createTableWithTableName:@"friend" andIndexWithProperties:@"id INTEGER PRIMARY KEY UNIQUE",@"name",@"email",@"gender",nil];
    [sql closeMyDB];
    self.logined = YES;
}

- (void)initWithData:(NSDictionary *)mdictionary
{
    self.userid = [mdictionary valueForKey:@"id"];
    self.name = [mdictionary valueForKey:@"name"];
    self.gender = [mdictionary valueForKey:@"gender"];
    self.sign = [mdictionary valueForKey:@"sign"];
    self.phone = [mdictionary valueForKey:@"phone"];
    self.location = [mdictionary valueForKey:@"location"];
    self.email = [mdictionary valueForKey:@"email"];
    
}


@end
