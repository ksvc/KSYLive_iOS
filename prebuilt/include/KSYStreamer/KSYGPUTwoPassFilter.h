//
//  KSYGPUFilter.h
//  KSYStreamer
//
//  Created by ksyun on 16/6/24.
//  Copyright © 2016年 yiqian. All rights reserved.
//
#import <GPUImage/GPUImage.h>

/** two pass 滤镜
 */
@interface KSYGPUTwoPassFilter: GPUImageTwoPassTextureSamplingFilter
{
}

/**
 @abstract   reload
 @param      firstStageVertexShaderString   第一轮的顶点shader
 @param      firstStageFragmentShaderString 第一轮的纹理shader
 @param      secondStageVertexShaderString  第二轮的顶点shader
 @param      secondStageFragmentShaderString 第二轮的纹理shader
 */
- (void)reloadFirstStageVertexShaderFromString:(NSString *)firstStageVertexShaderString
            firstStageFragmentShaderFromString:(NSString *)firstStageFragmentShaderString
             secondStageVertexShaderFromString:(NSString *)secondStageVertexShaderString
           secondStageFragmentShaderFromString:(NSString *)secondStageFragmentShaderString;

@end
