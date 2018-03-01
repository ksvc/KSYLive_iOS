//
//  KSYUIStreamerVC.h
//  KSYLiveUIDemo
//
//  Created by 王旭 on 2017/11/9.
//  Copyright © 2017年 王旭. All rights reserved.
//

#import "KSYUIBaseViewController.h"
#import <libksygpulive/KSYGPUStreamerKit.h>

typedef void(^buttonBlock)(UIButton *sender);

@interface KSYUIStreamerVC : KSYUIBaseViewController

@property (nonatomic,strong) KSYGPUStreamerKit *wxStreamerKit; //推流工具类
@property (nonatomic,strong) GPUImageOutput<GPUImageInput> *currentFilter; //当前美颜滤镜
@property (nonatomic,strong) KSYBuildInSpecialEffects *curEffectsFilter; //当前特效滤镜

@end
