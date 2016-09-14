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
@property UILabel       * lblAudioOnly;
@property UISwitch      * swAudioOnly;
@property UILabel       * lblPlayCapture;
@property UISwitch      * swPlayCapture;

@property UISegmentedControl  * liveSceneSeg;
@property UISegmentedControl  * vEncPerfSeg;

@property (nonatomic, readonly) KSYLiveScene liveScene;
@property (nonatomic, readonly) KSYVideoEncodePerformance  vEncPerf;

@end
