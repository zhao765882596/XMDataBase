//
//  XMDatabaseTool.h
//  FMDB
//
//  Created by 赵小明 on 2018/8/7.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    XMDBManagerErrorNoFoundDataBase = 100000,
    XMDBManagerErrorNoFoundTable,
    XMDBManagerErrorCreateDataBaseFailed,
    XMDBManagerErrorCreateTableFailed,
    XMDBManagerErrorSqlExecuteFailed,
    XMDBManagerErrorNoData,
    XMDBManagerErrorClaseeNull,
    XMDBManagerErrorNoSelectData,
    XMDBManagerErrorOther,
} XMDBManagerErrorType;


@interface XMDatabaseTool : NSObject
+ (NSString *)antiCollisionJointStr:(NSString *)property;
+ (NSString *)antiCollisionOmitStr:(NSString *)property;
+ (BOOL)isNoNull:(id)model;
+ (BOOL)isNoNullStr:(NSString *)str;
+ (BOOL)isNoNullData:(NSData *)data;
+ (BOOL)isNoNullArr:(NSArray *)arr;
+ (NSString *)getdbNameWithClass:(Class)aClass;
+ (NSString *)getdbPathWithClass:(Class)aClass;
+ (NSString *)primaryKeyWithClass:(Class)aClass;
+ (NSArray<NSString *> *)ignorePropertysWithClass:(Class)aClass;

+ (NSString *)tableNameWithClass:(Class)aClass;
/**
 根据错误类型返回NSError对象
 
 @param type 错误类型
 @return NSError对象
 */
+ (NSError *)errorWithErrorType:(XMDBManagerErrorType)type;
/**
 
 */
+ (NSError *)otherErrorWithDomain:(NSString *)domain;

@end
