//
//  KSYGPUPicInput.h
//  KSYStreamer
//
//  Created by yiqian on 1/30/16.
//  Copyright © 2016 yiqian. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <GPUImage/GPUImage.h>

/** GPU图像输输入
 
 * 将采集到的YUV/RGB数据上传到GPU, 传递给其他filter进行处理
 * 支持的颜色格式包括:
   - kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange: (NV12)
   - kCVPixelFormatType_420YpCbCr8BiPlanarFullRange:(NV12)
   - kCVPixelFormatType_420YpCbCr8Planar:(I420)
   - kCVPixelFormatType_420YpCbCr8PlanarFullRange:(I420)
   - kCVPixelFormatType_32BGRA:(BGRA)
 */
@interface KSYGPUPicInput : GPUImageOutput

/// Initialization and teardown
- (id)init;

/**
 @abstract 设置输入图像的像素格式
 @param    fmt 像素格式
 */
- (id)initWithFmt:(OSType)fmt;

/**
 @abstract   裁剪区域 将输入的图像按照区域裁剪出中间的一块
 @discussion cropRegion 标记了左上角的位置和宽高, 范围都是0.0 到1.0, 非法值无法设置成功
 */
@property(readwrite, nonatomic) CGRect cropRegion;

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

/**
 @abstract 输入图像数据
 @param    pData    图像数据每个分量的指针, 比如pData[0]为Y分量的指针
 @param    pixelFmt 图像数据类型, 必须与init时指定的格式一致
 @param    width    图像宽度
 @param    height   图像高度
 @param    strides  图像数据每个分量的行偏移, 比如 stride[0] 为Y分量的行偏移
 @param    timeInfo 时间信息
 */
- (void)processPixelData:(void**)  pData
                  format:(OSType)  pixelFmt
                   width:(size_t)  width
                  height:(size_t)  height
                  stride:(size_t*) strides
                    time:(CMTime)  timeInfo ;
@end

/** GPU图像输输入
 过期的类, 请使用KSYGPUPicInput
 */
@interface KSYGPUYUVInput : KSYGPUPicInput
@end
