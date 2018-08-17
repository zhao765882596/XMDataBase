//
//  UIImage+XMDataBase.m
//  XMDataBase
//
//  Created by 赵小明 on 2018/8/8.
//

#import "UIImage+XMDataBase.h"
#import "XMDatabaseTool.h"

@implementation UIImage (XMDataBase)
+ (nullable instancetype)initWithTransformData:(NSData *)data {
    if ([XMDatabaseTool isNoNullData:data]) {
        return [[self alloc] initWithData:data];
    }
    return nil;
}

- (nullable NSData *)transformToData {
    return UIImageJPEGRepresentation(self, 1.0);
}
@end
