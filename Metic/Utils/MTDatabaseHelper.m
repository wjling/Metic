//
//  MTDatabaseHelper.m
//  WeShare
//
//  Created by 俊健 on 15/4/17.
//  Copyright (c) 2015年 WeShare. All rights reserved.
//

#import "MTDatabaseHelper.h"
#import "FMDatabaseQueue.h"
#import "FMDatabase.h"
#import "MTUser.h"

static MTDatabaseHelper *singleInstance = nil;

@implementation MTDatabaseHelper
{
    FMDatabaseQueue* queue;
}


-(id) init
{
    self = [super init];
    if(self){
        NSArray* path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString* DBname =[NSString stringWithFormat:@"%@/db",[MTUser sharedInstance].userid];
        NSString *dbFilePath =[(NSString*)[path objectAtIndex:0] stringByAppendingPathComponent:DBname];
        queue = [FMDatabaseQueue databaseQueueWithPath:dbFilePath];
    }
    return self;
}

+(MTDatabaseHelper*) sharedInstance
{
    if(singleInstance == nil)
        singleInstance = [[self alloc] init];
    return singleInstance;
}

-(void) inDatabase:(void(^)(FMDatabase*))block
{
    [queue inDatabase:^(FMDatabase *db){
        block(db);
    }];
}

+(void) refreshDatabaseFile
{
    singleInstance = nil;
    return;
    MTDatabaseHelper *instance = [self sharedInstance];
    [instance doRefresh];
}

-(void) doRefresh
{
    NSArray* path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* DBname =[NSString stringWithFormat:@"%@/db",[MTUser sharedInstance].userid];
    NSString *dbFilePath =[(NSString*)[path objectAtIndex:0] stringByAppendingPathComponent:DBname];
    queue = [FMDatabaseQueue databaseQueueWithPath:dbFilePath];
}

//创建数据库的表（改成将字段和属性放在数组indexes里）
- (void)createTableWithTableName:(NSString*)tableName indexesWithProperties:(NSArray*)indexes
{
    if (!indexes || indexes.count == 0) return;
    NSMutableString* sql = [[NSMutableString alloc]initWithString:@"CREATE TABLE IF NOT EXISTS "];
    [sql appendString:[NSString stringWithFormat:@"%@%@",tableName,@" ("]];
    
    NSString* item = [indexes objectAtIndex:0];
    [sql appendString:item];
    for (NSInteger i = 1; i < indexes.count; i++) {
        [sql appendString:@","];
        item = [indexes objectAtIndex:i];
        [sql appendString:item];
    }
    
    [sql appendString:@")"];
    NSLog(@"create table sql: %@",sql);
    

    [queue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:sql];
    }];
}

//插入操作
- (void)insertToTable:(NSString*)tableName withColumns:(NSArray*)columns andValues:(NSArray*)values
{
    NSInteger columnsCount = columns.count;
    NSInteger valuesCount = values.count;
    if (!tableName || !columnsCount || !valuesCount) {
        NSLog(@"data input error");
        return;
    }
    NSMutableString* sql = [NSMutableString stringWithFormat:@"INSERT OR REPLACE INTO '%@'(",tableName];
    
    for (int i = 0; i < columnsCount; i++) {
        [sql appendString:[columns objectAtIndex:i]];
        if (i != columnsCount - 1) {
            [sql appendString:@","];
        }
    }
    [sql appendString:@")VALUES("];
    for (int i = 0; i < valuesCount; i++) {
        NSString* value = [values objectAtIndex:i];
        if (value && ![value isEqual:[NSNull null]]) {
            [sql appendString:value];
        }
        else if ([value isEqual:[NSNull null]])
        {
            [sql appendString:@"NULL"];
        }
        if (i != valuesCount - 1) {
            [sql appendString:@","];
        }
    }
    [sql appendString:@")"];
    NSLog(@"insert into table sql: %@",sql);
    [queue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:sql];
    }];
    
}

//更新操作
- (void)updateDataWithTableName:(NSString *)tableName andWhere:(NSDictionary*)wheres andSet:(NSDictionary*)sets
{
    NSInteger wheresCount = wheres.count;
    NSInteger setsCount = sets.count;
    if (!tableName || !wheresCount || !setsCount) {
        NSLog(@"input data error");
        return ;
    }
    
    NSMutableString* sql = [[NSMutableString alloc]initWithFormat:@"UPDATE %@ SET ",tableName];
    NSArray* wheresKeys = wheres.allKeys;
    NSArray* setsKeys = sets.allKeys;
    for (int i = 0; i < setsCount; i++) {
        NSString* key = [setsKeys objectAtIndex:i];
        NSString* value = [sets objectForKey:key];
        [sql appendFormat:@"%@ = %@ ",key,value];
        if (i != setsCount-1) {
            [sql appendString:@", "];
        }
    }
    [sql appendString:@"WHERE "];
    for (int i = 0; i < wheresCount; i++) {
        NSString* key = [wheresKeys objectAtIndex:i];
        NSString* value = [wheres objectForKey:key];
        [sql appendFormat:@"%@ = %@ ",key,value];
        if (i != wheresCount-1) {
            [sql appendString:@", "];
        }
    }
    NSLog(@"update sql: %@",sql);
    [queue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:sql];
    }];
}

//查询操作
- (void)queryTable:(NSString*)tableName withSelect:(NSArray*)selects andWhere:(NSDictionary*)wheres completion:(void(^)(NSMutableArray* resultsArray))block
{
    NSInteger selectsCount = selects.count;
    NSInteger wheresCount = wheres.count;
    if (!tableName || !selectsCount /*|| !wheresCount*/) {
        NSLog(@"input data error");
        return ;
    }
    NSMutableString* sql = [[NSMutableString alloc]initWithString:@"SELECT "];
    NSArray* wheresKeys = wheres.allKeys;
    for (int i = 0; i < selectsCount; i++) {
        NSString* value = [selects objectAtIndex:i];
        [sql appendString:value];
        if (i != selectsCount - 1) {
            [sql appendString:@", "];
        }
    }
    [sql appendFormat:@" FROM %@ ",tableName];
    for (int i = 0; i < wheresCount; i++) {
        if (i==0) {
            [sql appendString:@"WHERE "];
        }
        NSString* key = [wheresKeys objectAtIndex:i];
        NSString* value = [wheres objectForKey:key];
        [sql appendFormat:@"%@ LIKE %@",key,value];
        if (i != wheresCount - 1) {
            [sql appendString:@", "];
        }
    }
    NSLog(@"query sql: %@",sql);
    
    [queue inDatabase:^(FMDatabase *db) {
        FMResultSet *s = [db executeQuery:sql];
        NSMutableArray* resultArray = [[NSMutableArray alloc]init];
        while ([s next]) {
            [resultArray addObject:[s resultDictionary]];
        }
        [s close];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            block(resultArray);
        });
    }];
}

//删除操作
- (void)deleteTurpleFromTable:(NSString*)tableName withWhere:(NSDictionary*)wheres
{
    if (!tableName || [tableName isEqualToString:@""]) {
        NSLog(@"input data error");
        return ;
    }
    NSMutableString* sql;
    if (wheres && wheres.count > 0) {
        sql = [[NSMutableString alloc]initWithFormat:@"DELETE FROM %@ WHERE ",tableName];
        NSInteger wheresCount = wheres.count;
        NSArray* wheresKeys = wheres.allKeys;
        for (int i = 0; i < wheresCount; i++) {
            NSString* key = [wheresKeys objectAtIndex:i];
            NSString* value =[wheres objectForKey:key];
            [sql appendFormat:@"%@ = %@",key, value];
            if (i != wheresCount-1) {
                [sql appendString:@" and "];
            }
        }

    }
    else{
        sql = [[NSMutableString alloc] initWithFormat:@"DELETE * FROM %@",tableName];
    }
    NSLog(@"delete sql: %@",sql);
    [queue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:sql];
    }];
}


//增加表的列属性
-(void)addsColumntoTable:(NSString*)tableName addsColumn:(NSString*)column withDefault:(id)defaultValue
{
    if (!tableName || !column) return;
    NSMutableString* sql = [[NSMutableString alloc]initWithFormat:@"ALTER TABLE %@ ADD COLUMN placeName %@",tableName,column];
    [queue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:sql];
    }];
    
    
}



@end