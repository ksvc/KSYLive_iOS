//
//  KSYDBCreater.m
//  KSYPlayerDemo
//
//  Created by ksy on 16/4/25.
//  Copyright © 2016年 kingsoft. All rights reserved.
//

#import "KSYDBCreater.h"
#import "KSYSQLite.h"


@implementation KSYDBCreater

+ (void)initDatabase{
    NSString *key=@"IsCreatedDb";
    NSUserDefaults *defaults=[[NSUserDefaults alloc]init];
    if ([[defaults valueForKey:key] intValue]!=1) {
        [self createUrlTable];
        [defaults setValue:@1 forKey:key];
    }
}

+ (void)createUrlTable{
    NSString *sql=@"CREATE TABLE Address (address text)";
    [[KSYSQLite sharedInstance]executeNonQuery:sql];
}
@end

