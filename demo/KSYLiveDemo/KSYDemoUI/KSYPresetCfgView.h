//
//  KSYPresetCfgView.h
//  KSYStreamerVC
//
//  Created by yiqian on 10/15/15.
//  Copyright (c) 2015 qyvideo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KSYUIView.h"

#import <GPUImage/GPUImage.h>

#if USING_DYNAMIC_FRAMEWORK
#import <libksygpuliveDy/libksygpuimage.h>
#else
#import <libksygpulive/libksygpuimage.h>
#endif

/**
 KSY 预设参数配置视图
 
 主要是在开始采集和推流之前可以配置的一些参数
 */
@interface KSYPresetCfgView : KSYUIView

// UI elements
@property UIButton* btn0;
@property UIButton* btn2;
@property UIButton* btn3;
@property UIButton* btn4;

// preset settings
// capture
@property UITextField        * hostUrlUI;   // host URL
@property UILabel            *lblResolutionUI;
@property UISegmentedControl *resolutionUI; // 采集分辨率
@property UILabel            *lblStreamResoUI;
@property UISegmentedControl *streamResoUI; // 推流分辨率
@property UILabel            *lblCameraPosUI;
@property UISegmentedControl *cameraPosUI;  //

@property KSYNameSlider* frameRateUI;

// stream
@property UILabel            *lblVideoCodecUI;
@property UISegmentedControl *videoCodecUI; //
@property UILabel            *lblAudioCodecUI; //
@property UISegmentedControl *audioCodecUI; //
@property KSYNameSlider      *videoKbpsUI;
@property UILabel            *lblAudioKbpsUI; //
@property UISegmentedControl *audioKbpsUI; //
@property UILabel            *lblGpuPixFmtUI; //
@property UISegmentedControl *gpuPixFmtUI; //

// bandwith adapter
@property UILabel               *lblBwEstMode;    //
@property UISegmentedControl    *bwEstModeUI;   //

// get config data
- (NSString*) hostUrl;
- (NSString*) capResolution;
- (CGSize) strResolutionSize;
- (CGSize) capResolutionSize;
- (AVCaptureDevicePosition) cameraPos;
- (int) frameRate;
- (KSYVideoCodec) videoCodec;
- (KSYAudioCodec) audioCodec;
- (int) videoKbps;
- (int) audioKbps;
- (KSYBWEstimateMode) bwEstMode;

- (OSType) gpuOutputPixelFmt;
@end

