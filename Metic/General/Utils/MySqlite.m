////
////  MySqlite.m
////  Metic
////
////  Created by ligang5 on 14-5-28.
////  Copyright (c) 2014年 dishcool. All rights reserved.
////
//static dispatch_queue_t mysqlite_queue;
//
//#import "MySqlite.h"
//
//@implementation MySqlite
//@synthesize myDB;
//
//-(instancetype)init
//{
//    if (self = [super init]) {
//        static dispatch_once_t predicate;
//        dispatch_once(&predicate, ^{
//            mysqlite_queue = dispatch_queue_create("mysqliteQ", NULL);
//            mlock = [[NSLock alloc]init];
//        });
//    }
//    return self;
//}
//
//- (BOOL)openMyDB:(NSString*)DBname
//{
//    NSArray* path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString* DB_path = [(NSString*)[path objectAtIndex:0] stringByAppendingPathComponent:DBname];
//    
//    NSLog(@"array path: %@",path);
//    NSLog(@"DB_path: %@",DB_path);
////    NSLog(@"sqlite3 lib version: %s", sqlite3_libversion());
////    int err=sqlite3_config(SQLITE_CONFIG_SERIALIZED);
////    if (err == SQLITE_OK) {
////        NSLog(@"Can now use sqlite on multiple threads, using the same connection");
////    } else {
////        NSLog(@"setting sqlite thread safe mode to serialized failed!!! return code: %d", err);
////    }
//    
////    while (isLocked) {
////        NSLog(@"loop: isLocked");
////        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:1]];
////    }
//    [mlock lock];
//    
//    if (sqlite3_open([DB_path UTF8String], &myDB) != SQLITE_OK) {
//        NSLog(@"myDB open failed");
//        return NO;
//    }
//    NSLog(@"myDB open succeeded");
//    NSLog(@"database is locked++");
//    isLocked = true;
//    return YES;
//}
//
//- (BOOL)closeMyDB
//{
//    
//    if (sqlite3_close(self.myDB) != SQLITE_OK)
//    {
//        NSLog(@"close myDB failed");
//        isLocked = false;
//        [mlock unlock];
//        return NO;
//    }
//    else
//    {
//        isLocked = false;
//        NSLog(@"close myDB succeeded");
//        [mlock unlock];
//        return YES;
//    }
//    NSLog(@"database is unLocked--");
//}
//
//- (BOOL)execSql:(NSString *)sql
//{
//    char* error;
//    if (sqlite3_exec(self.myDB, [sql UTF8String], nil, nil, &error) != SQLITE_OK) {
//        sqlite3_close(self.myDB);
//        NSLog(@"executing sql failed. error: %s", error);
//        return NO;
//    }
//    else
//    {
//        NSLog(@"executing sql succeeded");
//        return YES;
//    }
//    
//}
//
//
//- (void)database:(NSString*)DBname execSql:(NSString *)sql completion:(void (^)(BOOL))block
//{
//    dispatch_async(mysqlite_queue, ^{
//        [self openMyDB:DBname];
//        char* error;
//        if (sqlite3_exec(self.myDB, [sql UTF8String], nil, nil, &error) != SQLITE_OK) {
//            NSLog(@"executing sql failed. error: %s", error);
//            [self closeMyDB];
//            if (block) {
//                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                    block(NO);
//                });
//            }
//        }
//        else
//        {
//            NSLog(@"executing sql succeeded");
//            [self closeMyDB];
//            if (block) {
//                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                    block(YES);
//                });
//            }
//        }
//
//    });
//}
//
//- (BOOL)createTableWithTableName:(NSString*)tableName andIndexWithProperties:(NSString*)index_properties, ...
//{
//    NSMutableString* sql = [[NSMutableString alloc]initWithString:@"CREATE TABLE IF NOT EXISTS "];
//    [sql appendString:[NSString stringWithFormat:@"%@%@",tableName,@" ("]];
////    NSLog(@"get sql1: %@",sql);
//    va_list indexList;
//    
//    NSString* item = index_properties;
//    if (item) {
//        [sql appendString:item];
//    }
//    else
//    {
//        NSLog(@"no index found, error");
//        return NO;
//    }
////    NSLog(@"get sql2: %@",sql);
//    va_start(indexList, index_properties);
//    item = va_arg(indexList, NSString*);
//    while (item) {
//        [sql appendString:@","];
//        [sql appendString:item];
//        item = va_arg(indexList, NSString*);
//    }
//    va_end(indexList);
//    [sql appendString:@")"];
//    NSLog(@"get sql: %@",sql);
//    
//    char* error;
//    if (sqlite3_exec(self.myDB, [sql UTF8String], nil, nil, &error) != SQLITE_OK) {
//        sqlite3_close(self.myDB);
//        NSLog(@"creating table failed. error: %s", error);
//        return NO;
//    }
//    else
//    {
//        NSLog(@"creating table succeeded");
//        return YES;
//    }
//
//}
//
//-(void)database:(NSString*)DBname createTableWithTableName:(NSString*)tableName indexesWithProperties:(NSArray*)indexes completion:(void(^)(BOOL result))block;
//{
//    dispatch_async(mysqlite_queue, ^{
//        [self openMyDB:DBname];
//        NSMutableString* sql = [[NSMutableString alloc]initWithString:@"CREATE TABLE IF NOT EXISTS "];
//        [sql appendString:[NSString stringWithFormat:@"%@%@",tableName,@" ("]];
//        
//        if (indexes && indexes.count > 0) {
//            NSString* item = [indexes objectAtIndex:0];
//            [sql appendString:item];
//            for (NSInteger i = 1; i < indexes.count; i++) {
//                [sql appendString:@","];
//                item = [indexes objectAtIndex:i];
//                [sql appendString:item];
//            }
//
//            [sql appendString:@")"];
//            NSLog(@"create table sql: %@",sql);
//            
//            char* error;
//            if (sqlite3_exec(self.myDB, [sql UTF8String], nil, nil, &error) != SQLITE_OK) {
//                NSLog(@"creating table failed. error: %s", error);
//                [self closeMyDB];
//                if (block) {
//                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                        block(NO);
//                    });
//                    
//                }
//            }
//            else
//            {
//                
//                NSLog(@"creating table succeeded");
//                [self closeMyDB];
//                if (block) {
//                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                        block(YES);
//                    });
//                }
//            }
//
//        }
//        else
//        {
//            NSLog(@"index input error");
//            [self closeMyDB];
//            if (block) {
//                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                    block(NO);
//                });
//            }
//        }
//
//    });
//}
//
//- (BOOL)insertToTable:(NSString *)tableName withColumns:(NSArray *)columns andValues:(NSArray *)values
//{
//    NSInteger columnsCount = columns.count;
//    NSInteger valuesCount = values.count;
//    if (!tableName || !columnsCount || !valuesCount) {
//        NSLog(@"data input error");
//        return NO;
//    }
//    NSMutableString* sql = [NSMutableString stringWithFormat:@"INSERT OR REPLACE INTO '%@'(",tableName];
//    
//    for (int i = 0; i < columnsCount; i++) {
//        [sql appendString:[columns objectAtIndex:i]];
//        if (i != columnsCount - 1) {
//            [sql appendString:@","];
//        }
//    }
//    [sql appendString:@")VALUES("];
//    for (int i = 0; i < valuesCount; i++) {
//        NSString* value = [values objectAtIndex:i];
//        if (value && ![value isEqual:[NSNull null]]) {
//            [sql appendString:value];
//        }
//        else if ([value isEqual:[NSNull null]])
//        {
//            [sql appendString:@"NULL"];
//        }
//        if (i != valuesCount - 1) {
//            [sql appendString:@","];
//        }
//    }
//    [sql appendString:@")"];
//    NSLog(@"sql: %@",sql);
//    
//    char* error;
//    if (sqlite3_exec(self.myDB, [sql UTF8String], nil, nil, &error) != SQLITE_OK) {
//        //        sqlite3_close(self.myDB);
//        NSLog(@"insert table failed. error: %s", error);
//        return NO;
//    }
//    else
//    {
//        NSLog(@"insert table succeeded");
//        return YES;
//    }
//    
//}
//
//- (void)database:(NSString*)DBname insertToTable:(NSString *)tableName withColumns:(NSArray *)columns andValues:(NSArray *)values completion:(void (^)(BOOL))block
//{
//    dispatch_async(mysqlite_queue, ^{
//        [self openMyDB:DBname];
//        NSInteger columnsCount = columns.count;
//        NSInteger valuesCount = values.count;
//        if (!tableName || !columnsCount || !valuesCount) {
//            NSLog(@"data input error");
//            [self closeMyDB];
//            if (block) {
//                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                    block(NO);
//                });
//            }
//            return;
//        }
//        NSMutableString* sql = [NSMutableString stringWithFormat:@"INSERT OR REPLACE INTO '%@'(",tableName];
//        
//        for (int i = 0; i < columnsCount; i++) {
//            [sql appendString:[columns objectAtIndex:i]];
//            if (i != columnsCount - 1) {
//                [sql appendString:@","];
//            }
//        }
//        [sql appendString:@")VALUES("];
//        for (int i = 0; i < valuesCount; i++) {
//            NSString* value = [values objectAtIndex:i];
//            if (value && ![value isEqual:[NSNull null]]) {
//                [sql appendString:value];
//            }
//            else if ([value isEqual:[NSNull null]])
//            {
//                [sql appendString:@"NULL"];
//            }
//            if (i != valuesCount - 1) {
//                [sql appendString:@","];
//            }
//        }
//        [sql appendString:@")"];
//        NSLog(@"insert into table sql: %@",sql);
//        
//        char* error;
//        if (sqlite3_exec(self.myDB, [sql UTF8String], nil, nil, &error) != SQLITE_OK) {
//            NSLog(@"insert table failed. error: %s", error);
//            [self closeMyDB];
//            if (block) {
//                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                    block(NO);
//                });
//            }
//        }
//        else
//        {
//            NSLog(@"insert table succeeded");
//            [self closeMyDB];
//            if (block) {
//                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                    block(YES);
//                });
//            }
//        }
//
//    });
//}
//
////abandoned
//- (BOOL)updateDataWitTableName:(NSString *)tableName andWhere:(NSString *)primaryKey andItsValue:(NSString*)value withColumns:(NSArray *)columns andValues:(NSArray *)values
//{
////    char* sql = "UPDATE ? SET ? = ? ";
//    NSInteger columnsCount = columns.count;
//    NSInteger valuesCount = values.count;
//    if (!tableName || !columnsCount || !valuesCount) {
//        NSLog(@"data input error");
//        sqlite3_close(self.myDB);
//        return NO;
//    }
//    NSMutableString* sql = [[NSMutableString alloc]initWithString:@"UPDATE ? SET ? = ? "];
//    for (int i = 1; i < columnsCount; i++) {
//        [sql appendString:@"AND ? = ? "];
//    }
//    [sql appendString:@"WHERE ? = ?"];
//    NSLog(@"updatetable sql: %@",sql);
//    char* sql_c = (char*)[sql UTF8String];
//    sqlite3_stmt* sql_statement;
//    
//    int state1 = sqlite3_prepare_v2(self.myDB, sql_c, -1, &sql_statement, nil);
//    if (state1 != SQLITE_OK) {
//        NSLog(@"transforming sql to sqlite3_stmt failed");
//        sqlite3_close(self.myDB);
//        return NO;
//    }
//    sqlite3_bind_text(sql_statement, 1, [tableName UTF8String], -1, SQLITE_TRANSIENT);
//    
//    int count = 2;
//
////    sqlite3_bind_int(sql_statement, 2, [value intValue]);
//    for (int i = 0; i < columnsCount; i++) {
//        sqlite3_bind_text(sql_statement, count++, [[columns objectAtIndex:i]UTF8String], -1, SQLITE_TRANSIENT);
//        id val = [values objectAtIndex:i];
//        if ([val isKindOfClass:[NSString class]]) {
//            sqlite3_bind_text(sql_statement, count++, [(NSString*)val UTF8String], -1, SQLITE_TRANSIENT);
//        }
//        else
//        {
//            sqlite3_bind_double(sql_statement, count++, [(NSString*)val intValue ]);
//        }
//    }
//    
//    int state2 = sqlite3_step(sql_statement);
//    if (state2 != SQLITE_OK) {
//        NSLog(@"sqlite3_stmt executing failed");
//        sqlite3_close(self.myDB);
//        return NO;
//    }
//    
//    return YES;
//}
//
//- (BOOL)updateDataWitTableName:(NSString *)tableName andWhere:(NSDictionary *)wheres andSet:(NSDictionary *)sets
//{
//    NSInteger wheresCount = wheres.count;
//    NSInteger setsCount = sets.count;
//    if (!tableName || !wheresCount || !setsCount) {
//        NSLog(@"input data error");
//        return NO;
//    }
//    
//    NSMutableString* sql = [[NSMutableString alloc]initWithFormat:@"UPDATE %@ SET ",tableName];
//    NSArray* wheresKeys = wheres.allKeys;
//    NSArray* setsKeys = sets.allKeys;
//    for (int i = 0; i < setsCount; i++) {
//        NSString* key = [setsKeys objectAtIndex:i];
//        NSString* value = [sets objectForKey:key];
//        [sql appendFormat:@"%@ = %@ ",key,value];
//        if (i != setsCount-1) {
//            [sql appendString:@", "];
//        }
//    }
//    [sql appendString:@"WHERE "];
//    for (int i = 0; i < wheresCount; i++) {
//        NSString* key = [wheresKeys objectAtIndex:i];
//        NSString* value = [wheres objectForKey:key];
//        [sql appendFormat:@"%@ = %@ ",key,value];
//        if (i != wheresCount-1) {
//            [sql appendString:@", "];
//        }
//    }
//    NSLog(@"update sql: %@",sql);
//
//    char* error;
//    if (sqlite3_exec(self.myDB, [sql UTF8String], nil, nil, &error) != SQLITE_OK) {
//        sqlite3_close(self.myDB);
//        NSLog(@"update table failed. error: %s", error);
//        return NO;
//    }
//    else
//    {
//        NSLog(@"update table succeeded");
//        return YES;
//    }
//
//}
//
//- (void)database:(NSString*)DBname updateDataWitTableName:(NSString *)tableName andWhere:(NSDictionary *)wheres andSet:(NSDictionary *)sets completion:(void (^)(BOOL))block
//{
//    dispatch_async(mysqlite_queue, ^{
//        [self openMyDB:DBname];
//        NSInteger wheresCount = wheres.count;
//        NSInteger setsCount = sets.count;
//        if (!tableName || !wheresCount || !setsCount) {
//            NSLog(@"input data error");
//            [self closeMyDB];
//            if (block) {
//                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                    block(NO);
//                });
//            }
//            return ;
//        }
//        
//        NSMutableString* sql = [[NSMutableString alloc]initWithFormat:@"UPDATE %@ SET ",tableName];
//        NSArray* wheresKeys = wheres.allKeys;
//        NSArray* setsKeys = sets.allKeys;
//        for (int i = 0; i < setsCount; i++) {
//            NSString* key = [setsKeys objectAtIndex:i];
//            NSString* value = [sets objectForKey:key];
//            [sql appendFormat:@"%@ = %@ ",key,value];
//            if (i != setsCount-1) {
//                [sql appendString:@", "];
//            }
//        }
//        [sql appendString:@"WHERE "];
//        for (int i = 0; i < wheresCount; i++) {
//            NSString* key = [wheresKeys objectAtIndex:i];
//            NSString* value = [wheres objectForKey:key];
//            [sql appendFormat:@"%@ = %@ ",key,value];
//            if (i != wheresCount-1) {
//                [sql appendString:@", "];
//            }
//        }
//        NSLog(@"update sql: %@",sql);
//        
//        char* error;
//        if (sqlite3_exec(self.myDB, [sql UTF8String], nil, nil, &error) != SQLITE_OK) {
//            NSLog(@"update table failed. error: %s", error);
//            [self closeMyDB];
//            if (block) {
//                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                    block(NO);
//                });
//            }
//        }
//        else
//        {
//            NSLog(@"update table succeeded");
//            [self closeMyDB];
//            if (block) {
//                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                    block(YES);
//                });
//            }
//        }
//
//    });
//}
//
//
//- (NSMutableArray*)queryTable:(NSString*)tableName withSelect:(NSArray*)selects andWhere:(NSDictionary *)wheres
//{
//    NSMutableArray* results = [[NSMutableArray alloc]init];
//    
//    NSInteger selectsCount = selects.count;
//    NSInteger wheresCount = wheres.count;
//    if (!tableName || !selectsCount /*|| !wheresCount*/) {
//        NSLog(@"input data error");
//        return nil;
//    }
//    NSMutableString* sql = [[NSMutableString alloc]initWithString:@"SELECT "];
//    NSArray* wheresKeys = wheres.allKeys;
//    for (int i = 0; i < selectsCount; i++) {
//        NSString* value = [selects objectAtIndex:i];
//        [sql appendString:value];
//        if (i != selectsCount - 1) {
//            [sql appendString:@", "];
//        }
//    }
//    [sql appendFormat:@" FROM %@ ",tableName];
//    for (int i = 0; i < wheresCount; i++) {
//        if (i==0) {
//            [sql appendString:@"WHERE "];
//        }
//        NSString* key = [wheresKeys objectAtIndex:i];
//        NSString* value = [wheres objectForKey:key];
//        [sql appendFormat:@"%@ LIKE %@",key,value];
//        if (i != wheresCount - 1) {
//            [sql appendString:@", "];
//        }
//    }
//    NSLog(@"query sql: %@",sql);
//    
//    char* sql_c = (char*)[sql UTF8String];
////    char* error_msg;
//    sqlite3_stmt* sql_stmt;
//    int state1 = sqlite3_prepare_v2(self.myDB, sql_c, -1, &sql_stmt, nil);
//    if (state1 != SQLITE_OK) {
//        NSLog(@"transforming sql to sqlite3_stmt failed, state: %d",state1);
//        sqlite3_close(self.myDB);
//        return nil;
//    }
//    
//    
//    while (sqlite3_step(sql_stmt) == SQLITE_ROW) {
//        NSMutableDictionary* result = [[NSMutableDictionary alloc]init];
//        int columnCount = sqlite3_column_count(sql_stmt);
//        for (int i = 0; i < columnCount; i++) {
//            char* columnName = (char*)sqlite3_column_name(sql_stmt, i);
//            char* columnContent = (char*)sqlite3_column_text(sql_stmt, i);
//            [result
//             setValue: (columnContent? [NSString stringWithCString:columnContent encoding:NSUTF8StringEncoding] : [NSNull null])
//             forKey:[NSString stringWithCString:columnName encoding:NSUTF8StringEncoding]];
//        }
//        [results addObject:result];
//    }
//    sqlite3_finalize(sql_stmt);
////    NSLog(@"query result: %@",results);
//    return results;
//    
//}
//
//- (void)database:(NSString*)DBname queryTable:(NSString *)tableName withSelect:(NSArray *)selects andWhere:(NSDictionary *)wheres completion:(void (^)(NSMutableArray *))block
//{
//    dispatch_async(mysqlite_queue, ^{
//        [self openMyDB:DBname];
//        NSMutableArray* results = [[NSMutableArray alloc]init];
//        
//        NSInteger selectsCount = selects.count;
//        NSInteger wheresCount = wheres.count;
//        if (!tableName || !selectsCount /*|| !wheresCount*/) {
//            NSLog(@"input data error");
//            [self closeMyDB];
//            if (block) {
//                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                    block(nil);
//                });
//            };
//            
//            return ;
//        }
//        NSMutableString* sql = [[NSMutableString alloc]initWithString:@"SELECT "];
//        NSArray* wheresKeys = wheres.allKeys;
//        for (int i = 0; i < selectsCount; i++) {
//            NSString* value = [selects objectAtIndex:i];
//            [sql appendString:value];
//            if (i != selectsCount - 1) {
//                [sql appendString:@", "];
//            }
//        }
//        [sql appendFormat:@" FROM %@ ",tableName];
//        for (int i = 0; i < wheresCount; i++) {
//            if (i==0) {
//                [sql appendString:@"WHERE "];
//            }
//            NSString* key = [wheresKeys objectAtIndex:i];
//            NSString* value = [wheres objectForKey:key];
//            [sql appendFormat:@"%@ LIKE %@",key,value];
//            if (i != wheresCount - 1) {
//                [sql appendString:@", "];
//            }
//        }
//        NSLog(@"query sql: %@",sql);
//        
//        char* sql_c = (char*)[sql UTF8String];
//        //    char* error_msg;
//        sqlite3_stmt* sql_stmt;
//        int state1 = sqlite3_prepare_v2(self.myDB, sql_c, -1, &sql_stmt, nil);
//        if (state1 != SQLITE_OK) {
//            NSLog(@"transforming sql to sqlite3_stmt failed, state: %d",state1);
//            [self closeMyDB];
//            if (block) {
//                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                    block(nil);
//                });
//            };
//            return;
//        }
//        
//        
//        while (sqlite3_step(sql_stmt) == SQLITE_ROW) {
//            NSMutableDictionary* result = [[NSMutableDictionary alloc]init];
//            int columnCount = sqlite3_column_count(sql_stmt);
//            for (int i = 0; i < columnCount; i++) {
//                char* columnName = (char*)sqlite3_column_name(sql_stmt, i);
//                char* columnContent = (char*)sqlite3_column_text(sql_stmt, i);
//                [result
//                 setValue: (columnContent? [NSString stringWithCString:columnContent encoding:NSUTF8StringEncoding] : [NSNull null])
//                 forKey:[NSString stringWithCString:columnName encoding:NSUTF8StringEncoding]];
//            }
//            [results addObject:result];
//        }
//        sqlite3_finalize(sql_stmt);
//        [self closeMyDB];
//        //    NSLog(@"query result: %@",results);
//        if (block) {
//            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                block(results);
//            });
//        }
//        
//
//    });
//}
//
//- (BOOL)deleteTurpleFromTable:(NSString *)tableName withWhere:(NSDictionary *)wheres
//{
//    NSInteger wheresCount = wheres.count;
//    if (!tableName || !wheresCount) {
//        NSLog(@"input data error");
//        return NO;
//    }
//    NSMutableString* sql = [[NSMutableString alloc]initWithFormat:@"DELETE FROM %@ WHERE ",tableName];
//    NSArray* wheresKeys = wheres.allKeys;
//    for (int i = 0; i < wheresCount; i++) {
//        NSString* key = [wheresKeys objectAtIndex:i];
//        NSString* value =[wheres objectForKey:key];
//        [sql appendFormat:@"%@ = %@",key, value];
//        if (i != wheresCount-1) {
//            [sql appendString:@" and "];
//        }
//    }
//    NSLog(@"delete sql: %@",sql);
//    
//    char* error;
//    if (sqlite3_exec(self.myDB, [sql UTF8String], nil, nil, &error) != SQLITE_OK) {
//        [self closeMyDB];
//        NSLog(@"delete table failed. error: %s", error);
//        return NO;
//    }
//    else
//    {
//        NSLog(@"delete table succeeded");
//        return YES;
//    }
//    
//}
//
//- (void)database:(NSString*)DBname deleteTurpleFromTable:(NSString *)tableName withWhere:(NSDictionary *)wheres completion:(void (^)(BOOL))block
//{
//    dispatch_async(mysqlite_queue, ^{
//        [self openMyDB:DBname];
//        NSInteger wheresCount = wheres.count;
//        if (!tableName || !wheresCount) {
//            NSLog(@"input data error");
//            [self closeMyDB];
//            if (block) {
//                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                    block(NO);
//                });
//            };
//            return ;
//        }
//        NSMutableString* sql = [[NSMutableString alloc]initWithFormat:@"DELETE FROM %@ WHERE ",tableName];
//        NSArray* wheresKeys = wheres.allKeys;
//        for (int i = 0; i < wheresCount; i++) {
//            NSString* key = [wheresKeys objectAtIndex:i];
//            NSString* value =[wheres objectForKey:key];
//            [sql appendFormat:@"%@ = %@",key, value];
//            if (i != wheresCount-1) {
//                [sql appendString:@" and "];
//            }
//        }
//        NSLog(@"delete sql: %@",sql);
//        
//        char* error;
//        if (sqlite3_exec(self.myDB, [sql UTF8String], nil, nil, &error) != SQLITE_OK) {
//            NSLog(@"delete table failed. error: %s", error);
//            [self closeMyDB];
//            if (block) {
//                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                    block(NO);
//                });
//            };
//        }
//        else
//        {
//            NSLog(@"delete table succeeded");
//            [self closeMyDB];
//            if (block) {
//                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                    block(YES);
//                });
//            }
//        }
//
//    });
//}
//
//- (BOOL)isExistTable:(NSString *)tableName
//{
////    NSString* sql_str = [NSString stringWithFormat:@"SELECT COUNT(*) FROM sqlite_master where type='table' and name='%@';",tableName];
////    char* sql_c = (char*)[sql_str UTF8String];
////    sqlite3_stmt* sql_stmt;
////    sqlite3_prepare_v2(self.myDB, sql_c, -1, &sql_stmt, nil);
//////    int state = sqlite3_step(sql_stmt);//(self.myDB, sql_c, nil, nil, nil);
////    char* error;
////    int state = sqlite3_exec(self.myDB, sql_c, nil, nil, &error);
//////    NSLog(@"HEHEHE table: %@  found, state: %d",tableName, state);
//    NSMutableArray* state = [self queryTable:tableName withSelect:[NSArray arrayWithObjects:@"*",nil] andWhere:nil];
//    if (state) {
//        NSLog(@"table: %@ found",tableName);
//        return YES;
//    }
//    else
//    {
//        NSLog(@"No table: %@  found",tableName);
//
//        return NO;
//    }
//    
//}
//
//- (void)database:(NSString*)DBname isExistTable:(NSString *)tableName completion:(void (^)(BOOL))block
//{
//    dispatch_async(mysqlite_queue, ^{
//        [self openMyDB:DBname];
//        [self database:DBname queryTable:tableName withSelect:[NSArray arrayWithObjects:@"*",nil] andWhere:nil completion:^(NSMutableArray *resultsArray) {
//            [self closeMyDB];
//            NSMutableArray* state = resultsArray;
//            if (state) {
//                NSLog(@"table: %@ found",tableName);
//                if (block) {
//                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                        block(YES);
//                    });
//                }
//            }
//            else
//            {
//                NSLog(@"No table: %@  found",tableName);
//                if (block) {
//                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                        block(NO);
//                    });
//                }
//            }
//            
//        }];
//    });
//    
//}
//
//
//-(BOOL)table:(NSString*)tableName addsColumn:(NSString*)column withDefault:(id)defaultValue
//{
//    char *errMsg;
//    int result = 1;
//    NSLog(@"表: %@ 增加字段", tableName);
//    NSString* searchSql = [NSString stringWithFormat:@"select sql from sqlite_master where tbl_name = ? and type = 'table'"];
//    sqlite3_stmt *statement;
//    if (sqlite3_prepare_v2(self.myDB, [searchSql UTF8String], -1, &statement, nil) == SQLITE_OK) {
//        sqlite3_bind_text(statement, 1, [tableName UTF8String], -1, nil);
//    }
//    
//    if (sqlite3_step(statement) == SQLITE_ROW) {
//        char *text_chr = (char*)sqlite3_column_text(statement, 0);
//        NSLog(@"获取创建表%@的SQL语句: %s",tableName,text_chr);
//        NSString* sqlStr = [[NSString alloc]initWithUTF8String:text_chr];
//        
//        if ([sqlStr rangeOfString: column].length <= 0) {
//            NSLog(@"没有字段: %@", column);
//            const char *sql_add = [[NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ DEFAULT %@", tableName, column, defaultValue] UTF8String];
//            NSLog(@"插入字段sql: %s",sql_add);
//            if (sqlite3_exec(self.myDB, sql_add, nil, nil, &errMsg) == SQLITE_OK) {
//                NSLog(@"表 %@ 成功插入字段 %@ ", tableName, column);
//            }
//            else
//            {
//                NSLog(@"表 %@ 插入字段 %@ 不成功，错误信息: %s", tableName, column, errMsg);
//                result = 0;
//            }
//        }
//        
//    }
//    sqlite3_finalize(statement);
//    return result;
//}
//
//-(void)database:(NSString*)DBname table:(NSString *)tableName addsColumn:(NSString *)column withDefault:(id)defaultValue completion:(void (^)(BOOL))block
//{
//    dispatch_async(mysqlite_queue, ^{
//        [self openMyDB:DBname];
//        char *errMsg;
//        int result = 1;
//        NSLog(@"表: %@ 增加字段", tableName);
//        NSString* searchSql = [NSString stringWithFormat:@"select sql from sqlite_master where tbl_name = ? and type = 'table'"];
//        sqlite3_stmt *statement;
//        if (sqlite3_prepare_v2(self.myDB, [searchSql UTF8String], -1, &statement, nil) == SQLITE_OK) {
//            sqlite3_bind_text(statement, 1, [tableName UTF8String], -1, nil);
//        }
//        
//        if (sqlite3_step(statement) == SQLITE_ROW) {
//            char *text_chr = (char*)sqlite3_column_text(statement, 0);
//            NSLog(@"获取创建表%@的SQL语句: %s",tableName,text_chr);
//            NSString* sqlStr = [[NSString alloc]initWithUTF8String:text_chr];
//            
//            if ([sqlStr rangeOfString: column].length <= 0) {
//                NSLog(@"没有字段: %@", column);
//                const char *sql_add = [[NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ DEFAULT %@", tableName, column, defaultValue] UTF8String];
//                NSLog(@"插入字段sql: %s",sql_add);
//                if (sqlite3_exec(self.myDB, sql_add, nil, nil, &errMsg) == SQLITE_OK) {
//                    NSLog(@"表 %@ 成功插入字段 %@ ", tableName, column);
//                }
//                else
//                {
//                    NSLog(@"表 %@ 插入字段 %@ 不成功，错误信息: %s", tableName, column, errMsg);
//                    result = 0;
//                }
//            }
//            
//        }
//        sqlite3_finalize(statement);
//        [self closeMyDB];
//        if (block) {
//            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                block(result);
//            });
//        };
//
//    });
//}
//
//
//@end
