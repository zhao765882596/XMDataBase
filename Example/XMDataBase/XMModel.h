//
//  Model.h
//  SYDatabaseManager
//
//  Created by 赵小明 on 2018/6/19.
//  Copyright © 2018年 ming-58. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <XMDataBase/XMDBTransformProtocol.h>

@interface XMModelBasics : NSObject

@property (assign, nonatomic) NSInteger integer;
@property (assign, nonatomic) int i;
@property (assign, nonatomic) long l;
@property (assign, nonatomic) long long ll;
@property (assign, nonatomic) short s;
@property (assign, nonatomic) unsigned int ui;
@property (assign, nonatomic) unsigned long ul;
@property (assign, nonatomic) unsigned long long ull;
@property (assign, nonatomic) unsigned short us;
@property (assign, nonatomic) unsigned char uc;
@property (assign, nonatomic) char  c;
@property (assign, nonatomic) CGFloat cgf;
@property (assign, nonatomic) double d;
@property (assign, nonatomic) float f;
@property (assign, nonatomic) BOOL bool1;



@property (strong, nonatomic) NSString *str;
@property (strong, nonatomic) NSDate *date;
@property (strong, nonatomic) NSData *data;
@property (strong, nonatomic) UIImage *image;




@property (strong, nonatomic) NSString *str1;
@property (strong, nonatomic) NSString *str2;
@property (strong, nonatomic) NSString *TABLE;
@property (strong, nonatomic) NSString *WHERE;

@property (strong, nonatomic) NSError *error;
@property (strong, nonatomic) UIColor *color;
@property (strong, nonatomic) NSIndexPath *indexPath;
@property (strong, nonatomic) NSArray *arr;
@property (strong, nonatomic) NSDictionary *dict;
@property (strong, nonatomic) NSURL *url;
@property (strong, nonatomic) NSDecimalNumber *decimal;
@property (strong, nonatomic) UIView *view;

@end
@interface XMModelStruct : XMModelBasics
@property (assign, nonatomic) Class selfClass;

@property (assign, nonatomic) CGRect rect;
@property (assign, nonatomic) CGSize size;
@property (assign, nonatomic) CGPoint poit;
@property (assign, nonatomic) UIEdgeInsets edgeinsets;

@property (assign, nonatomic) CGVector CGVector;
@property (assign, nonatomic) CGAffineTransform CGAffineTransform;
@property (nonatomic, assign) UIOffset offset;

@end
@interface XMModelClass : XMModelStruct
@end

