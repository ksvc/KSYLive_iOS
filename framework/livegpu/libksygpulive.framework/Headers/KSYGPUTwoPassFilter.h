//
//  KSYGPUFilter.h
//  KSYStreamer
//
//  Created by ksyun on 16/6/24.
//  Copyright © 2016年 yiqian. All rights reserved.
//

@class GPUImageTwoPassTextureSamplingFilter;

@interface KSYGPUTwoPassFilter: GPUImageTwoPassTextureSamplingFilter
{
}

-(NSString *)encodeFilterString:(NSString *)strString;

- (instancetype)init;

- (void)reloadFirstStageVertexShaderFromString:(NSString *)firstStageVertexShaderString firstStageFragmentShaderFromString:(NSString *)firstStageFragmentShaderString
    secondStageVertexShaderFromString:(NSString *)secondStageVertexShaderString secondStageFragmentShaderFromString:(NSString *)secondStageFragmentShaderString;

@end
