//
//  KSYAudioMixer.h
//  KSYStreamer
//
//
//  Created by pengbin on 10/15/15.
//  Copyright © 2015 ksy. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import "KSYTypeDef.h"
/**
 @abstract   播放背景音乐 提供混音接口
 */

@class KSYAudioMixer;

@interface KSYBgmPlayer : NSObject

/**
 @abstract   开始播放背景音乐
 @param      path 本地音乐的路径
 @param      loop 是否循环播放此音乐
 @return     是否能够开始播放
 */
- (BOOL) startPlayBgm:(NSString*) path
               isLoop:(BOOL) loop;
/**
 @abstract   停止播放背景音乐
 */
- (void) stopPlayBgm;
/**
 @abstract   暂停播放背景音乐
 */
- (void) pauseBgm;
/**
 @abstract   恢复播放背景音乐
 */
- (void) resumeBgm;

/**
 @abstract  耳返功能，注入mic音频
*/
- (BOOL)processMicAudioSampleBuffer:(CMSampleBufferRef)sampleBuffer;

/**
 @abstract   当背景音乐播放完成时，调用此回调函数
 @discussion 只有设置 loop为NO时才有效, 在开始播放前设置有效
 */
@property(nonatomic, copy) void(^bgmFinishBlock)(void);
/**
 @abstract   背景音乐的音量
@discussion  0.0~0.1
 */
@property (nonatomic, assign) double bgmVolume;

/**
 @abstract    播放状态
 */
@property (nonatomic, readonly) KSYBgmPlayerState bgmPlayerState;
/**
 @abstract    播放错误码
 @discuss     播放错误码具体内容可以参考AudioQueue的Apple文档。
 */
@property (nonatomic, readonly) OSStatus audioErrorCode;

/**
 @abstract    背景音的duration信息（总时长, 单位:秒）
 */
@property (nonatomic, readonly) float bgmDuration;

/**
 @abstract    背景音的已经播放长度 (单位:秒)
 @discuss     从0开始，最大为bgmDuration长度
 */
@property (nonatomic, readonly) float bgmPlayTime;

/**
 @abstract    音频的播放进度
 @discuss     取值从0.0~1.0，大小为bgmPlayTime/bgmDuration;
 */
@property (nonatomic, readonly) float bgmProcess;

/**
 @abstract    音频播放是否运行
 @discuss     音频是否输出到speaker播放
 */
@property (nonatomic, readonly) BOOL isRunning;

/**
 @abstract   音频数据输出回调
 @param      sampleBuffer 从音乐文件中解码得到的PCM数据
 
 @see CMSampleBufferRef
 */
@property(nonatomic, copy) void(^audioDataBlock)(CMSampleBufferRef sampleBuffer);


// Posted when audio state changes
FOUNDATION_EXPORT NSString *const KSYAudioStateDidChangeNotification NS_AVAILABLE_IOS(7_0);

@end
