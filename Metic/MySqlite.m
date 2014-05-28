//
//  MySqlite.m
//  Metic
//
//  Created by ligang5 on 14-5-28.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "MySqlite.h"

@implementation MySqlite
@synthesize myDB;

- (BOOL)openMyDB:(NSString*)DBname
{
    NSArray* path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* DB_path = [(NSString*)[path objectAtIndex:0] stringByAppendingPathComponent:DBname];
    
    NSLog(@"array path: %@",path);
    NSLog(@"DB_path: %@",DB_path);
    if (sqlite3_open([DB_path UTF8String], &myDB) != SQLITE_OK) {
        sqlite3_close(myDB);
        NSLog(@"database open failed");
        return NO;
    }
    NSLog(@"database open succeeded");
    return YES;
}

- (BOOL)execSql:(NSString *)sql
{
    char* error;
    if (sqlite3_exec(myDB, [sql UTF8String], nil, nil, &error) != SQLITE_OK) {
        sqlite3_close(myDB);
        NSLog(@"executing sql failed. error: %s", error);
        return NO;
    }
    else
    {
        NSLog(@"executing sql succeeded");
        return YES;
    }
    
}

- (BOOL)createTableWithTableName:(NSString*)tableName andIndexWithProperties:(NSString*)index_properties, ...
{
    NSMutableString* sql = [[NSMutableString alloc]initWithString:@"CREATE TABLE IF NOT EXISTS "];
    [sql appendString:[NSString stringWithFormat:@"%@%@",tableName,@" ("]];
//    NSLog(@"get sql1: %@",sql);
    va_list indexList;
    
    NSString* item = index_properties;
    if (item) {
        [sql appendString:item];
    }
    else
    {
        NSLog(@"no index found, error");
        return NO;
    }
//    NSLog(@"get sql2: %@",sql);
    va_start(indexList, index_properties);
    item = va_arg(indexList, NSString*);
    while (item) {
        [sql appendString:@","];
        [sql appendString:item];
        item = va_arg(indexList, NSString*);
    }
    va_end(indexList);
    [sql appendString:@")"];
    NSLog(@"get sql: %@",sql);
    
    char* error;
    if (sqlite3_exec(myDB, [sql UTF8String], nil, nil, &error) != SQLITE_OK) {
        sqlite3_close(myDB);
        NSLog(@"creating table failed. error: %s", error);
        return NO;
    }
    else
    {
        NSLog(@"creating table succeeded");
        return YES;
    }

}

- (BOOL)insertToTable:(NSString *)tableName withColumns:(NSArray *)columns andItsValues:(NSArray *)values
{
    if (!tableName || !columns.count || !values.count) {
        NSLog(@"data input error");
        return NO;
    }
    NSMutableString* sql = [NSMutableString stringWithFormat:@"INSERT INTO '%@'(",tableName];
    int count = columns.count;
    for (int i = 0; i < columns.count; i++) {
        [sql appendString:[columns objectAtIndex:i]];
        if (i != columns.count - 1) {
            [sql appendString:@","];
        }
    }
    [sql appendString:@") VALUES ("];
    for (int i = 0; i < values.count; i++) {
        [sql appendString:[values objectAtIndex:i]];
        if (i != values.count - 1) {
            [sql appendString:@","];
        }
    }
    [sql appendString:@")"];

    char* error;
    if (sqlite3_exec(myDB, [sql UTF8String], nil, nil, &error) != SQLITE_OK) {
        sqlite3_close(myDB);
        NSLog(@"insert table failed. error: %s", error);
        return NO;
    }
    else
    {
        NSLog(@"insert table succeeded");
        return YES;
    }

    
}


@end
