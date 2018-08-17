//
//  SYViewController.m
//  SYDataBase
//
//  Created by zhao765882596 on 08/07/2018.
//  Copyright (c) 2018 zhao765882596. All rights reserved.
//

#import "XMViewController.h"
#import "XMModel.h"
#import "XMDataBaseManager.h"
#import "XMDatabaseTool.h"

@interface XMViewController ()
{
    XMModelClass *_m;
}
@end

@implementation XMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)storageModel:(id)sender {
    XMModelClass * m1 = [XMModelClass new];
    _m = m1;
    [XMDataBaseManager storeModel:m1 completed:^(NSError * _Nullable error) {
        NSLog(@"storageModel ---- %@", error);
    }];
}
- (IBAction)storageModels:(id)sender {
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:1000];
    for (int i = 0; i < 1000; i++) {
        [arr addObject:[XMModelClass new]];
    }
    NSDate * date = [NSDate date];
    [XMDataBaseManager storeModels:arr completed:^(NSArray<NSError *> *errors,BOOL isAllSuccess) {
            NSLog(@"storageModels ---- %@", errors);
            NSTimeInterval i = [date timeIntervalSinceNow];
            NSLog(@"%@", @(i));
        
    }];
    
    
}
- (IBAction)deleteModel:(id)sender {
    [XMDataBaseManager deleteModel:_m completed:^(NSError * _Nullable error) {
        NSLog(@"deleteModel ---- %@", error);
    }];
}
- (IBAction)deleteIf:(id)sender {
    XMWhereTool *tool = [[XMWhereTool alloc] init];
    tool.equal(@"i", @69);
    
    [XMDataBaseManager deleteWithClass:XMModelClass.class whereTool:tool completed:^(NSError * _Nullable error) {
        NSLog(@"deleteIf ---- %@", error);
        
    }];
}
- (IBAction)deleteRang:(id)sender {
    XMWhereTool *tool = [[XMWhereTool alloc] init];
    tool.between(@"i", @35, @50);
    
    [XMDataBaseManager deleteWithClass:XMModelClass.class whereTool:tool completed:^(NSError * _Nullable error) {
        NSLog(@"deleteIf ---- %@", error);
        
    }];
}
- (IBAction)customdelete:(id)sender {
    XMWhereTool * tool = [XMWhereTool new];
    tool.expr(@"i", @"<=", @(90));
    [XMDataBaseManager deleteWithClass:XMModelClass.class whereTool:tool completed:^(NSError * _Nullable error) {
        NSLog(@"customdelete ---- %@", error);
    }];
}
- (IBAction)findAllData:(id)sender {
    NSDate * date = [NSDate date];
    [XMDataBaseManager selectWithClass:XMModelClass.class whereTool:nil completed:^(NSArray * _Nullable selectModels, NSError * _Nullable error) {
//        [self->_m isEqualMode:selectModels[0]];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            UIImage *image = ((Model2 *)selectModels[0]).image;
//            UIImageView *iv = [[UIImageView alloc] initWithImage:image];
//            iv.frame = CGRectMake(100, 100, 100, 100);
//            
//            [self.view addSubview:iv];
//        });
        
            NSTimeInterval i = [date timeIntervalSinceNow];
            NSLog(@"%@", @(i));

        NSLog(@"findAllData --   %@      ----error- %@", @(selectModels.count), error);
        
        for (XMModelClass *m in selectModels) {
            NSLog(@"---%@---", @(m.i));
        }
    }];
}
- (IBAction)findIf:(id)sender {
    XMWhereTool *tool = [[XMWhereTool alloc] init];
    tool.equal(@"i", @39);
    [XMDataBaseManager selectWithClass:XMModelClass.class whereTool:tool completed:^(NSArray * _Nullable selectModels, NSError * _Nullable error) {
        NSLog(@"findAllData --   %@      ----error- %@", @(selectModels.count), error);
        
        for (XMModelClass *m in selectModels) {
            NSLog(@"---%@---", @(m.i));
        }
    }];
}
- (IBAction)findRang:(id)sender {
    XMWhereTool *tool = [[XMWhereTool alloc] init];
    tool.between(@"i", @30, @75);
    
    [XMDataBaseManager selectWithClass:XMModelClass.class whereTool:tool completed:^(NSArray * _Nullable selectModels, NSError * _Nullable error) {
        NSLog(@"findAllData --   %@      ----error- %@", @(selectModels.count), error);
        
        for (XMModelClass *m in selectModels) {
            NSLog(@"---%@---", @(m.i));
        }
    }];
}
- (IBAction)customFind:(id)sender {
    XMWhereTool * tool = [XMWhereTool new];
    tool.expr(@"i", @">", @(90));
    [XMDataBaseManager selectWithClass:XMModelClass.class whereTool:tool completed:^(NSArray * _Nullable selectModels, NSError * _Nullable error) {
        NSLog(@"findRang   %@      ----error- %@", @(selectModels.count), error);
        for (XMModelClass *m in selectModels) {
            NSLog(@"---%d---", m.i);
        }
    }];
}
- (IBAction)emptyTable:(id)sender {
    [XMDataBaseManager deleteWithClass:XMModelClass.class whereTool:nil completed:^(NSError * _Nullable error) {
        NSLog(@"清空表%@", error);
    }];
    
}
- (IBAction)deleteTable:(id)sender {
    [XMDataBaseManager dropTableWithClass:XMModelClass.class completed:^(NSError * _Nullable error) {
        NSLog(@"deleteTable  %@", error);
    }];
}
- (IBAction)deletedataBase:(id)sender {
    [XMDataBaseManager deleteDBWithClass:XMModelClass.class completed:^(NSError * _Nullable error) {
        NSLog(@"deletedataBase %@", error);
    }];
}
- (IBAction)deleteDefaultDataBase:(id)sender {
    [XMDataBaseManager deleteDefaultDBWithCompleted:^(NSError * _Nullable error) {
        NSLog(@"deleteDefaultDataBase    %@", error);
    }];
}
- (IBAction)deleteColumn:(id)sender {
    [XMDataBaseManager deleteColumnWithClass:XMModelClass.class columnName:@"WHERE" completed:^(NSError * _Nullable error) {
        NSLog(@"deleteColumn ----%@", error);
    }];
}
- (IBAction)updateModel:(id)sender {
    if (_m) {
        _m.i = -111111111;
        _m.ull = NSIntegerMax;
        [XMDataBaseManager updateModel:_m completed:^(NSError * _Nullable error) {
            NSLog(@"updateModel ---%@", error);
        }];
    }
}
- (IBAction)queryStoreCount:(id)sender {
    [XMDataBaseManager queryStoreCountWithClass:XMModelClass.class Completed:^(NSError *error, NSUInteger count) {
        NSLog(@"queryStoreCount   %@ --- %@", error, @(count));
        
    }];
}


@end
