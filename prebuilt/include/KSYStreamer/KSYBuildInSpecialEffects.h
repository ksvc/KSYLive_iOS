//
//  KSYBuildInSpecialEffects.h
//  GPUImage
//
//  Created by gene on 16/9/19.
//  Copyright © 2016年 Brad Larson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AvailabilityMacros.h>
#import "KSYSpecialEffects.h"

/**
 @abstract 特效滤镜类型 SpecialEffects
 */
typedef NS_ENUM(NSInteger, KSYGPUEffectType) {
    /// 0 原图关闭特效
    KSYGPUEffectType_None = 0,
    /// 1 小清新
    KSYGPUEffectType_Freshy,
    /// 2 靓丽
    KSYGPUEffectType_Beauty,
    /// 3 甜美可人
    KSYGPUEffectType_Sweety,
    /// 4 怀旧
    KSYGPUEffectType_Sepia,
    /// 5 蓝调
    KSYGPUEffectType_Blue,
    /// 6 老照片
    KSYGPUEffectType_Nostalgia,
    /// 7 樱花
    KSYGPUEffectType_Sakura,
    /// 8 樱花（适用于光线较暗的环境）
    KSYGPUEffectType_Sakura_night,
    /// 9 红润（适用于光线较暗的环境）
    KSYGPUEffectType_Ruddy_night,
    /// 10 阳光（适用于光线较暗的环境）
    KSYGPUEffectType_Sunshine_night,
    /// 11 红润
    KSYGPUEffectType_Ruddy,
    /// 12 阳光
    KSYGPUEffectType_Sushine,
    /// 13 自然
    KSYGPUEffectType_Nature,
    /// 14 恋人
    KSYGPUEffectType_Amatorka,
    /// 15 高雅
    KSYGPUEffectType_Elegance,
    /// 16 红粉佳人 
    KSYGPUEffectType_1977,
    /// 17 优格 
    KSYGPUEffectType_Amaro,
    /// 18 流年 
    KSYGPUEffectType_Brannan,
    /// 19 柔光 
    KSYGPUEffectType_Early_bird,
    /// 20 经典 
    KSYGPUEffectType_Hefe,
    /// 21 初夏 
    KSYGPUEffectType_Hudson,
    /// 22 黑白 
    KSYGPUEffectType_Ink,
    /// 23 纽约 
    KSYGPUEffectType_Lomo,
    /// 24 上野 
    KSYGPUEffectType_Lord_kelvin,
    /// 25 碧波 
    KSYGPUEffectType_Nashville,
    /// 26 日系 
    KSYGPUEffectType_Rise,
    /// 27 清凉 
    KSYGPUEffectType_Sierra,
    /// 28 移轴 
    KSYGPUEffectType_Sutro,
    /// 29 梦幻 
    KSYGPUEffectType_Toaster,
    /// 30 恬淡 
    KSYGPUEffectType_Valencia,
    /// 31 候鸟 
    KSYGPUEffectType_Walden,
    /// 32 淡雅 
    KSYGPUEffectType_Xproll,

};


/** KSY 特效滤镜
 
 内置滤镜需要资源文件支持(参考KSYResource.bundle中的png)
 */
@interface KSYBuildInSpecialEffects : GPUImageFilterGroup

#pragma mark - internal special effects

/**
 @abstract   初始化为指定类型的特效滤镜
 @param      type 效果类型
 */
- (id)initWithType:(KSYGPUEffectType)type;

/**
 @abstract   当前特效的类型
 */
@property KSYGPUEffectType effectType;

/**
 @abstract   初始化为指定类型的特效滤镜
 @param      idx 效果的索引 (非法值无效)
 @warning
 */
- (id)initWithIdx:(NSInteger)idx;

/**
 @abstract   更新为指定类型的特效滤镜
 @param      idx 效果的索引 (非法值无效)
 */
-(void)setSpecialEffectsIdx:(NSInteger)idx;

/// 特效参数 (仅前15个滤镜有效)
@property(readwrite, nonatomic) CGFloat intensity;

@end
