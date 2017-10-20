//
//  KSYMvEffect.h
//
//  Created by gene on 16/8/17.
//  Copyright © 2016年 Cell Phone. All rights reserved.
//

#import <Foundation/Foundation.h>

/** KSYMvEffect MV特效类
 
 * 在原视频上添加上下、左右滑动、黑白等效果，用户可以根据自身需求自定义效果，以shader字符串的形式加载
 * 例如：video -->mvEffect -->mvFilter
 
 */
@interface KSYMvEffect : GPUImageFilter
/**
 设置MV特效生成的时间
 */
@property (nonatomic, assign) CGFloat timeInfo;

/**
 @abstract   初始化并导入effectShader
 @param      shader字符串 片源着色器
 @param      durTime MV特效持续时间
 */
- (instancetype)initWithEffectShader:(NSString *)effectShader durationTime:(CGFloat)durTime;

@end
