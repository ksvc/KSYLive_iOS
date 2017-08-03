//
//  KSYPlayerAudioView.m
//
//  Created by 施雪梅 on 17/7/12.
//  Copyright © 2017年 ksyun. All rights reserved.
//

#import "KSYPlayerAudioView.h"

@interface KSYPlayerAudioView(){
    UILabel *_labelMute;
    UILabel *_labelAudioPan;                                         ///设置左右声道
}
@end

@implementation KSYPlayerAudioView

- (id)init{
    self = [super init];
    
    [self setupUI];
    return self;
}

- (void) setupUI {
    _labelMute = [self addLable:@"静音"];
    _switchMute = [self addSwitch:NO];
    
    _sliderVolume =  [self addSliderName:@"音量" From:0 To:200 Init:100];
    
    _labelAudioPan = [self addLable:@"立体声平衡"];
    _segAudioPan = [self addSegCtrlWithItems:@[@"左声道", @"立体声", @"右声道"]];
    _segAudioPan.selectedSegmentIndex = 1;
    
    [self layoutUI];
}

- (void)layoutUI{
    [super layoutUI];
    self.yPos = 0;
    
    [self putLable:_labelMute andView:_switchMute];
    [self putRow1:_sliderVolume];
    [self putLable:_labelAudioPan andView:_segAudioPan];
}

@synthesize audioPan = _audioPan;
- (MPMovieAudioPan) audioPan{
    MPMovieAudioPan pan = MPMovieAudioPan_Stereo;
    if(0 == _segAudioPan.selectedSegmentIndex)
        pan = MPMovieAudioPan_Left;
    else if(1 == _segAudioPan.selectedSegmentIndex)
        pan = MPMovieAudioPan_Stereo;
    else if(2 == _segAudioPan.selectedSegmentIndex)
        pan =  MPMovieAudioPan_Right;
    return pan;
}

@end
