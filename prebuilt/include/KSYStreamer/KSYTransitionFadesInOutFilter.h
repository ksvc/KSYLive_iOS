//
//  KSYTransitionFadesInOutFilter.h
//  KSYGPUFilter
//
//  Created by pengbin
//  Copyright 2017 ksyun.com. All rights reserved.
//


#import <GPUImage/GPUImage.h>
#import "KSYGPUTwoInputFiter.h"
#import "KSYTransitionFilter.h"

/** KSYTransitionFadesInOutFilter 渐入淡出的转场效果
 
 * 转场: 两段视频串联的时候, 前一段的结尾和后一段的开头叠加
 * 渐入淡出: 前一段的画面慢慢变淡, 后一段的视频慢慢变清晰
 
 */
@interface KSYTransitionFadesInOutFilter : KSYGPUTwoInputFiter<KSYTransition>

/// 视频所在的图层
@property (nonatomic, readwrite) NSInteger masterLayer;

/// NO: 第一段视频淡入，第二段视频淡出 YES: 第一段视频淡出，第二段视频淡入 (默认为NO)
@property (nonatomic, readwrite) BOOL bReverse;
/// 转场重叠的帧数
@property (nonatomic, readwrite) int duration;

/// 转场已经处理的帧数
@property (nonatomic, readwrite) int frameIdx;

@end
