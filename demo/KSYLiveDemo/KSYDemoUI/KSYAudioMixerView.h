//
//  KSYFilterView.h
//  KSYGPUStreamerDemo
//
//  Created by 孙健 on 16/6/24.
//  Copyright © 2016年 ksyun. All rights reserved.
//

#import "KSYUIView.h"

#if USING_DYNAMIC_FRAMEWORK
#import <libksygpulivedylib/libksygpulivedylib.h>
#import <libksygpulivedylib/libksygpuimage.h>
#else
#import <libksygpulive/libksygpulive.h>
#import <libksygpulive/libksygpuimage.h>
#endif

@class KSYNameSlider;

@interface KSYAudioMixerView : KSYUIView
@property UILabel * lblDesc;   // 说明
@property KSYNameSlider * micVol;
@property KSYNameSlider * bgmVol;
@property KSYNameSlider * pipVol;
@property UISwitch      * bgmMix;
@property UISwitch      * pipMix;

@property UISegmentedControl  * micInput;
@property UILabel       * lblMuteSt;
@property UISwitch      * muteStream;

// get value from UI ( micInput )
@property (atomic, readwrite) KSYMicType    micType;
// 初始化mic选择控件
- (void) initMicInput;
@end
