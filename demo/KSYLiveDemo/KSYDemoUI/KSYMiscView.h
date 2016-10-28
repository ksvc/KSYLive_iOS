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

@property UISegmentedControl  * layerSeg;
@property KSYNameSlider       * alphaSl;

/// 直播场景配置
@property UISegmentedControl  * liveSceneSeg;
@property UISegmentedControl  * vEncPerfSeg;

@property (nonatomic, readonly) KSYLiveScene liveScene;
@property (nonatomic, readonly) KSYVideoEncodePerformance  vEncPerf;

@end
