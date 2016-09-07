
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "KSYTypeDef.h"

/** 音频采集模块
 
 1. 基于 AUdioUnit 实现的低延时音频采集模块
 2. 能够对采集的语音添加混响音效 (目前提供了4种类型的混响场景)
 3. 能够将采集的声音低延时播放,帮助主播选择音效 (又称"耳返")
 4. 采集的声音通过回调函数提供出来
 注意: 当使用本模块时, 需要禁用KSYGPUCamera中的音频采集

 */
@interface KSYAUAudioCapture : NSObject

#pragma mark - KSYAUAudioCapture config
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

/**
 @abstract   设置声音采集需要的AUAudioSession的参数
 @discussion 主要是保证音频采集需要的PlayAndRecord类型
 @see AUAudioSession
 */
- (void) setAUAudioSessionOption;

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
 @abstract  查询当前是否有耳机(包括蓝牙耳机)
 */
+ (BOOL) isHeadsetPluggedIn;

/**
 @abstract   当前使用的音频设备
 @discussion 当设置新值时, 如果修改成功, 重新查询为新值,修改不成功值不变
 @see        KSYMicType
 */
@property KSYMicType currentMicType;


@end
