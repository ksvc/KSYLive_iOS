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
 @abstract   音频处理回调接口
 @discussion sampleBuffer 经过filter处理后的音频数据
 @discussion 请注意本函数的执行时间，如果太长可能导致不可预知的问题
 @discussion 请参考 CMSampleBufferRef
 */
@property(nonatomic, copy) void(^audioProcessingCallback)(CMSampleBufferRef sampleBuffer);

@end
