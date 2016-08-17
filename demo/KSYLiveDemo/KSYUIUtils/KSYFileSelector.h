//
//  KSYFileSelector.h
//  KSYGPUStreamerDemo
//
//  Created by pengbin on 7/23/16.
//  Copyright © 2016 ksyun. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, KSYSelectType){
    KSYSelectType_NEXT = 0,
    KSYSelectType_RANDOM,
    KSYSelectType_PREVIOUS
};
/** 文件选择工具
 在app的目录下选择特定文件用的工具类
 
 指定app的NSHomeDirectory下面的"yyy/xxx"为目标目录
 指定需要选择的文件后缀列表
 初始化时,得到将Documents/xxx目录下的所有后缀匹配的文件列表
 调用下个时,返回下一个文件的路径
 维护一个状态信息字符串,格式如下
 "文件名(index/满足条件的文件总数)"

 */
@interface KSYFileSelector : NSObject

#pragma mark - configs
//目标目录, 比如"Documents/bgms"
@property (atomic, copy) NSString* filesDir;

// 需要匹配的文件后缀列表
@property (atomic, copy) NSArray* suffixList;

#pragma mark - results
// 满足条件的文件列表
@property (atomic, readonly) NSArray* fileList;

// 当前选中的文件的路径(完整路径)
@property (atomic, readonly) NSString* filePath;

// 当前正在播放的音乐文件的索引
@property (atomic, readonly) NSInteger fileIdx;

// "文件名(index/满足条件的文件总数)"
@property (atomic, readonly) NSString* fileInfo;

#pragma mark - methods

/**
 @abstract   初始化
 @param      dir 目标地址
 @param      suf 后缀列表, 比如: @[".mp3", ".aac"]
 */
- (id) initWithDir: (NSString *) dir
         andSuffix: (NSArray *) suf;

/**
 @abstract   重新载入
 @discussion 当目标目录和后缀列表有变动, 或者目录中文件有增减时可用与重新生成列表
 @discussion reload后, fileIdx 重置为0
 @return     NO: 1. 目标目录不存在, 2. 目标目录中没有满足条件的文件
 */
- (BOOL) reload;

/**
 @abstract   获取一个文件
 */
- (BOOL) selectFileWithType:(KSYSelectType)type;
@end
