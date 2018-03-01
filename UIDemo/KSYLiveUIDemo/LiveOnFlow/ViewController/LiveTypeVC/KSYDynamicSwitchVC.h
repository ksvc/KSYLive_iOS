//
//  KSYDynamicSwitchVC.h
//  KSYLiveUIDemo
//
//  Created by 王旭 on 2017/12/20.
//  Copyright © 2017年 王旭. All rights reserved.
//

#import "KSYUIBaseViewController.h"
#import <libksygpulive/KSYGPUStreamerKit.h>

//主要增加一些工具函数
#define SYSTEM_VERSION_GE_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
typedef NS_ENUM(NSInteger,ScreenDirection) {
    ScreenDirectionLandScape = 0,
    ScreenDirectionPortrait = 1
};

typedef void(^buttonBlock)(UIButton *sender);

@interface KSYDynamicSwitchVC : KSYUIBaseViewController

/// 预览视图父控件（用于处理转屏，保持画面相对手机静止）
@property (nonatomic, strong) UITraitCollection *curCollection;
//推流工具类
@property (nonatomic,strong) KSYGPUStreamerKit *wxStreamerKit;
//当前滤镜
@property (nonatomic,strong) GPUImageOutput<GPUImageInput> *currentFilter;
//当前特效滤镜
@property (nonatomic,strong) KSYBuildInSpecialEffects *curEffectsFilter;
//布局
-(void)layoutUI;

@end
