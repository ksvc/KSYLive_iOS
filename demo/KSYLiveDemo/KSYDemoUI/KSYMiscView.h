//
//  KSYFilterView.h
//  KSYGPUStreamerDemo
//
//  Created by 孙健 on 16/6/24.
//  Copyright © 2016年 ksyun. All rights reserved.
//

#import "KSYUIView.h"
@class KSYNameSlider;

@interface KSYMiscView : KSYUIView {
    
}

@property UIButton* btn0;
@property UIButton* btn1;
@property UIButton* btn2;
@property UIButton* btn3;
@property UIButton* btn4;
@property UIButton* btn5;

// 动态logo的
@property UIButton* btnAnimate;
@property UIButton* btnNext;
@property UILabel*  lblAnimate;
@property NSString* animatePath;

//显示拉流地址并获取二维码
@property UIButton *buttonPlayUrlAndQR;

@property UIButton *buttonAe;

@property UISwitch* swBypassRec; // 旁路录制
@property UILabel*  lblRecDur;   // 旁路录制的时长

@property UISegmentedControl  * layerSeg;
@property KSYNameSlider       * alphaSl;

/// 直播场景配置
@property UISegmentedControl  * liveSceneSeg;
/// 本地录制场景配置
@property UISegmentedControl  * recSceneSeg;
@property UISegmentedControl  * vEncPerfSeg;

@property (nonatomic, readonly) KSYLiveScene liveScene;
@property (nonatomic, readonly) KSYRecScene recScene;
@property (nonatomic, readwrite) KSYVideoEncodePerformance  vEncPerf;

@property KSYNameSlider       * autoReconnect;

@end
