//
//  NSDecimalNumber+XMDataBase.m
//  XMDataBase
//
//  Created by 赵小明 on 2018/8/8.
//

#import "NSDecimalNumber+XMDataBase.h"
#import "XMDatabaseTool.h"

@implementation NSDecimalNumber (XMDataBase)
+ (nullable instancetype)initWithTransformString:(NSString *)string {
    if ([XMDatabaseTool isNoNullStr:string]) {
        return [self decimalNumberWithString:string];
    }
    return nil;
}

- (nullable NSString *)transformToString {
    return self.stringValue;
}

@end
