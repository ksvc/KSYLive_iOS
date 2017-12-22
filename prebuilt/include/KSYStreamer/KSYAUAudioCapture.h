//
//  KSYAUAudioCapture.h
//  KSYStreamer
//
//
//  Created by pengbin on 10/15/15.
//  Copyright © 2015 ksyun. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#define KSYAUReverb_FLAG 0x001
#define KSYAUDelay_FLAG 0x002
#define KSYAUPitchshift_FLAG 0x004

/*!
 * @abstract  音效类型
 */
typedef NS_ENUM(NSUInteger, KSYAudioEffectType){
    /// 初始化时状态为空闲
    KSYAudioEffectType_NONE = 0,
    /// 大叔
    KSYAudioEffectType_MALE,
    /// 萝莉
    KSYAudioEffectType_FEMALE,
    /// 宏大
    KSYAudioEffectType_HEROIC,
    /// 机器人
    KSYAudioEffectType_ROBOT,
    /// 自定义
    KSYAudioEffectType_COUSTOM,
};


/*!
 * @abstract  噪声抑制等级
 */
typedef NS_ENUM(NSInteger, KSYAudioNoiseSuppress){
    /// 关闭
    KSYAudioNoiseSuppress_OFF = -1,
    /// 温和
    KSYAudioNoiseSuppress_LOW = 0,
    /// 中等
    KSYAudioNoiseSuppress_MEDIUM = 1,
    /// 激进
    KSYAudioNoiseSuppress_HIGH = 2,
    /// 非常激进
    KSYAudioNoiseSuppress_VERYHIGH = 3,
};

/** 音频采集模块
 
 1. 基于 AudioUnit 实现的低延时音频采集模块
 2. 支持对采集的语音添加混响音效 (目前提供了4种类型的混响场景)
 3. 支持将采集的声音低延时播放,帮助主播选择音效 (又称"耳返")
 4. 支持对采集的音频进行降噪处理
 5. 采集的声音通过回调函数提供出来
 6. 当启用噪声抑制功能时,输出音频数据的采样率为16K(重采样得到,与采集的采样率无关)
 */
@interface KSYAUAudioCapture : NSObject

/**
 指定采集音频的采样率

 @param sampleRate 指定的采样率 , 默认为44100Hz
 @return  采集设备实例
 @warning 请尽量使用默认的44100, 使用其他的采样率可能导致混响和变声等功能异常
 */
- (id) initWithSampleRate:(double)sampleRate;

/** Start Audio capturing
 @abstract  启动音频采集, 占据麦克风资源
 @return    是否启动采集成功
 */
- (BOOL)startCapture;

/** 停止音频采集, 释放麦克风资源
 */
- (void)stopCapture;

/** 暂停音频采集(仍然占用麦克风资源) 停止回调音频数据
 */
- (BOOL)pauseCapture;

/** 暂停音频采集(仍然占用麦克风资源), 回调静音音频数据
 */
- (BOOL)pauseWithMuteData;

/** 恢复正常音频采集和回调
 */
- (BOOL)resumeCapture;

/**
 @abstract 是否播放采集的声音 (又称"耳返")
 @warning 如果在没有插入耳机的情况下启动, 容易出现很刺耳的声音
 */
@property(nonatomic, assign) BOOL bPlayCapturedAudio;

/**
 @abstract 是否使用带回声消除的采集模块(默认为NO)
 @discussion 请在连麦开始时在设置此属性为YES, 连麦结束记得设置为NO
 @discussion 此属性为YES时, 启动采集一定会打断其他音乐播放
 */
@property(nonatomic, assign) BOOL enableVoiceProcess;

/**
 @abstract 噪声抑制处理的等级(默认为KSYAudioNoiseSuppress_OFF)
 @discussion 当启用噪声抑制处理后, 内部会进行输出音频数据的
 */
@property(nonatomic, assign) KSYAudioNoiseSuppress noiseSuppressionLevel;

/**
 @abstract 是否强制设置AVAudioSession的类别为PlayAndRecord(默认为YES)
 @discussion 此属性为YES时, 每次启动采集会将类别强制设置为AVAudioSessionCategoryPlayAndRecord
 @discussion 为了避免别APP中的其他SDK将AVAudioSession的类别修改为无法录音,导致无法采集到声音
 */
@property(nonatomic, assign) BOOL bForceAudioSessionCatogary;

/**
 @abstract  设置mic采集的声音音量
 @discussion 调整范围 0.0~1.0
 */
@property(nonatomic, assign) Float32 micVolume;

/** 最近一次输出的音频包的时间戳*/
@property(nonatomic, readonly) CMTime    outputPts;

/**
 @abstract 混响类型
 @discussion 目前提供了4种类型的混响场景, type和场景的对应关系如下
 
 - 0 关闭
 - 1 录音棚
 - 2 ktv
 - 3 小舞台
 - 4 演唱会
 */
@property(nonatomic, assign) int reverbType;

/**
 @abstract 音效类型
 @discussion  音效类型仅在enableVoiceProcess=NO时有效
 */
@property(nonatomic, assign) KSYAudioEffectType effectType;

/**
 @abstract   采集数据输出回调函数
 @discussion sampleBuffer 为采集到的音频数据
 @discussion 与pcmProcessingCallback两者只能二选一, 设置 audioProcessingCallback 会清空pcmProcessingCallback
 */
@property(nonatomic, copy) void(^audioProcessingCallback)(CMSampleBufferRef sampleBuffer);

/**
 @abstract   采集数据输出回调函数
 @discussion pData 和 len 为采集数据和长度 (目前只支持单声道, 只有pData[0]为有效数据指针 )
 @discussion 与audioProcessingCallback两者只能二选一, 设置 pcmProcessingCallback 会清空audioProcessingCallback
 */
@property(nonatomic, copy) void(^pcmProcessingCallback)(uint8_t** pData, int len, const AudioStreamBasicDescription* fmt, CMTime timeInfo);

/**
 @abstract 用户可以自定义播放的内容，直接把数据填入ioData
 @discussion ioData 目前只支持int16 的单声道数据
 */
@property(nonatomic, copy) void(^customPlayCallback)(AudioBufferList *ioData, UInt32 inumber);

/**
 @abstract   是否有耳机麦克风可用
 @return     是/否有耳机麦克风
 */
+ (BOOL)isHeadsetPluggedIn;

/**
 设备是否正在采集音频数据
 */
@property (nonatomic, readonly) BOOL isRunning;

/**
 @abstract 变调组合类型
 @discussion 目前提供了8种类型的变调场景, flag和变调组合类型的对应关系如下
 - 0 无组合
 - 1 reverb
 - 2 delay
 - 3 reverb+delay
 - 4 pitchShift
 - 5 reverb+pitchShift
 - 6 delay+pitchShift
 - 7 reverb+delay+pitchShift
 @warning 在设置effectTypeFlag时，请先将effectType设置成KSYAudioEffectType_COUSTOM模式，否则effectTypeFlag设置无法生效
 */
@property(nonatomic, assign) int effectTypeFlag;

/**
 @abstract  自定义混响参数接口
 @param     inValue 混响参数对应的值
 @param     inID 混响参数(0~6), 对应关系如下
 - 0 kReverb2Param_DryWetMix
 - 1 kReverb2Param_Gain
 - 2 kReverb2Param_MinDelayTime
 - 3 kReverb2Param_MaxDelayTime
 - 4 kReverb2Param_DecayTimeAt0Hz
 - 5 kReverb2Param_DecayTimeAtNyquist
 - 6 kReverb2Param_RandomizeReflections
 **/
- (void) setReverbParamID:(AudioUnitParameterID)inID
             withInValue:(AudioUnitParameterValue)inValue;

/**
 @abstract  自定义pitchShift参数接口
 @param     inValue pitchShift参数对应的值
 @param     inID pitchShift参数,对应关系如下
 - 0 kNewTimePitchParam_Rate
 - 1 kNewTimePitchParam_Pitch (SDK中变调主要是调这个参数)
 - 4 kNewTimePitchParam_Overlap
 - 6 kNewTimePitchParam_EnablePeakLocking
 **/
- (void) setPitchParamID:(AudioUnitParameterID)inID
              withInValue:(AudioUnitParameterValue)inValue;

/**
 @abstract  自定义delay参数接口
 @param     inValue delay参数对应的值
 @param     inID delay参数(0~3),对应关系如下
 - 0 kDelayParam_WetDryMix
 - 1 kDelayParam_DelayTime
 - 2 kDelayParam_Feedback
 - 3 kDelayParam_LopassCutoff
 **/
- (void) setDelayParamID:(AudioUnitParameterID)inID
             withInValue:(AudioUnitParameterValue)inValue;


@end
