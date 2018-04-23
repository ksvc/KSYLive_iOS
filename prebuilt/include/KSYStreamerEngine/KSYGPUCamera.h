//
//  KSYGPUCamera.h
//  KSYStreamer
//
//  Created by yiqian on 1/30/16.
//  Copyright © 2016 yiqian. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <GPUImage/GPUImage.h>

/**
 基于 AVFoundation的 音视频采集模块
 
 * 通过回调将采集的音频和视频数据传出
 * 将摄像头和音频的常用操作进行封装
 * 注意: 同时使用AVFoundation的音视频采集, 可能无法使用后台采集的功能
 * 音频采集为可选项
 */
@interface KSYGPUCamera : GPUImageVideoCamera <AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate> {
    
}

#pragma mark - override

/** Begin a capture session
 
 See AVCaptureSession for acceptable values
 
 @param  sessionPreset Session preset to use
 @param  cameraPosition Camera to capture from
 @return nil 表明cameraPosition对应的sessionPreset不支持，初始化不成功
 */
- (id)initWithSessionPreset:(NSString *)sessionPreset cameraPosition:(AVCaptureDevicePosition)cameraPosition;

#pragma mark - Torch
/**
 @abstract   当前采集设备是否支持闪光灯
 @return     YES / NO
 @discussion 通常只有后置摄像头支持闪光灯
 */
- (BOOL) isTorchSupported;

/**
 @abstract   开关闪光灯
 @discussion 切换闪光灯的开关状态 开 <--> 关
 */
- (void) toggleTorch;

/**
 @abstract   设置闪光灯
 @param      mode  AVCaptureTorchModeOn/Off
 @discussion 设置闪光灯的开关状态
 @discussion 开始预览后开始有效
 @discussion 请参考 AVCaptureTorchMode
 */
- (void) setTorchMode: (AVCaptureTorchMode)mode;

/**
 @abstract  判断是否运行
  */
@property(readonly, nonatomic) BOOL isRunning;

#pragma mark - raw data
/**
 @abstract   音频处理回调接口
 @discussion sampleBuffer 原始采集到的音频数据
 @discussion 请注意本函数的执行时间，如果太长可能导致不可预知的问题@discussion 请参考 CMSampleBufferRef
 @discussion 请参考 CMSampleBufferRef
 */
@property(nonatomic, copy) void(^audioProcessingCallback)(CMSampleBufferRef sampleBuffer);

/**
 @abstract   视频处理回调接口
 @discussion sampleBuffer 原始采集到的视频数据
 @discussion 请注意本函数的执行时间，如果太长可能导致不可预知的问题
 @discussion 请参考 CMSampleBufferRef
 */
@property(nonatomic, copy) void(^videoProcessingCallback)(CMSampleBufferRef sampleBuffer);

/**
 @abstract   UIInterfaceOrientation 转 AVCaptureVideoOrientation
 @param      orien UI的朝向
 */
+ (AVCaptureVideoOrientation) getCapOrientation: (UIInterfaceOrientation) orien;
@end
