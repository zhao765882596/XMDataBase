//
//  UIColor+XMDataBase.m
//  XMDataBase
//
//  Created by 赵小明 on 2018/8/10.
//

#import "UIColor+XMDataBase.h"
#import "XMDatabaseTool.h"

@implementation UIColor (XMDataBase)

+ (nullable instancetype)initWithTransformString:(NSString *)string {
    if ([XMDatabaseTool isNoNullStr:string]) {
        NSArray<NSString *> *arr = [string componentsSeparatedByString:@"-"];
        if ([XMDatabaseTool isNoNullArr:arr] && arr.count == 4) {
            return [UIColor colorWithRed:[arr[0] doubleValue] green:[arr[1] doubleValue] blue:[arr[2] doubleValue] alpha:[arr[3] doubleValue]];
        }
        
    }
    return nil;
}

- (nullable NSString *)transformToString {
    CGFloat r=0,g=0,b=0,a=0;
    if ([self respondsToSelector:@selector(getRed:green:blue:alpha:)]) {
        [self getRed:&r green:&g blue:&b alpha:&a];
    } else {
        const CGFloat *components = CGColorGetComponents(self.CGColor);
        r = components[0];
        g = components[1];
        b = components[2];
        a = components[3];
    }
    return [NSString stringWithFormat:@"%f-%f-%f-%f",r,g,b,a];
}

@end
