//
//  KSYLandScapeKitVC.h
//  KSYLiveUIDemo
//
//  Created by 王旭 on 2017/11/29.
//  Copyright © 2017年 王旭. All rights reserved.
//

#import "KSYUIBaseViewController.h"
#import <libksygpulive/KSYGPUStreamerKit.h>

//主要增加一些工具函数
#define SYSTEM_VERSION_GE_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

typedef void(^buttonBlock)(UIButton *sender);

@interface KSYLandScapeKitVC : KSYUIBaseViewController

@property (nonatomic,strong) KSYGPUStreamerKit *wxStreamerKit; //推流工具类
@property (nonatomic,strong) GPUImageOutput<GPUImageInput> *currentFilter; //当前滤镜
@property (nonatomic,strong) KSYBuildInSpecialEffects *curEffectsFilter; //当前特效滤镜

@end



