//
//  KSYFilterView.h
//  KSYGPUStreamerDemo
//
//  Created by 孙健 on 16/6/24.
//  Copyright © 2016年 ksyun. All rights reserved.
//

#import "KSYUIView.h"


@class KSYNameSlider;

@interface KSYAudioMixerView : KSYUIView

@property KSYNameSlider * micVol;
@property KSYNameSlider * bgmVol;
@property UISwitch      * bgmMix;

@property UISegmentedControl  * micInput;
@property UILabel             * lblMuteSt;
@property UISwitch            * muteStream;

// get value from UI ( micInput )
@property (atomic, readwrite) KSYMicType    micType;
// 初始化mic选择控件
- (void) initMicInput;
@end
