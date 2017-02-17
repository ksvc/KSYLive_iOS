//
//  KSYAVAudioSession.h
//  KSYStreamer
//
//
//  Created by pengbin on 10/15/15.
//  Copyright © 2015 ksyun. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "KSYTypeDef.h"

/** iOS的AVAudioSession 属性配置工具类
 
 1. 主要是保证推流时有采集和播放音频的权限 AVAudioSessionCategoryPlayAndRecord
 2. 将一些常用的AVAudioSession的配置项提取为属性, 方便设置
 3. 提供查询和修改当前音频采集设备相关的工具函数 比如查询是否有耳机
 */
@interface KSYAVAudioSession : NSObject

/**
 @abstract 是否打断其他后台的音乐播放 (默认为NO)
 @discussion 也可以理解为是否允许在其他后台音乐播放的同时进行采集
 @discussion YES:开始采集时，会打断其他的后台播放音乐，也会被其他音乐打断（采集过程中，启动其他音乐播放，音频采集被中止）
 @discussion NO: 可以与其他后台播放共存，相互之间不会被打断
 @discussion 参考 AVAudioSessionCategoryOptionMixWithOthers
 */
@property (nonatomic, assign) BOOL  bInterruptOtherAudio;

/**
 @abstract   启动采集后,是否从扬声器播放声音 (默认为YES)
 @discussion 启动声音采集后,iOS系统的行为是默认从听筒播放声音的
 @discussion 将该属性设为YES, 则改为默认从扬声器播放
 @discussion 参考 AVAudioSessionCategoryOptionDefaultToSpeaker
 */
@property (nonatomic, assign) BOOL bDefaultToSpeaker;

/**
 @abstract   是否启用蓝牙设备 (默认为YES)
 @discussion 参考 AVAudioSessionCategoryOptionAllowBluetooth
 */
@property (nonatomic, assign) BOOL bAllowBluetooth;

/**
 @abstract   设置声音采集需要的AUAudioSession的参数
 @discussion 按照属性的设置值刷新AUAudioSession的配置
 @discussion 参考 AUAudioSession
 */
- (void) setAVAudioSessionOption;

/**
 @abstract 本SDK使用的AVAudioSession的类别 (默认为AVAudioSessionCategoryPlayAndRecord)
 @discussion 用于指定推流过程中需要采集和播放音频的权限
 @warning 如无必要请勿修改
 */
@property (nonatomic, assign) NSString * AVAudioSessionCategory;

/**
 @abstract 检查当前AVAudioSession的类别是否与设置的AVAudioSessionCategory 一致
 @discussion AVAudioSession为公有的单例, APP中的其他SDK也可以修改
 @discussion 因此可能出现直播时,改为无录音权限的类别的情况, 通过此方法进行检查
 */
- (BOOL) checkCategory;

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
+ (BOOL)switchBluetoothInput:(BOOL)onOrOff;

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
 @abstract   当前使用的音频采集设备
 @discussion 当设置新值时, 如果修改成功, 重新查询为新值, 修改不成功值不变
 @discussion 参考 KSYMicType
 */
@property KSYMicType currentMicType;


@end
