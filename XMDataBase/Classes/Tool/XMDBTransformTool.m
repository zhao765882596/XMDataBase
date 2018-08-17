//
//  XMDBTransformManager.m
//  XMDataBase
//
//  Created by 赵小明 on 2018/8/15.
//

#import "XMDBTransformTool.h"
#import "XMDatabaseTool.h"
#import "XMDBTransformProtocol.h"
#import "NSValue+XMDataBase.h"
#import "XMDatabasePropertyTool.h"

@implementation XMDBTransformTool
+ (id)transformDataBaseStorageType:(id)value {
    if ([XMDatabaseTool isNoNull:value]) {
        if ([value conformsToProtocol:@protocol(XMDBTransformStringProtocol)]) {
            NSString *valueStr = [value transformToString];
            if ([XMDatabaseTool isNoNullStr:valueStr]) {
                return valueStr;
            } else {
                return nil;
            }
        } else if ([value conformsToProtocol:@protocol(XMDBTransformDataProtocol)]) {
            NSData *valueData = [value transformToData];
            if ([XMDatabaseTool isNoNullData:valueData]) {
                return valueData;
            } else {
                return nil;
            }
        } else if ([value conformsToProtocol:@protocol(XMDBTransformIntegerProtocol)]) {
            long long intege = [value transformToIntege];
            return [NSNumber numberWithLongLong:intege];
        } else if ([value conformsToProtocol:@protocol(XMDBTransformRealProtocol)]) {
            double real = [value transformToReal];
            return [NSNumber numberWithDouble:real];
        } else if ([value isKindOfClass:NSNumber.class] || [value isKindOfClass:NSData.class] || [value isKindOfClass:NSString.class]){
            return value;
        } else if ([value isKindOfClass:NSValue.class]) {
            return [value transformString];
        } else if ([value conformsToProtocol:@protocol(NSCoding)]) {
            return [NSKeyedArchiver archivedDataWithRootObject:value];;
        } else {
            return NSStringFromClass(value);
        }
    }
    return nil;
}
+ (id)transformProtocolObjectWithCGType:(NSString *)type value:(id)value {
    if ([value conformsToProtocol:@protocol(XMDBTransformProtocol)]) {
        if ([value conformsToProtocol:@protocol(XMDBTransformStringProtocol)]) {
            NSString *valueStr = [value transformToString];
            if ([XMDatabaseTool isNoNullStr:valueStr]) {
                return valueStr;
            } else {
                return XMDB_TYPE_NULL;
            }
        } else if ([value conformsToProtocol:@protocol(XMDBTransformDataProtocol)]) {
            NSData *valueData = [value transformToData];
            if ([XMDatabaseTool isNoNullData:valueData]) {
                return valueData;
            } else {
                return XMDB_TYPE_NULL;
            }
        } else if ([value conformsToProtocol:@protocol(XMDBTransformIntegerProtocol)]) {
            long long intege = [value transformToIntege];
            return [NSNumber numberWithLongLong:intege];
        } else if ([value conformsToProtocol:@protocol(XMDBTransformRealProtocol)]) {
            double real = [value transformToReal];
            return [NSNumber numberWithDouble:real];
        }
    }
    return XMDB_TYPE_NULL;
    
}
+ (id)transformObjectWithCGType:(NSString *)type value:(id)value {
    if ([XMDatabaseTool isNoNull:value]) {
        if ([value conformsToProtocol:@protocol(XMDBTransformProtocol)]) {
            return [self transformProtocolObjectWithCGType:type value:value];
        } else if ([type hasPrefix:XMDB_TYPE_NSValue] && [value isKindOfClass:NSValue.class]){
            NSString *valueStr = [value transformStringWithCGType:type];
            if ([XMDatabaseTool isNoNullStr:valueStr]) {
                return valueStr;
            } else {
                return XMDB_TYPE_NULL;
            }
        } else if ([type containsString:@"#"]) {
            return NSStringFromClass(value);
        } else if ([type containsString:XMDB_TYPE_NSCODING]) {
            NSData *valueData = [NSKeyedArchiver archivedDataWithRootObject:value];
            if ([XMDatabaseTool isNoNullData:valueData]) {
                return valueData;
            } else {
                return XMDB_TYPE_NULL;
            }
        } else {
            return value;
        }
        
    } else {
        return XMDB_TYPE_NULL;
    }
}
+ (id)initObjectProtocolWithCGType:(NSString *)type value:(id)value {
    if ([type hasPrefix:XMDB_TYPE_TEXT]) {
        Class  class = NSClassFromString([type substringFromIndex:4]);
        if (class && [class conformsToProtocol:@protocol(XMDBTransformStringProtocol)] && [XMDatabaseTool isNoNullStr:(NSString *)value]) {
            return [class initWithTransformString:(NSString *)value];
        } else if ([type containsString:@"#"] && [value isKindOfClass:NSString.class]) {
            return NSClassFromString(value);
        }
    } else if ([type hasPrefix:XMDB_TYPE_BLOB] && type.length > 4) {
        Class  class = NSClassFromString([type substringFromIndex:4]);
        if (class && [class conformsToProtocol:@protocol(XMDBTransformDataProtocol)] && [XMDatabaseTool isNoNullData:(NSData *)value]) {
            return [class initWithTransformData:(NSData *)value];
        } else if ([type containsString:XMDB_TYPE_NSCODING] && [XMDatabaseTool isNoNullData:(NSData *)value]) {
            return [NSKeyedUnarchiver unarchiveObjectWithData: (NSData *)value];
        }
    } else if ([type hasPrefix:XMDB_TYPE_INTEGER]) {
        Class  class = NSClassFromString([type substringFromIndex:7]);
        if (class && [class conformsToProtocol:@protocol(XMDBTransformIntegerProtocol)] && [value isKindOfClass:NSNumber.class]) {
            return [class initWithTransformIntege:[(NSNumber *)value longLongValue]];
        }
    } else if ([type hasPrefix:XMDB_TYPE_REAL]) {
        Class  class = NSClassFromString([type substringFromIndex:4]);
        if (class && [class conformsToProtocol:@protocol(XMDBTransformRealProtocol)] && [value isKindOfClass:NSNumber.class]) {
            return [class initWithTransformReal:[(NSNumber *)value doubleValue]];
        }
    }
    return nil;
}

+ (id)initObjectWithCGType:(NSString *)type value:(id)value {
    if (value) {
        if ([type isEqualToString:XMDB_TYPE_TEXT] || [type isEqualToString:XMDB_TYPE_BLOB] || [type isEqualToString:XMDB_TYPE_INTEGER] || [type isEqualToString:XMDB_TYPE_REAL] ) {
            return value;
        } else if ([type hasPrefix:XMDB_TYPE_NSValue] && [value isKindOfClass:NSString.class]) {
            NSValue *tmpValue = [NSValue initValueWithCGType:type string:value];
            if ([XMDatabaseTool isNoNull:tmpValue]) {
                return tmpValue;
            }
        } else {
            return [self initObjectProtocolWithCGType:type value:value];
        }
    }
    return nil;
    
}

@end
