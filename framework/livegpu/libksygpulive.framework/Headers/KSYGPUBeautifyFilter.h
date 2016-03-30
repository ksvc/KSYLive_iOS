//
//  KSYGPUBeautifyFilter.h
//  GPUImage
//
//  Created by yulin on 16/2/26.
//  Copyright © 2016年 ksyun. All rights reserved.
//

 /* KSYGPUBeautifyFilter_h */
@class  GPUImageFilter;

@interface KSYGPUBeautifyFilter : GPUImageFilter
{
    GLint paramsUniform, singleStepOffsetUniform;
    
};

-(void)setBeautylevel:(int)level;

@property (readwrite, nonatomic) CGPoint singleStepOffset;
@property (readwrite, nonatomic) GPUVector4 params;

-(void) setTexelSize:(CGPoint)size;

@end