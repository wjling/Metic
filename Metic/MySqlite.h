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

- (BOOL)openMyDB:(NSString*)DBname;
- (BOOL)execSql:(NSString*)sql;
- (BOOL)createTableWithTableName:(NSString*)tableName andIndexWithProperties:(NSString*)index_properties,...;
- (BOOL)insertToTable:(NSString*)tableName withColumns:(NSArray*)columns andItsValues:(NSArray*)values;
@end
