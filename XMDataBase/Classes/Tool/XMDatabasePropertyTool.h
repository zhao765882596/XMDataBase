//
//  XMDatabasePropertyTool.h
//  XMDataBase
//
//  Created by 赵小明 on 2018/8/15.
//

#import <Foundation/Foundation.h>
#define XMDB_TYPE_INTEGER     @"INTEGER"
#define XMDB_TYPE_REAL        @"REAL"
#define XMDB_TYPE_TEXT        @"TEXT"
#define XMDB_TYPE_BLOB        @"BLOB"
#define XMDB_TYPE_NULL        @"NULL"
#define XMDB_TYPE_NSValue     @"VALUE"
#define XMDB_TYPE_NSCODING    @"NSCODING"

@interface XMDatabasePropertyTool : NSObject

/**
 获取类所有属性名列表
 
 @param modelClass 类名
 @return 属性名列表
 */
+ (NSDictionary<NSString *, NSString *> *)allPropertysWithClass:(Class)modelClass;
/**
 获取累的属性列表
 
 @param modelClass 类名
 @return 属性名列表
 */
+ (NSDictionary<NSString *, NSString *> *)propertysWithClass:(Class)modelClass;
/**
 获取累的属性列表
 
 @param str 类型字符串
 @return 属性sql存储类型
 */
+ (NSString *)getPropertyTypeWithString:(NSString *)str;
@end
