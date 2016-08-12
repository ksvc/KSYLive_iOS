//
//  KSYFilterView.h
//  KSYGPUStreamerDemo
//
//  Created by 孙健 on 16/6/24.
//  Copyright © 2016年 ksyun. All rights reserved.
//

#import "KSYUIView.h"
@class KSYNameSlider;
@class GPUImageFilter;

@interface KSYMiscView : KSYUIView {
    
}

@property UIButton* btn0;
@property UIButton* btn1;
@property UIButton* btn2;
@property UIButton* btn3;
@property UIButton* btn4;

@property KSYNameSlider * micmVol;
@property UISwitch      * micmMix;
@property UILabel       * audioLabel;
@property UISwitch      * swiAudio;
// 初始化micm选择控件
- (void) initMicmOutput;

@end
