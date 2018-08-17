//
//  XMWhereTool.h
//  XMDataBaseManager
//
//  Created by 赵小明 on 2018/6/19.
//  Copyright © 2018年 ming-58. All rights reserved.
//

#import <Foundation/Foundation.h>

@class XMWhereTool;
typedef XMWhereTool * (^XMWhereToolBlock)(void);
typedef XMWhereTool * (^XMWhereToolKBlock)(NSString *);
typedef XMWhereTool * (^XMWhereToolVBlock)(unsigned long long);


typedef XMWhereTool * (^XMWhereToolKVBlock)(NSString *, id);
typedef XMWhereTool * (^XMWhereToolKEVBlock)(NSString *, NSString *, id);
typedef XMWhereTool * (^XMWhereToolKRBlock)(NSString *, id, id);

typedef XMWhereTool * (^XMWhereToolKVsBlock)(NSString *, ... );
typedef XMWhereTool * (^XMWhereToolKEVsBlock)(NSString *, NSString *, ... );


@interface XMWhereTool : NSObject

- (NSString *_Nonnull)sqlStr;
- (NSArray *_Nonnull)sqlValues;

@end


@interface XMWhereTool (Chained)
@property (nonatomic, readonly) XMWhereToolKVBlock equal;
@property (nonatomic, readonly) XMWhereToolKVBlock orEqual;

@property (nonatomic, readonly) XMWhereToolKRBlock between;
@property (nonatomic, readonly) XMWhereToolKRBlock orBetween;
/**
 =    等于
 <>    不等于
 >    大于
 <    小于
 >=    大于等于
 <=    小于等于
 */

@property (nonatomic, readonly) XMWhereToolKEVBlock expr;
@property (nonatomic, readonly) XMWhereToolKEVBlock orExpr;


@property (nonatomic, readonly) XMWhereToolKVsBlock equalIn;
@property (nonatomic, readonly) XMWhereToolKVsBlock orEqualIn;
@property (nonatomic, readonly) XMWhereToolKVsBlock noEqualIn;
@property (nonatomic, readonly) XMWhereToolKVsBlock noOrEqualIn;

@property (nonatomic, readonly) XMWhereToolKEVsBlock exprIn;
@property (nonatomic, readonly) XMWhereToolKEVsBlock orExprIn;
@property (nonatomic, readonly) XMWhereToolKEVsBlock noExprIn;
@property (nonatomic, readonly) XMWhereToolKEVsBlock noOrExprIn;


@property (nonatomic, readonly) XMWhereToolKVBlock like;//包含
@property (nonatomic, readonly) XMWhereToolKVBlock orLike;//或者包含

@property (nonatomic, readonly) XMWhereToolKVBlock noLike;//不包含
@property (nonatomic, readonly) XMWhereToolKVBlock orNoLike;//或者不包含


@property (nonatomic, readonly) XMWhereToolKBlock orderByAsc;//升序
@property (nonatomic, readonly) XMWhereToolKBlock orderByDesc;//降序
@property (nonatomic, readonly) XMWhereToolKBlock orderByRand;//随机读取
@property (nonatomic, readonly) XMWhereToolKVBlock orderBy;//排序


@property (nonatomic, readonly) XMWhereToolVBlock limit;//限制数量
@property (nonatomic, readonly) XMWhereToolVBlock offset;//偏移量

@end
