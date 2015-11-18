//
//  MTDatabaseHelper.h
//  WeShare
//
//  Created by 俊健 on 15/4/17.
//  Copyright (c) 2015年 WeShare. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MTDatabaseHelper : NSObject

+(MTDatabaseHelper*) sharedInstance;

//更换账号后需要调用此函数切换相应数据库，需要确保mtuser的userid已经获得
+(void) refreshDatabaseFile;

////直接执行sql
//- (void)execSql:(NSString*)sql completion:(void(^)(BOOL result))block;

//创建数据库的表（改成将字段和属性放在数组indexes里）
- (void)createTableWithTableName:(NSString*)tableName indexesWithProperties:(NSArray*)indexes;

//插入方法。columns和values两个数组的元素都是(NSString*)。插入元组主键相同，会直接覆盖表中原有的元组
//举例：
//1. 如果插入表中的数据是数字，则在array中插入object形如: @"3"，@"3.5"
//2. 如果插入表中的数据是字符串，则在array中插入object形如（注意加单引号）： @"'2011-1-12'", @"'John'"
- (void)insertToTable:(NSString*)tableName withColumns:(NSArray*)columns andValues:(NSArray*)values;

//更新方法。wheres是WHERE语句的键值对，sets是SET语句的键值对
//关于NSDictionary的键值对：
//1. 键（key）的类型是NSString
//2. 如果值是数字，则形如：@"3"，@"3.5"
//3. 如果值是字符串，则需加单引号，形如：@"'2011-1-12'", @"'John'"
//4. 键值对形如：name = 'Jhon', number = 1
//表名（tableName）可以不用加单引号,如：@"TESTTABLE"。加了也没问题
- (void)updateDataWithTableName:(NSString *)tableName andWhere:(NSDictionary*)wheres andSet:(NSDictionary*)sets;

//查询方法。selects是SELECT语句的字段名，wheres是WHERE语句的键值对
//说明：
//1. selects中的字段名都是(NSString*)，可以不用加单引号，如：@"user_id"
//2. wheres中键值对的键类型是（NSString*)，
//   值的类型如果是数字，则形如：@"3"，@"3.5"
//   值的类型如果是字符串，则要加单引号，形如：@"'2011-1-12'", @"'John'"
//3. 如果没有where语句，可以用nil。
//4. 如果要查询所有列，可以将select的数组设成{"*"};
//5. 如果表中字段的值为空（NULL），则查询的结果的值是[NSNull null];
- (void)queryTable:(NSString*)tableName withSelect:(NSArray*)selects andWhere:(NSDictionary*)wheres completion:(void(^)(NSMutableArray* resultsArray))block;

//删除方法。wheres是WHERE语句的键值对，对应的说明如上的“查询方法”
- (void)deleteTurpleFromTable:(NSString*)tableName withWhere:(NSDictionary*)wheres;

//增加表的列属性
//在已有的表中增加字段。tableName是表名，column是新增字段名，defaultValue是新增字段的默认值
//说明：
//1. column可以是单纯的字段名，如：@"name"，也可以是带有额外属性的字符串，如：@"item_id INTEGER"等。
//2. defaultValue为nil时，表中等字段默认值为空（NULL）
-(void)addsColumntoTable:(NSString*)tableName addsColumn:(NSString*)column withDefault:(id)defaultValue;




@end
