//
//  KSYSQLite.h
//  KSYLiveDemo
//
//  Created by ksy on 16/4/13.
//  Copyright © 2016年 qyvideo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface KSYSQLite : NSObject

#pragma mark - 属性
#pragma mark 数据库引用，使用它进行数据库操作
@property (nonatomic) sqlite3 *database;
+ (KSYSQLite *)sharedInstance;
-(void)executeNonQuery:(NSString *)sql;
-(NSArray *)executeQuery:(NSString *)sql;
- (void)insertAddress:(NSString *)address;
- (NSArray *)getAddress;
@end
