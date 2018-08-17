//
//  NSIndexPath+XMDataBase.m
//  XMDataBase
//
//  Created by 赵小明 on 2018/8/13.
//

#import "NSIndexPath+XMDataBase.h"
#import "XMDatabaseTool.h"

@implementation NSIndexPath (XMDataBase)
+ (nullable instancetype)initWithTransformString:(NSString *)string {
    if ([XMDatabaseTool isNoNullStr:string]) {
        NSArray<NSString *> *arr = [string componentsSeparatedByString:@"-"];
        if ([XMDatabaseTool isNoNullArr:arr] && arr.count == 2) {
            return [self indexPathForRow:[arr[1] integerValue] inSection:[arr[0] integerValue]];
        }
        
    }
    return nil;
}

- (nullable NSString *)transformToString {
    return [NSString stringWithFormat:@"%@-%@",@(self.section),@(self.row)];
}
@end
