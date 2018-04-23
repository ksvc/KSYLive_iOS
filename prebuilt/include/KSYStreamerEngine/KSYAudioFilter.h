//
//  KSYAudioFilter.h
//  KSYStreamer
//
//
//  Created by shixuemei on 06/15/17.
//  Copyright © 2015 ksy. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#pragma mark - audio filter

/** 音频filter
 1. 使用filter对音频进行处理，目前支持功能包括：
  * 变速 - speed
 2. 输出格式与输入格式相同
 3. 建议放在KSYAudioMixer前使用
 */
@interface KSYAudioFilter : NSObject

/**
 @abstract   速率，默认值是1.0
 @discussion 取值范围从0.5 - 2.0
 @discussion 如果配置速率不在有效范围，则设置不生效
 */
@property(nonatomic, assign) float speed;

/**
 @abstract  输入音频PCM
 @param     sampleBuffer 音频数据
 */
- (void)processAudioSampleBuffer:(CMSampleBufferRef)inSampleBuffer;

/**
 @abstract  输入音频PCM
 @param     pData 数据地址
 @param     nbSample 采样点个数
 @param     fmt 输入数据的音频格式
 @param     pts 输入数据的时间戳
 */
- (void)processAudioData:(uint8_t**)pData
                nbSample:(int)nbSample
              withFormat:(const AudioStreamBasicDescription*)fmt
                timeinfo:(CMTime)pts;

/**
 @abstract   音频处理回调接口
 @discussion sampleBuffer 经过filter处理后的音频数据
 @discussion 请注意本函数的执行时间，如果太长可能导致不可预知的问题
 @discussion 请参考 CMSampleBufferRef
 @discussion 与pcmProcessingCallback两者只能二选一, 设置 audioProcessingCallback 会清空 pcmProcessingCallback
 */
@property(nonatomic, copy) void(^audioProcessingCallback)(CMSampleBufferRef sampleBuffer);

/**
 @abstract   音频处理回调接口
 @discussion pData 为数据指针 (双通道时, 数据为交织格式), 仅pData[0] 有效
 @discussion nbSample 为数据长度, 单位为sample (bytes / sizeof(sample)/channels)
 @discussion 请注意本函数的执行时间，如果太长可能导致不可预知的问题
 @discussion 与audioProcessingCallback两者只能二选一, 设置 pcmProcessingCallback 会清空audioProcessingCallback
 */
@property(nonatomic, copy) void(^pcmProcessingCallback)(uint8_t** pData, int nbSample, CMTime pts);

@end
