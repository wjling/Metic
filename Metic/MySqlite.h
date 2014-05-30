//
//  MySqlite.h
//  Metic
//
//  Created by ligang5 on 14-5-28.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface MySqlite : NSObject
@property(nonatomic,readwrite) sqlite3* myDB;

//打开数据库。使用数据库前先执行此方法
- (BOOL)openMyDB:(NSString*)DBname;

//关闭数据库。操作完数据库之后执行此方法，释放数据库内存占用
- (BOOL)closeMyDB;

//直接执行sql
- (BOOL)execSql:(NSString*)sql;

//建数据表
- (BOOL)createTableWithTableName:(NSString*)tableName andIndexWithProperties:(NSString*)index_properties,...;

//插入方法。columns和values两个数组的元素都是(NSString*)。插入元组主键相同，会直接覆盖表中原有的元组
//举例：
//1. 如果插入表中的数据是数字，则在array中插入object形如: @"3"，@"3.5"
//2. 如果插入表中的数据是字符串，则在array中插入object形如（注意加单引号）： @"'2011-1-12'", @"'John'"
- (BOOL)insertToTable:(NSString*)tableName withColumns:(NSArray*)columns andValues:(NSArray*)values;

//这个方法有bug，用不了，废弃
- (BOOL)updateDataWitTableName:(NSString*)tableName andWhere:(NSString*)primaryKey andItsValue:(NSString*)value withColumns:(NSArray*)columns andValues:(NSArray*)values;


//更新方法。wheres是WHERE语句的键值对，sets是SET语句的键值对
//关于NSDictionary的键值对：
//1. 键（key）的类型是NSString
//2. 如果值是数字，则形如：@"3"，@"3.5"
//3. 如果值是字符串，则需加单引号，形如：@"'2011-1-12'", @"'John'"

//表名（tableName）可以不用加单引号,如：@"TESTTABLE"。加了也没问题
- (BOOL)updateDataWitTableName:(NSString *)tableName andWhere:(NSDictionary*)wheres andSet:(NSDictionary*)sets;


//查询方法。selects是SELECT语句的字段名，wheres是WHERE语句的键值对
//说明：
//1. selects中的字段名都是(NSString*)，可以不用加单引号，如：@"user_id"
//2. wheres中键值对的键类型是（NSString*)，
//   值的类型如果是数字，则形如：@"3"，@"3.5"
//   值的类型如果是字符串，则要加单引号，形如：@"'2011-1-12'", @"'John'"

- (NSMutableArray*)queryTable:(NSString*)tableName withSelect:(NSArray*)selects andWhere:(NSDictionary*)wheres;


//删除方法。wheres是WHERE语句的键值对，对应的说明如上的“查询方法”
- (BOOL)deleteTurpleFromTable:(NSString*)tableName withWhere:(NSDictionary*)wheres;

@end
