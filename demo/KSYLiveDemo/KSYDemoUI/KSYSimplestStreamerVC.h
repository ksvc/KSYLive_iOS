//
//  KSYSimplestStreamerVC.h
//  KSYLiveDemo
//
//  Created by 孙健 on 2017/2/7.
//  Copyright © 2017年 qyvideo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KSYUIVC.h"
#import "KSYUIView.h"
#import <libksygpulive/KSYGPUStreamerKit.h>

@interface KSYSimplestStreamerVC : KSYUIVC

@property KSYGPUStreamerKit *kit;
@property GPUImageOutput<GPUImageInput>* curFilter;
// profile picker
@property UIPickerView *profilePicker;
@property (nonatomic, readonly) KSYUIView   * ctrlView;

- (id)initWithUrl:(NSURL *)rtmpUrl;
// 重写此方法，调整UI布局
- (void)setupUI;
- (void)onBtn:(UIButton *)btn;
- (void)onQuit;
@end
