//
//  KSYPlayerPicView.h
//  KSYGPUStreamerDemo
//
//  Created by 施雪梅 on 17/7/12.
//  Copyright © 2016年 ksyun. All rights reserved.
//

/**
 图像相关控制
 */
#import "KSYUIView.h"
#import <libksygpulive/KSYMoviePlayerController.h>

@interface KSYPlayerPicView: KSYUIView

@property (nonatomic)UISegmentedControl *segContentMode;             //画面填充模式

@property (nonatomic)UISegmentedControl *segRotate;                         //旋转

@property (nonatomic)UISegmentedControl *segMirror;                         //镜像

@property (nonatomic)UIButton *btnShotScreen;

@property (atomic, readwrite) MPMovieScalingMode contentMode;

@property (atomic, readonly) int rotateDegress;

@property (atomic, readonly) BOOL bMirror;

@end
