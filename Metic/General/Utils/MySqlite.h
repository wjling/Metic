////
////  MySqlite.h
////  Metic
////
////  Created by ligang5 on 14-5-28.
////  Copyright (c) 2014年 dishcool. All rights reserved.
////
//
//#import <Foundation/Foundation.h>
//#import <sqlite3.h>
//
//static BOOL isLocked = false;
//
//@interface MySqlite : NSObject
//{
//    NSLock* mlock;
//}
//@property(nonatomic,readwrite) sqlite3* myDB;
//
////打开数据库。使用数据库前先执行此方法
//- (BOOL)openMyDB:(NSString*)DBname;
//
////关闭数据库。操作完数据库之后执行此方法，释放数据库内存占用
//- (BOOL)closeMyDB;
//
////直接执行sql
//- (BOOL)execSql:(NSString*)sql;
//
////建数据表
//- (BOOL)createTableWithTableName:(NSString*)tableName andIndexWithProperties:(NSString*)index_properties,...;
//
////插入方法。columns和values两个数组的元素都是(NSString*)。插入元组主键相同，会直接覆盖表中原有的元组
////举例：
////1. 如果插入表中的数据是数字，则在array中插入object形如: @"3"，@"3.5"
////2. 如果插入表中的数据是字符串，则在array中插入object形如（注意加单引号）： @"'2011-1-12'", @"'John'"
//- (BOOL)insertToTable:(NSString*)tableName withColumns:(NSArray*)columns andValues:(NSArray*)values;
//
////这个方法有bug，用不了，废弃
//- (BOOL)updateDataWitTableName:(NSString*)tableName andWhere:(NSString*)primaryKey andItsValue:(NSString*)value withColumns:(NSArray*)columns andValues:(NSArray*)values;
//
//
////更新方法。wheres是WHERE语句的键值对，sets是SET语句的键值对
////关于NSDictionary的键值对：
////1. 键（key）的类型是NSString
////2. 如果值是数字，则形如：@"3"，@"3.5"
////3. 如果值是字符串，则需加单引号，形如：@"'2011-1-12'", @"'John'"
////4. 键值对形如：name = 'Jhon', number = 1
////表名（tableName）可以不用加单引号,如：@"TESTTABLE"。加了也没问题
//- (BOOL)updateDataWitTableName:(NSString *)tableName andWhere:(NSDictionary*)wheres andSet:(NSDictionary*)sets;
//
//
////查询方法。selects是SELECT语句的字段名，wheres是WHERE语句的键值对
////说明：
////1. selects中的字段名都是(NSString*)，可以不用加单引号，如：@"user_id"
////2. wheres中键值对的键类型是（NSString*)，
////   值的类型如果是数字，则形如：@"3"，@"3.5"
////   值的类型如果是字符串，则要加单引号，形如：@"'2011-1-12'", @"'John'"
////3. 如果没有where语句，可以用nil。
////4. 如果要查询所有列，可以将select的数组设成{"*"};
////5. 如果表中字段的值为空（NULL），则查询的结果的值是[NSNull null];
//
//- (NSMutableArray*)queryTable:(NSString*)tableName withSelect:(NSArray*)selects andWhere:(NSDictionary*)wheres;
//
//
////删除方法。wheres是WHERE语句的键值对，对应的说明如上的“查询方法”
//- (BOOL)deleteTurpleFromTable:(NSString*)tableName withWhere:(NSDictionary*)wheres;
//
//
////判断数据库中一个表是否存在
//- (BOOL)isExistTable:(NSString*)tableName;
//
////在已有的表中增加字段。tableName是表名，column是新增字段名，defaultValue是新增字段的默认值
////说明：
////1. column可以是单纯的字段名，如：@"name"，也可以是带有额外属性的字符串，如：@"item_id INTEGER"等。
////2. defaultValue为nil时，表中等字段默认值为空（NULL）
//-(BOOL)table:(NSString*)tableName addsColumn:(NSString*)column withDefault:(id)defaultValue;
//
//
///*-------------------------2015.04.11更新新方法（基本用法见上面）------------------------------*/
///* 以下的方法自动加入队列顺序执行，并且使用下面方法的时候不用再加上打开数据库和关闭数据库的操作
// * 使用范例（以查询为例）:
// * 直接使用：
// * [mysqlite database:DBname query...];
// * 而不再是：
// * [mysqlite openMyDB];
// * [mysqlite database:DBname query...];
// * [mysqlite closeMyDB];
// *
// * block为方法执行完之后的回调
// *
// * (NSString*)DBname为数据库文件的路径
// */
//
////直接执行sql
//- (void)database:(NSString*)DBname execSql:(NSString*)sql completion:(void(^)(BOOL result))block;
//
////创建数据库的表（改成将字段和属性放在数组indexes里）
//- (void)database:(NSString*)DBname createTableWithTableName:(NSString*)tableName indexesWithProperties:(NSArray*)indexes completion:(void(^)(BOOL result))block;
//
////插入操作
//- (void)database:(NSString*)DBname insertToTable:(NSString*)tableName withColumns:(NSArray*)columns andValues:(NSArray*)values completion:(void(^)(BOOL result))block;
//
////更新操作
//- (void)database:(NSString*)DBname updateDataWitTableName:(NSString *)tableName andWhere:(NSDictionary*)wheres andSet:(NSDictionary*)sets completion:(void (^)(BOOL result)) block;
//
////查询操作
//- (void)database:(NSString*)DBname queryTable:(NSString*)tableName withSelect:(NSArray*)selects andWhere:(NSDictionary*)wheres completion:(void(^)(NSMutableArray* resultsArray))block;
//
////删除操作
//- (void)database:(NSString*)DBname deleteTurpleFromTable:(NSString*)tableName withWhere:(NSDictionary*)wheres completion:(void(^)(BOOL result))block;
//
////查询一个表是否存在
//- (void)database:(NSString*)DBname isExistTable:(NSString*)tableName completion:(void(^)(BOOL result))block;
//
////增加表的列属性
//-(void)database:(NSString*)DBname table:(NSString*)tableName addsColumn:(NSString*)column withDefault:(id)defaultValue completion:(void(^)(BOOL result))block;
//
//@end
