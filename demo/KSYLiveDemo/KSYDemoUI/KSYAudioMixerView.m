//
//  KSYFilterView.m
//  KSYGPUStreamerDemo
//
//  Created by 孙健 on 16/6/24.
//  Copyright © 2016年 ksyun. All rights reserved.
//

#import <GPUImage/GPUImage.h>

#if USING_DYNAMIC_FRAMEWORK
#import <libksygpulivedylib/libksygpulivedylib.h>
#import <libksygpulivedylib/libksygpuimage.h>
#else
#import <libksygpulive/libksygpuimage.h>
#endif

#import "KSYAudioMixerView.h"
#import "KSYNameSlider.h"

@implementation KSYAudioMixerView

- (id)init{
    self = [super init];
    //_lblTitle = [self addLable:@"混音相关设置"];;  // 标题
    //_lblTitle.textAlignment = NSTextAlignmentCenter;
    _micVol = [self addSliderName:@"麦克风音量" From:0.0 To:1.0 Init:1.0];
    _bgmVol = [self addSliderName:@"背景乐音量"  From:0.0 To:1.0 Init:0.5];

    _bgmMix = [self addSwitch:YES];

    _micInput = [self addSegCtrlWithItems:@[ @"内置mic", @"耳麦", @"蓝牙mic"]];
    [self initMicInput];
    _lblMuteSt       = [self addLable:@"静音推流"];
    _muteStream      = [self addSwitch:NO];
    return self;
}
- (void)layoutUI{
    [super layoutUI];
    self.btnH = 30;

    [self putRow1:_micVol];
    [self putSlider:_bgmVol
          andSwitch:_bgmMix];
    
    [self putRow1:_micInput];
    id nu = [NSNull null];
    [self putRow:@[nu,nu, _lblMuteSt,_muteStream] ];
}
- (void) initMicInput {
    BOOL bHS = [KSYAVAudioSession isHeadsetInputAvaible];
    BOOL bBT = [KSYAVAudioSession isBluetoothInputAvaible];
    [_micInput setEnabled:YES forSegmentAtIndex:1];
    [_micInput setEnabled:YES forSegmentAtIndex:2];
    if (!bHS){
        [_micInput setEnabled:NO forSegmentAtIndex:1];
    }
    if (!bBT){
        [_micInput setEnabled:NO forSegmentAtIndex:2];
    }
}

static int micType2Int( KSYMicType t) {
    if (t == KSYMicType_builtinMic){
        return 0;
    }
    else if (t == KSYMicType_headsetMic){
        return 1;
    }
    else if (t == KSYMicType_bluetoothMic){
        return 2;
    }
    return 0;
}

static KSYMicType int2MicType( int t) {
    if (t == 0){
        return KSYMicType_builtinMic;
    }
    else if (t == 1){
        return KSYMicType_headsetMic;
    }
    else if (t == 2){
        return KSYMicType_bluetoothMic;
    }
    return KSYMicType_builtinMic;
}

@synthesize  micType = _micType;
- (void) setMicType:(KSYMicType)micType{
    _micType = micType;
    _micInput.selectedSegmentIndex = micType2Int(micType);
}

- (KSYMicType) micType{
    _micType = int2MicType((int)_micInput.selectedSegmentIndex);
    return _micType;
}
@end
