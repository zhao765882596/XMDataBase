//
//  XMDBTransformManager.h
//  XMDataBase
//
//  Created by 赵小明 on 2018/8/15.
//

#import <Foundation/Foundation.h>

@interface XMDBTransformTool : NSObject
+ (id)transformDataBaseStorageType:(id)value;
+ (id)transformObjectWithCGType:(NSString *)type value:(id)value;
+ (id)initObjectWithCGType:(NSString *)type value:(id)value;
@end
