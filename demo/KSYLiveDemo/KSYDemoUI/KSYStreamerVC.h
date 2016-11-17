//
//  KSYStreamerVC.h
//  KSYStreamerVC
//
//  Created by yiqian on 10/15/15.
//  Copyright (c) 2015 qyvideo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GPUImage/GPUImage.h>
#import "KSYUIView.h"
#import "KSYUIVC.h"
#import "KSYPresetCfgView.h"
#import "KSYCtrlView.h"
#import "KSYStreamerVC.h"
#import "KSYFilterView.h"
#import "KSYBgmView.h"
#import "KSYPipView.h"
#import "KSYAudioCtrlView.h"
#import "KSYMiscView.h"
#import "KSYStateLableView.h"

#if USING_DYNAMIC_FRAMEWORK
#import <libksygpuliveDy/KSYGPUStreamerKit.h>
#else
#import <libksygpulive/KSYGPUStreamerKit.h>
#endif

/**
 KSY 推流SDK的主要演示视图
 
 主要演示了SDK 提供的API的基本使用方法
 */
@interface KSYStreamerVC : KSYUIVC

// 切到当前VC后， 界面自动开启推流   /// forTest ///
@property BOOL  bAutoStart;     /// forTest ///

//初始化函数, 通过传入的presetCfgView来配置默认参数

/**
 @abstract   构造函数
 @param      presetCfgView    含有用户配置的启动参数的视图 (前一个页面)
 @discussion presetCfgView 为nil时, 使用默认参数
 */
- (id) initWithCfg:(KSYPresetCfgView*)presetCfgView;
// presetCfgs
@property (nonatomic, readonly) KSYPresetCfgView * presetCfgView;

#pragma mark - sub views
/// 摄像头的基本控制视图
@property (nonatomic, readonly) KSYCtrlView   * ctrlView;
@property (nonatomic, readwrite) NSArray       * menuNames;
/// 背景音乐配置页面
@property (nonatomic, readonly) KSYBgmView    * ksyBgmView;
/// 视频滤镜相关参数配置页面
@property (nonatomic, readonly) KSYFilterView * ksyFilterView;
/// 声音配置页面
@property (nonatomic, readonly) KSYAudioCtrlView * audioView;
/// 其他功能配置页面
@property (nonatomic, readonly) KSYMiscView   *miscView;

#pragma mark - kit instance
@property (nonatomic, retain) KSYGPUStreamerKit * kit;

// 推流地址 完整的URL
@property NSURL * hostURL;

// 采集的参数设置
- (void) setCaptureCfg;
// 推流的参数设置
- (void) setStreamerCfg;

- (void) initObservers;
- (void) addObservers;
- (void) rmObservers;

- (void) addSubViews;
- (void) onMenuBtnPress:(UIButton *)btn;
@end
