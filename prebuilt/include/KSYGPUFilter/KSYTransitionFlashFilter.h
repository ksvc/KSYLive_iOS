//
//  KSYTransitionFlashFilter.h
//  KSYGPUFilter
//
//  Created by pengbin
//  Copyright 2017 ksyun.com. All rights reserved.
//

#import <GPUImage/GPUImage.h>
#import "KSYGPUFilter.h"
#import "KSYTransitionFilter.h"

/** KSYTransitionFlashFilter 闪黑/闪白的转场效果
 
 * 转场: 两段视频串联的时候, 前一段的结尾和后一段的开头叠加
 * 闪黑/闪白: 作用在前一段的结尾画面慢慢变黑或变白,全黑/全白后, 切换为下一段视频
 * 本滤镜只处理一段视频的输入
 * 闪的颜色通过 以下下方法设置, 默认为黑色
 * [f setBackgroundColorRed:1.0 green:1.0 blue:1.0 alpha:0.0];  // 白色
 * [f setBackgroundColorRed:0.0 green:0.0 blue:0.0 alpha:0.0];  // 黑色
 */
@interface KSYTransitionFlashFilter : KSYGPUFilter<KSYTransition>

/// 转场重叠的帧数
@property (nonatomic, readwrite) int duration;

/// 转场已经处理的帧数
@property (nonatomic, readwrite) int frameIdx;

@end
