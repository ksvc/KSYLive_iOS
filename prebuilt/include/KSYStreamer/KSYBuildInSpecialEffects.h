//
//  KSYBuildInSpecialEffects.h
//  GPUImage
//
//  Created by gene on 16/9/19.
//  Copyright © 2016年 Brad Larson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KSYSpecialEffects.h"
/** KSY 特效滤镜
 
 内置滤镜需要资源文件支持(KSYResource.bundle)
 目前内置了如下6中特效:
 1 小清新
 2 靓丽
 3 甜美可人
 4 怀旧
 5 蓝调
 6 老照片
 */
@interface KSYBuildInSpecialEffects : KSYSpecialEffects

#pragma mark - internal special effects
/**
 @abstract   初始化并指定 1~6 的index来创建对应效果
 @param      idx 效果的索引 (非法值无效)
 */
- (id)initWithIdx:(NSInteger)idx;

/**
 @abstract   指定 1~6 的index来创建对应效果
 @param      idx 效果的索引 (非法值无效)
 */
-(void)setSpecialEffectsIdx:(NSInteger)idx;


@end
