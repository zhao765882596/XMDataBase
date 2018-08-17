//
//  Model.h
//  SYDatabaseManager
//
//  Created by 赵小明 on 2018/6/19.
//  Copyright © 2018年 ming-58. All rights reserved.
//

#import "XMModel.h"

@implementation XMModelBasics
- (instancetype)init
{
    self = [super init];
    if (self) {
        int tmp =  arc4random() % 100;
        self.integer = tmp++;
        self.i = tmp++;
        self.l = tmp++;
        self.ll = tmp++;
        self.s = tmp++;
        self.ui = tmp++;
        self.ul = tmp++;
        self.ull = tmp++;
        self.us = tmp++;
        self.uc = tmp++;
        self.c = tmp++;
        self.cgf = tmp++;
        self.d = tmp++;
        self.f = tmp++;
    }
    return self;
}

@end
@implementation XMModelStruct
//+ (NSString * _Nullable)primaryKey {
//    return @"timeStamp";
//}
//+ (NSString * _Nullable)dbName {
//    return @"model-2";
//}
//+ (NSUInteger)maxStorageCapacity {
//    return 2000;
//}
- (instancetype)init
{
    self = [super init];
    if (self) {
        int tmp =  arc4random() % 100;
        self.rect = CGRectMake(tmp * 1.13, tmp * 1.13, tmp * 1.13, tmp * 1.13);
        self.size = CGSizeMake(tmp * 2.13, tmp * 2.13);
        self.poit = CGPointMake(tmp * 3.11, tmp * 3.11);
        self.edgeinsets = UIEdgeInsetsMake(tmp * 1.34, tmp * 1.34, tmp * 1.34, tmp * 1.34);
        self.CGVector = CGVectorMake(tmp * 13.11, tmp * 13.11);
        self.CGAffineTransform = CGAffineTransformMake(7, 8, 9, 10, 1, 3);
        self.offset = UIOffsetMake(8.88, 9.99);


    }
    return self;
}
@end
@implementation XMModelClass

- (instancetype)init
{
    self = [super init];
    if (self) {
        int tmp =  arc4random() % 100;
        self.selfClass = NSClassFromString(@"SYViewController");
        self.str = [NSString stringWithFormat:@"%d",tmp];
        self.str1 = [NSString stringWithFormat:@"%d",tmp + tmp];
        self.str2 = [NSString stringWithFormat:@"%d",tmp % 15];
        self.TABLE = [NSString stringWithFormat:@"%d",tmp * tmp];
        self.WHERE = [NSString stringWithFormat:@"%d",tmp / 5];
        self.image = [UIImage imageNamed:@"1"];
        
        self.date = [NSDate date];
        self.data = [self.str dataUsingEncoding:NSUTF8StringEncoding];
        self.error = [NSError errorWithDomain:@"111" code:200 userInfo:@{@"111":@(200)}];
        self.color = [UIColor redColor];
        self.indexPath = [NSIndexPath indexPathForRow:100 inSection:10];
        self.arr = @[@"1", @"32", @"ds"];
        self.dict = @{@"1": @1, @"2": @2};
        self.url = [NSURL URLWithString:@"https://www.baidu.com"];
        self.decimal = [NSDecimalNumber decimalNumberWithString:@"12312312312312.4123123123"];
        self.view = [[UIView alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
        self.view.backgroundColor = self.color;
    }
    return self;
}
@end

