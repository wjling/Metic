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

//插入操作
- (void)insertToTable:(NSString*)tableName withColumns:(NSArray*)columns andValues:(NSArray*)values;

//更新操作
- (void)updateDataWithTableName:(NSString *)tableName andWhere:(NSDictionary*)wheres andSet:(NSDictionary*)sets;

//查询操作
- (void)queryTable:(NSString*)tableName withSelect:(NSArray*)selects andWhere:(NSDictionary*)wheres completion:(void(^)(NSMutableArray* resultsArray))block;

//删除操作
- (void)deleteTurpleFromTable:(NSString*)tableName withWhere:(NSDictionary*)wheres;

//增加表的列属性
-(void)addsColumntoTable:(NSString*)tableName addsColumn:(NSString*)column withDefault:(id)defaultValue;




@end
