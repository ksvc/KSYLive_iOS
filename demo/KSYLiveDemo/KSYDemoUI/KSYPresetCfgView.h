//
//  KSYPresetCfgView.h
//  KSYStreamerVC
//
//  Created by yiqian on 10/15/15.
//  Copyright (c) 2015 qyvideo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <libksygpulive/KSYGPUStreamerKit.h>
// 找不到这个头文件的话, 可能你没执行pod install
// 参见 : https://github.com/ksvc/KSYLive_iOS 的 3.2.3 使用Cocoapods 进行安装
// http://cocoadocs.org/docsets/libksygpulive/2.0.2/

#import "KSYUIView.h"
/**
 KSY 预设参数配置视图
 
 主要是在开始采集和推流之前可以配置的一些参数
 */
@interface KSYPresetCfgView : KSYUIView<
            UIPickerViewDataSource,
            UIPickerViewDelegate >

// UI elements
@property UIButton* btn0;
@property UIButton* btn1;
@property UIButton* btn2;
@property UIButton* btn3;
@property UIButton* btn4;
@property UIButton* btn5;

// preset settings
// capture
@property UITextField        * hostUrlUI;   // host URL
@property UILabel            *lblResolutionUI;
@property UISegmentedControl *resolutionUI; // 采集分辨率
@property UILabel            *lblStreamResoUI;
@property UISegmentedControl *streamResoUI; // 推流分辨率
@property UILabel            *lblCameraPosUI;
@property UISegmentedControl *cameraPosUI;  //

@property UILabel            *lblProfileUI;
@property UISegmentedControl *profileUI;//预设等级 and 自定义

@property (nonatomic, readonly) UIPickerView  * profilePicker;

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

//message
@property UILabel                               *lblWithMessage;
@property UISegmentedControl           *withMessageUI;

// get config data
- (NSString*) hostUrl;
@property(nonatomic, assign) NSString *capResolution;
@property(nonatomic, assign) CGSize capResolutionSize;
@property(nonatomic, assign) CGSize strResolutionSize;
@property(nonatomic, assign) int frameRate;
@property(nonatomic, assign) AVCaptureDevicePosition cameraPos;
@property(nonatomic, assign) OSType gpuOutputPixelFmt;
@property(nonatomic, assign) KSYVideoCodec videoCodec;
@property(nonatomic, assign) int videoKbps;
@property(nonatomic, assign) KSYAudioCodec audioCodec;
@property(nonatomic, assign) int audioKbps;
@property(nonatomic, assign) KSYBWEstimateMode bwEstMode;

//当前profile id
@property NSInteger curProfileIdx;

//message
@property(nonatomic, assign) BOOL withMessage;

@end

