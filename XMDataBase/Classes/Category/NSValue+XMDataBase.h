//
//  NSValue+XMDataBase.h
//  XMDataBase
//
//  Created by 赵小明 on 2018/8/15.
//

#import <Foundation/Foundation.h>

@interface NSValue (XMDataBase)
- (nullable NSString *)transformString;
- (nullable NSString *)transformStringWithCGType:(NSString *)type ;
+ (nullable instancetype)initValueWithCGType:(NSString *)type string:(NSString *)str;
@end
