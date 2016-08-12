//
//  KSYGPUYUVInput.h
//  KSYStreamer
//
//  Created by yiqian on 1/30/16.
//  Copyright © 2016 yiqian. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>

@class GPUImageOutput;


/** GPU图像输输入
 
 将采集到的YUV数据上传到GPU, 传递给其他filter进行处理
 
 * 本模块含有一个GPUImageOutput的接口, 向其他filter提供纹理
 
 */
@interface KSYGPUYUVInput : GPUImageOutput {
    dispatch_semaphore_t dataUpdateSemaphore;
    
    GPUImageRotationMode outputRotation, internalRotation;
    GLuint luminanceTexture, chrominanceTexture;
}

// Initialization and teardown
- (id)init;

/**
 @abstract 输入图像数据
 @param    sampleBuffer 图像数据和时间信息
 */
- (void)processSampleBuffer:(CMSampleBufferRef)sampleBuffer;

/**
 @abstract 输入图像数据
 @param    pixelBuffer 图像数据
 @param    timeInfo    时间信息
 */
- (void)processPixelBuffer:(CVPixelBufferRef)pixelBuffer
                      time:(CMTime)timeInfo;
@end
