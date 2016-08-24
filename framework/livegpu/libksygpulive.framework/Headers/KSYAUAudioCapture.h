
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

/** 音频采集模块
 
 1. 基于 AUdioUnit 实现的低延时音频采集模块
 2. 能够对采集的语音添加混响音效 (目前提供了4种类型的混响场景)
 3. 能够将采集的声音低延时播放,帮助主播选择音效 (又称"耳返")
 4. 采集的声音通过回调函数提供出来
 注意: 当使用本模块时, 需要禁用KSYGPUCamera中的音频采集

 */
@interface KSYAUAudioCapture : NSObject

/** Start Audio capturing
 @abstract  启动音频采集
 @return    是否启动采集成功
 */
- (BOOL)startCapture;

/** Start Audio capturing
 */
- (void)stopCapture;

/**
 @abstract 是否播放采集的声音 (又称"耳返")
 @warning 如果在没有插入耳机的情况下启动, 容易出现很刺耳的声音
 */
@property(nonatomic, assign) BOOL bPlayCapturedAudio;

/**
 @abstract  设置mic采集的声音音量
 */
@property(nonatomic, assign) Float32 micVolume;

/**
 @abstract 是否开启采集时的回声消除
 */
@property(nonatomic, assign) BOOL bEchoCancelAudio;

/**
 @abstract  查询当前是否有耳机
 */
+ (BOOL) isHeadsetPluggedIn;

/**
 目前提供了4种类型的混响场景， type和场景的对应关系如下：
 * 0 关闭
 * 1 录音棚
 * 2 KTV
 * 3 小舞台
 * 4 演唱会
 */
@property(nonatomic, assign) int reverbType;

/**
 @abstract   采集数据输出回调函数
 @param      sampleBuffer 采集到的音频数据
 */
@property(nonatomic, copy) void(^audioProcessingCallback)(CMSampleBufferRef sampleBuffer);

@end
