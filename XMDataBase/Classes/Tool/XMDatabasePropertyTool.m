//
//  XMDatabasePropertyTool.m
//  XMDataBase
//
//  Created by 赵小明 on 2018/8/15.
//

#import "XMDatabasePropertyTool.h"
#import "XMDBTransformProtocol.h"
#import "XMDatabaseTool.h"
#import <objc/runtime.h>

@implementation XMDatabasePropertyTool
/**
 将objc类型转化为Sqllite对应的类型
 
 @param objcType 属性类型
 @return Sqllite对应的类型
 */
+ (NSString *)objcTypeToSqlType:(const char *)objcType{
    NSString *type = [NSString stringWithUTF8String:objcType];
    if ([type hasPrefix:@"@\""]) {
        type = [type stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        type = [type stringByReplacingOccurrencesOfString:@"@" withString:@""];
        if ([type  isEqual:@"NSString"] || [type isEqual:@"NSMutableString"]) {
            return XMDB_TYPE_TEXT;
        } else if ([type  isEqual:@"NSData"] || [type isEqual:@"NSMutableData"]) {
            return XMDB_TYPE_BLOB;
        } else if ([type isEqual:@"NSNumber"]) {
            return XMDB_TYPE_REAL;
        } else {
            Class  class = NSClassFromString(type);
            if ([class conformsToProtocol:@protocol(XMDBTransformStringProtocol)]) {
                return [XMDB_TYPE_TEXT stringByAppendingString:type];
            } else if ([class conformsToProtocol:@protocol(XMDBTransformDataProtocol)]) {
                return [XMDB_TYPE_BLOB stringByAppendingString:type];
            } else if ([class conformsToProtocol:@protocol(XMDBTransformIntegerProtocol)]) {
                return [XMDB_TYPE_INTEGER stringByAppendingString:type];
            } else if ([class conformsToProtocol:@protocol(XMDBTransformRealProtocol)]) {
                return [XMDB_TYPE_REAL stringByAppendingString:type];
            } else if ([class conformsToProtocol:@protocol(NSCoding)]) {
                return [XMDB_TYPE_BLOB stringByAppendingString:XMDB_TYPE_NSCODING];
            } else {
                return nil;
            }
        }
    } else if ([type containsString:@"CGRect"]) {
        return [XMDB_TYPE_NSValue stringByAppendingString:@"CGRect"];
    } else if ([type containsString:@"CGSize"]) {
        return [XMDB_TYPE_NSValue stringByAppendingString:@"CGSize"];
    } else if ([type containsString:@"CGPoint"]) {
        return [XMDB_TYPE_NSValue stringByAppendingString:@"CGPoint"];
    } else if ([type containsString:@"UIEdgeInsets"]) {
        return [XMDB_TYPE_NSValue stringByAppendingString:@"UIEdgeInsets"];
    } else if ([type containsString:@"CGVector"]) {
        return [XMDB_TYPE_NSValue stringByAppendingString:@"CGVector"];
    } else if ([type containsString:@"CGAffineTransform"]) {
        return [XMDB_TYPE_NSValue stringByAppendingString:@"CGAffineTransform"];
    } else if ([type containsString:@"UIOffset"]) {
        return [XMDB_TYPE_NSValue stringByAppendingString:@"UIOffset"];
    } else if ([type containsString:@"#"]) {
        return [XMDB_TYPE_TEXT stringByAppendingString:type];
    } else {
        char t = objcType[0];
        if (t == '^') {
            t = objcType[1];
        }
        
        switch (t) {
            case 'i':
            case 'I':
            case 'q':
            case 'Q':
            case 'D':
            case 's':
            case 'S':
            case 'l':
            case 'L':
            case 'c':
            case 'C':
                return XMDB_TYPE_INTEGER;
                break;
            case 'f':
            case 'd':
            case 'F':
                return XMDB_TYPE_REAL;
                break;
            default:
                return nil;
                break;
        }
    }
}



/**
 获取类所有属性名列表
 
 @param modelClass 类名
 @return 属性名列表
 */
+ (NSDictionary<NSString *, NSString *> *)allPropertysWithClass:(Class)modelClass {
    Class class = modelClass;
    NSMutableDictionary<NSString *, NSString *> *propertys = [NSMutableDictionary dictionary];
    while (class != [NSObject class]) {
        [propertys addEntriesFromDictionary:[self propertysWithClass:class]];
        class = [class superclass];
    }
    NSArray<NSString *> *ignorePropertys = [XMDatabaseTool ignorePropertysWithClass:modelClass];
    for ( NSString *propertyName in ignorePropertys) {
        if ([propertys.allKeys containsObject:[XMDatabaseTool antiCollisionJointStr:propertyName]]) {
            [propertys removeObjectForKey:[XMDatabaseTool antiCollisionJointStr:propertyName]];
        }
    }
    return propertys.copy;
}

/**
 获取累的属性列表
 
 @param modelClass 类名
 @return 属性名列表
 */
+ (NSDictionary<NSString *, NSString *> *)propertysWithClass:(Class)modelClass {
    unsigned int propertyCount = 0;
    objc_property_t *propertys = class_copyPropertyList(modelClass, &propertyCount);
    NSMutableDictionary<NSString *, NSString *> *allPropertys = [NSMutableDictionary dictionaryWithCapacity:propertyCount];
    for (int i = 0; i < propertyCount; i ++) {
        objc_property_t property = propertys[i];
        const char *propertyName = property_getName(property);
        char *type = property_copyAttributeValue(property,"T");
        NSString *OCString = [NSString stringWithUTF8String:propertyName];
        NSString *typeStr = [self objcTypeToSqlType:type];
        allPropertys[[XMDatabaseTool antiCollisionJointStr:OCString]] = typeStr;
        free(type);
    }
    free(propertys);
    return allPropertys.copy;
}
+ (NSString *)getPropertyTypeWithString:(NSString *)str {
    if (![XMDatabaseTool isNoNullStr:str]) {
        return XMDB_TYPE_NULL;
    }
    if ([str hasPrefix:XMDB_TYPE_TEXT]) {
        return XMDB_TYPE_TEXT;
    } else if ([str hasPrefix:XMDB_TYPE_BLOB]) {
        return XMDB_TYPE_BLOB;
    } else if ([str hasPrefix:XMDB_TYPE_INTEGER]) {
        return XMDB_TYPE_INTEGER;
    } else if ([str hasPrefix:XMDB_TYPE_REAL]) {
        return XMDB_TYPE_REAL;
    } else if ([str hasPrefix:XMDB_TYPE_NSValue]) {
        return XMDB_TYPE_TEXT;
    } else {
        return XMDB_TYPE_NULL;
    }
}

@end
