//
//  KSYGPUFilter.h
//  KSYStreamer
//
//  Created by ksyun on 16/6/1.
//  Copyright © 2016年 yiqian. All rights reserved.
//

#import <GPUImage/GPUImage.h>

/** KSY的滤镜基类
 
 1. 继承自GPUImageFilter的基本类
 2. 添加了重新载入shader的接口
 */
@interface KSYGPUFilter: GPUImageFilter {
}

/// 构造
- (instancetype)init;

/**
 @abstract   重新载入纹理shader的代码
 @param      fragmentShaderString 新的纹理shader的代码
 */
- (void)reload:(NSString *)fragmentShaderString;

@end
