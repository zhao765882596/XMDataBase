//
//  XMDatabaseTool.m
//  FMDB
//
//  Created by 赵小明 on 2018/8/7.
//

#import "XMDatabaseTool.h"
#import "XMDataBaseManagerProtocol.h"

@implementation XMDatabaseTool
+ (NSString *)antiCollisionJointStr:(NSString *)property {
    if (property == nil || ![property isKindOfClass:[NSString class]] || property.length < 1) {
        return @"";
    }
    return [@"xm_" stringByAppendingString:property];
}
+ (NSString *)antiCollisionOmitStr:(NSString *)property {
    if (property == nil || ![property isKindOfClass:[NSString class]] || property.length < 4) {
        return @"";
    }
    return [property substringFromIndex:3];
}
+ (BOOL)isNoNull:(id)model {
    if (model && ![model isKindOfClass:NSNull.class]) {
        return YES;
    }
    return NO;
}
+ (BOOL)isNoNullStr:(NSString *)str {
    if (str && [str isKindOfClass:NSString.class] && str.length > 0) {
        return YES;
    }
    return NO;
}
+ (BOOL)isNoNullData:(NSData *)data {
    if (data && [data isKindOfClass:NSData.class] && data.length > 0) {
        return YES;
    }
    return NO;
}

+ (BOOL)isNoNullArr:(NSArray *)arr {
    if (arr && [arr isKindOfClass:NSArray.class] && arr.count > 0) {
        return YES;
    }
    return NO;
}
+ (NSString *)getdbNameWithClass:(Class)aClass {
    if (!aClass) {
        return nil;
    }
    if ([aClass respondsToSelector: @selector(dbName)])  {
        NSString *dbName = [aClass dbName];
        if ([self isNoNullStr:dbName]) {
            return dbName;
        }
    }

    return nil;
}
+ (NSString *)getdbPathWithClass:(Class)aClass {
    if (!aClass) {
        return nil;
    }
    if ([aClass respondsToSelector: @selector(path)])  {
        NSString *path = [aClass path];
        if ([self isNoNullStr:path]) {
            return path;
        }
    }
    return nil;
}
/**
 获取关键字
 
 @param aClass 类名
 @return 关键字
 */
+ (NSString *)primaryKeyWithClass:(Class)aClass {
    if ( aClass == nil) {
        return nil;
    }
    NSString * primaryKey = nil;
    if ([aClass respondsToSelector: @selector(primaryKey)])  {
        primaryKey = [aClass primaryKey];
        if ([self isNoNullStr:primaryKey]) {
            return primaryKey;
        }
    }
    return nil;
}

/**
 获取忽略属性列表
 
 @param aClass 类名
 @return 当前类及父类所有忽略属性列表
 */
+ (NSArray<NSString *> *)ignorePropertysWithClass:(Class)aClass {
    if (!aClass) {
        return nil;
    }
    Class modelClass = aClass;
    NSMutableArray<NSString *> *ignorePropertys = [NSMutableArray array];
    while (modelClass != [NSObject class]) {
        if ([modelClass respondsToSelector: @selector(ignorePropertys)]) {
            NSArray<NSString *> * ignoreProperty = [aClass ignorePropertys];
            if ([self isNoNullArr:ignoreProperty]) {
                [ignorePropertys addObjectsFromArray:[modelClass ignorePropertys]];
            }
        }
        modelClass = [modelClass superclass];
    }
    return ignorePropertys.copy;
}
/**
 获取表名
 
 @param aClass 类名
 @return 表名
 */
+ (NSString *)tableNameWithClass:(Class)aClass {
    if ( aClass == nil) {
        return nil;
    }
    NSString *tableName = [[[NSStringFromClass(aClass) componentsSeparatedByString:@"."] lastObject] stringByAppendingString:@"_table"];
    if ([aClass respondsToSelector: @selector(tableName)] )  {
        NSString *tmpTableName = [aClass tableName];
        if ([self isNoNullStr:tmpTableName]) {
            tableName = tmpTableName;
        }
    }
    return tableName;
}

/**
 根据错误类型返回NSError对象
 
 @param type 错误类型
 @return NSError对象
 */
+ (NSError *)errorWithErrorType:(XMDBManagerErrorType)type {
    NSError *error = nil;
    switch (type) {
        case XMDBManagerErrorNoFoundDataBase:
            error = [NSError errorWithDomain:@"未找到数据库" code:type userInfo:nil];
            break;
        case XMDBManagerErrorNoFoundTable:
            error = [NSError errorWithDomain:@"未找到表" code:type userInfo:nil];
            break;
        case XMDBManagerErrorCreateDataBaseFailed:
            error = [NSError errorWithDomain:@"创建数据库失败" code:type userInfo:nil];
            break;
        case XMDBManagerErrorCreateTableFailed:
            error = [NSError errorWithDomain:@"创建表失败" code:type userInfo:nil];
            break;
        case XMDBManagerErrorSqlExecuteFailed:
            error = [NSError errorWithDomain:@"执行失败" code:type userInfo:nil];
            break;
        case XMDBManagerErrorNoData:
            error = [NSError errorWithDomain:@"没有数据" code:type userInfo:nil];
            break;
        case XMDBManagerErrorClaseeNull:
            error = [NSError errorWithDomain:@"Class不能为空" code:type userInfo:nil];
            break;
        case XMDBManagerErrorNoSelectData:
            error = [NSError errorWithDomain:@"没有查到数据" code:type userInfo:nil];
            break;
        case XMDBManagerErrorOther:
            error = [NSError errorWithDomain:@"其它错误" code:type userInfo:nil];
            break;
        default:
            error = [NSError errorWithDomain:@"其它错误" code:type userInfo:nil];
            break;
    }
    return error;
}
/**
 
 */
+ (NSError *)otherErrorWithDomain:(NSString *)domain {
    return [NSError errorWithDomain:domain code:100008 userInfo:nil];
}

@end












