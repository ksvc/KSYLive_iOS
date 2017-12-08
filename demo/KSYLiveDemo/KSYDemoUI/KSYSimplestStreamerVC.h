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
// 适配iphoneX用到的背景视图(在iphoneX上为了保持主播和观众的画面一致, 竖屏时需要上下填一点黑边, 不再全屏预览)
@property (nonatomic, readonly) UIView* bgView;

@property UIButton *captureBtn;//预览按钮
@property UIButton *streamBtn;//开始推流
@property UIButton *cameraBtn;//前后摄像头
@property UIButton *quitBtn;//返回按钮
@property NSURL    *url;

- (id)initWithUrl:(NSURL *)rtmpUrl;
// 重写此方法，调整UI布局
- (void)setupUI;
- (void)onBtn:(UIButton *)btn;
- (void)onQuit;
@end
