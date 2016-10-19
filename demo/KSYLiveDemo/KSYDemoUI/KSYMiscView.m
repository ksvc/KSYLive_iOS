//
//  KSYFilterView.m
//  KSYGPUStreamerDemo
//
//  Created by 孙健 on 16/6/24.
//  Copyright © 2016年 ksyun. All rights reserved.
//
#import "KSYPresetCfgView.h"
#import "KSYMiscView.h"

@interface KSYMiscView() {
    UIButton * _curBtn;
    UILabel  * _lblScene;
    UILabel  * _lblPerf;
}

@end

@implementation KSYMiscView

- (id)init{
    self = [super init];
    _btn0  = [self addButton:@"str截图为文件"];
    _btn1  = [self addButton:@"str截图为UIImage"];
    _btn2  = [self addButton:@"filter截图"];
    _lblScene      = [self addLable:@"直播场景"];
    _liveSceneSeg  = [self addSegCtrlWithItems:@[ @"默认", @"秀场"]];
    _lblPerf       = [self addLable:@"编码性能"];
    _vEncPerfSeg   = [self addSegCtrlWithItems:@[ @"低功耗", @"均衡", @"高性能"]];
    return self;
}

- (void)layoutUI{
    [super layoutUI];
    self.btnH = 30;
    [self putRow3:_btn0
              and:_btn1
              and:_btn2];
    [self putLable:_lblScene
           andView:_liveSceneSeg];
    [self putLable:_lblPerf
           andView:_vEncPerfSeg];
}

@synthesize liveScene = _liveScene;
- (KSYLiveScene) liveScene{
    if (_liveSceneSeg.selectedSegmentIndex == 1){
        return KSYLiveScene_Showself;
    }
    else {
        return KSYLiveScene_Default;
    }
}
@synthesize vEncPerf =  _vEncPerf;
- (KSYVideoEncodePerformance) vEncPerf{
    if ( _vEncPerfSeg.selectedSegmentIndex == 0){
        return KSYVideoEncodePer_LowPower;
    }
    else if ( _vEncPerfSeg.selectedSegmentIndex == 1){
        return KSYVideoEncodePer_Balance;
    }
    else if ( _vEncPerfSeg.selectedSegmentIndex == 2){
        return KSYVideoEncodePer_HighPerformance;
    }
    else {
        return KSYVideoEncodePer_Balance;
    }
}
@end
