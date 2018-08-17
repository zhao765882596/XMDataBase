//
//  NSValue+XMDataBase.m
//  XMDataBase
//
//  Created by 赵小明 on 2018/8/15.
//

#import "NSValue+XMDataBase.h"
#import "XMDatabaseTool.h"

@implementation NSValue (XMDataBase)
- (nullable NSString *)transformString {
    NSString *type = [NSString stringWithUTF8String:self.objCType];
    return [self transformStringWithCGType:type];
}
- (nullable NSString *)transformStringWithCGType:(NSString *)type {
    if ([XMDatabaseTool isNoNull:self] ) {
        if ([type containsString:@"CGRect"]) {
            CGRect rect = self.CGRectValue;
            if (CGRectIsNull(rect) || CGRectIsEmpty(rect) || CGRectIsInfinite(rect)) {
                return nil;
            } else {
                return [NSString stringWithFormat:@"%f-%f-%f-%f",rect.origin.x,rect.origin.y,rect.size.width,rect.size.height];
            }
        } else if ([type containsString:@"CGSize"]) {
            CGSize size = self.CGSizeValue;
            return [NSString stringWithFormat:@"%f-%f",size.width,size.height];
        } else if ([type containsString:@"CGPoint"]) {
            CGPoint point = self.CGPointValue;
            return [NSString stringWithFormat:@"%f-%f",point.x,point.y];
        } else if ([type containsString:@"UIEdgeInsets"]) {
            UIEdgeInsets insets = self.UIEdgeInsetsValue;
            return [NSString stringWithFormat:@"%f-%f-%f-%f",insets.top,insets.left,insets.bottom,insets.right];
        } else if ([type containsString:@"CGVector"]) {
            CGVector vector = self.CGVectorValue;
            return [NSString stringWithFormat:@"%f-%f",vector.dx,vector.dy];
        } else if ([type containsString:@"CGAffineTransform"]) {
            CGAffineTransform affineTransform = self.CGAffineTransformValue;
            return [NSString stringWithFormat:@"%f-%f-%f-%f-%f-%f",affineTransform.a
                    ,affineTransform.b,affineTransform.c,affineTransform.d,affineTransform.tx,affineTransform.ty];
        } else if ([type containsString:@"UIOffset"]) {
            UIOffset offset = self.UIOffsetValue;
            return [NSString stringWithFormat:@"%f-%f",offset.horizontal,offset.vertical];
        }
    }
    return nil;
}
+ (nullable instancetype)initValueWithCGType:(NSString *)type string:(NSString *)str {
    if ([type containsString:@"CGRect"]) {
        if ([XMDatabaseTool isNoNullStr:str]) {
            NSArray<NSString *> *strs = [str componentsSeparatedByString:@"-"];
            if (strs && [strs isKindOfClass:NSArray.class] && strs.count == 4) {
                CGRect rect = CGRectMake(strs[0].doubleValue, strs[1].doubleValue, strs[2].doubleValue, strs[3].doubleValue);
                return [NSValue valueWithCGRect:rect];
                
            } else {
                return nil;
            }
        } else {
            return nil;
        }
    } else if ([type containsString:@"CGSize"]) {
        if ([XMDatabaseTool isNoNullStr:str]) {
            NSArray<NSString *> *strs = [str componentsSeparatedByString:@"-"];
            if (strs && [strs isKindOfClass:NSArray.class] && strs.count == 2) {
                CGSize size = CGSizeMake(strs[0].doubleValue, strs[1].doubleValue);
                return [NSValue valueWithCGSize:size];
            } else {
                return nil;
            }
        } else {
            return nil;
        }
        
    } else if ([type containsString:@"CGPoint"]) {
        if ([XMDatabaseTool isNoNullStr:str]) {
            NSArray<NSString *> *strs = [str componentsSeparatedByString:@"-"];
            if (strs && [strs isKindOfClass:NSArray.class] && strs.count == 2) {
                CGPoint point = CGPointMake(strs[0].doubleValue, strs[1].doubleValue);
                return [NSValue valueWithCGPoint:point];
            } else {
                return nil;
            }
        } else {
            return nil;
        }
    } else if ([type containsString:@"UIEdgeInsets"]) {
        if ([XMDatabaseTool isNoNullStr:str]) {
            NSArray<NSString *> *strs = [str componentsSeparatedByString:@"-"];
            if (strs && [strs isKindOfClass:NSArray.class] && strs.count == 4) {
                UIEdgeInsets insets = UIEdgeInsetsMake(strs[0].doubleValue, strs[1].doubleValue, strs[2].doubleValue, strs[3].doubleValue);
                return [NSValue valueWithUIEdgeInsets:insets];
            } else {
                return nil;
            }
        } else {
            return nil;
        }
    } else if ([type containsString:@"CGVector"]) {
        if ([XMDatabaseTool isNoNullStr:str]) {
            NSArray<NSString *> *strs = [str componentsSeparatedByString:@"-"];
            if (strs && [strs isKindOfClass:NSArray.class] && strs.count == 2) {
                CGVector vector = CGVectorMake(strs[0].doubleValue, strs[1].doubleValue);
                return [NSValue valueWithCGVector:vector];
            } else {
                return nil;
            }
        } else {
            return nil;
        }
    } else if ([type containsString:@"CGAffineTransform"]) {
        if ([XMDatabaseTool isNoNullStr:str]) {
            NSArray<NSString *> *strs = [str componentsSeparatedByString:@"-"];
            if (strs && [strs isKindOfClass:NSArray.class] && strs.count == 6) {
                CGAffineTransform from = CGAffineTransformMake(strs[0].doubleValue, strs[1].doubleValue, strs[2].doubleValue, strs[3].doubleValue, strs[4].doubleValue, strs[5].doubleValue);
                return [NSValue valueWithCGAffineTransform:from];
            } else {
                return nil;
            }
        } else {
            return nil;
        }
    } else if ([type containsString:@"UIOffset"]) {
        if ([XMDatabaseTool isNoNullStr:str]) {
            NSArray<NSString *> *strs = [str componentsSeparatedByString:@"-"];
            if (strs && [strs isKindOfClass:NSArray.class] && strs.count == 2) {
                UIOffset offset = UIOffsetMake(strs[0].doubleValue, strs[1].doubleValue);
                return [NSValue valueWithUIOffset:offset];
            } else {
                return nil;
            }
        } else {
            return nil;
        }
    }
    
    return nil;
    
}

@end
