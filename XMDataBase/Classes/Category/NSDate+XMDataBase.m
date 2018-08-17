//
//  NSDate+XMDataBase.m
//  XMDataBase
//
//  Created by 赵小明 on 2018/8/8.
//

#import "NSDate+XMDataBase.h"

@implementation NSDate (XMDataBase)
+ (nullable instancetype)initWithTransformReal:(double)real {
    NSDate *date = [[self alloc] initWithTimeIntervalSince1970:real];
    return date;
}

- (double)transformToReal {
    return [self timeIntervalSince1970];
}
@end
