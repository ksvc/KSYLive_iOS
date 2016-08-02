//
//  KSYGPUBeautifyExtFilter.h
//  GPUImage
//
//  Created by yulin on 16/2/26.
//  Copyright © 2016年 ksyun. All rights reserved.
//

 /* KSYGPUBeautifyFilter_h */
#import "KSYGPUFilter.h"

@interface KSYGPUBeautifyExtFilter : KSYGPUFilter
{
    GLint paramsUniform, singleStepOffsetUniform;
};

/*
 @abstract 美颜的等级
 @discussion  1 ~ 5，逐级增强, 默认为3
 */

-(void)setBeautylevel:(int)level;

@property (readwrite, nonatomic) CGPoint singleStepOffset;
@property (readwrite, nonatomic) GPUVector4 params;

-(void) setTexelSize:(CGPoint)size;

@end