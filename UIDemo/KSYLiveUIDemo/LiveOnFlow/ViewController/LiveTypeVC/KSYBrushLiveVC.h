//
//  KSYBrushLiveVC.h
//  KSYLiveUIDemo
//
//  Created by 王旭 on 2017/11/19.
//  Copyright © 2017年 王旭. All rights reserved.
//

#import "KSYUIBaseViewController.h"
#import <libksygpulive/KSYGPUBrushStreamerKit.h>

typedef void(^buttonBlock)(UIButton *sender);

@interface KSYBrushLiveVC : KSYUIBaseViewController

@property(nonatomic,strong)KSYGPUBrushStreamerKit *wxStreamerKit; //推流工具类
@property (nonatomic,strong) GPUImageOutput<GPUImageInput> *currentFilter; //当前美颜滤镜
@property (nonatomic,strong) KSYBuildInSpecialEffects *curEffectsFilter; //当前特效滤镜

@end
