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

@interface KSYFilterView : KSYUIView

// 参数调节
@property (nonatomic, readonly) KSYNameSlider * filterLevel;

// 选择滤镜
@property (nonatomic, readonly) GPUImageOutput<GPUImageInput>* curFilter;
// 滤镜组合
@property (nonatomic, readonly) UISegmentedControl  * filterGroupType;

@end
