//
//  KSYPlayerAudioView.h
//  KSYGPUStreamerDemo
//
//  Created by 施雪梅 on 17/7/12.
//  Copyright © 2016年 ksyun. All rights reserved.
//

/**
 声音相关控制
 */
#import "KSYUIView.h"
#import "KSYNameSlider.h"
#import <libksygpulive/KSYMoviePlayerController.h>

@interface KSYPlayerAudioView: KSYUIView

@property UISwitch *switchMute;                                           ///静音

@property KSYNameSlider *sliderVolume;                            ///音量

@property UISegmentedControl  *segAudioPan;                    ///左右声道

@property (atomic, readonly) MPMovieAudioPan audioPan; 

@end
