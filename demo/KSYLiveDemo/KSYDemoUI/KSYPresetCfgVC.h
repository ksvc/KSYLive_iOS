//
//  KSYPresetCfgVC.h
//  KSYStreamerVC
//
//  Created by yiqian on 10/15/15.
//  Copyright (c) 2015 qyvideo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KSYUIVC.h"

#import <GPUImage/GPUImage.h>

#if USING_DYNAMIC_FRAMEWORK
#import <libksygpuliveDy/libksygpuimage.h>
#else
#import <libksygpulive/libksygpuimage.h>
#endif

/**
 KSY 预设参数配置视图控制器
 
 demo的入口
 */
@interface KSYPresetCfgVC : KSYUIVC
// 初始化
- (instancetype)initWithURL:(NSString *)url;
// 初始传入的 rtmpserver 地址
@property NSString * rtmpURL;

@end

