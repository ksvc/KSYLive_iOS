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

#pragma mark - KSYGPUCamera config

/**
 @abstract 收到通知事件时是否暂停采集 (默认为YES)
 @discussion 通知事件也包括下拉通知栏、上拉控制台和切后台
 @discussion YES: 类似事件发生时 视频主动暂停采集，音频继续采集
 @discussion NO: 下拉通知栏和上拉控制台发生时，音视频继续采集；但是切后台，视频暂停采集，音频继续采集
 @discussion UIApplicationWillResignActiveNotification
 */
@property BOOL  bPauseCaptureOnNotice;

/**
 @abstract 是否打断其他后台的音乐播放 (默认为YES)
 @discussion 也可以理解为是否允许在其他后台音乐播放的同时进行采集
 @discussion YES:开始采集时，会打断其他的后台播放音乐，也会被其他音乐打断（采集过程中，启动其他音乐播放，采集被中止）
 @discussion NO: 可以与其他后台播放共存，相互之间不会被打断
 @see AVAudioSessionCategoryOptionMixWithOthers
 */
@property BOOL  bInterruptOtherAudio;

/**
 @abstract   启动采集后,是否从扬声器播放声音 (默认为YES)
 @discussion 启动声音采集后,iOS系统的行为是默认从听筒播放声音的
 @discussion 将该属性设为YES, 则改为默认从扬声器播放
 @see AVAudioSessionCategoryOptionDefaultToSpeaker
 */
@property (nonatomic, assign) BOOL bDefaultToSpeaker;

/**
 @abstract   是否启用蓝牙设备 (默认为YES)
 @see AVAudioSessionCategoryOptionAllowBluetooth
 */
@property (nonatomic, assign) BOOL bAllowBluetooth;

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


/**
 @abstract   设置声音采集需要的AVAudioSession的参数
 @discussion 主要是保证音频采集需要的PlayAndRecord类型
 @see AVAudioSession
 */
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
