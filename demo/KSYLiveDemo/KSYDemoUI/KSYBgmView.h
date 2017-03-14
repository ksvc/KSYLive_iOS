//
//  KSYAudioView.h
//  KSYGPUStreamerDemo
//
//  Created by 孙健 on 16/6/24.
//  Copyright © 2016年 ksyun. All rights reserved.
//


#import "../KSYUIUtils/KSYUIView.h"
#import "../KSYPlayerDemo/KSYProgressView.h"
@class KSYNameSlider;

@interface KSYBgmView : KSYUIView
@property UIButton * previousBtn;
@property UIButton * playBtn;
@property UIButton * pauseBtn;
@property UIButton * stopBtn;
@property KSYProgressView *progressBar;
@property KSYNameSlider * volumSl;
@property UIButton * nextBtn;
@property UIButton * muteBtn;
@property UISegmentedControl * loopType;
@property KSYNameSlider * pitchSl;
@property UIStepper * pitchStep;


/// 当前播放的背景音乐的路径
@property (nonatomic, readonly) NSString* bgmPath;
/// bgmStatus string
@property (nonatomic) NSString* bgmStatus;
/// match pattern(音乐文件的后缀)
@property (nonatomic, readonly) NSArray* bgmPattern;

/// get next bgm path to play
- (NSString*) nextBgmPath;
- (NSString*) previousBgmPath;

/// get next bgm path to play
- (NSString*) loopNextBgmPath;
@end
