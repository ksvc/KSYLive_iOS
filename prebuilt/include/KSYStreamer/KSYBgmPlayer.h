//
//  KSYBgmPlayer.h
//  KSYStreamer
//
//
//  Created by pengbin on 10/15/15.
//  Copyright © 2015 ksyun. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>
#import "KSYTypeDef.h"

@class KSYAudioMixer;

/** 背景音乐播放器
 
    提供背景音乐播放的功能, 并能将被播放的音频数据通过回调送出
 */
@interface KSYBgmPlayer : NSObject

#pragma mark - player control
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
 @abstract   背景音乐的音量
 @discussion 调整范围 0.0~1.0
 @discussion 仅仅调整播放的音量, 不影响回调的音频数据
 */
@property (nonatomic, assign) double bgmVolume;

/**
 @abstract   背景音乐播放静音
 @discussion 仅仅静音播放, 不影响回调的音频数据
 */
@property (nonatomic, assign) BOOL bMutBgmPlay;

#pragma mark - callbacks
/**
 @abstract   音频数据输出回调
 @discussion sampleBuffer 从音乐文件中解码得到的PCM数据
 */
@property(nonatomic, copy) void(^audioDataBlock)(CMSampleBufferRef sampleBuffer);

/**
 @abstract   当背景音乐播放完成时，调用此回调函数
 @discussion 只有设置 loop为NO时才有效, 在开始播放前设置有效
 */
@property(nonatomic, copy) void(^bgmFinishBlock)(void);

#pragma mark - player state
/**
 @abstract    背景音的duration信息（总时长, 单位:秒）
 */
@property (nonatomic, readonly) float bgmDuration;

/**
 @abstract    背景音的已经播放长度 (单位:秒)
 @discussion  从0开始，最大为bgmDuration长度
 */
@property (nonatomic, readonly) float bgmPlayTime;

/**
 @abstract    音频的播放进度
 @discussion  取值从0.0~1.0，大小为bgmPlayTime/bgmDuration;
 */
@property (nonatomic, readonly) float bgmProcess;

/**
 @abstract    音频播放是否运行
 @discussion  音频是否输出到speaker播放
 */
@property (nonatomic, readonly) BOOL isRunning;

/**
 @abstract    播放错误码
 @discussion  播放错误码具体内容可以参考AudioQueue的Apple文档。
 */
@property (nonatomic, readonly) OSStatus audioErrorCode;

/**
 @abstract    播放状态
 */
@property (nonatomic, readonly) KSYBgmPlayerState bgmPlayerState;
/**
 @abstract    单曲循环
 */
@property (nonatomic, assign) BOOL bLoop;
/**
 @abstract   获取状态对应的字符串
 @param      stat 状态
 */
- (NSString*) getBgmStateName : (KSYBgmPlayerState) stat;
/**
 @abstract   获取当前状态对应的字符串
 */
- (NSString*) getCurBgmStateName;

// Posted when audio state changes
FOUNDATION_EXPORT NSString *const KSYAudioStateDidChangeNotification NS_AVAILABLE_IOS(7_0);

@end
