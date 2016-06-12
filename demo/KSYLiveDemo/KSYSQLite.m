//
//  KSYSQLite.m
//  KSYLiveDemo
//
//  Created by ksy on 16/4/13.
//  Copyright © 2016年 qyvideo. All rights reserved.
//

#import "KSYSQLite.h"
#ifndef kDatabaseName

#define kDatabaseName @"myDatabase.db"

#endif


@implementation KSYSQLite
+ (KSYSQLite *)sharedInstance{
    static KSYSQLite *ksysqlite = nil;
    static dispatch_once_t instance;
    dispatch_once(&instance, ^{
        ksysqlite = [[self alloc]init];
    });
    return ksysqlite;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        //打开数据库
        [self openDb:kDatabaseName];
    }
    return self;
}
- (void)openDb:(NSString *)dataName{
    //取得数据库保存路径，通常保存沙盒Documents目录
    NSString *directory=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *filePath=[directory stringByAppendingPathComponent:dataName];
    //如果有数据库则直接打开，否则创建并打开（注意filePath是ObjC中的字符串，需要转化为C语言字符串类型）
    if (SQLITE_OK ==sqlite3_open(filePath.UTF8String, &_database)) {
        return ;
    }else{

        NSLog(@"open sqlite dadabase fail!");
    }
}
-(void)executeNonQuery:(NSString *)sql{
    char *error;
    //单步执行sql语句，用于插入、修改、删除
    if (SQLITE_OK == sqlite3_exec(_database, sql.UTF8String, NULL, NULL,&error)) {
        
        return;

    }else{
        NSLog(@"table creat error %s",error);
        sqlite3_free(error);//每次使用完毕清空error字符串，提供下次使用
    }
}

-(NSArray *)executeQuery:(NSString *)sql{
    NSMutableArray *rows=[NSMutableArray array];//数据行
    
    //评估语法正确性
    sqlite3_stmt *stmt;
    //检查语法正确性
    if (SQLITE_OK==sqlite3_prepare_v2(_database, sql.UTF8String, -1, &stmt, NULL)) {
        //单步执行sql语句
        while (SQLITE_ROW==sqlite3_step(stmt)) {
            int columnCount= sqlite3_column_count(stmt);
            NSMutableDictionary *dic=[NSMutableDictionary dictionary];
            for (int i=0; i<columnCount; i++) {
                const char *name= sqlite3_column_name(stmt, i);//取得列名
                const unsigned char *value= sqlite3_column_text(stmt, i);//取得某列的值
                dic[[NSString stringWithUTF8String:name]]=[NSString stringWithUTF8String:(const char *)value];
            }
            [rows addObject:dic];
        }
    }
    
    //释放句柄
    sqlite3_finalize(stmt);
    
    return rows;
}
- (void)insertAddress:(NSString *)addr{
    NSString *sql=[NSString stringWithFormat:@"INSERT INTO Address (address) VALUES('%@')",addr];
    NSArray *array = [self getAddress];
    for(NSDictionary *dic in array){
        NSString *address = [dic objectForKey:@"address"];
        if ([address isEqualToString:addr]) {
            return;
        }
    }
    [self executeNonQuery:sql];
}
- (NSArray *)getAddress{
    NSString *sql = @"SELECT * FROM Address";
    NSArray *array = [self executeQuery:sql];
    return array;
}
@end
