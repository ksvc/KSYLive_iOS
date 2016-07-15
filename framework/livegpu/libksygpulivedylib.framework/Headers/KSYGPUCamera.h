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
 @abstract 是否打断其他后台的音乐播放
 @discussion 也可以理解为是否允许在其他后台音乐播放的同时进行采集
 @discussion YES:开始采集时，会打断其他的后台播放音乐，也会被其他音乐打断（采集过程中，启动其他音乐播放，采集被中止）
 @discussion NO: 可以与其他后台播放共存，相互之间不会被打断
 @discussion 默认为YES
 @see AVAudioSessionCategoryOptionMixWithOthers
 */
@property BOOL  bInterruptOtherAudio;

/**
 @abstract   是否将视频数据送入streamer (默认为NO)

 @see streamer
 */
@property BOOL  bStreamVideo;

/**
 @abstract   是否将音频数据送入streamer (默认为YES)
 
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
- (void) setAVAudioSessionOption;

/**
 @abstract  判断是否运行
  */
@property(readonly, nonatomic) BOOL isRunning;

#pragma mark - raw data
/**
 @abstract   音频处理回调接口
 @param      sampleBuffer 原始采集到的音频数据
 @discussion 请注意本函数的执行时间，如果太长可能导致不可预知的问题
 
 @see CMSampleBufferRef
 */
@property(nonatomic, copy) void(^audioProcessingCallback)(CMSampleBufferRef sampleBuffer);

/**
 @abstract   视频处理回调接口
 @param      sampleBuffer 原始采集到的视频数据
 @discussion 请注意本函数的执行时间，如果太长可能导致不可预知的问题
 
 @see CMSampleBufferRef
 */
@property(nonatomic, copy) void(^videoProcessingCallback)(CMSampleBufferRef sampleBuffer);

#pragma mark - audio input ports
/**
 @abstract   是否有蓝牙麦克风可用
 @return     是/否有蓝牙麦克风可用
 */
+ (BOOL)isBluetoothInputAvaible;

/**
 @abstract   选择是否使用蓝牙麦克风
 @param      onOrOff : YES 使用蓝牙麦克风 NO
 @return     是/否有蓝牙麦克风可用
 */
- (BOOL)switchBluetoothInput:(BOOL)onOrOff;

/**
 @abstract   是否有耳机麦克风可用
 @return     是/否有耳机麦克风
 */
+ (BOOL)isHeadsetInputAvaible;

/**
 @abstract   当前使用的音频设备
 @discussion 当设置新值时, 如果修改成功, 重新查询为新值,修改不成功值不变
 @see        KSYMicType
 */
@property KSYMicType currentMicType;

@end
