//
//  KSYGPUViewCapture.h
//  KSYStreamer
//
//  Created by yiqian on 1/30/16.
//  Copyright © 2016 yiqian. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <GPUImage/GPUImage.h>

/** GPU UIView视图 采集模块
 
 * 采集UIView视图的内容到GPU
 * 内部使用 CADisplayLink 作为timer 驱动画面更新
 * 可通过属性设置更新频率
 */
@interface KSYGPUViewCapture : GPUImageOutput

/**
 设置需要采集的视图

 @param inputView 被采集的视图
 @return 采集实例
 */
- (id)initWithView:(UIView *)inputView;

/**
 设置需要采集的视图图层

 @param inputLayer 被采集的图层
 @return 采集实例
 */
- (id)initWithLayer:(CALayer *)inputLayer;

// Layer management
- (CGSize)layerSizeInPixels;

/** 更新画面内容 使用无效时间戳 */
- (void)update;
/** 更新画面内容 使用当前时间戳 */
- (void)updateUsingCurrentTime;

/**
 更新画面内容

 @param frameTime 时间戳
 */
- (void)updateWithTimestamp:(CMTime)frameTime;

/// UI刷新的频率 默认值为15 (有效值fps=60/N, 比如60, 30, 20, 15, 10等)
@property int updateFps;

/** 启动采集 */
- (void) start;

/** 停止采集 */
- (void) stop;

/** 暂停 / 继续 */
@property BOOL paused;

@end
