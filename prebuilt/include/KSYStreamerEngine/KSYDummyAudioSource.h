//
//  KSYDummyAudioSource.h
//  KSYStreamer
//
//
//  Created by pengbin on 10/15/15.
//  Copyright © 2015 ksyun. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
/** 静音音频数据源
 
 和音频采集模块类型能够实时产生音频数据, 但是音量都为0
 主要用于真实音频采集需要被暂停时,用于持续产生音频数据避免中断
 */
@interface KSYDummyAudioSource : NSObject

/** 构造函数
 @param      asbd 输入的音频格式
 @return     新实例
 */
- (id) initWithAudioFmt:(AudioStreamBasicDescription) asbd;

/** 启动产生数据
 @return    是否启动成功
 @discussion 自动生成系统时间戳
 */
- (BOOL)start;

/** 启动产生数据
 @param     initPts 设置启动时间戳
 @return    是否启动采集成功
 @discussion 内部都会先将时间戳的timescale转为ns
 */
- (BOOL)startAt: (CMTime) initPts;

/** 停止产生数据 */
- (void)stop;

/**
 @abstract   静音音频数据输出回调函数
 @discussion sampleBuffer 生成的音频数据
 */
@property(nonatomic, copy) void(^audioProcessingCallback)(CMSampleBufferRef sampleBuffer);

/** format description for audio data
 * 默认PCM格式为: (Float32), 单声道, 44100Hz
 */
@property(nonatomic, assign) AudioStreamBasicDescription asbd;

/** 
 * 每次尝试产生的数据长度 (sample数, 默认为1024)
 * 实际每次产生的音频的数据长度不确定, 应该是在nbSample附近波动
 */
@property(nonatomic, assign) int    nbSample;

/** 当前是否正在工作 */
@property(nonatomic, readonly) BOOL   bRunning;

@end
