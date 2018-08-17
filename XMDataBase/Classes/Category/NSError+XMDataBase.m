//
//  NSError+XMDataBase.m
//  XMDataBase
//
//  Created by 赵小明 on 2018/8/8.
//

#import "NSError+XMDataBase.h"
#import "NSDictionary+XMDataBase.h"

@implementation NSError (XMDataBase)

+ (nullable instancetype)initWithTransformData:(NSData *)data {
    NSMutableDictionary *dict = [NSDictionary initWithTransformData:data].mutableCopy;
    if (dict && dict.count > 0) {
        NSInteger code = [dict[@"code"] integerValue];
        NSString *domain = dict[@"domain"];
        [dict removeObjectForKey:@"code"];
        [dict removeObjectForKey:@"domain"];
        return [self errorWithDomain:domain ? domain : @"" code:code userInfo:dict.count > 0 ? dict.copy : nil];
    }
    return nil;

}

- (nullable NSData *)transformToData {
    NSMutableDictionary *dict = self.userInfo.mutableCopy;
    if (!dict) {
        dict = [NSMutableDictionary dictionaryWithCapacity:2];
    }
    dict[@"code"] = @(self.code);
    dict[@"domain"] = self.domain;
    return [dict transformToData];
}

@end
