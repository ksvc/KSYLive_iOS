//
//  KSYBeautifyFaceFilter.h
//  GPUImage
//
//  Created by gene on 16/8/22.
//  Copyright © 2016年 Brad Larson. All rights reserved.
//
#import <GPUImage/GPUImage.h>

/** 金山云美颜滤镜
 
 磨皮 + 美白 + [红润特效]的美颜滤镜
 其中 红润特效为可选效果. 
 如果启用, 需要依赖外部的KSYGPUResource.bundle中的资源文件
 详细使用方法参见demo
 */
@interface KSYBeautifyFaceFilter : GPUImageFilterGroup

/// init
- (id)init;

/// show version of this filter
+(void) showVersion;

/// grindRatio ranges from 0.0 to 1.0, with 0.87 as the normal level
@property(readwrite,nonatomic) CGFloat grindRatio;


/// whitenRatio ranges from 0.0 to 1.0, with 0.6 as the normal level
@property(readwrite,nonatomic) CGFloat whitenRatio;

#pragma mark
/**
 @abstract   初始化输入的红润特效素材图像
 @param      img 红润特效素材文件 (比如KSYGPUResource.bundle中的资源文件)
 @return     构造出来的滤镜
 */
- (id)initWithRubbyMaterial:(UIImage *)img;

/// ruddyRatio ranges from 0.0 to 1.0, with 1.0 as the normal level, need to use the initWithRubbyMaterial
@property(readwrite,nonatomic) CGFloat ruddyRatio;
@end


