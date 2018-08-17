//
//  XMDataBaseManagerProtocol.h
//  XMDataBase
//
//  Created by 赵小明 on 2018/8/7.
//

#import <Foundation/Foundation.h>

@protocol XMDatabaseManagerProtocol <NSObject>
@optional

/**
 //数据库文件夹路径
 //全路径  path + dnName + .db
 @return path
 */
+ (NSString * _Nullable)path;

/**
 //数据库名称
 //默认 类名 若path dbName 都为空  为defaultDB
 @return dbName
 */
+ (NSString * _Nullable)dbName;
+ (NSString * _Nullable)primaryKey;//关键字 默认 id integer
+ (NSString * _Nullable)tableName;//表名//默认 (类名)_table
+ (NSArray<NSString *> *_Nullable)ignorePropertys;//忽略属性 默认无
+ (NSUInteger)maxStorageCapacity;//最大存储量 默认 NSUIntegerMax  不能小于100 否则无效

@end
