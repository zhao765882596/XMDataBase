//
//  NSURL+XMDataBase.m
//  XMDataBase
//
//  Created by 赵小明 on 2018/8/8.
//

#import "NSURL+XMDataBase.h"
#import "XMDatabaseTool.h"

@implementation NSURL (XMDataBase)

+ (nullable instancetype)initWithTransformString:(NSString *)string {
    if ([XMDatabaseTool isNoNullStr:string]) {
        return [[self alloc] initWithString:string];
    }
    return nil;
    
}

- (nullable NSString *)transformToString {
    return self.absoluteString;
}

@end
