//
//  KSYFileSelector.m
//  KSYGPUStreamerDemo
//
//  Created by pengbin on 7/23/16.
//  Copyright © 2016 ksyun. All rights reserved.
//

#import "KSYFileSelector.h"
@interface KSYFileSelector(){
    NSString* _fullDir;
}

@end

@implementation KSYFileSelector


/**
 @abstract   初始化
 @param      dir 目标地址
 @param      suf 后缀列表, 比如: @[".mp3", ".aac"]
 */
- (id) initWithDir: (NSString *) dir
         andSuffix: (NSArray *) suf{
    if (( dir == nil)      ||
        ([dir length] == 0)||
        ([suf count]  == 0)){
        return nil;
    }
    self =[super init];
    _filesDir = dir;
    _suffixList = suf;
    [self reload];
    return self;
}

/**
 @abstract   重新载入
 @discussion 当目标目录和后缀列表有变动, 或者目录中文件有增减时可用与重新生成列表
 @discussion reload后, fileIdx 重置为0
 @return     NO: 1. 目标目录不存在, 2. 目标目录中没有满足条件的文件
 */
- (BOOL) reload{
    _fullDir = [NSHomeDirectory() stringByAppendingString:_filesDir];
    
    NSFileManager * fmgr = [NSFileManager defaultManager];
    NSArray * list = [fmgr contentsOfDirectoryAtPath:_fullDir
                                               error:nil];
    _fileList = @[];
    // filter all files
    for (NSString* f in list) {
        for (NSString* p in _suffixList) {
            if ( [f hasSuffix:p]){
                _fileList = [_fileList arrayByAddingObject:f];
                break;
            }
        }
    }
    _fileIdx = -1;
    NSLog(@"find %lu in %@", (unsigned long)[_fileList count], _filesDir);
    return [self selectFileWithType:KSYSelectType_NEXT];
}

/**
 @abstract   获取一个音频文件
*/
- (BOOL)selectFileWithType:(KSYSelectType)type{
    NSInteger cnt =[_fileList count];
    if (cnt == 0) { // no file
        _fileInfo = @"can't find any file";
        _filePath = nil;
        return NO;
    }
    if (type == KSYSelectType_NEXT) {
        //next
        _fileIdx = (_fileIdx+1)%cnt;
    }
    else if (type == KSYSelectType_RANDOM){
        //random
        _fileIdx = (NSInteger)(arc4random() % cnt);
    }
    else if (type == KSYSelectType_PREVIOUS){
        //previous
        _fileIdx = (_fileIdx+cnt-1)%cnt;
    }
    else {
        return NO;
    }
    NSString * name = _fileList[_fileIdx];
    _fileInfo = [NSString stringWithFormat:@" %@(%ld/%d)",name,(long)_fileIdx,(int)cnt];
    _filePath = [_fullDir stringByAppendingString:name];
    return YES;
}
@end
