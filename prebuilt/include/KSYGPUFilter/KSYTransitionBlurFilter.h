//
//  KSYTransitionBlurFilter
//  KSYGPUFilter
//
//  Created by pengbin
//  Copyright 2017 ksyun.com. All rights reserved.
//

#import <GPUImage/GPUImage.h>
#import "KSYGPUFilter.h"
#import "KSYTransitionFilter.h"

/** KSYTransitionBlurFilter 模糊的转场效果
 
 * 转场: 两段视频串联的时候, 前一段的结尾和后一段的开头叠加
 * 前模糊: 作用在前一段的结尾画面慢慢变模糊后, 切换为下一段视频
 * 后模糊: 作用在后一段的开头画面从模糊变清晰
 * 本滤镜只处理一段视频的输入
 */
@interface KSYTransitionBlurFilter : KSYGPUFilter<KSYTransition>

/// YES: 清晰变模糊  NO: 模糊变清晰 (默认YES)
@property (nonatomic, readwrite) BOOL bToBlur;

/// 转场重叠的帧数
@property (nonatomic, readwrite) int duration;

/// 转场已经处理的帧数
@property (nonatomic, readwrite) int frameIdx;

@end
