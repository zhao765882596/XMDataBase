//
//  XMDBTransformProtocol.h
//  XMDataBase
//
//  Created by 赵小明 on 2018/8/7.
//

#import <Foundation/Foundation.h>
@protocol XMDBTransformProtocol <NSObject>
@end
@protocol XMDBTransformStringProtocol <XMDBTransformProtocol>
+ (nullable instancetype)initWithTransformString:(NSString *)string;
- (nullable NSString *)transformToString;
@end

@protocol XMDBTransformDataProtocol <XMDBTransformProtocol>
+ (nullable instancetype)initWithTransformData:(NSData *)data;
- (nullable NSData *)transformToData;
@end

@protocol XMDBTransformIntegerProtocol <XMDBTransformProtocol>
+ (nullable instancetype)initWithTransformIntege:(long long)integer;
- (long long)transformToIntege;
@end

@protocol XMDBTransformRealProtocol <XMDBTransformProtocol>
+ (nullable instancetype)initWithTransformReal:(double)real;
- (double)transformToReal;
@end
