//
//  KSYMvEffect.h
//
//  Created by gene on 16/8/17.
//  Copyright © 2016年 Cell Phone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KSYGPUFilter.h"

/// 抖动类型
typedef NS_ENUM(NSInteger, KSYShakeType) {
    /// 放大抖动效果
    KSYShakeType_ZOOM = 0,
    /// 彩色抖动效果
    KSYShakeType_Color = 1,
    /// 冲击波效果
    KSYShakeType_ShockWave = 2,
    /// Black magic效果
    KSYShakeType_BlackMagic = 3,
    /// 闪电效果
    KSYShakeType_Lightning = 4,
    /// KTV效果
    KSYShakeType_Ktv = 5,
    /// 幻觉
    KSYShakeType_Illusion = 6,
    /// X-Signal
    KSYShakeType_Xsignal = 7,
    /// 70s
    KSYShakeType_70s = 8,
};

/** KSYShakeFilter 画面抖动效果
 
 * 类似抖音里放大抖动的效果
 
 */
@interface KSYShakeFilter : KSYGPUFilter

/**
 @abstract   创建抖动效果的滤镜
 @param      type 抖动效果的类型
 */
- (instancetype)initWithType:(KSYShakeType) type;

@end
