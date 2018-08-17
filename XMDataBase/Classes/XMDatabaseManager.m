//
//  XMDatabaseManager.h
//  XMDatabaseManager
//
//  Created by 赵小明 on 2018/6/19.
//  Copyright © 2018年 ming-58. All rights reserved.
//

#import "XMDatabaseManager.h"
#import <FMDB/FMDB.h>
#import <objc/runtime.h>
#import "XMDBTransformProtocol.h"
#import "XMDatabaseManagerProtocol.h"
#import "XMDBTransformTool.h"
#import "XMDatabasePropertyTool.h"
#import "XMDatabaseTool.h"


NSString * const DBFOLDER = @"xm_dbFolder";

@interface XMDataBaseManager ()
@property (nonatomic, strong) NSMutableDictionary<NSString * , FMDatabase *> *dataBases;
@property (nonatomic, strong) NSMutableDictionary<NSString * , NSDictionary<NSString * , NSString *> *> *classPropertys;

@property (nonatomic, strong) dispatch_queue_t queue;

@end

@implementation XMDataBaseManager
#pragma mark -
+ (XMDataBaseManager *)ShareDBManager
{
    static dispatch_once_t onceToken;
    static XMDataBaseManager *databaseManager = nil;
    dispatch_once(&onceToken, ^{
        if (databaseManager == nil) {
            databaseManager = [[XMDataBaseManager alloc] init];
            databaseManager.dataBases = [[NSMutableDictionary alloc] init];
            databaseManager.classPropertys = [[NSMutableDictionary alloc] init];
            NSString * path = [databaseManager.dbFolderPath stringByAppendingPathComponent:@"default.db"];
            databaseManager.dataBases[@"default"] = [[FMDatabase alloc] initWithPath: path];
            [[NSNotificationCenter defaultCenter] addObserver:databaseManager selector:@selector(clearCache) name:UIApplicationDidEnterBackgroundNotification object:nil];
        }
    });
    return databaseManager;
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
}
- (void)clearCache {
    [self.dataBases removeAllObjects ];
    [self.classPropertys removeAllObjects ];
}

#pragma mark - 公开类方法
//增
+ (void)storeModel:(nonnull id<NSObject>)model completed:(void(^)(NSError* _Nullable error))completed {
    dispatch_async([XMDataBaseManager ShareDBManager].queue, ^{
        [[XMDataBaseManager ShareDBManager] addModel:model completed:completed];
    });
}
+ (void)storeModels:(NSArray *)modelArr completed:(void(^)(NSArray<NSError *> *errors,BOOL isAllSuccess))completed {
    if ([XMDatabaseTool isNoNullArr:modelArr]) {
        dispatch_async([XMDataBaseManager ShareDBManager].queue, ^{
            [[XMDataBaseManager ShareDBManager] addModels:modelArr completed:completed];
        });
    }
}


//删
+ (void)deleteModel:(nonnull id<NSObject>)model completed:(void(^)(NSError* _Nullable error))completed {
    dispatch_async([XMDataBaseManager ShareDBManager].queue, ^{
        [[XMDataBaseManager ShareDBManager] deleteModel:model completed:completed];
    });
}

+ (void)deleteWithClass:(Class)modelClass whereTool:(XMWhereTool *)whereTool completed: (void(^)(NSError* _Nullable error))completed;{
    dispatch_async([XMDataBaseManager ShareDBManager].queue, ^{
        [[XMDataBaseManager ShareDBManager] deleteWithClass:modelClass whereTool:whereTool completed:completed];
    });
}


//改
+ (void)updateModel:(nonnull id<NSObject>)model completed:(void(^)(NSError* _Nullable error))completed {
    dispatch_async([XMDataBaseManager ShareDBManager].queue, ^{
        [[XMDataBaseManager ShareDBManager] addModel:model completed:completed];
    });
}

+ (void)updateModels:(NSArray *)models completed:(void(^)(NSArray<NSError *> *errors,BOOL isAllSuccess))completed {
    [self storeModels:models completed:completed];
}


//查
+ (void)selectWithClass:(Class)modelClass whereTool:(XMWhereTool *)whereTool completed: (void(^)(NSArray * _Nullable selectModels,NSError* _Nullable error))completed;{
    dispatch_async([XMDataBaseManager ShareDBManager].queue, ^{
        [[XMDataBaseManager ShareDBManager] selectWithClass:modelClass whereTool:whereTool completed:completed];
    });
}

+ (void)queryStoreCountWithClass:(Class)modelClass Completed: (void(^)(NSError *, NSUInteger))completed {
    dispatch_async([XMDataBaseManager ShareDBManager].queue, ^{
        [[XMDataBaseManager ShareDBManager] queryStoreCountWithClass:modelClass Completed:completed];
    });
}


//表操作
+ (void)deleteColumnWithClass:(Class)modelClass columnName:(NSString *)columnName completed: (void(^)(NSError* _Nullable error))completed {
    dispatch_async([XMDataBaseManager ShareDBManager].queue, ^{
        [[XMDataBaseManager ShareDBManager] deleteColumnWithClass:modelClass columnName:columnName completed:completed];
    });
}

+ (void)dropTableWithClass:(Class)modelClass completed: (void(^)(NSError* _Nullable error))completed {
    dispatch_async([XMDataBaseManager ShareDBManager].queue, ^{
        [[XMDataBaseManager ShareDBManager] dropTableWithClass:modelClass completed:completed];
    });
}


//数据库操作
+ (void)deleteDBWithClass:(Class)modelClass completed: (void(^)(NSError* _Nullable error))completed {
    dispatch_async([XMDataBaseManager ShareDBManager].queue, ^{
        [[XMDataBaseManager ShareDBManager] deleteDBWithClass:modelClass completed:completed];
    });
}
+ (void)deleteDefaultDBWithCompleted: (void(^)(NSError* _Nullable error))completed {
    dispatch_async([XMDataBaseManager ShareDBManager].queue, ^{
        [[XMDataBaseManager ShareDBManager].dataBases removeObjectForKey:@"default"];
        NSString *path = [[XMDataBaseManager ShareDBManager].dbFolderPath stringByAppendingPathComponent:@"default.db"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            if ([[NSFileManager defaultManager] removeItemAtPath:path error:nil]) {
                if (completed) {
                    completed(nil);
                } else {
                    completed([XMDatabaseTool otherErrorWithDomain:@"未找到数据库文件"]);
                }
            }
        } else {
            completed([XMDatabaseTool errorWithErrorType:XMDBManagerErrorNoFoundDataBase]);
        }
    });
}


#pragma mark - 数据库操作方法
//增
- (void)addModel:(nonnull id<NSObject>)model completed: (void(^)(NSError* error))completed {
    if (model == nil) {
        if (completed) completed([XMDatabaseTool errorWithErrorType:XMDBManagerErrorNoData]);
        return;
    }

    FMDatabase *db = [self createDatabaseWithClass:model.class];
    NSString *tableName = [XMDatabaseTool tableNameWithClass:model.class];
    NSError * error = [self createTableWithDatabase:db tableName:tableName model:model.class ignoreProperty:nil];
    if (error) {
        if (completed) completed(error);
        return;
    }

    error = [self insertModelWithDatabase:db model:model tableName:tableName];
    [self deleteOldDataWithDatabase:db class:model.class inTable:tableName];
    if (completed) completed(error);
}

- (void)addModels:(nonnull NSArray*)models completed: (void(^)(NSArray<NSError *> *errors,BOOL isAllSuccess))completed {
    if (![XMDatabaseTool isNoNullArr:models]) {
        if (completed) completed(@[[XMDatabaseTool errorWithErrorType:XMDBManagerErrorNoData]], NO);
    }
    NSMutableArray *errors = [NSMutableArray array];
    for (int i = 0; i < models.count; i ++) {
        [self addModel:models[i] completed:^(NSError *error) {
            if (error && completed ) {
                [errors addObject:[NSError errorWithDomain:error.domain code:error.code userInfo:@{@"index":@(i)}]];
            }
            if (i == models.count - 1 && completed) {
                completed(errors.copy,errors.count == 0);
            }
        }];
    }
}


//删
- (void)deleteWithClass:(Class)modelClass whereTool:(XMWhereTool *)whereTool completed: (void(^)(NSError* _Nullable error))completed {
    if (modelClass == nil) {
        if (completed) completed([XMDatabaseTool errorWithErrorType:XMDBManagerErrorClaseeNull]);
        return;
    }

    FMDatabase *db = [self databaseWithClass:modelClass];
    if (!db) {
        if (completed) completed([XMDatabaseTool errorWithErrorType:XMDBManagerErrorNoFoundDataBase]);
        return;
    }
    NSString *tableName = [XMDatabaseTool tableNameWithClass:modelClass];
    NSString *whereSqlStr = whereTool.sqlStr;
    NSArray *sqlValues = whereTool.sqlValues;
    NSError *error = nil;
    if ([XMDatabaseTool isNoNullStr:whereSqlStr]) {
        if ([XMDatabaseTool isNoNullArr:sqlValues]) {
            error = [self executeUpdate:db inTable:tableName sqlStr:[NSString stringWithFormat:@"DELETE FROM %@ %@", tableName, whereSqlStr] values:sqlValues];
        } else {
            error =  [self executeUpdate:db inTable:tableName sqlStr:[NSString stringWithFormat:@"DELETE FROM %@ %@", tableName, whereSqlStr]];
        }
        
    } else {
       error =  [self executeUpdate:db inTable:tableName sqlStr:[NSString stringWithFormat:@"DELETE FROM %@", tableName]];
    }

    if (completed) {
        completed(error);
    }
}

- (void)deleteModel:(nonnull NSObject *)model completed:(void(^)(NSError* _Nullable error))completed {
    if (![XMDatabaseTool isNoNull:model]) {
        if (completed) completed([XMDatabaseTool errorWithErrorType:XMDBManagerErrorNoData]);
        return;
    }

    FMDatabase *db = [self databaseWithClass:model.class];
    if (!db) {
        if (completed) completed([XMDatabaseTool errorWithErrorType:XMDBManagerErrorNoFoundDataBase]);
        return;
    }
    NSString *tableName = [XMDatabaseTool tableNameWithClass:model.class];
    NSString *primaryKey = [XMDatabaseTool primaryKeyWithClass:model.class];
    if (primaryKey)  {
        NSString * sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = '%@'", tableName, [XMDatabaseTool antiCollisionJointStr:primaryKey], [model valueForKey:primaryKey]];
        NSError * error = [self executeUpdate:db inTable:tableName sqlStr: sql];
        if (completed) {
            completed(error);
        }

    } else {
        NSMutableString *deleteSQLString = [NSMutableString stringWithFormat:@"DELETE FROM %@ WHERE", tableName];
        NSDictionary<NSString *, NSString *> *propertys = [self allPropertysWithClass:[model class]];
        NSMutableArray *values = [NSMutableArray arrayWithCapacity:propertys.count];
        for (int i = 0; i < propertys.allKeys.count; i ++) {
            NSString *keyString = @" AND ";
            if (i == 0) {
                keyString = @"";
            }
            [deleteSQLString appendFormat:@"%@%@ = ?", keyString, propertys.allKeys[i]];

            id value = [model valueForKey:[XMDatabaseTool antiCollisionOmitStr:propertys.allKeys[i]]];
            NSString *type = propertys[propertys.allKeys[i]];
            [values addObject:[XMDBTransformTool transformObjectWithCGType:type value:value]];
        }
        NSError * error = [self executeUpdate:db inTable:tableName sqlStr:deleteSQLString.copy values:values.copy];
        if (completed) completed(error);
    }
}
//删除列
- (void)deleteColumnWithClass:(Class)modelClass columnName:(NSString *)columnName completed: (void(^)(NSError* _Nullable error))completed {
    if (modelClass == nil) {
        if (completed) completed([XMDatabaseTool errorWithErrorType:XMDBManagerErrorClaseeNull]);
        return;
    }
    if (columnName == nil) {
        if (completed) completed([XMDatabaseTool errorWithErrorType:XMDBManagerErrorNoData]);
        return;
    }
    NSString *primaryKey = [XMDatabaseTool primaryKeyWithClass:modelClass];
    primaryKey = primaryKey ? primaryKey : @"id";
    if ([columnName isEqualToString:primaryKey]) {
        if (completed) completed([XMDatabaseTool otherErrorWithDomain:@"不可用删除关键列"]);
        return;
    }

    FMDatabase *db = [self databaseWithClass:modelClass];
    if (!db) {
        if (completed) completed([XMDatabaseTool errorWithErrorType:XMDBManagerErrorNoFoundDataBase]);
        return;
    }
    NSString *tableName = [XMDatabaseTool tableNameWithClass:modelClass];
    NSString *tmpTableName = [tableName stringByAppendingString:@"_tmp"];
    NSError * error = [self createTableWithDatabase:db tableName:tmpTableName model:modelClass ignoreProperty:columnName];
    if (error) {
        if (completed) completed([XMDatabaseTool errorWithErrorType:XMDBManagerErrorNoFoundDataBase]);
        return;
    }
    NSArray * models = [self searchWithDatabase:db model:modelClass inTable:tableName sqlStr:[NSString stringWithFormat:@"SELECT * FROM %@", tableName] values:nil];
    error = [self executeUpdate:db inTable:tableName sqlStr:[NSString stringWithFormat:@"DROP TABLE %@", tableName]];
    if (error) {
        if (completed) completed(error);
    }
    error = [self executeUpdate:db inTable:tmpTableName sqlStr:[NSString stringWithFormat:@"ALTER TABLE %@ RENAME TO %@", tmpTableName, tableName]];
    if (error) {
        if (completed) completed(error);
    }

    if ([XMDatabaseTool isNoNullArr:models]) {
        for (id model in models) {
            if ([model valueForKey:columnName]) {
                [model setValue:nil forKey:columnName];
            }
        }
        self.classPropertys[NSStringFromClass(modelClass)] = nil;
        [XMDataBaseManager storeModels:models completed:nil];
    }
}
//查
- (void)selectWithClass:(Class)modelClass whereTool:(XMWhereTool *)whereTool completed: (void(^)(NSArray * _Nullable selectModels,NSError* _Nullable error))completed {
    if (modelClass == nil) {
        if (completed) completed(nil, [XMDatabaseTool errorWithErrorType:XMDBManagerErrorClaseeNull]);
        return;
    }

    FMDatabase *db = [self databaseWithClass:modelClass];
    if (!db) {
        if (completed) completed(nil, [XMDatabaseTool errorWithErrorType:XMDBManagerErrorNoFoundDataBase]);
        return;
    }
    NSString *tableName = [XMDatabaseTool tableNameWithClass:modelClass];
    NSString *whereSqlStr = [whereTool sqlStr];
    NSArray *sqlValues = whereTool.sqlValues;
    id returnId = nil;
    if ([XMDatabaseTool isNoNullStr:whereSqlStr]) {
        returnId = [self searchWithDatabase:db model:modelClass inTable:tableName sqlStr:[NSString stringWithFormat:@"SELECT * FROM %@ %@", tableName, whereSqlStr] values:sqlValues];
    } else {
        returnId = [self searchWithDatabase:db model:modelClass inTable:tableName sqlStr:[NSString stringWithFormat:@"SELECT * FROM %@", tableName] values:nil];
    }
    if (completed) {
        if ([returnId isKindOfClass:NSArray.class]) {
            completed((NSArray *)returnId, ((NSArray *)returnId).count > 0 ? nil : [XMDatabaseTool errorWithErrorType:XMDBManagerErrorNoSelectData]);
        } else {
            completed( nil, (NSError *)returnId);
        }
    }
}

/**
 查询表存储数量
 */
- (void)queryStoreCountWithClass:(Class)modelClass Completed: (void(^)(NSError *, NSUInteger))completed  {
    if (modelClass == nil) {
        if (completed) completed([XMDatabaseTool errorWithErrorType:XMDBManagerErrorClaseeNull], 0);
        return;
    }
    
    FMDatabase *db = [self databaseWithClass:modelClass];
    NSString *tableName = [XMDatabaseTool tableNameWithClass:modelClass];
    NSError * error = nil;
    NSUInteger count = 0;
    if (db) {
        [db open];
        if ([db tableExists:tableName]) {
            NSString * primaryKey = [XMDatabaseTool antiCollisionJointStr:[XMDatabaseTool primaryKeyWithClass:modelClass]];
            if (!primaryKey || primaryKey.length == 0) {
                primaryKey = @"id";
            }
            count = [db intForQuery:[NSString stringWithFormat:@"SELECT COUNT(%@) FROM %@ ;", primaryKey, tableName]];
            
        } else {
            error = [XMDatabaseTool errorWithErrorType:XMDBManagerErrorNoFoundTable];
        }
        [db close];
    } else {
        error = [XMDatabaseTool errorWithErrorType:XMDBManagerErrorNoFoundDataBase];
    }
    if (completed) completed(error, count);
    
}


/**
 删除表
 
 @param modelClass 删除的类对象
 @param completed 删除执行完成回调 (error 为空 即删除成功)
 */
- (void)dropTableWithClass:(Class)modelClass completed: (void(^)(NSError* _Nullable error))completed {
    if (modelClass == nil) {
        if (completed) completed([XMDatabaseTool errorWithErrorType:XMDBManagerErrorClaseeNull]);
        return;
    }
    FMDatabase *db = [self databaseWithClass:modelClass];
    NSString *tableName = [XMDatabaseTool tableNameWithClass:modelClass];
    NSError *error = [self executeUpdate:db inTable:tableName sqlStr:[NSString stringWithFormat:@"DROP TABLE %@", tableName]];
    if (completed) {
        completed(error);
    }
}

/**
 删除数据库
 @param modelClass 删除的类对象
 @param completed 删除执行完成回调 (error 为空 即删除成功)
 */
- (void)deleteDBWithClass:(Class)modelClass completed: (void(^)(NSError* _Nullable error))completed {
    if (modelClass == nil) {
        if (completed) completed([XMDatabaseTool errorWithErrorType:XMDBManagerErrorClaseeNull]);

        return;
    }
    NSString * dbName = [XMDatabaseTool getdbNameWithClass:modelClass];
    NSString * path = [XMDatabaseTool getdbPathWithClass:modelClass];
    if (completed && path == nil && dbName == nil) {
        completed([XMDatabaseTool otherErrorWithDomain:@"未找到数据库"]);
        return;
    }
    if (!dbName) {
        dbName = [[NSStringFromClass(modelClass) componentsSeparatedByString:@"."] lastObject];
    }
    FMDatabase * db = self.dataBases[dbName];
    if (!path) {
        if (!dbName) {
            dbName = [[NSStringFromClass(modelClass) componentsSeparatedByString:@"."] lastObject] ;
        }
        path = [self.dbFolderPath stringByAppendingPathComponent:[dbName stringByAppendingString:@".db"]];
    }
    db = [[FMDatabase alloc] initWithPath:path];
    NSString *tableName = [XMDatabaseTool tableNameWithClass:modelClass];
    [self executeUpdate:db inTable:tableName sqlStr:[NSString stringWithFormat:@"DROP TABLE %@", tableName]];
    if (db) {
        [db open];
        int count = [db intForQuery:@"select count(1) from sqlite_master where type = 'table';"];
        [db close];
        if (count > 0) {
            if (completed) completed([XMDatabaseTool otherErrorWithDomain:@"当前数据库还有其他表,无法删除"]);
        } else {
            db = nil;
            self.dataBases[dbName] = nil;
            if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
                [self.dataBases removeObjectForKey:dbName];
                [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
            } else {
                if (completed) completed([XMDatabaseTool errorWithErrorType:XMDBManagerErrorNoFoundDataBase]);
            }
        }
    }
}




#pragma mark - 数据库操作
/**
 创建数据表

 @param db 数据库对象
 @param tableName 表名
 @param modelClass 类名
 @return 返回错误对象  成功 nil
 */
- (NSError *)createTableWithDatabase:(FMDatabase * _Nonnull)db tableName:(NSString * _Nonnull)tableName model:(Class _Nonnull)modelClass ignoreProperty:(NSString *)ignoreProperty {
    [self allPropertysWithClass:modelClass];
    if (db) {
        [db open];
        if ([db tableExists:tableName]) {
            [db close];
            return nil;
        } else {
            NSString *SQLString = [self createTableSQLString:modelClass tableName:tableName primaryKey:[XMDatabaseTool primaryKeyWithClass:modelClass] ignoreProperty:ignoreProperty];
            if ([db executeUpdate:SQLString]) {
                [db close];
                return nil;
            } else {
                return [XMDatabaseTool errorWithErrorType:XMDBManagerErrorSqlExecuteFailed];
            }
        }
    } else {
        return [XMDatabaseTool errorWithErrorType:XMDBManagerErrorNoFoundDataBase];
    }
}

/**
 查询

 @param db 数据库对象
 @param modelClass 类名
 @param tableName 表名
 @param sqlStr sql字符串
 @return 查到的对象数组
 */
- (id)searchWithDatabase:(FMDatabase *_Nonnull)db model:(Class _Nonnull)modelClass inTable:(NSString *_Nonnull)tableName sqlStr:(NSString *_Nonnull)sqlStr values:(NSArray *)values
{
    NSDictionary<NSString *, NSString *> *propertys = [self allPropertysWithClass:modelClass];
    if (db) {
        [db open];
        if ([db tableExists:tableName]) {
            FMResultSet *FMResult = nil;
            if ([XMDatabaseTool isNoNullArr:values]) {
                FMResult = [db executeQuery:sqlStr withArgumentsInArray:values];
            } else {
                FMResult = [db executeQuery:sqlStr];
            }
            if (FMResult) {
                NSMutableArray *resultModelArr = [NSMutableArray array];
                while ([FMResult next]) {
                    id reslutModel = [[modelClass class] new];
                    
                    for (int i = 0; i < propertys.allKeys.count; i ++) {
                        id value = [FMResult objectForColumn:propertys.allKeys[i]];
                        NSString *type = propertys[propertys.allKeys[i]];
                        id dbValue = [XMDBTransformTool initObjectWithCGType:type value:value];
                        if (dbValue) {
                            [reslutModel setValue:dbValue forKey:[XMDatabaseTool antiCollisionOmitStr:propertys.allKeys[i]]];
                        }

                    }
                    [resultModelArr addObject:reslutModel];
                }
                return resultModelArr.copy;
            }
            [db close];
            return [XMDatabaseTool errorWithErrorType:XMDBManagerErrorSqlExecuteFailed];
        } else {
            [db close];
            return [XMDatabaseTool errorWithErrorType:XMDBManagerErrorNoFoundTable];
        }
    }
    return [XMDatabaseTool errorWithErrorType:XMDBManagerErrorNoFoundDataBase];
}
/**
 删除老数据
 */
- (void)deleteOldDataWithDatabase:(FMDatabase *)db class:(Class)modelClass inTable:(NSString *)tableName {
    if (nil != modelClass && [modelClass respondsToSelector:@selector(maxStorageCapacity)] && [modelClass maxStorageCapacity] >= 100) {
        NSUInteger maxStorageCapacity = [modelClass maxStorageCapacity];
        if(db) {
            [db open];
            if ([db tableExists:tableName]) {
                NSString * primaryKey = [XMDatabaseTool antiCollisionJointStr:[XMDatabaseTool primaryKeyWithClass:modelClass]];
                if (!primaryKey || primaryKey.length == 0) {
                    primaryKey = @"id";
                }
                int count = [db intForQuery:[NSString stringWithFormat:@"SELECT COUNT(%@) FROM %@ ;", primaryKey, tableName]];
                if (count >= maxStorageCapacity) {
                    BOOL flag = [db executeUpdate: [NSString stringWithFormat:@"DELETE FROM %@  LIMIT %d", tableName, (int)(maxStorageCapacity * 0.25)]];
                    NSLog(@"%@",@(flag));
                }
            }
            [db close];
        }
    }
}

/**
 检查字段 属性列表里有数据表里没有的列  增加列

 @param modelClass 类名
 @param propertys 存储属性列表
 */
- (void)checkTableWithClass:(Class)modelClass propertys:(NSDictionary<NSString *, NSString *> *)propertys {
    FMDatabase *db = [self databaseWithClass:modelClass];
    NSString *tableName = [XMDatabaseTool tableNameWithClass:modelClass];
    if (db) {
        [db open];
        if ([db tableExists:tableName]) {
  
            FMResultSet *result = [db executeQuery:[NSString stringWithFormat:@"PRAGMA TABLE_INFO (\"%@\");",tableName]];
            NSMutableDictionary<NSString *, NSString *> *tablePropertys = [NSMutableDictionary dictionary];
            while ([result next]) {
                NSString *name = [result stringForColumn:@"name"];
                NSString *type = [result stringForColumn:@"type"];
                
                tablePropertys[name] = type;
            }
            NSMutableDictionary<NSString *, NSString *> * remainPropertys = propertys.mutableCopy;
            for (NSString *propertyName in tablePropertys.allKeys) {
                if ([remainPropertys.allKeys containsObject:propertyName]) {
                    [remainPropertys removeObjectForKey:propertyName];
                }
            }
            for (NSString *propertyName in remainPropertys.allKeys) {
                [self executeUpdate:db inTable:tableName sqlStr:[NSString stringWithFormat:@"ALTER TABLE %@ ADD COLUMN %@ %@;", tableName, propertyName, remainPropertys[propertyName]]];
            }
        }
        [db close];
    }
}
/**
 插入数据
 */
- (NSError *)insertModelWithDatabase:(FMDatabase *_Nonnull)db model:(id)model tableName:(NSString *)tableName
{
    NSDictionary<NSString *, NSString *> * propertyseys = [self allPropertysWithClass:[model class]];
    NSMutableString *sqliteString = [[NSMutableString alloc] initWithFormat:@"INSERT OR REPLACE INTO %@ (", tableName];
    NSMutableString *valuesStr = [[NSMutableString alloc] initWithCapacity:propertyseys.count];
    NSMutableArray *values = [NSMutableArray arrayWithCapacity:propertyseys.count];
    
    for (int i = 0; i < propertyseys.allKeys.count; i ++) {
        if (i == 0) {
            [sqliteString appendString:propertyseys.allKeys[i]];
            [valuesStr appendFormat:@"?"];
        } else {
            [sqliteString appendFormat:@", %@", propertyseys.allKeys[i]];
            [valuesStr appendString:@", ?"];
        }
        id value = [model valueForKey:[XMDatabaseTool antiCollisionOmitStr:propertyseys.allKeys[i]]];
        NSString *type = propertyseys[propertyseys.allKeys[i]];
        [values addObject:[XMDBTransformTool transformObjectWithCGType:type value:value]];
    }
    [sqliteString appendFormat:@") VALUES (%@)",valuesStr];
    return [self executeUpdate:db inTable:tableName sqlStr:sqliteString.copy values:values];
}


#pragma mark - 数据执行方法
/**
 执行更新sql
 
 @param db 数据库对象
 @param tableName 表名
 @param sql sql字符串
 @return 错误信息 执行正常返回 nil
 */
- (NSError *)executeUpdate:(FMDatabase *)db inTable:(NSString *)tableName sqlStr:(NSString *)sql {
    
    if (db) {
        [db open];
        if ([db tableExists:tableName]) {
            BOOL success = [db executeUpdate:sql];
            [db close];
            return success ? nil : [XMDatabaseTool errorWithErrorType:XMDBManagerErrorSqlExecuteFailed];
        } else {
            [db close];
            return [XMDatabaseTool errorWithErrorType:XMDBManagerErrorNoFoundTable];
        }
    }
    return [XMDatabaseTool errorWithErrorType:XMDBManagerErrorNoFoundDataBase];
}

- (NSError *)executeUpdate:(FMDatabase *)db inTable:(NSString *)tableName sqlStr:(NSString *)sql values:(NSArray *)values {
    
    if (db) {
        [db open];
        if ([db tableExists:tableName]) {
            BOOL success = [db executeUpdate:sql withArgumentsInArray:values];
            [db close];
            return success ? nil : [XMDatabaseTool errorWithErrorType:XMDBManagerErrorSqlExecuteFailed];
        } else {
            [db close];
            return [XMDatabaseTool errorWithErrorType:XMDBManagerErrorNoFoundTable];
        }
    }
    return [XMDatabaseTool errorWithErrorType:XMDBManagerErrorNoFoundDataBase];
}

#pragma mark - 组合SQL语句

/**
 创建表sql

 @param modelClass 类名
 @param tableName 表名
 @param primaryKey 住key名
 @return sql字符串
 */
- (NSString *)createTableSQLString:(Class)modelClass tableName:(NSString *)tableName primaryKey:(NSString *)primaryKey ignoreProperty:(NSString *)ignoreProperty {
    NSString *sqliteString = @"";
    NSString * primaryKeyType = nil;
    NSDictionary<NSString *, NSString *> *propertys = [self allPropertysWithClass:modelClass];
    for (NSString * propertyName in propertys.allKeys) {
        if ([propertyName isEqualToString:[XMDatabaseTool antiCollisionJointStr:primaryKey]] ) {
             primaryKeyType = propertys[[XMDatabaseTool antiCollisionJointStr:primaryKey]];
        } else if  ([propertyName isEqualToString:[XMDatabaseTool antiCollisionJointStr:ignoreProperty]]) {
        } else {
            sqliteString = [sqliteString stringByAppendingString:[NSString stringWithFormat:@", %@ %@", propertyName, [XMDatabasePropertyTool getPropertyTypeWithString:propertys[propertyName]]]];
        }
    }
   
    sqliteString = [sqliteString stringByAppendingString:@")"];
    NSString *sql = nil;
    if (primaryKey == nil || [primaryKey  isEqual: @""]) {
        sql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (sy_id INTEGER PRIMARY KEY AUTOINCREMENT", tableName];
    } else {
        sql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (%@ %@ PRIMARY KEY", tableName, [XMDatabaseTool antiCollisionJointStr:primaryKey], primaryKeyType ? primaryKeyType : @"TEXT"];
    }
    
    return [sql stringByAppendingString:sqliteString];
}

#pragma mark 获取属性列表
/**
 获取类所有属性名列表
 
 @param modelClass 类名
 @return 属性名列表
 */
- (NSDictionary<NSString *, NSString *> *)allPropertysWithClass:(Class)modelClass {
    NSString *className = NSStringFromClass(modelClass);
    if (!self.classPropertys[className]) {
        NSDictionary<NSString *, NSString *> *propertys = [XMDatabasePropertyTool allPropertysWithClass:modelClass];
        [self checkTableWithClass:modelClass propertys:propertys];
        self.classPropertys[className] = propertys;
    }
    return self.classPropertys[className];
}




#pragma mark - 数据库对象获取
/**
 创建数据库对象
 
 @param class 类名
 @return 数据库对象
 */
- (FMDatabase *)createDatabaseWithClass:(Class)class {
    if (class == nil) {
        return nil;
    }
    NSString * dbName = [XMDatabaseTool getdbNameWithClass:class];
    NSString * path = [XMDatabaseTool getdbPathWithClass:class];
    if (path == nil && dbName == nil) {
        return self.defaultDataBase;
    }
    if (dbName) {
        if (self.dataBases[dbName]) {
            return self.dataBases[dbName];
        }
        if (path) {
            FMDatabase *db = [[FMDatabase alloc] initWithPath: path];
            self.dataBases[dbName] = db;
            return db;
        } else {
            path = [self.dbFolderPath stringByAppendingPathComponent:[dbName stringByAppendingString:@".db"]];
            FMDatabase *db = [[FMDatabase alloc] initWithPath: path];
            self.dataBases[dbName] = db;
            return db;
        }
    } else {
        dbName = [[NSStringFromClass(class) componentsSeparatedByString:@"."] lastObject];
        if (self.dataBases[dbName]) {
            return self.dataBases[dbName];
        }
        FMDatabase *db = [[FMDatabase alloc] initWithPath: path];
        self.dataBases[dbName] = db;
        return db;
    }
}

/**
 获取数据库对象
 
 @param class 类名
 @return 数据库
 */
- (FMDatabase *)databaseWithClass:(Class)class {
    if (class == nil) {
        return nil;
    }
    NSString * dbName = [XMDatabaseTool getdbNameWithClass:class];
    NSString * path = [XMDatabaseTool getdbPathWithClass:class];
    if (path == nil && dbName == nil) {
        return self.defaultDataBase;
    }
    if (!dbName) {
        dbName = [[NSStringFromClass(class) componentsSeparatedByString:@"."] lastObject];
    }
    if (self.dataBases[dbName]) {
        return self.dataBases[dbName];
    }
    if (!path) {
        path = [self.dbFolderPath stringByAppendingPathComponent:[dbName stringByAppendingString:@".db"]];
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        FMDatabase *db = [[FMDatabase alloc] initWithPath: path];
        self.dataBases[dbName] = db;
        return db;
    }
    return nil;
}
#pragma mark - 懒加载
/**
 获取数据库操作队列
 */
- (dispatch_queue_t)queue {
    if (!_queue) {
        _queue = dispatch_queue_create("com.daojia.suyun.dbqueue", DISPATCH_QUEUE_SERIAL);
    }
    return _queue;
}

/**
 获取默认数据库
 */
- (FMDatabase *)defaultDataBase {
    FMDatabase *db = self.dataBases[@"default"];
    if (!db) {
        NSString * path = [self.dbFolderPath stringByAppendingPathComponent:@"default.db"];
        db = [[FMDatabase alloc] initWithPath: path];
        self.dataBases[@"default"] = db;
    }
    return db;
}

/**
 获取数据库文件默认存储path
 
 @return 存储path
 */
- (NSString *)dbFolderPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    NSString * dbFolderPath = [documentsDirectory stringByAppendingPathComponent:DBFOLDER];
    if (![[NSFileManager defaultManager] fileExistsAtPath: dbFolderPath]) {
        BOOL success = [[NSFileManager defaultManager] createDirectoryAtPath:dbFolderPath withIntermediateDirectories:YES attributes:nil error:nil];
#if DEBUG
        NSAssert(success,@"创建目录失败");
#endif
        return dbFolderPath;
    }
    return dbFolderPath;
}
@end


