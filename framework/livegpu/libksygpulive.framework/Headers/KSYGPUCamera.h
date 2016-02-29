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
#ifdef KSYGPUSTREAM_A_
#import "GPUImage.h"
#else
#import <GPUImage/GPUImage.h>
#endif

@class KSYStreamerBase;
@class KSYGPUStreamer;
/**
 A KSYGPUCamera that provides frames from either camera
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

#pragma mark - KSYStreamer config
/**
 @abstract   是否将视频数据送入streamer

 @see streamer
 */
@property BOOL  bStreamVideo;

/**
 @abstract   是否将音频数据送入streamer
 
 @see streamer
 */
@property BOOL  bStreamAudio;

/**
 @abstract   采集到的音频通过此target发送
 
 @see bStreamAudio
 */
- (void) setBaseAudioEncTarget:(KSYStreamerBase*) target;

/**
 @abstract   采集到的音频通过此target发送
 
 @see bStreamAudio
 */
- (void) setAudioEncTarget:(KSYGPUStreamer*) target;


#pragma mark - Torch
/**
 @abstract   当前采集设备是否支持闪光灯
 @return     YES / NO
 @discussion 通常只有后置摄像头支持闪光灯
 
 @see setTorchMode
 */
- (BOOL) isTorchSupported;

/**
 @abstract   开关闪光灯
 @discussion 切换闪光灯的开关状态 开 <--> 关
 
 @see setTorchMode
 */
- (void) toggleTorch;

/**
 @abstract   设置闪光灯
 @param      mode  AVCaptureTorchModeOn/Off
 @discussion 设置闪光灯的开关状态
 @discussion 开始预览后开始有效
 
 @see AVCaptureTorchMode
 */
- (void) setTorchMode: (AVCaptureTorchMode)mode;

@end