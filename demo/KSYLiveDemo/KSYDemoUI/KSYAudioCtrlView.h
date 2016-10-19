//
//  KSYAudioCtrlView.h
//  KSYGPUStreamerDemo
//
//  Created by 孙健 on 16/6/24.
//  Copyright © 2016年 ksyun. All rights reserved.
//

#import "KSYUIView.h"
/**
 音频控制相关
 
 主要增加的功能如下:
 1. 混音
 2. 输入音频设备选择
 3. 混响类型选择
 4. 耳返
 */
@interface KSYAudioCtrlView : KSYUIView

/// 混音时, 麦克风的比例
@property KSYNameSlider * micVol;
/// 混音时, 背景音乐的比例
@property KSYNameSlider * bgmVol;
/// 混音时, 背景音乐是否混入
@property UISwitch      * bgmMix;

/// 纯音频推流开关 ( 纯音频 == 关闭视频 )
@property UISwitch      * swAudioOnly;
/// 静音推流开关 ( 发送音量为0的音频数据 )
@property UISwitch      * muteStream;

/// 音频输入设备选择(话筒, 有限耳麦 或 蓝牙耳麦)
@property UISegmentedControl  * micInput;
/// get value from UI ( micInput )
@property (atomic, readwrite) KSYMicType    micType;

/// 初始化mic选择控件
- (void) initMicInput;

/// 混响类型选择
@property UISegmentedControl  * reverbType;

/// 耳返 (本地直接播放采集到的声音) (请戴耳机之后再使用本功能)
@property UISwitch      * swPlayCapture;
/// 本地播放的音量
@property KSYNameSlider * playCapVol;

@end
