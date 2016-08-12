//
//  KSYFilterView.m
//  KSYGPUStreamerDemo
//
//  Created by 孙健 on 16/6/24.
//  Copyright © 2016年 ksyun. All rights reserved.
//
#import "KSYBlockDemoVC.h"

#import "KSYMiscView.h"

@interface KSYMiscView() {
    UIButton * _curBtn;
}

@end

@implementation KSYMiscView

- (id)init{
    self = [super init];
    _btn0  = [self addButton:@"str截图为文件"];
    _btn1  = [self addButton:@"str截图为UIImage"];
    _btn2  = [self addButton:@"filter截图"];
    _micmVol = [self addSliderName:@"耳返音量" From:0.0 To:1.0 Init:1.0];
    _micmMix = [self addSwitch:NO]; // default to NO
    _audioLabel = [self addLable:@"纯音频推流"];
    _swiAudio =[self addSwitch:NO];
    return self;
}

- (void)layoutUI{
    [super layoutUI];
    self.btnH = 30;
    
    [self putRow3:_btn0
              and:_btn1
              and:_btn2];
        
    [self putSlider:_micmVol
          andSwitch:_micmMix];
    
    [self putRow3:_audioLabel
              and:_swiAudio
              and:nil];
}

- (void) initMicmOutput {
    if([KSYMicMonitor isHeadsetPluggedIn]){
        _micmVol.slider.enabled = YES;
        [_micmMix setEnabled:YES];
    }
    else{
        _micmVol.slider.enabled = NO;
        [_micmMix setEnabled:NO];
    }
}

@end
