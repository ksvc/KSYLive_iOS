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
    _lblAudioOnly = [self addLable:@"纯音频推流"];
    _swAudioOnly  = [self addSwitch:NO];
    _lblPlayCapture = [self addLable:@"耳返"];
    _swPlayCapture  = [self addSwitch:NO];
    _audioEchoCancelLabel = [self addLable:@"回声消除"];
    _swiauEchoCancelAudio = [self addSwitch:YES];
    return self;
}

- (void)layoutUI{
    [super layoutUI];
    self.btnH = 30;
    [self putRow3:_btn0
              and:_btn1
              and:_btn2];
    [self putRow1:_micmVol];
    [self putRow3:_lblAudioOnly
              and:_swAudioOnly
              and:nil];
    [self putRow3:_lblPlayCapture
              and:_swPlayCapture
              and:nil];
    [self putRow3:_audioEchoCancelLabel
              and:_swiauEchoCancelAudio
              and:nil];
}
@end
