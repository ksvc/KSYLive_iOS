//
//  KSYAQPlayer.h
//  KSYStreamer
//
//
//  Created by pengbin on 10/15/17.
//  Copyright © 2015 ksyun. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>
#import "KSYTypeDef.h"

/** 基于AudioQueue的音乐播放器
 
    * 提供声音播放的功能
    * 通过回调拉取新的数据
    * 提供音量和音调调节功能
    * 能将播放后的音频数据通过回调送出 (回调的数据为音效处理之后的数据)
 */
@interface KSYAQPlayer : NSObject

#pragma mark - player control
/**
 @abstract   开始播放
 @param      fmt, 后续送入的音频数据的格式
 @return     是否能够开始播放
 */
- (BOOL) play:(AudioStreamBasicDescription*)fmt;

/** 停止播放背景音乐 */
- (void) stop;
/** 暂停播放背景音乐 */
- (void) pause;
/** 恢复播放背景音乐 */
- (void) resume;

/**
 @abstract   播放音量
 @discussion 调整范围 0.0~1.0, 默认为1
 */
@property (nonatomic, assign) double volume;
/**
 @abstract   播放声音的音调
 @discussion 调整范围 [-24.0 ~ 24.0], 默认为0.01, 单位为半音
 @discussion 0.01 为1度, 1.0为一个半音, 12个半音为1个八度
 */
@property (nonatomic, assign) double pitch;

/**
 @abstract   播放速度
 @discussion 调整范围 0.5~2.0, 默认为1
 */
@property (nonatomic, assign) double playRate;

/**
 @abstract   输入的音频格式
 @discussion 每次输入音频格式可能变化时,请重新调用play: 方法
 */
@property (nonatomic, readonly) AudioStreamBasicDescription inFmt;

/**
 @abstract   回调输出的音频格式
 */
@property (nonatomic, readonly) AudioStreamBasicDescription outFmt;

/**
 @abstract   背景音乐播放静音
 @discussion 仅仅静音播放, 不影响回调的音频数据
 */
@property (nonatomic, assign) BOOL mute;

#pragma mark - callbacks
/**
 @abstract   音频数据输入回调
 @discussion buf 送入的音频数据
 */
@property(nonatomic, copy) BOOL (^pullDataCB)(AudioQueueBufferRef buf);

/**
 @abstract   音频数据输出回调
 @discussion pData 回调输出的数据指针
 @discussion len sample数
 @discussion fmt 数据的格式
 @discussion pts 目前没有时间戳输出
 */
@property(nonatomic, copy) BOOL (^putDataCB)(uint8_t** pData, int len, const AudioStreamBasicDescription* fmt, CMTime pts);

#pragma mark - player state

/**
 @abstract    音频播放是否运行
 @discussion  音频是否输出到speaker播放
 */
@property (nonatomic, readonly) BOOL isRunning;

/**
 @abstract    音频播放是否暂停
 @discussion  通过 pause/resume 改变状态
 */
@property (nonatomic, readonly) BOOL isPaused;

/**
 @abstract    播放错误码
 @discussion  播放错误码具体内容可以参考AudioQueue的Apple文档。
 */
@property (nonatomic, readonly) OSStatus audioErrorCode;


@end
