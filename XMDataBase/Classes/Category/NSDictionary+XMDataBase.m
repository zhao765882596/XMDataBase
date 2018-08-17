//
//  NSDictionary+XMDataBase.m
//  XMDataBase
//
//  Created by 赵小明 on 2018/8/8.
//

#import "NSDictionary+XMDataBase.h"
#import "XMDatabaseTool.h"

@implementation NSDictionary (XMDataBase)
+ (nullable instancetype)initWithTransformData:(NSData *)data {
    if ([XMDatabaseTool isNoNullData:data]) {
        NSDictionary *dict =  [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if (dict && [dict isKindOfClass:NSDictionary.class] && dict.count > 0) {
            return dict;
        }
    }
    return nil;
    
}

- (nullable NSData *)transformToData {
    if (self && self.count > 0) {
        if (@available(iOS 11.0, *)) {
            return [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingSortedKeys error:nil];
        } else {
            return [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:nil];
        }
    }
    return nil;
}

@end
