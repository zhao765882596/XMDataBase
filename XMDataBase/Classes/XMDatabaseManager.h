//
//  XMDatabaseManager.h
//  XMDatabaseManager
//
//  Created by 赵小明 on 2018/6/19.
//  Copyright © 2018年 ming-58. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMWhereTool.h"

@interface XMDataBaseManager : NSObject
#pragma mark - 存储数据

/**
 存入数据
 
 @param model 存储的对象
 @param completed 存储执行完成回调 (error 为空 即存储成功)
 */
+ (void)storeModel:(nonnull id<NSObject>)model completed:(void(^)(NSError* _Nullable error))completed;

/**
 存入数据
 
 @param modelArr 存储的对象数组 必须为同一个类  如果数组内对象超过20个会拆分调用
 @param completed 存储执行完成回调 (error 为空 即存储成功) 如果数组内对象超过20个会多次调用
 */
+ (void)storeModels:(NSArray *)modelArr completed:(void(^)(NSArray<NSError *> *errors,BOOL isAllSuccess))completed;




#pragma mark - 删除数据
/**
 删除数据

 @param model 删除对象
 @param completed 删除执行完成回调 (error 为空 即删除成功)
 */
+ (void)deleteModel:(nonnull id<NSObject>)model completed:(void(^)(NSError* _Nullable error))completed;

/**
 删除数据

 @param modelClass 删除的类
 @param whereTool 使用XMWhereTool创建 控制sql nil 清空表
 @param completed 删除执行完成回调 (error 为空 即删除成功)
 */
+ (void)deleteWithClass:(Class)modelClass whereTool:(XMWhereTool *)whereTool completed: (void(^)(NSError* _Nullable error))completed;




#pragma mark - 更改数据
/**
 更新数据 [model.class primaryKey] 有值 且 model 的primaryKey有值是执行
 
 @param model 更新对象 如无 插入
 @param completed 更新执行完成回调 (error 为空 即更新成功)
 */
+ (void)updateModel:(nonnull id<NSObject>)model completed:(void(^)(NSError* _Nullable error))completed;
/**
 更新数据 [model.class primaryKey] 有值 且 model 的primaryKey有值时执行
 
 @param models 更新对象数组 如无 插入
 @param completed 更新执行完成回调 (error 为空 即更新成功)
 */
+ (void)updateModels:(NSArray *)models completed:(void(^)(NSArray<NSError *> *errors,BOOL isAllSuccess))completed;




#pragma mark - 查询数据
/**
 查找范围数据
 
 @param modelClass 查找的类
 @param whereTool 使用WhereTool创建 控制sql nil 查找全部
 @param completed 查找执行完成回调 (selectModels 查找返回对象数组 error 为空 即查找成功)
 */
+ (void)selectWithClass:(Class)modelClass whereTool:(XMWhereTool *)whereTool completed: (void(^)(NSArray * _Nullable selectModels,NSError* _Nullable error))completed;
/**
 查询存储数量
 
 @param modelClass 查询类名
 @param completed NSError nil 查询成功   NSUInteger 返回查询到的数量
 */
+ (void)queryStoreCountWithClass:(Class)modelClass Completed: (void(^)(NSError *error, NSUInteger count))completed;




#pragma mark - 其他表操作
/**
 删除表的对应列  不能删除primaryKey  model属性里删除对应属性 或者加入忽略列表 否则删除列还会添加

 @param modelClass 删除的类
 @param columnName 需要删除对应的列
 @param completed 删除执行完成回调 (error 为空 即删除成功)
 */
+ (void)deleteColumnWithClass:(Class)modelClass columnName:(NSString *)columnName completed: (void(^)(NSError* _Nullable error))completed;

/**
 删除表
 
 @param modelClass 删除的类对象
 @param completed 删除执行完成回调 (error 为空 即删除成功)
 */
+ (void)dropTableWithClass:(Class)modelClass completed: (void(^)(NSError* _Nullable error))completed;




#pragma mark - 其他数据库操作
/**
 删除数据库
 如果数据库内只有一张表 则删除数据库 否则只删除表
 @param modelClass 删除的类对象
 @param completed 删除执行完成回调 (error 为空 即删除成功) //当前方法默认数据库不会删除
 */
+ (void)deleteDBWithClass:(Class)modelClass completed: (void(^)(NSError* _Nullable error))completed;
/**
 删除默认数据库
 @param completed 删除执行完成回调 (error 为空 即删除成功) //当前方法默认数据库不会删除
 */
+ (void)deleteDefaultDBWithCompleted: (void(^)(NSError* _Nullable error))completed;

@end
