//
//  NSArray+XMDataBase.m
//  XMDataBase
//
//  Created by 赵小明 on 2018/8/8.
//

#import "NSArray+XMDataBase.h"
#import "XMDatabaseTool.h"

@implementation NSArray (XMDataBase)

+ (nullable instancetype)initWithTransformData:(NSData *)data {
    if ([XMDatabaseTool isNoNullData:data]) {
        NSArray *arr =  [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if ([XMDatabaseTool isNoNullArr:arr]) {
            return arr;
        }
    }
    return nil;

}

- (nullable NSData *)transformToData {
    if ([XMDatabaseTool isNoNullArr:self]) {
        if (@available(iOS 11.0, *)) {
            return [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingSortedKeys error:nil];
        } else {
            return [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:nil];
        }
    }
    return nil;
}

@end
