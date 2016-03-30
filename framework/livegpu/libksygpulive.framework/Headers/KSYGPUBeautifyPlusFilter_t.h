//
//  KSYGPUBeautifyFilter.h
//  GPUImage
//
//  Created by yulin on 16/2/26.
//  Copyright © 2016年 ksyun. All rights reserved.
//

 /* KSYGPUBeautifyFilter_h */
@class  GPUImageFilter;

@interface KSYGPUBeautifyPlusFilter_t : GPUImageFilter
{
    GLint paramsUniform, singleStepOffsetUniform;
    
};

/*
 @abstract 美颜的等级
 @discussion  1 ~ 5，逐级增强, 默认为3
 */
-(void)setBeautylevel:(int)level;


@end