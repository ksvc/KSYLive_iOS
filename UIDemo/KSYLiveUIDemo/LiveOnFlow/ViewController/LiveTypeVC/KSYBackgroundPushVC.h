//
//  KSYBackgroundPushVC.h
//  KSYLiveUIDemo
//
//  Created by 王旭 on 2017/11/17.
//  Copyright © 2017年 王旭. All rights reserved.
//

#import "KSYUIBaseViewController.h"
#import <libksygpulive/KSYGPUStreamerKit+bgp.h>

typedef void(^buttonBlock)(UIButton *sender);

@interface KSYBackgroundPushVC : KSYUIBaseViewController

@property (nonatomic,strong) KSYGPUStreamerKit *wxStreamerKit; //推流工具类
@property (nonatomic,strong) GPUImageOutput<GPUImageInput> *currentFilter; //当前滤镜

@end
