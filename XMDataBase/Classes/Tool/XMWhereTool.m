//
//  XMWhereTool.h
//  XMDataBaseManager
//
//  Created by 赵小明 on 2018/6/19.
//  Copyright © 2018年 ming-58. All rights reserved.
//

#import "XMWhereTool.h"
#import "XMDatabaseTool.h"
#import "XMDBTransformTool.h"

@interface XMWhereTool ()
{
    unsigned long long limitNum ;
    unsigned long long offsetNum ;
}

@property (nonatomic, strong) NSMutableString *sql;
@property (nonatomic, strong) NSMutableArray *values;

@end

@implementation XMWhereTool
- (instancetype)init
{
    self = [super init];
    if (self) {
        _sql = [NSMutableString string];
        _values = [NSMutableArray array];
    }
    return self;
}
- (NSString *_Nonnull)sqlStr {
    if (nil == _sql) {
        return @"";
    } else if (limitNum > 0) {
        if (offsetNum > 0) {
            [_sql appendFormat:@" LIMIT %llu, %llu", offsetNum, limitNum];
        } else {
            [_sql appendFormat:@" LIMIT %llu", limitNum];
        }
    } 
    return [@" WHERE" stringByAppendingString:_sql.copy];
}
- (NSArray *_Nonnull)sqlValues {
    return _values.copy;
}

- (XMWhereTool *)internalOffset:(unsigned long long)offset {
    if (offset > 0) {
        offsetNum = offset;
    }
    return  self;
}
- (XMWhereTool *)internalLimit:(unsigned long long)limit {
    if (limit > 0) {
        limitNum = limit;
    }
    return  self;
}


- (XMWhereTool *)orderBy:(NSString *)key direction:(NSString *)direction {
    if ([XMDatabaseTool isNoNullStr:key] && [XMDatabaseTool isNoNullStr:direction]) {
        [_sql appendFormat:@" ORDER BY %@ %@", [XMDatabaseTool antiCollisionJointStr:key], direction];
        return self;
    }

    return self;
}


- (XMWhereTool *)internalLike:(NSString *)field match:(NSObject *)match type:(NSString *)type side:(NSString *)side invert:(BOOL)invert {
    if ( nil == field || nil == match )
        return self;
    
    NSString * value = nil;
    
    if ([side isEqualToString:@"before"]) {
        value = @"%%?";
    } else if ([side isEqualToString:@"after"]) {
        value = @"?%%";
    } else {
        value = @"%%?%%";
    }
    id transformValue  = [XMDBTransformTool transformDataBaseStorageType:match];
    if (!transformValue) {
        return self;
    }
    [_values addObject:transformValue];
    
    NSMutableString * sqlStr = [NSMutableString string];
    
    if (sqlStr.length) {
        [sqlStr appendString:type];
    }
    
    [sqlStr appendFormat:@" %@", [XMDatabaseTool antiCollisionJointStr:field]];
    
    if ( invert )
    {
        [sqlStr appendString:@" NOT"];
    }
    
    [sqlStr appendFormat:@" LIKE '%@'", value];
    
    [_sql appendString:sqlStr];
    return self;
}

- (XMWhereTool *)internalWhere:(NSString *)key expr:(NSString *)expr invert:(BOOL)invert values:(NSArray *)values type:(NSString *)type {
    if ( nil == key || nil == values || 0 == values.count )
        return self;
    
    NSMutableString * sqlStr = [NSMutableString string];
    
    if (_sql.length > 0){
        [sqlStr appendFormat:@"%@ ", type];
    }
    
    [sqlStr appendFormat:@"%@", [XMDatabaseTool antiCollisionJointStr:key]];
    
    if (invert) {
        [sqlStr appendString:@" NOT"];
    }
    
    [sqlStr appendString:@" IN ("];
    NSMutableArray *exprValues = [NSMutableArray arrayWithCapacity:values.count];
    for ( NSInteger i = 0; i < values.count; ++i ) {
        NSObject * value = [values objectAtIndex:i];
        id transformValue  = [XMDBTransformTool transformDataBaseStorageType:value];
        if (!transformValue) {
            continue;
        }
        [exprValues addObject:transformValue];
        
        if (i > 0) {
            [sqlStr appendFormat:@", ?"];
        } else {
            [sqlStr appendFormat:@"?"];
        }
    }
    [sqlStr appendString:@")"];
    if (exprValues.count > 0) {
        [_values addObjectsFromArray:exprValues];
        [_sql appendString:sqlStr.copy];
    }
    
    return self;
}
- (XMWhereTool *)internalBetween:(NSString *)key start:(id)start end:(id)end type:(NSString *)type {
    
    NSString *prefix = (0 == _sql.length) ? @"" : type;
    NSString *sqlStr = nil;
    key = [XMDatabaseTool antiCollisionJointStr:key];//@"%@ %@ BETWEEN %@ AND %@"
    id transformStart  = [XMDBTransformTool transformDataBaseStorageType:start];
    if (!transformStart) {
        return self;
    }
    id transformEnd  = [XMDBTransformTool transformDataBaseStorageType:end];
    if (!transformEnd) {
        return self;
    }
    [_values addObject:transformStart];
    [_values addObject:transformEnd];

    sqlStr = [NSString stringWithFormat:@"%@ %@ BETWEEN ? AND ?", prefix, key];
    
    [_sql appendString:sqlStr];

    return self;
}
- (XMWhereTool *)internalWhere:(NSString *)key expr:(NSString *)expr value:(NSObject *)value type:(NSString *)type {
    
    NSString *prefix = (0 == _sql.length) ? @"" : type;
    NSString *sqlStr = nil;
    
    if ([XMDatabaseTool isNoNull:value]){
        id transformValue  = [XMDBTransformTool transformDataBaseStorageType:value];
        if (transformValue) {
            sqlStr = [NSString stringWithFormat:@"%@ %@ %@ ?", prefix, [XMDatabaseTool antiCollisionJointStr:key], expr];
            [_values addObject:transformValue];
            
        } else {
            sqlStr = [NSString stringWithFormat:@"%@ %@ IS NULL", prefix, [XMDatabaseTool antiCollisionJointStr:key]];
        }
    } else {
        sqlStr = [NSString stringWithFormat:@"%@ %@ IS NULL", prefix, [XMDatabaseTool antiCollisionJointStr:key]];
    }
    [_sql appendString:sqlStr];
    return self;
}
@end
@implementation XMWhereTool (Chained)
- (XMWhereToolKVBlock)equal {
    XMWhereToolKVBlock block = ^ XMWhereTool* ( NSString * key, id value) {
        return [self internalWhere:key expr:@"=" value:value type:@"AND"];
    };
    return [block copy];
}
- (XMWhereToolKVBlock)orEqual {
    XMWhereToolKVBlock block = ^ XMWhereTool* ( NSString * key, id value) {
        return [self internalWhere:key expr:@"=" value:value type:@"OR"];
    };
    return [block copy];
}
- (XMWhereToolKRBlock)between {
    XMWhereToolKRBlock block = ^ XMWhereTool* ( NSString * key, id start, id end) {
        return [self internalBetween:key start:start end:end type:@"AND"];
    };
    return [block copy];
}
- (XMWhereToolKRBlock)orBetween {
    XMWhereToolKRBlock block = ^ XMWhereTool* ( NSString * key, id start, id end) {
        return [self internalBetween:key start:start end:end type:@"OR"];
    };
    return [block copy];
}
- (XMWhereToolKEVBlock)expr {
    XMWhereToolKEVBlock block = ^ XMWhereTool* ( NSString * key, NSString *expr, id value) {
        return [self internalWhere:key expr:expr value:value type:@"AND"];
    };
    return [block copy];
}
- (XMWhereToolKEVBlock)orExpr {
    XMWhereToolKEVBlock block = ^ XMWhereTool* ( NSString * key, NSString *expr, id value) {
        return [self internalWhere:key expr:expr value:value type:@"OR"];
    };
    return [block copy];
}
- (XMWhereToolKVsBlock)equalIn {
    XMWhereToolKVsBlock block = ^ XMWhereTool* (NSString *key, ... ) {
        va_list args;
        va_start(args, key);
        
        NSMutableArray * array = [NSMutableArray array];
        for ( ;; ) {
            NSObject * value = va_arg( args, NSObject * );
            if (nil == value) break;
            
            if ([value isKindOfClass:[NSArray class]]) {
                [array addObjectsFromArray:(id)value];
            } else {
                [array addObject:(NSString *)value];
            }
        }
        va_end(args);
        return [self internalWhere:key expr:@"=" invert:NO values:array.copy type:@"AND"];
    };
    return [block copy];
}
- (XMWhereToolKVsBlock)orEqualIn {
    XMWhereToolKVsBlock block = ^ XMWhereTool* (NSString *key, ... ) {
        va_list args;
        va_start(args, key);
        
        NSMutableArray * array = [NSMutableArray array];
        for ( ; ;) {
            NSObject * value = va_arg( args, NSObject * );
            if (nil == value) break;
            
            if ([value isKindOfClass:[NSArray class]]) {
                [array addObjectsFromArray:(id)value];
            } else {
                [array addObject:(NSString *)value];
            }
        }
        va_end(args);
        return [self internalWhere:key expr:@"=" invert:NO values:array.copy type:@"OR"];
    };
    return [block copy];
}
- (XMWhereToolKVsBlock)noEqualIn {
    XMWhereToolKVsBlock block = ^ XMWhereTool* (NSString *key, ... ) {
        va_list args;
        va_start(args, key);
        
        NSMutableArray * array = [NSMutableArray array];
        for ( ; ; ){
            NSObject * value = va_arg( args, NSObject * );
            if (nil == value) break;
            
            if ([value isKindOfClass:[NSArray class]]) {
                [array addObjectsFromArray:(id)value];
            } else {
                [array addObject:(NSString *)value];
            }
        }
        va_end(args);
        return [self internalWhere:key expr:@"=" invert:YES values:array.copy type:@"AND"];
    };
    return [block copy];
}
- (XMWhereToolKVsBlock)noOrEqualIn {
    XMWhereToolKVsBlock block = ^ XMWhereTool* (NSString *key, ... ) {
        va_list args;
        va_start(args, key);
        
        NSMutableArray * array = [NSMutableArray array];
        for ( ;; ) {
            NSObject * value = va_arg( args, NSObject * );
            if (nil == value) break;
            
            if ([value isKindOfClass:[NSArray class]]) {
                [array addObjectsFromArray:(id)value];
            } else {
                [array addObject:(NSString *)value];
            }
        }
        va_end(args);
        return [self internalWhere:key expr:@"=" invert:YES values:array.copy type:@"OR"];
    };
    return [block copy];
}
- (XMWhereToolKEVsBlock)exprIn {
    XMWhereToolKEVsBlock block = ^ XMWhereTool* (NSString *key, NSString* expr, ... ) {
        va_list args;
        va_start(args, expr);
        
        NSMutableArray * array = [NSMutableArray array];
        for ( ; ;) {
            NSObject * value = va_arg( args, NSObject * );
            if (nil == value) break;
            
            if ([value isKindOfClass:[NSArray class]]) {
                [array addObjectsFromArray:(id)value];
            } else {
                [array addObject:(NSString *)value];
            }
        }
        va_end(args);
        return [self internalWhere:key expr:expr invert:NO values:array.copy type:@"OR"];
    };
    return [block copy];
}
- (XMWhereToolKEVsBlock)orExprIn {
    XMWhereToolKEVsBlock block = ^ XMWhereTool* (NSString *key, NSString* expr, ... ) {
        va_list args;
        va_start(args, expr);
        
        NSMutableArray * array = [NSMutableArray array];
        for ( ; ;) {
            NSObject * value = va_arg( args, NSObject * );
            if (nil == value) break;
            
            if ([value isKindOfClass:[NSArray class]]) {
                [array addObjectsFromArray:(id)value];
            } else {
                [array addObject:(NSString *)value];
            }
        }
        va_end(args);
        return [self internalWhere:key expr:expr invert:NO values:array.copy type:@"OR"];
    };
    return [block copy];
}
- (XMWhereToolKEVsBlock)noExprIn {
    XMWhereToolKEVsBlock block = ^ XMWhereTool* (NSString *key, NSString* expr, ... ) {
        va_list args;
        va_start(args, expr);
        
        NSMutableArray * array = [NSMutableArray array];
        for ( ; ;) {
            NSObject * value = va_arg( args, NSObject * );
            if (nil == value) break;
            
            if ([value isKindOfClass:[NSArray class]]) {
                [array addObjectsFromArray:(id)value];
            } else {
                [array addObject:(NSString *)value];
            }
        }
        va_end(args);
        return [self internalWhere:key expr:expr invert:YES values:array.copy type:@"AND"];
    };
    return [block copy];
}

- (XMWhereToolKEVsBlock)noOrExprIn {
    XMWhereToolKEVsBlock block = ^ XMWhereTool* (NSString *key, NSString* expr, ... ) {
        va_list args;
        va_start(args, expr);
        
        NSMutableArray * array = [NSMutableArray array];
        for ( ;; ) {
            NSObject * value = va_arg( args, NSObject * );
            if (nil == value) break;
            
            if ([value isKindOfClass:[NSArray class]]) {
                [array addObjectsFromArray:(id)value];
            } else {
                [array addObject:(NSString *)value];
            }
        }
        va_end(args);
        return [self internalWhere:key expr:expr invert:YES values:array.copy type:@"OR"];
    };
    return [block copy];
}


- (XMWhereToolKVBlock)like {
    XMWhereToolKVBlock block = ^ XMWhereTool* ( NSString * key, id value) {
        return [self internalLike:key match:value type:@"AND" side:@"both" invert:NO];
    };
    return [block copy];
}
- (XMWhereToolKVBlock)orLike {
    XMWhereToolKVBlock block = ^ XMWhereTool* ( NSString * key, id value) {
        return [self internalLike:key match:value type:@"OR" side:@"both" invert:NO];
    };
    return [block copy];
}
- (XMWhereToolKVBlock)noLike {
    XMWhereToolKVBlock block = ^ XMWhereTool* ( NSString * key, id value) {
        return [self internalLike:key match:value type:@"AND" side:@"both" invert:YES];
    };
    return [block copy];
}
- (XMWhereToolKVBlock)orNoLike {
    XMWhereToolKVBlock block = ^ XMWhereTool* ( NSString * key, id value) {
        return [self internalLike:key match:value type:@"OR" side:@"both" invert:YES];
    };
    return [block copy];
}
- (XMWhereToolKBlock)orderByAsc {
    XMWhereToolKBlock block = ^ XMWhereTool* ( NSString * key) {
        return [self orderBy:key direction:@"ASC"];
    };
    return [block copy];
}
- (XMWhereToolKBlock)orderByDesc {
    XMWhereToolKBlock block = ^ XMWhereTool* ( NSString * key) {
        return [self orderBy:key direction:@"DESC"];
    };
    return [block copy];
}
- (XMWhereToolKBlock)orderByRand {
    XMWhereToolKBlock block = ^ XMWhereTool* ( NSString * key) {
        return [self orderBy:key direction:@"RAND()"];
    };
    return [block copy];
}
- (XMWhereToolKVBlock)orderBy {
    XMWhereToolKVBlock block = ^ XMWhereTool* ( NSString * key, id value) {
        NSString *direction = [NSString stringWithFormat:@"%@", value];
        return [self orderBy:key direction:direction];
    };
    return [block copy];
}
- (XMWhereToolVBlock)limit {
    XMWhereToolVBlock block = ^ XMWhereTool* (unsigned long long i) {
        return [self internalLimit:i];
    };
    return [block copy];
}
- (XMWhereToolVBlock)offset {
    XMWhereToolVBlock block = ^ XMWhereTool* (unsigned long long i) {
        return [self internalOffset:i];
    };
    return [block copy];
    
}
@end

