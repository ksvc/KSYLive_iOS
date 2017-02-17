//
//  KSYBgmStreamerVC.h
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
#import "KSYFilterView.h"
#import "KSYBgmView.h"
#import "KSYAudioCtrlView.h"
#import "KSYMiscView.h"
#import "KSYStateLableView.h"
#import "KSYStreamerVC.h"

#import <libksygpulive/KSYGPUBgmStreamerKit.h>

/**
 KSY 推流SDK的主要演示视图
 
 主要演示了SDK 提供的API的基本使用方法
 */
@interface KSYBgmStreamerVC : KSYStreamerVC
/**
 @abstract   构造函数
 @param      presetCfgView    含有用户配置的启动参数的视图 (前一个页面)
 @discussion presetCfgView 为nil时, 使用默认参数
 */
- (id) initWithCfg:(KSYPresetCfgView*)presetCfgView;

/**
 @abstract   当背景音乐播放完成时，调用此回调函数
 @discussion 在开始播放前设置有效
 */
@property(nonatomic, copy) void(^bgmFinishBlock)(void);

#pragma mark - kit instance
@property (nonatomic, retain) KSYGPUBgmStreamerKit * bgmKit;

- (void) addSubViews;
@end
