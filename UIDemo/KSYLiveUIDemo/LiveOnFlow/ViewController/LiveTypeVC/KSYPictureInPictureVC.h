//
//  KSYPictureInPictureVC.h
//  KSYLiveUIDemo
//
//  Created by 王旭 on 2017/11/19.
//  Copyright © 2017年 王旭. All rights reserved.
//

#import "KSYUIBaseViewController.h"
#import <libksygpulive/KSYGPUPipStreamerKit.h>

typedef void(^buttonBlock)(UIButton *sender);

@interface KSYPictureInPictureVC : KSYUIBaseViewController

@property (nonatomic,strong) KSYGPUPipStreamerKit *wxStreamerKit; //推流工具类
@property (nonatomic,strong) GPUImageOutput<GPUImageInput> *currentFilter; //当前美颜滤镜
@property (nonatomic,strong) KSYBuildInSpecialEffects *curEffectsFilter; //当前特效滤镜
// 在addObservers 中会注册此timer, 每秒重复调用onTimer
@property (nonatomic,weak) NSTimer *timer;

// 定时更新调试信息、每秒重复调用
- (void)onTimer:(NSTimer *)theTimer;

@end
