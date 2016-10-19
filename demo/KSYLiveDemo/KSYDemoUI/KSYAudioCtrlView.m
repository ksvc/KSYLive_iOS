//
//  KSYAudioCtrlView.m
//  KSYGPUStreamerDemo
//
//  Created by 孙健 on 16/6/24.
//  Copyright © 2016年 ksyun. All rights reserved.
//

#import <GPUImage/GPUImage.h>
#import "KSYPresetCfgView.h"
#import "KSYAudioCtrlView.h"
#import "KSYNameSlider.h"
@interface KSYAudioCtrlView() {
    
}

@property UILabel       * lblPlayCapture;
@property UILabel       * lblAudioOnly;
@property UILabel       * lblMuteSt;
@property UILabel       * lblReverb;
@end
@implementation KSYAudioCtrlView

- (id)init{
    self = [super init];
    // 混音音量
    _micVol = [self addSliderName:@"麦克风音量" From:0.0 To:1.0 Init:1.0];
    _bgmVol = [self addSliderName:@"背景乐音量"  From:0.0 To:1.0 Init:0.5];
    _bgmMix = [self addSwitch:YES];

    _micInput = [self addSegCtrlWithItems:@[ @"内置mic", @"耳麦", @"蓝牙mic"]];
    [self initMicInput];
    
    _lblAudioOnly    = [self addLable:@"纯音频推流"]; // 关闭视频
    _swAudioOnly     = [self addSwitch:NO]; // 关闭视频
    _lblMuteSt       = [self addLable:@"静音推流"];
    _muteStream      = [self addSwitch:NO];
    
    _lblReverb  = [self addLable:@"混响"];
    _reverbType = [self addSegCtrlWithItems:@[@"关闭", @"录影棚",
                                              @"演唱会",@"KTV",@"小舞台"]];
    _lblPlayCapture = [self addLable:@"耳返"];
    _swPlayCapture  = [self addSwitch:NO];
    _playCapVol= [self addSliderName:@"耳返音量"  From:0.0 To:1.0 Init:0.5];
    return self;
}
- (void)layoutUI{
    [super layoutUI];
    self.btnH = 30;

    [self putRow1:_micVol];
    [self putSlider:_bgmVol
          andSwitch:_bgmMix];
    [self putRow1:_micInput];
    [self putRow:@[_lblAudioOnly,_swAudioOnly,
                   _lblMuteSt,_muteStream] ];
    [self putLable:_lblReverb andView:_reverbType];
    id nu = [NSNull null];
    [self putRow:@[nu,nu,_lblPlayCapture,_swPlayCapture]];
    [self putRow1:_playCapVol];
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
