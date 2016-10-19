//
//  KSYFilterView.h
//  KSYGPUStreamerDemo
//
//  Created by 孙健 on 16/6/24.
//  Copyright © 2016年 ksyun. All rights reserved.
//

#import "KSYUIView.h"


@class GPUImageFilter;
@class GPUImageFilterGroup;
@class GPUImageOutput;
@protocol GPUImageInput;

@interface KSYFilterView : KSYUIView <
                UIPickerViewDataSource,
                UIPickerViewDelegate >

// 参数调节
@property (nonatomic, readonly) KSYNameSlider * filterParam1; // 参数1
@property (nonatomic, readonly) KSYNameSlider * filterParam2; // 参数2
@property (nonatomic, readonly) KSYNameSlider * filterParam3; // 参数3

// 选择滤镜
@property (nonatomic, readonly) GPUImageOutput<GPUImageInput>* curFilter;
// 滤镜组合
@property (nonatomic, readonly) UISegmentedControl  * filterGroupType;
// 特效滤镜
@property (nonatomic, readonly) UIPickerView  * effectPicker;

// 镜像翻转按钮
@property (nonatomic) UISwitch * swPrevewFlip;
@property (nonatomic) UISwitch * swStreamFlip;

// 界面旋转 和推流画面动态旋转
@property (nonatomic) UISwitch * swUiRotate; // 只在iphone上能锁定
@property (nonatomic) UISwitch * swStrRotate;

@end
