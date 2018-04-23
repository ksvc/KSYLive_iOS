//
//  KSYGPUBeautifyFilter.h
//  GPUImage
//
//  Created by yulin on 16/2/26.
//  Copyright © 2016年 ksyun. All rights reserved.
//

 /* KSYGPUBeautifyFilter_h */
#import "KSYGPUFilter.h"

/** 增强美颜滤镜
 */
@interface KSYGPUBeautifyPlusFilter : KSYGPUFilter
{
    GLint paramsUniform, singleStepOffsetUniform;
    
};

/**
 @abstract 美颜的等级
 @param    level  1 ~ 5，逐级增强, 默认为3
 */
-(void)setBeautylevel:(int)level;

@end