//
//  KSYFilterView.h
//  KSYGPUStreamerDemo
//
//  Created by 孙健 on 16/6/24.
//  Copyright © 2016年 ksyun. All rights reserved.
//

#import "KSYUIView.h"
@class KSYNameSlider;
@class GPUImageFilter;

@interface KSYFilterView : KSYUIView {
    UIButton  * _filterBtns[6];
}
@property KSYNameSlider * filterLevel;
// 通过按钮选择的滤镜
@property GPUImageFilter * curFilter;
@end
